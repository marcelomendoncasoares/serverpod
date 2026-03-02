import 'package:serverpod_service_client/serverpod_service_client.dart';
import 'package:serverpod_shared/serverpod_shared.dart';

import '../analyzer/models/definitions.dart';
import '../generator/types.dart';
import 'dialects/postgres.dart';
import 'dialects/sqlite.dart';

abstract interface class SqlGenerator {
  factory SqlGenerator.forDialect(DatabaseDialect dialect) => switch (dialect) {
    DatabaseDialect.postgres => PostgresSqlGenerator(),
    DatabaseDialect.sqlite => SqliteSqlGenerator(),
  };

  String generateDatabaseDefinitionSql(
    DatabaseDefinition databaseDefinition, {
    required List<DatabaseMigrationVersion> installedModules,
  });

  String generateDatabaseMigrationSql(
    DatabaseMigration databaseMigration, {
    required List<DatabaseMigrationVersion> installedModules,
    required List<DatabaseMigrationVersion> removedModules,
    required DatabaseDefinition targetDefinition,
  });

  IndexDefinition? getPrimaryKeyIndex({
    required SerializableModelFieldDefinition idField,
    required String tableName,
  });

  String? getColumnDefault(
    TypeDefinition columnType,
    dynamic defaultValue,
    String tableName,
  );
}
