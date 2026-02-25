import 'package:serverpod_cli/src/analyzer/models/definitions.dart';
import 'package:serverpod_cli/src/generator/types.dart';
import 'package:serverpod_serialization/serverpod_serialization.dart';
import 'package:serverpod_service_client/serverpod_service_client.dart';
import 'package:serverpod_shared/serverpod_shared.dart';

import '../../analyzer/models/utils/quote_utils.dart';
import '../sql_generator.dart';

class SqliteSqlGenerator implements SqlGenerator {
  @override
  String generateDatabaseDefinitionSql(
    DatabaseDefinition databaseDefinition, {
    required List<DatabaseMigrationVersion> installedModules,
  }) {
    return databaseDefinition.toSqliteSql(
      installedModules: installedModules,
    );
  }

  @override
  String generateDatabaseMigrationSql(
    DatabaseMigration databaseMigration, {
    required List<DatabaseMigrationVersion> installedModules,
    required List<DatabaseMigrationVersion> removedModules,
  }) {
    return databaseMigration.toSqliteSql(
      installedModules: installedModules,
      removedModules: removedModules,
    );
  }

  @override
  String? getColumnDefault(
    TypeDefinition columnType,
    dynamic defaultValue,
    String tableName,
  ) {
    return columnType.getSqliteColumnDefault(
      defaultValue,
      tableName,
    );
  }
}

const _sqliteSchemaTable = 'serverpod_sqlite_schema';

//
// SQL generation for SQLite
//
extension SqliteDatabaseDefinitionSqlGeneration on DatabaseDefinition {
  String toSqliteSql({
    required List<DatabaseMigrationVersion> installedModules,
  }) {
    String out = '';

    var tableCreation = '';
    // SQLite requires FKs to be defined INLINE in the Create Table statement.
    for (var table in tables.where((table) => table.managed != false)) {
      tableCreation += '--\n';
      tableCreation += '-- Class ${table.dartName} as table ${table.name}\n';
      tableCreation += '--\n';
      tableCreation += table.tableCreationToSql();
      tableCreation += '\n'; // Spacing between tables
    }

    // NOTE: Although it is a good practice to explicitly start a transaction,
    // this line will actually be ignored in the migrations manager since it
    // uses a previously created migration for all actions.
    out += 'BEGIN;\n';
    out += '\n';

    // Create tables
    out += tableCreation;

    if (installedModules.isNotEmpty) {
      out += '\n';
    }

    for (var module in installedModules) {
      out += _sqlStoreMigrationVersion(
        module: module.module,
        version: module.version,
      );
    }

    out += '\n';
    out += 'COMMIT;\n';

    return out;
  }
}

extension SqliteTableDefinitionSqlGeneration on TableDefinition {
  String tableCreationToSql({bool ifNotExists = false}) {
    String out = '';

    // Table
    if (ifNotExists) {
      out += 'CREATE TABLE IF NOT EXISTS "$name" (\n';
    } else {
      out += 'CREATE TABLE "$name" (\n';
    }

    var definitions = <String>[];

    // 1. Columns
    for (var column in columns) {
      definitions.add('    ${column.toSqlFragment()}');
    }

    // 2. Inline Foreign Keys
    // In SQLite, we must define these inside the CREATE TABLE block.
    for (var key in foreignKeys) {
      definitions.add('    ${key.toInlineSql()}');
    }

    out += definitions.join(',\n');
    out += '\n) STRICT;\n';

    // Indexes
    var indexesExceptId = <IndexDefinition>[];
    for (var index in indexes) {
      if (index.elements.length == 1 &&
          index.elements.first.definition == 'id') {
        continue;
      }
      indexesExceptId.add(index);
    }

    if (indexesExceptId.isNotEmpty) {
      out += '\n';
      out += '-- Indexes\n';
      for (var index in indexesExceptId) {
        out += index.toSql(tableName: name, ifNotExists: ifNotExists);
      }
    }

    out += '\n';

    return out;
  }
}

extension SqliteColumnDefinitionSqlGeneration on ColumnDefinition {
  /// Whether the column is the default primary key column.
  bool get isIdColumn => name == defaultPrimaryKeyName;

  /// Whether the column is of a vector type.
  bool get isVectorColumn =>
      columnType == ColumnType.vector ||
      columnType == ColumnType.halfvec ||
      columnType == ColumnType.sparsevec ||
      columnType == ColumnType.bit;

