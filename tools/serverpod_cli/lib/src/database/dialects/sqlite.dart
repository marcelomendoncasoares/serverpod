import 'package:serverpod_cli/src/util/serverpod_cli_logger.dart';
import 'package:serverpod_database/serverpod_database.dart';

// This is a temporary internal import since the normalize functions are not
// meant to be exported from the database package. It will be removed once the
// [SqliteSqlGenerator] gets moved to the database package.
// ignore: implementation_imports
import 'package:serverpod_database/src/adapters/sqlite/sqlite_default_value.dart';

import '../sql_generator.dart';

class SqliteSqlGenerator implements SqlGenerator {
  @override
  String generateDatabaseDefinitionSql(
    DatabaseDefinition databaseDefinition, {
    required List<DatabaseMigrationVersionModel> installedModules,
  }) {
    return databaseDefinition.toSqliteSql(
      installedModules: installedModules,
    );
  }

  @override
  String generateDatabaseMigrationSql(
    DatabaseMigration databaseMigration,
    DatabaseDefinition databaseDefinition, {
    required List<DatabaseMigrationVersionModel> installedModules,
    required List<DatabaseMigrationVersionModel> removedModules,
  }) {
    return databaseMigration.toSqliteSql(
      databaseDefinition: databaseDefinition,
      installedModules: installedModules,
      removedModules: removedModules,
    );
  }
}

const _sqliteSchemaTable = 'serverpod_sqlite_schema';

//
// SQL generation for SQLite
//
extension SqliteDatabaseDefinitionSqlGeneration on DatabaseDefinition {
  String toSqliteSql({
    required List<DatabaseMigrationVersionModel> installedModules,
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

    out += _sqlStoreColumnTypesForMigrations(
      tables,
      installedModules.first,
    );

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
  String tableCreationToSql({
    bool ifNotExists = false,
    String? tableNameOverride,
    bool skipIndexes = false,
  }) {
    final tableName = tableNameOverride ?? name;

    String out = '';

    // Table
    if (ifNotExists) {
      out += 'CREATE TABLE IF NOT EXISTS "$tableName" (\n';
    } else {
      out += 'CREATE TABLE "$tableName" (\n';
    }

    var definitions = <String>[];

    for (var column in columns) {
      definitions.add('    ${column.toSqlFragment()}');
    }

    // Inline Foreign Keys
    // In SQLite, we must define these inside the CREATE TABLE block.
    for (var key in foreignKeys) {
      definitions.add('    ${key.toInlineSql()}');
    }

    out += definitions.join(',\n');
    out += '\n) STRICT;\n';

    if (!skipIndexes) {
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
          out += index.toSql(
            tableName: tableName,
            ifNotExists: ifNotExists,
          );
        }
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
      case ColumnType.uuid: // Storing UUIDs as BLOB for efficiency
      case ColumnType.bytea:
        type = 'BLOB';
      case ColumnType.text:
      case ColumnType.json:
      case ColumnType.vector:
      case ColumnType.halfvec:
      case ColumnType.sparsevec:
      case ColumnType.bit:
        type = 'TEXT';
      case ColumnType.unknown:
        throw const FormatException('Unknown column type');
    }

    var nullable = isNullable ? '' : ' NOT NULL';
    var defaultSql = columnType.getSqliteColumnDefault(columnDefault);

    var defaultValue = defaultSql != null ? ' DEFAULT ($defaultSql)' : '';

    // The id column is special.
    if (isIdColumn) {
      if (isNullable) {
        throw const FormatException('The id column must be non-nullable');
      }
      // SQLite "INTEGER PRIMARY KEY" is an alias for ROWID.
      if (type == 'INTEGER') {
        defaultValue = '';
      }
      type = '$type PRIMARY KEY';
      nullable = '';
    }

    return '"$name" $type$nullable$defaultValue';
  }
}

extension SqliteIndexDefinitionSqlGeneration on IndexDefinition {
  String toSql({
    required String tableName,
    bool ifNotExists = false,
  }) {
    if (type != 'btree') {
      log.warning(
        'SQLite does not support index type "$type" for index "$indexName". '
        'Skipping index creation.',
      );
      type = 'btree';
    }

    var uniqueStr = isUnique ? ' UNIQUE' : '';
    var elementStrs = elements.map((e) => '"${e.definition}"');
    var ifNotExistsStr = ifNotExists ? ' IF NOT EXISTS' : '';

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
    required DatabaseDefinition databaseDefinition,
    required List<DatabaseMigrationVersionModel> installedModules,
    required List<DatabaseMigrationVersionModel> removedModules,
  }) {
    var out = '';

    out += 'BEGIN;\n';
    out += '\n';

    for (var action in actions) {
      out += action.toSqliteSql(databaseDefinition: databaseDefinition);
    }

    out += _sqlStoreColumnTypesForMigrations(
      databaseDefinition.tables,
      installedModules.first,
    );

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

    out += '\n';
    out += 'COMMIT;\n';

    return out;
  }
}

extension SqliteMigrationActionSqlGeneration on DatabaseMigrationAction {
  String toSqliteSql({required DatabaseDefinition databaseDefinition}) {
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
        final rebuildSql = alterTable!.toSqliteRebuildSql(databaseDefinition);
        if (rebuildSql != null) {
          out += rebuildSql;
        } else {
          out += alterTable!.toSql();
        }
        break;
    }

