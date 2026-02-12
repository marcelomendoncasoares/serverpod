import 'package:serverpod/protocol.dart';
import 'package:serverpod/src/database/adapters/postgres/postgres_analyzer.dart';
import 'package:serverpod/src/database/adapters/sqlite/sqlite_analyzer.dart';
import 'package:serverpod/src/database/database.dart';
import 'package:serverpod_shared/serverpod_shared.dart';

/// Analyzes the structure of [Database]s.
class DatabaseAnalyzer {
  /// Analyze the structure of the [database].
  static Future<DatabaseDefinition> analyze(Database database) async {
    final analyzer = switch (database.dialect) {
      DatabaseDialect.postgres => PostgresDatabaseAnalyzer(
        database: database,
      ),
      DatabaseDialect.sqlite => SqliteDatabaseAnalyzer(
        database: database,
      ),
    };

    return analyzer.analyze();
  }
}
