import 'package:serverpod_service_client/serverpod_service_client.dart';
import 'package:serverpod_shared/serverpod_shared.dart';

import '../generator/types.dart';
import 'dialects/postgres.dart';
import 'dialects/sqlite.dart';

class SqlGenerator {
  static String generateDatabaseDefinitionSql(
    DatabaseDialect dialect,
    DatabaseDefinition databaseDefinition, {
    required List<DatabaseMigrationVersion> installedModules,
  }) {
    return switch (dialect) {
      DatabaseDialect.postgres => databaseDefinition.toPgSql(
        installedModules: installedModules,
      ),
      DatabaseDialect.sqlite => databaseDefinition.toSqliteSql(
        installedModules: installedModules,
      ),
    };
  }

  static String generateDatabaseMigrationSql(
    DatabaseDialect dialect,
    DatabaseMigration databaseMigration, {
    required List<DatabaseMigrationVersion> installedModules,
    required List<DatabaseMigrationVersion> removedModules,
  }) {
    return switch (dialect) {
      DatabaseDialect.postgres => databaseMigration.toPgSql(
        installedModules: installedModules,
        removedModules: removedModules,
      ),
      DatabaseDialect.sqlite => databaseMigration.toSql(
        installedModules: installedModules,
        removedModules: removedModules,
      ),
    };
  }

  static String? getColumnDefault(
    DatabaseDialect dialect,
    TypeDefinition columnType,
    dynamic defaultValue,
    String tableName,
  ) {
    return switch (dialect) {
      DatabaseDialect.postgres => columnType.getPgColumnDefault(
        defaultValue,
        tableName,
      ),
      DatabaseDialect.sqlite => columnType.getSqliteColumnDefault(
        defaultValue,
        tableName,
      ),
    };
  }
}
