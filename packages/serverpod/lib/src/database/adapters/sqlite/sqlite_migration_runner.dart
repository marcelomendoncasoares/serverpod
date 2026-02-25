import 'package:meta/meta.dart';
import 'package:serverpod/database.dart';

import '../../interface/migration_runner.dart';

@internal
class SqliteDatabaseMigrationRunner implements MigrationRunner {
  const SqliteDatabaseMigrationRunner();

  /// On SQLite, we can use the transaction directly to ensure that the
  /// database is locked during the migration. However, the transaction must
  /// be passed to the action to ensure we don't create a recursive locks.
  @override
  Future<void> runMigrations(
    DatabaseSession session,
    Future<void> Function(Transaction? transaction) action,
  ) async {
    return session.db.transaction(
      (transaction) => action(transaction),
    );
  }
}
