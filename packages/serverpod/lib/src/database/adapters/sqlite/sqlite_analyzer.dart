import 'package:serverpod/protocol.dart';
import 'package:serverpod/src/database/concepts/database_result.dart';
import 'package:serverpod/src/database/database.dart';

import '../../../util/column_type_extension.dart';
import '../../concepts/analyzer.dart';

/// Analyzes the structure of SQLite [Database]s.
class SqliteDatabaseAnalyzer extends DatabaseAnalyzer {
  /// Creates a new [SqliteDatabaseAnalyzer] for the given [database].
  SqliteDatabaseAnalyzer({required super.database});

  /// SQLite uses a single default schema.
  static const String _defaultSchema = 'main';

  @override
  Future<String> getCurrentDatabaseName() async {
    var result = await database.unsafeQuery('PRAGMA database_list');
    if (result.isEmpty) return _defaultSchema;
    return result.first[1] as String;
  }

  @override
  Future<List<TableDefinition>> getTableDefinitions() async {
    var result = await database.unsafeQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'",
    );

    return Future.wait(
      result.map((row) async {
        var tableName = row[0] as String;
        var columns = getColumnDefinitions(
          schemaName: _defaultSchema,
          tableName: tableName,
        );
        var foreignKeys = getForeignKeyDefinitions(
          schemaName: _defaultSchema,
          tableName: tableName,
        );
        var indexes = getIndexDefinitions(
          schemaName: _defaultSchema,
          tableName: tableName,
        );

        return TableDefinition(
          name: tableName,
          schema: _defaultSchema,
          columns: await columns,
          foreignKeys: await foreignKeys,
          indexes: await indexes,
        );
      }),
    );
  }

  @override
  Future<List<ColumnDefinition>> getColumnDefinitions({
    required String schemaName,
    required String tableName,
  }) async {
    var quotedTable = _quoteIdentifier(tableName);
    var queryResult = await database.unsafeQuery(
      'PRAGMA table_info($quotedTable)',
    );

    return queryResult.map((row) {
      var rawType = row[2] as String? ?? '';
      var columnType = _sqliteTypeToColumnType(rawType);
      return ColumnDefinition(
        name: row[1] as String,
        columnDefault: row[4] as String?,
        columnType: columnType,
        isNullable: (row[3] as int?) != 1,
        vectorDimension: null,
      );
    }).toList();
  }

  @override
  Future<List<IndexDefinition>> getIndexDefinitions({
    required String schemaName,
    required String tableName,
  }) async {
    var quotedTable = _quoteIdentifier(tableName);
    var indexListResult = await database.unsafeQuery(
      'PRAGMA index_list($quotedTable)',
    );

    var indexes = <IndexDefinition>[];
    for (var indexRow in indexListResult) {
      var indexName = indexRow[1] as String;
      var isUnique = (indexRow[2] as int?) == 1;
      var origin = indexRow[3] as String? ?? '';
      var isPrimary = origin == 'pk';

      var quotedIndex = _quoteIdentifier(indexName);
      var indexInfoResult = await database.unsafeQuery(
        'PRAGMA index_info($quotedIndex)',
      );

      var elements = indexInfoResult.map((infoRow) {
        var columnName = infoRow[2] as String?;
        return IndexElementDefinition(
          type: IndexElementDefinitionType.column,
          definition: columnName ?? '',
        );
      }).toList();

      indexes.add(
        IndexDefinition(
          indexName: indexName,
          tableSpace: null,
          elements: elements,
          type: 'btree',
          isUnique: isUnique,
          isPrimary: isPrimary,
          predicate: null,
          vectorDistanceFunction: null,
          vectorColumnType: null,
          parameters: null,
        ),
      );
    }

    return indexes;
  }

  @override
  Future<List<ForeignKeyDefinition>> getForeignKeyDefinitions({
    required String schemaName,
    required String tableName,
  }) async {
    var quotedTable = _quoteIdentifier(tableName);
    var queryResult = await database.unsafeQuery(
      'PRAGMA foreign_key_list($quotedTable)',
    );

    // Group rows by id (same foreign key can have multiple columns)
    var fkById = <int, List<DatabaseResultRow>>{};
    for (var row in queryResult) {
      var id = row[0] as int;
      fkById.putIfAbsent(id, () => []).add(row);
    }

    final maxId = fkById.isNotEmpty
        ? fkById.keys.reduce((a, b) => a > b ? a : b)
        : 0;

    return fkById.entries.map((entry) {
      var rows = entry.value
        ..sort((a, b) => (a[1] as int).compareTo(b[1] as int));
      var first = rows.first;
      // Constraints seem to appear in reverse order of creation, so we need to
      // subtract the id from the max id to get the correct index.
      var constraintName = '${tableName}_fk_${maxId - entry.key}';
      var columns = rows.map((r) => r[3] as String).toList();
      var referenceTable = first[2] as String;
      var referenceColumns = rows.map((r) => r[4] as String).toList();
      var onUpdate = _parseForeignKeyAction(first[5] as String?);
      var onDelete = _parseForeignKeyAction(first[6] as String?);
      var matchType = _parseForeignKeyMatchType(first[7] as String?);

      return ForeignKeyDefinition(
        constraintName: constraintName,
        columns: columns,
        referenceTable: referenceTable,
        referenceTableSchema: _defaultSchema,
        referenceColumns: referenceColumns,
        onUpdate: onUpdate,
        onDelete: onDelete,
        matchType: matchType,
      );
    }).toList();
  }

  ColumnType _sqliteTypeToColumnType(String rawType) {
    switch (rawType.toUpperCase().split('(').first.trim()) {
      case 'REAL':
        return ColumnType.doublePrecision;
      case 'BLOB':
        return ColumnType.bytea;
      default:
        return ExtendedColumnType.fromSqlType(rawType);
    }
  }

  ForeignKeyAction? _parseForeignKeyAction(String? value) {
    if (value == null || value.isEmpty) return null;
    switch (value.toUpperCase()) {
      case 'SET NULL':
        return ForeignKeyAction.setNull;
      case 'SET DEFAULT':
        return ForeignKeyAction.setDefault;
      case 'RESTRICT':
        return ForeignKeyAction.restrict;
      case 'NO ACTION':
        return ForeignKeyAction.noAction;
      case 'CASCADE':
        return ForeignKeyAction.cascade;
      default:
        return null;
    }
  }

  ForeignKeyMatchType? _parseForeignKeyMatchType(String? value) {
    if (value == null || value.isEmpty) return ForeignKeyMatchType.simple;
    switch (value.toUpperCase()) {
      case 'FULL':
        return ForeignKeyMatchType.full;
      case 'PARTIAL':
        return ForeignKeyMatchType.partial;
      case 'SIMPLE':
      case 'NONE':
      default:
        return ForeignKeyMatchType.simple;
    }
  }

  String _quoteIdentifier(String identifier) {
    return '"${identifier.replaceAll('"', '""')}"';
  }
}