  String toSqlFragment() {
    String type;
    switch (columnType) {
      case ColumnType.bigint:
      case ColumnType.integer:
      case ColumnType.timestampWithoutTimeZone: // Stored as epoch milliseconds
      case ColumnType.boolean: // SQLite uses INTEGER (0/1) for booleans
        type = 'INTEGER';
      case ColumnType.doublePrecision:
        type = 'REAL';
      case ColumnType.bytea:
        type = 'BLOB';
      case ColumnType.text:
      case ColumnType.json:
      case ColumnType.uuid: // SQLite usually stores UUIDs as TEXT
      case ColumnType.vector:
      case ColumnType.halfvec:
      case ColumnType.sparsevec:
      case ColumnType.bit:
        type = 'TEXT';
      case ColumnType.unknown:
        throw const FormatException('Unknown column type');
    }

    var nullable = isNullable ? '' : ' NOT NULL';
    var defaultValue = '';

    if (columnDefault != null) {
      // Clean up Postgres specific casting syntax (e.g. 'value'::text -> 'value')
      var cleanDefault = columnDefault!.replaceAll(
        RegExp(r'::[a-zA-Z0-9_ ]+$'),
        '',
      );

      switch (columnType) {
        case ColumnType.bigint:
        case ColumnType.integer:
          if (cleanDefault.startsWith('nextval(')) {
            cleanDefault = 'AUTOINCREMENT';
          }
        case ColumnType.boolean:
          cleanDefault = cleanDefault == 'true' ? '1' : '0';
        case ColumnType.uuid:
          cleanDefault =
              {
                'gen_random_uuid()': _generateRandomUuid,
                'gen_random_uuid_v7()': _generateRandomUuidV7,
              }[cleanDefault] ??
              cleanDefault;
        default:
      }

      defaultValue = ' DEFAULT ($cleanDefault)';
    }

    // The id column is special.
    if (isIdColumn && type == 'INTEGER') {
      if (isNullable) {
        throw const FormatException('The id column must be non-nullable');
      }
      // SQLite "INTEGER PRIMARY KEY" is an alias for ROWID (auto-incrementing)
      type = 'INTEGER PRIMARY KEY';
      nullable = '';
      defaultValue = '';
    }

    return '"$name" $type$nullable$defaultValue';
  }
}

extension SqliteIndexDefinitionSqlGeneration on IndexDefinition {
  String toSql({
    required String tableName,
    bool ifNotExists = false,
  }) {
    // Vector indexes are not supported in SQLite and are ignored.
    if (type == 'hnsw' || type == 'ivfflat') {
      return '';
    }

    var uniqueStr = isUnique ? ' UNIQUE' : '';
    var elementStrs = elements.map((e) => '"${e.definition}"');
    var ifNotExistsStr = ifNotExists ? ' IF NOT EXISTS' : '';

    // SQLite doesn't use "USING btree" syntax, it's implied.
    return 'CREATE$uniqueStr INDEX$ifNotExistsStr "$indexName" ON "$tableName" '
        '(${elementStrs.join(', ')});\n';
  }
}

extension SqliteForeignKeyDefinitionSqlGeneration on ForeignKeyDefinition {
  /// SQLite requires inline constraints for "CREATE TABLE".
  /// It does NOT support "ALTER TABLE ADD CONSTRAINT".
  String toInlineSql() {
    var refColumnsFmt = referenceColumns.map((e) => '"$e"');

    var out =
        'CONSTRAINT "$constraintName" '
        'FOREIGN KEY ("${columns.join(', ')}") '
        'REFERENCES "$referenceTable" (${refColumnsFmt.join(', ')})';

    if (onDelete != null) {
      out += ' ON DELETE ${onDelete!.toSqlAction()}';
    }

    if (onUpdate != null) {
      out += ' ON UPDATE ${onUpdate!.toSqlAction()}';
    }

    return out;
  }
}

extension on ForeignKeyAction {
  String toSqlAction() {
    switch (this) {
      case ForeignKeyAction.noAction:
        return 'NO ACTION';
      case ForeignKeyAction.restrict:
        return 'RESTRICT';
      case ForeignKeyAction.cascade:
        return 'CASCADE';
      case ForeignKeyAction.setNull:
        return 'SET NULL';
      case ForeignKeyAction.setDefault:
        return 'SET DEFAULT';
    }
  }
}

