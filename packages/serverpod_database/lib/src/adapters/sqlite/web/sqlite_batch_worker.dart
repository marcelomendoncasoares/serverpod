import 'dart:js_interop';

import 'package:sqlite3/wasm.dart';
import 'package:sqlite3_web/protocol_utils.dart';
import 'package:sqlite3_web/sqlite3_web.dart';
import 'package:sqlite_async/sqlite3_web_worker.dart';

import '../sqlite_statement_batch.dart';
import 'sqlite_batch_protocol.dart';

/// Keeps sqlite_async's update subscriptions and adds ordered returning batches.
final class ServerpodSqliteController extends AsyncSqliteController {
  @override
  Future<WorkerDatabase> openDatabase(
    WasmSqlite3 sqlite3,
    String path,
    String vfs,
    JSAny? additionalData,
  ) async => _ServerpodSqliteDatabase(
    database: sqlite3.open(path, vfs: vfs),
  );
}

class _ServerpodSqliteDatabase extends AsyncSqliteDatabase {
  _ServerpodSqliteDatabase({required super.database});

  @override
  Future<JSAny?> handleCustomRequest(
    ClientConnection connection,
    CustomClientDatabaseRequest request,
  ) {
    final message = SqliteBatchRequest(request.request as JSObject);
    if (message.kind?.toDart != sqliteBatchMessageKind) {
      return super.handleCustomRequest(connection, request);
    }

    return request.useLock(() {
      if (message.requireTransaction.toDart && database.autocommit) {
        throw SqliteException(
          extendedResultCode: 0,
          message: 'Transaction rolled back by earlier statement',
        );
      }

      final statements = message.statements.toDart;
      final results = runPreparedSqliteBatch(
        database,
        statements.map((statement) => statement.sql.toDart),
        (statement, index) => runStatementAndEncodeResults(
          statement,
          deserializeParameters(
            statements[index].parameters,
            statements[index].types,
          ),
        ),
      );
      return results.toJS;
    });
  }
}
