import 'dart:js_interop';

import 'package:meta/meta.dart';
import 'package:sqlite3_web/protocol_utils.dart';

import '../sqlite_statement_batch.dart';

/// Versioned separately from sqlite_async's standard worker messages.
const sqliteBatchMessageKind = 'serverpod.orderedBatch.v1';

@internal
extension type SqliteBatchRequest(JSObject object) implements JSObject {
  external factory SqliteBatchRequest.create({
    required JSString kind,
    required JSArray<SqliteBoundStatement> statements,
    required JSBoolean requireTransaction,
  });

  factory SqliteBatchRequest.encode(
    List<SqliteBatchStatement> statements, {
    required bool requireTransaction,
  }) => SqliteBatchRequest.create(
    kind: sqliteBatchMessageKind.toJS,
    statements: statements.map(SqliteBoundStatement.encode).toList().toJS,
    requireTransaction: requireTransaction.toJS,
  );

  external JSString? get kind;
  external JSArray<SqliteBoundStatement> get statements;
  external JSBoolean get requireTransaction;
}

@internal
extension type SqliteBoundStatement(JSObject object) implements JSObject {
  external factory SqliteBoundStatement.create({
    required JSString sql,
    required JSArray parameters,
    required JSArrayBuffer types,
  });

  factory SqliteBoundStatement.encode(SqliteBatchStatement statement) {
    final (values, types) = serializeParameters(statement.parameters);
    return SqliteBoundStatement.create(
      sql: statement.sql.toJS,
      parameters: values,
      types: types,
    );
  }

  external JSString get sql;
  external JSArray get parameters;
  external JSArrayBuffer get types;
}
