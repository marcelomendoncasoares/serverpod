import 'dart:collection';
import 'dart:js_interop';

import 'package:sqlite3/common.dart';
import 'package:sqlite3_web/protocol_utils.dart';
import 'package:sqlite3_web/sqlite3_web.dart';
import 'package:sqlite_async/sqlite_async.dart';
import 'package:sqlite_async/web.dart';

import '../sqlite_statement_batch.dart';
import 'sqlite_batch_protocol.dart';
import 'sqlite_batch_worker.dart';

const _batchCommand = '/* Serverpod ordered statement batch */';

/// Executes a bounded plan using the transaction's existing worker lock.
Future<List<ResultSet>> executeSqliteBatch(
  SqliteWriteContext context,
  List<SqliteBatchStatement> statements,
) async {
  final call = _BatchCall(statements);
  // sqlite_async doesn't expose customRequest on a transaction. Route this
  // private envelope through execute so its lock token and transaction check
  // reach _BatchDatabase.select. The envelope never becomes SQL or a binding.
  await context.execute(_batchCommand, [call]);
  return call.results!;
}

/// Opens a database with the Serverpod worker protocol extension.
SqliteDatabase openSqliteDatabase(String path, SqliteOptions options) =>
    SqliteDatabase.withFactory(
      _BatchOpenFactory(
        path: path,
        // The driver caches controllers by asset URI. Keep this extension
        // separate from ordinary sqlite_async databases in the same app.
        sqliteOptions: options.copyWith(
          webSqliteOptions: WebSqliteOptions(
            wasmUri: options.webSqliteOptions.wasmUri,
            workerUri: 'serverpod_db_worker.js',
          ),
        ),
      ),
    );

// A list also keeps the driver's debug profiler from trying to JSON-encode
// custom Dart objects. Application-provided SQL cannot construct this type.
class _BatchCall extends UnmodifiableListView<SqliteBatchStatement> {
  _BatchCall(super.statements);

  List<ResultSet>? results;
}

final class _BatchOpenFactory extends WebSqliteOpenFactory {
  _BatchOpenFactory({required super.path, required super.sqliteOptions});

  @override
  Future<WebSqlite> openWebSqlite(WebSqliteOptions options) async =>
      WebSqlite.open(
        wasmModule: options.wasmUri,
        workers: WorkerConnector.defaultWorkers(options.workerUri),
        controller: ServerpodSqliteController(),
        handleCustomRequest: handleCustomRequest,
      );

  @override
  Future<ConnectToRecommendedResult> connectToWorker(
    WebSqlite sqlite,
    String name,
  ) async {
    final connection = await super.connectToWorker(sqlite, name);
    return ConnectToRecommendedResult(
      database: _BatchDatabase(connection.database),
      features: connection.features,
      implementation: connection.implementation,
    );
  }
}

/// Decorates the public sqlite3_web boundary without acquiring a second lock.
/// All ordinary operations and notifications retain the driver's behavior.
class _BatchDatabase implements Database {
  final Database _database;

  _BatchDatabase(this._database);

  @override
  Future<DatabaseResult<ResultSet>> select(
    String sql, {
    List<Object?> parameters = const [],
    bool checkInTransaction = false,
    LockToken? token,
    Future<void>? abortTrigger,
  }) async {
    if (parameters case [final _BatchCall call] when sql == _batchCommand) {
      final response = await _database.customRequest(
        SqliteBatchRequest.encode(call, requireTransaction: checkInTransaction),
        token: token,
        abortTrigger: abortTrigger,
      );
      call.results = (response as JSArray<JSObject>).toDart
          .map(deserializeResultSet)
          .toList();
      // sqlite_async consumes only .result. No rowid or autocommit metadata
      // escapes this internal envelope; the worker checks the real state.
      return (
        result: ResultSet(const [], null, const []),
        autocommit: !checkInTransaction,
        lastInsertRowid: 0,
      );
    }

    return _database.select(
      sql,
      parameters: parameters,
      checkInTransaction: checkInTransaction,
      token: token,
      abortTrigger: abortTrigger,
    );
  }

  @override
  Future<DatabaseResult<void>> execute(
    String sql, {
    List<Object?> parameters = const [],
    bool checkInTransaction = false,
    LockToken? token,
    Future<void>? abortTrigger,
  }) => _database.execute(
    sql,
    parameters: parameters,
    checkInTransaction: checkInTransaction,
    token: token,
    abortTrigger: abortTrigger,
  );

  @override
  Future<JSAny?> customRequest(
    JSAny? request, {
    LockToken? token,
    Future<void>? abortTrigger,
  }) => _database.customRequest(
    request,
    token: token,
    abortTrigger: abortTrigger,
  );

  @override
  Future<T> requestLock<T>(
    Future<T> Function(LockToken lock) body, {
    Future<void>? abortTrigger,
  }) => _database.requestLock(body, abortTrigger: abortTrigger);

  @override
  FileSystem get fileSystem => _database.fileSystem;

  @override
  Stream<SqliteUpdate> get updates => _database.updates;

  @override
  Stream<void> get rollbacks => _database.rollbacks;

  @override
  Stream<void> get commits => _database.commits;

  @override
  Future<void> get closed => _database.closed;

  @override
  bool get isClosed => _database.isClosed;

  @override
  Future<void> dispose() => _database.dispose();

  @override
  Future<SqliteWebEndpoint> additionalConnection() =>
      _database.additionalConnection();
}
