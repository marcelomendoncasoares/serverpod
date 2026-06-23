import '../concepts/transaction.dart';
import '../database.dart';

/// Function type for logging a query.
typedef LogQueryFunction =
    void Function({
      required String query,
      required Duration duration,
      required int? numRowsAffected,
      required String? error,
      required StackTrace stackTrace,
    });

/// Function type for logging a warning during the execution of a query.
typedef LogWarningFunction =
    Future<void> Function(
      String message,
    );

/// Interface for accessing the database.
abstract interface class DatabaseSession {
  /// The database to access.
  Database get db;

  /// Optional transaction to use for all database queries.
  Transaction? get transaction;

  /// Optional function to log a query.
  LogQueryFunction? get logQuery;

  /// Optional function to log a warning during the execution of a query.
  LogWarningFunction? get logWarning;

  /// Runtime parameters applied with `SET LOCAL` for the duration of a
  /// [Database.transactionForUser] call.
  ///
  /// Each entry is set as a database session variable (read back with
  /// `current_setting`) so that, for example, PostgreSQL row-level security
  /// policies can resolve against the authenticated user. Null when the session
  /// carries no such context (for example, when it is not authenticated).
  Map<String, String>? get transactionForUserSettings;
}
