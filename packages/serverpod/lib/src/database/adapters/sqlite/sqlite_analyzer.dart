import 'package:serverpod/protocol.dart';
import 'package:serverpod/src/database/concepts/database_result.dart';
import 'package:serverpod/src/database/database.dart';

import '../../../server/serverpod.dart';
import '../../interface/analyzer.dart';

/// Analyzes the structure of SQLite [Database]s.
class SqliteDatabaseAnalyzer extends DatabaseAnalyzer {
  /// Creates a new [SqliteDatabaseAnalyzer] for the given [database].
  SqliteDatabaseAnalyzer({required super.database});

  /// Since the types are so simple in SQLite, we need to previously check the
  /// target to adapt the types and ensure no real changes would be needed on
  /// the underlying database columns.
  static final _targetCache = Serverpod.instance.serializationManager
      .getTargetTableDefinitions();

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

    final targetTable = _targetCache
        .where((t) => t.name.toLowerCase() == tableName.toLowerCase())
        .firstOrNull;

    return queryResult.map((row) {
      var columnName = row[1] as String;
      var rawType = row[2] as String? ?? '';

      var targetColumn = targetTable?.columns
          .where((c) => c.name.toLowerCase() == columnName.toLowerCase())
          .firstOrNull;

      var columnType = targetColumn == null
          ? ColumnType.unknown
          : _sqliteTypeToColumnType(rawType, targetColumn);

      var isNullable = (row[3] as int?) != 1;
      var defaultValue = row[4] as String?;
      var targetDefaultValue = targetColumn?.columnDefault;
      if (targetDefaultValue != null && targetDefaultValue != defaultValue) {
        switch (columnType) {
          case ColumnType.bigint:
          case ColumnType.integer:
            if (columnName == 'id' &&
                    defaultValue == null &&
                    (targetDefaultValue.startsWith('nextval(')) ||
                targetDefaultValue == 'AUTOINCREMENT') {
              isNullable = false;
              defaultValue = targetDefaultValue;
            }
          case ColumnType.boolean:
            defaultValue = defaultValue == '1' ? 'true' : 'false';
          case ColumnType.uuid:
            defaultValue =
                {
                  _generateRandomUuid: 'gen_random_uuid()',
                  _generateRandomUuidV7: 'gen_random_uuid_v7()',
                }[defaultValue] ??
                defaultValue;
          default:
        }
      }

      return ColumnDefinition(
        name: columnName,
        columnDefault: defaultValue,
        columnType: columnType,
        isNullable: isNullable,
        // Vector is not supported and stored as plain text in SQLite, so we
        // just return the target to avoid migration issues.
        vectorDimension: targetColumn?.vectorDimension,
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

  ColumnType _sqliteTypeToColumnType(String rawType, ColumnDefinition target) {
    final convertedTarget = target.toSqliteSqlType().toLowerCase();
    if (rawType.toLowerCase() == convertedTarget) {
      return target.columnType;
    }
    for (var entry in ColumnType.values) {
      if (rawType.toLowerCase() == entry.name.toLowerCase()) {
        return entry;
      }
    }
    return ColumnType.unknown;
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

/// Extensions on the [ColumnDefinition] class.
extension SQLiteColumnDefinitionSqlGeneration on ColumnDefinition {
  /// Returns the SQL type for the column definition.
  String toSqliteSqlType() {
    String type;
    switch (columnType) {
      case ColumnType.bigint:
      case ColumnType.integer:
      case ColumnType.timestampWithoutTimeZone:
      case ColumnType.boolean: // SQLite uses INTEGER (0/1) for booleans
        type = 'INTEGER';
        break;
      case ColumnType.doublePrecision:
        type = 'REAL';
        break;
      case ColumnType.bytea:
        type = 'BLOB';
        break;
      case ColumnType.text:
      case ColumnType.json:
      case ColumnType.uuid: // SQLite usually stores UUIDs as TEXT
      case ColumnType.vector:
      case ColumnType.halfvec:
      case ColumnType.sparsevec:
      case ColumnType.bit:
        type = 'TEXT';
        break;
      case ColumnType.unknown:
        throw (const FormatException('Unknown column type'));
    }

    return type;
  }
}

const _generateRandomUuid =
    'lower('
    "hex(randomblob(4)) || '-' || hex(randomblob(2)) || '-' || "
    "'4' || substr(hex(randomblob(2)), 2) || '-' || "
    "substr('89ab', 1 + (abs(random()) % 4), 1) || "
    "substr(hex(randomblob(2)), 2) || '-' || "
    'hex(randomblob(6))'
    ')';

const _generateRandomUuidV7 =
    'lower('
    "substr(printf('%012x', unixepoch('now', 'subsecond') * 1000), 1, 8) || '-' || "
    "substr(printf('%012x', unixepoch('now', 'subsecond') * 1000), 9, 4) || '-' || "
    "'7' || substr(hex(randomblob(2)), 2, 3) || '-' || "
    "substr('89ab', 1 + (abs(random()) % 4), 1) || "
    "substr(hex(randomblob(2)), 2, 3) || '-' || "
    'hex(randomblob(6))'
    ')';