    return out;
  }
}

extension SqliteTableMigrationSqlGeneration on TableMigration {
  /// Returns SQL for a full table rebuild (SQLite 12-step procedure) when this
  /// migration requires it (column type/nullability changes or FK add/drop).
  /// Returns null when simple ALTER is sufficient.
  String? toSqliteRebuildSql(DatabaseDefinition targetDefinition) {
    final needsRebuild =
        modifyColumns.isNotEmpty ||
        deleteForeignKeys.isNotEmpty ||
        addForeignKeys.isNotEmpty;
    if (!needsRebuild) return null;

    TableDefinition? targetTable;
    for (var t in targetDefinition.tables) {
      if (t.name == name) {
        targetTable = t;
        break;
      }
    }
    if (targetTable == null) {
      throw StateError(
        'SQLite table rebuild for "$name" requires target table definition.',
      );
    }

    return _toSqliteTableRebuild(targetTable);
  }

  /// Implements SQLite's "Making Other Kinds Of Table Schema Changes" procedure.
  String _toSqliteTableRebuild(TableDefinition targetTable) {
    const newTablePrefix = 'new_';
    final newTableName = newTablePrefix + name;

    var out = '';

    // 1. If foreign key constraints are enabled, disable them. (handled by the migration runner)

    // 2. Transaction is already started by the migration script (BEGIN above).

    // 3. Indexes/triggers/views: we recreate from target table (step 8).

    // 4. CREATE TABLE new_X in the desired revised format.
    out += targetTable.tableCreationToSql(
      tableNameOverride: newTableName,
      skipIndexes: true,
    );

    // 5. Transfer content from X into new_X.
    final addColumnNames = addColumns.map((c) => c.name).toSet();
    final copyColumns = targetTable.columns
        .where((c) => !addColumnNames.contains(c.name))
        .toList();
    if (copyColumns.isNotEmpty) {
      final colList = copyColumns.map((c) => '"${c.name}"').join(', ');
      out +=
          'INSERT INTO "$newTableName" ($colList) '
          'SELECT $colList FROM "$name";\n';
    }

    // 6. Drop the old table.
    out += 'DROP TABLE "$name";\n';

    // 7. Rename new_X to X.
    out += 'ALTER TABLE "$newTableName" RENAME TO "$name";\n';

    // 8. Recreate indexes (excluding primary key on id).
    var indexesExceptId = <IndexDefinition>[];
    for (var index in targetTable.indexes) {
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
        out += index.toSql(tableName: name);
      }
    }

    // 9. (Triggers/views: Serverpod does not use them; skip.)

    // 10. Verify foreign key constraints (optional; run manually if desired).
    // out += 'PRAGMA foreign_key_check;\n';

    // 11. Commit is done by the migration script.

    // 12. Re-enable foreign keys. (handled by the migration runner)
    out += '\n';

    return out;
  }

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

    // 5. Modify columns (NOT SUPPORTED) - handled via toSqliteRebuildSql when targetDefinition is passed
    if (modifyColumns.isNotEmpty) {
      throw UnimplementedError(
        'Modifying columns (types, nullability) is not supported in SQLite. '
        'Requires table rebuild. Pass targetDefinition when generating migration SQL.',
      );
    }

    // 6. Add indexes (Supported)
    for (var addIndex in addIndexes) {
      out += addIndex.toSql(tableName: name);
    }

    // 7. Add Foreign Keys (NOT SUPPORTED) - handled via toSqliteRebuildSql when targetDefinition is passed
    if (addForeignKeys.isNotEmpty) {
      throw UnimplementedError(
        'Adding Foreign Keys via ALTER TABLE is not supported in SQLite. '
        'Requires table rebuild. Pass targetDefinition when generating migration SQL.',
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
String _sqlStoreColumnTypesForMigrations(
  List<TableDefinition> tables,
  DatabaseMigrationVersionModel currentModule,
) {
  String out = '';
  out += '--\n';
  out += '-- STORE COLUMN TYPES FOR MIGRATIONS\n';
  out += '--\n';
  out += 'DROP TABLE IF EXISTS "$_sqliteSchemaTable";\n';
  out += '\n';
  out += 'CREATE TABLE "$_sqliteSchemaTable" (\n';
  out += '    "table_name" TEXT NOT NULL,\n';
  out += '    "column_name" TEXT NOT NULL,\n';
  out += '    "column_type" TEXT NOT NULL,\n';
  out += '    "column_vector_dimension" INTEGER,\n';
  out += '    PRIMARY KEY ("table_name", "column_name")\n';
  out += ');\n';
  out += '\n';
  out += 'INSERT INTO "$_sqliteSchemaTable" VALUES\n';
  for (var t in tables) {
    for (var c in t.columns) {
      out += '    (';
      out += "'${t.name}', ";
      out += "'${c.name}', ";
      out += "'${c.columnType.name}', ";
      out += "${c.vectorDimension ?? 'NULL'}";
      out += ')';
      out += (t == tables.last && c == t.columns.last) ? ';\n' : ',\n';
    }
  }
  return out;
}

String _sqlRemoveMigrationVersion(List<DatabaseMigrationVersionModel> modules) {
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
