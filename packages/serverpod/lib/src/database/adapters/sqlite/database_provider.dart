import 'package:serverpod_shared/serverpod_shared.dart';

import '../../interface/serialization_manager.dart';
import '../../concepts/runtime_parameters.dart';
import '../../database.dart';
import '../../interface/provider.dart';
import '../../interface/database_pool_manager.dart';
import 'sqlite_pool_manager.dart';
import 'database_connection.dart';
import 'sqlite_analyzer.dart';
import 'sqlite_migration_runner.dart';

/// Provides a [DatabaseProvider] for the Sqlite database.
class SqliteDatabaseProvider implements DatabaseProvider {
  @override
  SqlitePoolManager createPoolManager(
    SerializationManagerServer serializationManager,
    RuntimeParametersListBuilder? runtimeParametersBuilder,
    DatabaseConfig config,
  ) {
    if (runtimeParametersBuilder != null) {
      throw UnsupportedError('SQLite does not support runtime parameters.');
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
