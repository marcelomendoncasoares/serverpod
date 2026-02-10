import 'package:serverpod_service_client/serverpod_service_client.dart';
import 'package:serverpod_shared/serverpod_shared.dart';

import '../generator/types.dart';
import 'dialects/postgres.dart';

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
      _ => throw UnimplementedError('Dialect $dialect not implemented'),
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
      _ => throw UnimplementedError('Dialect $dialect not implemented'),
    };
  }

  static String? getColumnDefault(
    DatabaseDialect dialect,
    TypeDefinition columnType,
    dynamic defaultValue,
    String tableName,
  ) {
    return switch (dialect) {
      DatabaseDialect.postgres => columnType.getColumnDefault(
        defaultValue,
        tableName,
      ),
      _ => throw UnimplementedError('Dialect $dialect not implemented'),
    };
  }
}