extension SqliteDatabaseMigrationSqlGeneration on DatabaseMigration {
  String toSqliteSql({
    required List<DatabaseMigrationVersion> installedModules,
    required List<DatabaseMigrationVersion> removedModules,
  }) {
    var out = '';

    out += 'BEGIN;\n';
    out += '\n';

    for (var action in actions) {
      out += action.toSqliteSql();
    }

    if (installedModules.isNotEmpty) {
      out += '\n';
    }

    for (var module in installedModules) {
      out += _sqlStoreMigrationVersion(
        module: module.module,
        version: module.version,
      );
    }

    if (removedModules.isNotEmpty) {
      out += '\n';
      out += _sqlRemoveMigrationVersion(removedModules);
    }

    // FIXME:
    // out += _sqlStoreColumnTypesForMigrations();

    out += '\n';
    out += 'COMMIT;\n';

    return out;
  }
}

extension SqliteMigrationActionSqlGeneration on DatabaseMigrationAction {
  String toSqliteSql() {
    var out = '';

    switch (type) {
      case DatabaseMigrationActionType.deleteTable:
        out += '--\n';
        out += '-- ACTION DROP TABLE\n';
        out += '--\n';
        // SQLite doesn't support CASCADE in DROP TABLE, but it's ignored if FKs are off,
        // or enforced if on. Standard is just DROP TABLE.
        out += 'DROP TABLE "$deleteTable";\n';
        out += '\n';
        break;
      case DatabaseMigrationActionType.createTable:
        out += '--\n';
        out += '-- ACTION CREATE TABLE\n';
        out += '--\n';
        // This includes inline FKs now
        out += createTable!.tableCreationToSql();
        break;
      case DatabaseMigrationActionType.createTableIfNotExists:
        out += '--\n';
        out += '-- ACTION CREATE TABLE IF NOT EXISTS\n';
        out += '--\n';
        out += createTable!.tableCreationToSql(ifNotExists: true);
        break;
      case DatabaseMigrationActionType.alterTable:
        out += '--\n';
        out += '-- ACTION ALTER TABLE\n';
        out += '--\n';
        out += alterTable!.toSql();
        break;
    }

    return out;
  }
}

extension SqliteTableMigrationSqlGeneration on TableMigration {
  String toSql() {
    var out = '';

    // 1. Drop indexes (Supported)
    for (var deleteIndex in deleteIndexes) {
      out += 'DROP INDEX "$deleteIndex";\n';
    }

    // 2. Drop foreign keys (NOT SUPPORTED in SQLite via ALTER)
    if (deleteForeignKeys.isNotEmpty) {
      throw UnimplementedError(
        'Dropping Foreign Keys via ALTER TABLE is not supported in SQLite. '
        'Requires table rebuild.',
      );
    }

    // 3. Drop columns (Supported in SQLite 3.35+)
    for (var deleteColumn in deleteColumns) {
      out += 'ALTER TABLE "$name" DROP COLUMN "$deleteColumn";\n';
    }

    // 4. Add columns (Supported, but with limitations on constraints)
    for (var addColumn in addColumns) {
      // Note: SQLite ADD COLUMN cannot support PRIMARY KEY or UNIQUE constraints (usually).
      // It allows REFERENCES if not strict, but best to be careful.
      out += 'ALTER TABLE "$name" ADD COLUMN ${addColumn.toSqlFragment()};\n';
    }

    // 5. Modify columns (NOT SUPPORTED)
    if (modifyColumns.isNotEmpty) {
      throw UnimplementedError(
        'Modifying columns (types, nullability) is not supported in SQLite. '
        'Requires table rebuild.',
      );
    }

    // 6. Add indexes (Supported)
    for (var addIndex in addIndexes) {
      out += addIndex.toSql(tableName: name);
    }

    // 7. Add Foreign Keys (NOT SUPPORTED)
    if (addForeignKeys.isNotEmpty) {
      throw UnimplementedError(
        'Adding Foreign Keys via ALTER TABLE is not supported in SQLite. '
        'Requires table rebuild.',
      );
    }

    return out;
  }
}

// FIXME:
// Column migration helper for SQLite is strictly limited because
// ALTER COLUMN is not supported.
// We removed PostgresColumnMigrationPgSqlGenerator because it's almost entirely
// unusable in SQLite without a full table rebuild strategy.

