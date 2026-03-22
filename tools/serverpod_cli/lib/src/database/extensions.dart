import 'package:serverpod_cli/src/analyzer/models/definitions.dart';
import 'package:serverpod_cli/src/database/migration.dart';
import 'package:serverpod_database/serverpod_database.dart' as db;
import 'package:serverpod_service_client/serverpod_service_client.dart';

import 'sql_generator.dart';

// Export underlying dialect implementations.
export 'dialects/postgres.dart';
export 'dialects/sqlite.dart';

//
// Comparisons of database models
//
extension DatabaseComparisons on DatabaseDefinition {
  bool like(DatabaseDefinition other) {
    var diff = generateDatabaseMigration(
      databaseSource: this,
      databaseTarget: other,
    );
    return diff.isEmpty;
  }
}

extension TableComparisons on TableDefinition {
  bool like(TableDefinition other) =>
      db.TableComparisons(this).like(other).isEmpty;
}

extension ColumnComparisons on ColumnDefinition {
  bool get isPrimary => db.ColumnComparisons(this).isPrimary;

  bool like(ColumnDefinition other) =>
      db.ColumnComparisons(this).like(other).isEmpty;

  bool canMigrateTo(ColumnDefinition other) {
    // It's ok to change column default or nullability.
    if (other.dartType != null &&
        dartType != null &&
        !_canMigrateType(dartType!, other.dartType!)) {
      return false;
    }

    // Vector dimension changes require dropping and recreating the column.
    if (vectorDimension != other.vectorDimension) {
      return false;
    }

    return other.columnType == columnType && other.name == name;
  }

  bool get canBeCreatedInTableMigration {
    return (isNullable || columnDefault != null) &&
        name != defaultPrimaryKeyName;
  }
}

bool _canMigrateType(String src, String dst) {
  src = removeNullability(src);
  dst = removeNullability(dst);

  return src == dst;
}

String removeNullability(String type) {
  if (type.endsWith('?')) {
    return type.substring(0, type.length - 1);
  }
  return type;
}

extension IndexComparisons on IndexDefinition {
  bool like(IndexDefinition other) =>
      db.IndexComparisons(this).like(other).isEmpty;
}

extension ForeignKeyComparisons on ForeignKeyDefinition {
  bool like(ForeignKeyDefinition other) =>
      db.ForeignKeyComparisons(this).like(other).isEmpty;
}

extension DatabaseDiffComparisons on DatabaseMigration {
  bool get isEmpty => actions.isEmpty;
}

extension TableDiffComparisons on TableMigration {
  bool get isEmpty =>
      addColumns.isEmpty &&
      deleteColumns.isEmpty &&
      modifyColumns.isEmpty &&
      addIndexes.isEmpty &&
      deleteIndexes.isEmpty &&
      addForeignKeys.isEmpty &&
      deleteForeignKeys.isEmpty;
}

extension TableDefinitionExtension on TableDefinition {
  bool get isManaged => managed != false;
}

extension ColumnTypeComparison on ColumnType {
  bool like(ColumnType other) {
    // Integer and bigint are considered the same type.
    if (this == ColumnType.integer || this == ColumnType.bigint) {
      return other == ColumnType.integer || other == ColumnType.bigint;
    }

    return this == other;
  }
}

extension DatabaseDefinitionSqlGeneration on DatabaseDefinition {
  String toSql({
    required List<DatabaseMigrationVersion> installedModules,
    required db.DatabaseDialect dialect,
  }) {
    return SqlGenerator.forDialect(dialect).generateDatabaseDefinitionSql(
      this,
      installedModules: installedModules,
    );
  }
}

extension DatabaseMigrationSqlGeneration on DatabaseMigration {
  String toSql({
    required List<DatabaseMigrationVersion> installedModules,
    required List<DatabaseMigrationVersion> removedModules,
    required db.DatabaseDialect dialect,
    required DatabaseDefinition databaseDefinition,
  }) {
    return SqlGenerator.forDialect(dialect).generateDatabaseMigrationSql(
      this,
      databaseDefinition,
      installedModules: installedModules,
      removedModules: removedModules,
    );
  }
}

/// Returns the last element of the list, or null if the list is empty.
///
/// Used to get the latest migration version from the list of migration versions.
extension LastOrNullOnListString on List<String> {
  String? get lastOrNull => isEmpty ? null : last;
}
