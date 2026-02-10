import 'package:serverpod/src/database/adapters/postgres/postgres_analyzer.dart';
import 'package:serverpod_shared/serverpod_shared.dart';
import 'package:serverpod/protocol.dart';
import 'package:serverpod/src/database/database.dart';

/// Analyzes the structure of [Database]s.
class DatabaseAnalyzer {
  /// Analyze the structure of the [database].
  static Future<DatabaseDefinition> analyze(Database database) async {
    final analyzer = switch (database.dialect) {
      DatabaseDialect.postgres => PostgresDatabaseAnalyzer(
        database: database,
      ),
      _ => throw UnimplementedError(
        'Unsupported database adapter with dialect: ${database.dialect}',
      ),
    };

    return analyzer.analyze();
  }
}