String _sqlStoreMigrationVersion({
  required String module,
  required String version,
}) {
  String out = '';
  out += '--\n';
  out += '-- MIGRATION VERSION FOR $module\n';
  out += '--\n';
  out +=
      'INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")\n';
  out +=
      '    VALUES (\'$module\', \'$version\', (unixepoch(\'now\', \'subsecond\') * 1000))\n';
  out += '    ON CONFLICT ("module")\n';
  out +=
      '    DO UPDATE SET "version" = \'$version\', "timestamp" = (unixepoch(\'now\', \'subsecond\') * 1000);\n';
  out += '\n';

  return out;
}

/// Stores all column types on a table to be able to compare schema changes
/// in migrations. This is required since column types on SQLite are simpler
/// and comparing only the actual column types would be too permissive and
/// generate deserialization errors in case the dart type being stored changes
/// between migrations.
String _sqlStoreColumnTypesForMigrations(List<TableDefinition> tables) {
  String out = '';
  out += '--\n';
  out += '-- STORE COLUMN TYPES FOR MIGRATIONS\n';
  out += '--\n';
  out += 'CREATE TABLE IF NOT EXISTS "$_sqliteSchemaTable" (\n';
  out += '    "table_name" TEXT NOT NULL,\n';
  out += '    "column_name" TEXT NOT NULL,\n';
  out += '    "column_type" TEXT NOT NULL,\n';
  out += '    PRIMARY KEY ("table_name", "column_name")\n';
  out += ');\n';
  out += '\n';
  out +=
      'INSERT INTO "$_sqliteSchemaTable" ("table_name", "column_name", "column_type") VALUES\n';
  for (var t in tables) {
    for (var c in t.columns) {
      out += "    ('${t.name}', '${c.name}', '${c.columnType.name}');\n";
    }
  }
  return out;
}

String _sqlRemoveMigrationVersion(List<DatabaseMigrationVersion> modules) {
  var moduleNames = modules.map((e) => "'${e.module}'").toList().join(', ');
  String out = '';
  out += '--\n';
  out += '-- MIGRATION VERSION FOR $moduleNames\n';
  out += '--\n';
  out += 'DELETE FROM "serverpod_migrations" ';
  out += 'WHERE "module" IN ($moduleNames);';
  out += '\n';

  return out;
}

// TODO: Support vector.
extension SqliteTypeDefinition on TypeDefinition {
  String? getSqliteColumnDefault(
    dynamic defaultValue,
    String tableName,
  ) {
    var defaultValueType = this.defaultValueType;
    if ((defaultValue == null) || (defaultValueType == null)) return null;

    switch (defaultValueType) {
      case DefaultValueAllowedType.dateTime:
        if (defaultValue is! String) {
          throw StateError('Invalid DateTime default value: $defaultValue');
        }

        if (defaultValue == defaultDateTimeValueNow) {
          return "CAST(unixepoch('subsecond') * 1000 AS INTEGER)";
        }

        DateTime? dateTime = DateTime.parse(defaultValue).toUtc();
        return '${dateTime.millisecondsSinceEpoch}';
      case DefaultValueAllowedType.bool:
        return defaultValue;
      case DefaultValueAllowedType.int:
        if (defaultValue == defaultIntSerial) {
          return 'AUTOINCREMENT';
        }
        return '$defaultValue';
      case DefaultValueAllowedType.double:
        return '$defaultValue';
      case DefaultValueAllowedType.string:
        return 'CAST(${escapeSqlString(defaultValue)} AS TEXT)';
      case DefaultValueAllowedType.uuidValue:
        if (defaultValue == defaultUuidValueRandom) {
          return _generateRandomUuid;
        }
        if (defaultValue == defaultUuidValueRandomV7) {
          return _generateRandomUuidV7;
        }
        return 'CAST(${escapeSqlString(defaultValue)} AS TEXT)';
      case DefaultValueAllowedType.uri:
        return 'CAST(${escapeSqlString(defaultValue)} AS TEXT)';
      case DefaultValueAllowedType.bigInt:
        var parsedBigInt = BigInt.parse(defaultValue);
        return "CAST('${parsedBigInt.toString()}' AS TEXT)";
      case DefaultValueAllowedType.duration:
        Duration parsedDuration = parseDuration(defaultValue);
        return '${parsedDuration.toJson()}';
      case DefaultValueAllowedType.isEnum:
        var enumDefinition = this.enumDefinition;
        if (enumDefinition == null) return null;
        var values = enumDefinition.values;
        return switch (enumDefinition.serialized) {
          EnumSerialization.byIndex =>
            '${values.indexWhere((e) => e.name == defaultValue)}',
          EnumSerialization.byName => 'CAST(\'$defaultValue\' AS TEXT)',
        };
    }
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
