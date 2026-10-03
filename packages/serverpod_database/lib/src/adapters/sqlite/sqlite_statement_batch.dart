import 'package:meta/meta.dart';
import 'package:sqlite3/common.dart';

/// A single bound statement in an ordered write batch.
@internal
class SqliteBatchStatement {
  final String sql;
  final List<Object?> parameters;

  const SqliteBatchStatement(this.sql, this.parameters);
}

/// Runs statements in input order, reusing preparation without reordering writes.
/// The caller owns the transaction and limits the size of the batch.
@internal
List<T> runPreparedSqliteBatch<T>(
  CommonDatabase database,
  Iterable<String> statements,
  T Function(CommonPreparedStatement statement, int index) execute,
) {
  final prepared = <String, CommonPreparedStatement>{};
  final results = <T>[];

  try {
    for (final sql in statements) {
      final statement = prepared.putIfAbsent(
        sql,
        () => database.prepare(sql, checkNoTail: true),
      );
      try {
        results.add(execute(statement, results.length));
      } finally {
        // The web result encoder steps the raw statement. Reset before its
        // next binding, just as sqlite3_web's prepared statement cache does.
        statement.reset();
      }
    }
    return results;
  } finally {
    for (final statement in prepared.values) {
      statement.close();
    }
  }
}
