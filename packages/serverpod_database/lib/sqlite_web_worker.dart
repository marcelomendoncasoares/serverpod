/// Serverpod's SQLite browser worker, including ordered returning writes.
///
/// Build with `dart run serverpod_database:build_sqlite_web_worker` and serve
/// the output as `serverpod_db_worker.js`
/// beside the SQLite WASM asset. See the package README for setup commands.
library;

import 'package:sqlite3_web/sqlite3_web.dart';

import 'src/adapters/sqlite/web/sqlite_batch_worker.dart';

void main() {
  WebSqlite.workerEntrypoint(controller: ServerpodSqliteController());
}
