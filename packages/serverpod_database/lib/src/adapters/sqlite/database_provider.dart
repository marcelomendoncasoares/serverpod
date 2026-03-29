import 'package:serverpod_shared/serverpod_shared.dart';

import '../../../serverpod_database.dart';
import 'database_connection.dart';
import 'sqlite_analyzer.dart';
import 'sqlite_migration_runner.dart';
import 'sqlite_pool_manager.dart';

/// Provides a [DatabaseProvider] for the Sqlite database.
class SqliteDatabaseProvider implements DatabaseProvider {
  /// Creates a new [SqliteDatabaseProvider].
  const SqliteDatabaseProvider();

  @override
  DatabaseDefinitionRestrictions get definitionRestrictions =>
      const DatabaseDefinitionRestrictions(
        supportedIndexTypes: ['btree'],
      );

  @override
  SqlitePoolManager createPoolManager(
    SerializationManagerServer serializationManager,
    RuntimeParametersListBuilder? runtimeParametersBuilder,
    DatabaseConfig config,
  ) {
    if (runtimeParametersBuilder != null) {
      throw UnsupportedError('SQLite does not support runtime parameters.');
    }
    if (config is! SqliteDatabaseConfig) {
      throw ArgumentError('Config must be a "SqliteDatabaseConfig".');
    }
    return SqlitePoolManager(
      serializationManager,
      config,
    );
  }

  @override
  SqliteDatabaseConnection createConnection(DatabasePoolManager poolManager) {
    if (poolManager is! SqlitePoolManager) {
      throw ArgumentError('Pool manager must be a "SqlitePoolManager".');
    }
    return SqliteDatabaseConnection(poolManager);
  }

  @override
  SqliteDatabaseMigrationRunner createMigrationRunner() {
    return const SqliteDatabaseMigrationRunner();
  }

  @override
  SqliteDatabaseAnalyzer createAnalyzer(Database database) {
    return SqliteDatabaseAnalyzer(database: database);
  }
}
