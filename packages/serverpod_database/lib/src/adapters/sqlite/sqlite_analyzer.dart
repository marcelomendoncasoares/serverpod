import 'dart:async';

import 'package:serverpod/protocol.dart';
import 'package:serverpod/src/database/concepts/database_result.dart';
import 'package:serverpod/src/database/database.dart';

import '../../../serverpod/lib/src/server/serverpod.dart';
import '../../../serverpod/lib/src/database/interface/analyzer.dart';
import 'package:serverpod/src/database/interface/analyzer.dart';

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
    var result = await database.unsafeQuery('''
      SELECT name
      FROM sqlite_master
      WHERE (type = 'table')
        AND (name NOT LIKE 'sqlite_%')
        AND (name != 'serverpod_sqlite_schema');
    ''');

    return result.map((row) async {
      var tableName = row[0] as String;

      return TableDefinition(
        name: tableName,
        schema: _defaultSchema,
        columns: await getColumnDefinitions(
          schemaName: _defaultSchema,
          tableName: tableName,
        ),
        foreignKeys: await getForeignKeyDefinitions(
          schemaName: _defaultSchema,
          tableName: tableName,
        ),
        indexes: await getIndexDefinitions(
          schemaName: _defaultSchema,
          tableName: tableName,
        ),
      );
    }).wait;
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

    final columnTypes = {
      for (var row in await database.unsafeQuery('''
        SELECT "column_name",
               "column_type",
               -- "column_default",
               "column_vector_dimension"
        FROM serverpod_sqlite_schema
        WHERE (table_name = $quotedTable);'''))
        row[0] as String: _ColumnInfo(
          type: ColumnType.values.byName(row[1] as String),
          // defaultValue: row[2] as String?,
          vectorDimension: row[2] as int?,
        ),
    };

    return queryResult.map((row) {
      var columnName = row[1] as String;
      var columnType = columnTypes[columnName]?.type ?? ColumnType.unknown;

      var isNullable = (row[3] as int?) != 1;
      var defaultValue = row[4] as String?;

      if (columnName == 'id' &&
          (columnType == ColumnType.integer ||
              columnType == ColumnType.bigint)) {
        // Modules will have their definition generated for Postgres, with
        // default values that differ from the SQLite default value. In these
        // cases, we use the default value from the module that was stored in
        // the schema table while applying the migration.
        defaultValue = columnTypes[columnName]?.defaultValue ?? 'AUTOINCREMENT';
        isNullable = false;
      }

      return ColumnDefinition(
        name: columnName,
        columnDefault: defaultValue,
        columnType: columnType,
        isNullable: isNullable,
        // Vector is not supported and stored as plain text in SQLite, so we
        // just return the target to avoid migration issues.
        vectorDimension: columnTypes[columnName]?.vectorDimension,
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
      var indexInfoResult = await database.unsafeQuery(
        'PRAGMA index_info(${_quoteIdentifier(indexName)})',
      );

      indexes.add(
        IndexDefinition(
          indexName: indexName,
          tableSpace: null,
          elements: [
            for (var infoRow in indexInfoResult)
              IndexElementDefinition(
                type: IndexElementDefinitionType.column,
                definition: infoRow[2] as String? ?? '',
              ),
          ],
          type: 'btree',
          isUnique: (indexRow[2] as int?) == 1,
          isPrimary: indexRow[3] == 'pk',
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

class _ColumnInfo {
  final ColumnType type;
  // final String? defaultValue;
  final int? vectorDimension;

  _ColumnInfo({
    required this.type,
    // required this.defaultValue,
    required this.vectorDimension,
  });
}
