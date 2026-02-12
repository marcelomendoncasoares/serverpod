import 'dart:async';

import 'package:meta/meta.dart';
import 'package:serverpod/src/database/adapters/postgres/postgres_result_parser.dart';
import 'package:serverpod/src/database/adapters/sqlite/sqlite_database_result.dart';
import 'package:serverpod/src/database/concepts/column_value.dart';
import 'package:serverpod/src/database/concepts/columns.dart';
import 'package:serverpod/src/database/concepts/database_connection.dart';
import 'package:serverpod/src/database/concepts/exceptions.dart';
import 'package:serverpod/src/database/concepts/includes.dart';
import 'package:serverpod/src/database/concepts/order.dart';
import 'package:serverpod/src/database/concepts/runtime_parameters.dart';
import 'package:serverpod/src/database/concepts/table_relation.dart';
import 'package:serverpod/src/database/concepts/transaction.dart';
import 'package:serverpod/src/database/sql_query_builder.dart';
import 'package:sqlite3/sqlite3.dart' hide Session;
import 'package:sqlparser/sqlparser.dart' show BaseSelectStatement, SqlEngine;
import 'package:sqlite_async/sqlite_async.dart';
import 'package:uuid/uuid.dart';

import '../../../server/session.dart';
import '../../concepts/expressions.dart';
import '../../concepts/table.dart';
import '../../query_parameters.dart';
import 'sqlite_pool_manager.dart';

part 'sqlite_exceptions.dart';

/// A connection to the SQLite database.
@internal
class SqliteDatabaseConnection extends DatabaseConnection<SqlitePoolManager> {
  SqliteDatabaseConnection(super.poolManager);

  static final _sqlEngine = SqlEngine();

  SqliteDatabase get _db => poolManager.database;

  @override
  Future<bool> testConnection() async {
    return poolManager.testConnection();
  }

  @override
  Future<List<T>> find<T extends TableRow>(
    Session session, {
    Expression? where,
    int? limit,
    int? offset,
    Column? orderBy,
    bool orderDescending = false,
    List<Order>? orderByList,
    Include? include,
    Transaction? transaction,
  }) async {
    var table = _getTableOrAssert<T>(session, operation: 'find');
    orderByList = _resolveOrderBy(orderByList, orderBy, orderDescending);

    var query = SelectQueryBuilder(table: table)
        .withSelectFields(table.columns)
        .withWhere(where)
        .withOrderBy(orderByList)
        .withLimit(limit)
        .withOffset(offset)
        .withInclude(include)
        .build();

    return _deserializedMappedQuery<T>(
      session,
      query,
      table: table,
      timeoutInSeconds: 60,
      transaction: transaction,
      include: include,
    );
  }

  @override
  Future<T?> findFirstRow<T extends TableRow>(
    Session session, {
    Expression? where,
    int? offset,
    Column? orderBy,
    List<Order>? orderByList,
    bool orderDescending = false,
    Transaction? transaction,
    Include? include,
  }) async {
    _getTableOrAssert<T>(session, operation: 'findRow');
    var rows = await find<T>(
      session,
      where: where,
      offset: offset,
      orderBy: orderBy,
      orderByList: orderByList,
      orderDescending: orderDescending,
      limit: 1,
      transaction: transaction,
      include: include,
    );

    if (rows.isEmpty) return null;
    return rows.first;
  }

  @override
  Future<T?> findById<T extends TableRow>(
    Session session,
    Object id, {
    Transaction? transaction,
    Include? include,
  }) async {
    var table = _getTableOrAssert<T>(session, operation: 'findById');
    return await findFirstRow<T>(
      session,
      where: table.id.equals(id),
      transaction: transaction,
      include: include,
    );
  }

  @override
  Future<List<T>> insert<T extends TableRow>(
    Session session,
    List<T> rows, {
    Transaction? transaction,
  }) async {
    if (rows.isEmpty) return [];

    var table = rows.first.table;
    var encoder = poolManager.encoder;

    Future<ResultSet> runInsert(
      List<T> filteredRows,
      bool withIdNull,
    ) async {
      var columns = withIdNull
          ? table.columns.where((c) => c.columnName != 'id').toList()
          : table.columns;
      if (columns.isEmpty && withIdNull) {
        return ResultSet([], null, []);
      }
      var columnNames = columns.map((e) => '"${e.columnName}"').join(', ');
      var valueClauses = <String>[];
      for (var row in filteredRows) {
        var rowJson = row.toJsonForDatabase() as Map<String, dynamic>;
        var values = columns
            .map((c) {
              var v = rowJson[c.columnName];
              return encoder.convert(v, hasDefaults: c.hasDefault);
            })
            .join(', ');
        valueClauses.add('($values)');
      }
      var sql =
          'INSERT INTO "${table.tableName}" ($columnNames) VALUES ${valueClauses.join(', ')} RETURNING *';
      return _runQuery(session, sql, transaction: transaction);
    }

    var withIdNull = rows.where((r) => r.id == null).toList();
    var withIdNotNull = rows.where((r) => r.id != null).toList();

    List<Map<String, dynamic>> allMaps = [];
    if (withIdNull.isNotEmpty) {
      var rs = await runInsert(withIdNull, true);
      for (var row in rs) {
        allMaps.add(Map<String, dynamic>.from(row));
      }
    }
    if (withIdNotNull.isNotEmpty) {
      var rs = await runInsert(withIdNotNull, false);
      for (var row in rs) {
        allMaps.add(Map<String, dynamic>.from(row));
      }
    }

    var merged = _mergeResultsWithNonPersistedFields(rows)(allMaps);
    return merged.map(poolManager.serializationManager.deserialize<T>).toList();
  }

  @override
  Future<T> insertRow<T extends TableRow>(
    Session session,
    T row, {
    Transaction? transaction,
  }) async {
    var result = await insert<T>(session, [row], transaction: transaction);

    if (result.length != 1) {
      throw _SqliteDatabaseInsertRowException(
        'Failed to insert row, updated number of rows is ${result.length} != 1',
      );
    }

    return result.first;
  }

  @override
  Future<List<T>> update<T extends TableRow>(
    Session session,
    List<T> rows, {
    List<Column>? columns,
    Transaction? transaction,
  }) async {
    if (rows.isEmpty) return [];
    if (rows.any((r) => r.id == null)) {
      throw ArgumentError.notNull('row.id');
    }

    var table = rows.first.table;
    var selectedColumns = (columns ?? table.managedColumns).toSet();
    if (columns != null) {
      _validateColumnsExists(selectedColumns, table.columns.toSet());
      selectedColumns.add(table.id);
    }

    var encoder = poolManager.encoder;
    var results = <Map<String, dynamic>>[];

    for (var row in rows) {
      var rowJson = row.toJsonForDatabase() as Map<String, dynamic>;
      var setParts = <String>[];
      var idValue = encoder.convert(row.id);

      for (var col in selectedColumns) {
        if (col.columnName == 'id') continue;
        var v = rowJson[col.columnName];
        setParts.add('"${col.columnName}" = ${encoder.convert(v)}');
      }

      var sql =
          'UPDATE "${table.tableName}" SET ${setParts.join(', ')} WHERE "${table.id.columnName}" = $idValue RETURNING *';
      var rs = await _runQuery(session, sql, transaction: transaction);
      if (rs.isNotEmpty) {
        results.add(Map<String, dynamic>.from(rs.first));
      }
    }

    var merged = _mergeResultsWithNonPersistedFields(rows)(results);
    return merged.map(poolManager.serializationManager.deserialize<T>).toList();
  }

  @override
  Future<T> updateRow<T extends TableRow>(
    Session session,
    T row, {
    List<Column>? columns,
    Transaction? transaction,
  }) async {
    var updated = await update<T>(
      session,
      [row],
      columns: columns,
      transaction: transaction,
    );

    if (updated.isEmpty) {
      throw _SqliteDatabaseUpdateRowException(
        'Failed to update row, no rows updated',
      );
    }

    return updated.first;
  }

  @override
  Future<T> updateById<T extends TableRow>(
    Session session,
    Object id, {
    required List<ColumnValue> columnValues,
    Transaction? transaction,
  }) async {
    var table = _getTableOrAssert<T>(session, operation: 'updateById');

    if (columnValues.isEmpty) {
      throw ArgumentError('columnValues cannot be empty');
    }

    var encoder = poolManager.encoder;
    var setClause = columnValues
        .map((cv) => '"${cv.column.columnName}" = ${encoder.convert(cv.value)}')
        .join(', ');

    var sql =
        'UPDATE "${table.tableName}" SET $setClause WHERE "${table.id.columnName}" = ${encoder.convert(id)} RETURNING *';

    var result = await _mappedResultsQuery(
      session,
      sql,
      transaction: transaction,
    );

    if (result.isEmpty) {
      throw _SqliteDatabaseUpdateRowException(
        'Failed to update row, no rows updated',
      );
    }

    return poolManager.serializationManager.deserialize<T>(result.first);
  }

  @override
  Future<List<T>> updateWhere<T extends TableRow>(
    Session session, {
    required List<ColumnValue> columnValues,
    required Expression where,
    int? limit,
    int? offset,
    Column? orderBy,
    List<Order>? orderByList,
    bool orderDescending = false,
    Transaction? transaction,
  }) async {
    var table = _getTableOrAssert<T>(session, operation: 'updateWhere');

    if (columnValues.isEmpty) {
      throw ArgumentError('columnValues cannot be empty');
    }

    var encoder = poolManager.encoder;
    var setClause = columnValues
        .map((cv) => '"${cv.column.columnName}" = ${encoder.convert(cv.value)}')
        .join(', ');

    var requiresFilteredSubquery =
        limit != null ||
        offset != null ||
        orderBy != null ||
        orderByList != null;

    String selectQuery;
    if (requiresFilteredSubquery) {
      var orders = _resolveOrderBy(orderByList, orderBy, orderDescending);
      selectQuery = SelectQueryBuilder(table: table)
          .withSelectFields([table.id])
          .withWhere(where)
          .withOrderBy(orders)
          .withLimit(limit)
          .withOffset(offset)
          .build();
    } else {
      selectQuery = SelectQueryBuilder(
        table: table,
      ).withSelectFields([table.id]).withWhere(where).build();
    }

    // SQLite: get ids to update, then UPDATE ... WHERE id IN (...)
    var idResult = await _mappedResultsQuery(
      session,
      selectQuery,
      transaction: transaction,
    );
    if (idResult.isEmpty) return [];

    var ids = idResult.map((r) => r['id']).toList();
    var idList = ids.map(encoder.convert).join(', ');
    var updateSql =
        'UPDATE "${table.tableName}" SET $setClause WHERE "${table.id.columnName}" IN ($idList) RETURNING *';

    var result = await _mappedResultsQuery(
      session,
      updateSql,
      transaction: transaction,
    );

    return result.map(poolManager.serializationManager.deserialize<T>).toList();
  }

  @override
  Future<List<T>> delete<T extends TableRow>(
    Session session,
    List<T> rows, {
    Transaction? transaction,
  }) async {
    if (rows.isEmpty) return [];
    if (rows.any((r) => r.id == null)) {
      throw ArgumentError.notNull('row.id');
    }

    var table = rows.first.table;
    return deleteWhere<T>(
      session,
      table.id.inSet(rows.map((row) => row.id!).castToIdType().toSet()),
      transaction: transaction,
    );
  }

  @override
  Future<T> deleteRow<T extends TableRow>(
    Session session,
    T row, {
    Transaction? transaction,
  }) async {
    var result = await delete<T>(session, [row], transaction: transaction);

    if (result.isEmpty) {
      throw _SqliteDatabaseDeleteRowException(
        'Failed to delete row, no rows deleted.',
      );
    }

    return result.first;
  }

  @override
  Future<List<T>> deleteWhere<T extends TableRow>(
    Session session,
    Expression where, {
    Transaction? transaction,
  }) async {
    var table = _getTableOrAssert<T>(session, operation: 'deleteWhere');

    // SQLite does not support DELETE ... USING. Use subquery to get ids first.
    var selectIds = SelectQueryBuilder(
      table: table,
    ).withSelectFields([table.id]).withWhere(where).build();
    var deleteQuery =
        'DELETE FROM "${table.tableName}" WHERE "${table.id.columnName}" IN ($selectIds) RETURNING *';

    return await _deserializedMappedQuery(
      session,
      deleteQuery,
      table: table,
      transaction: transaction,
    );
  }

  @override
  Future<int> count<T extends TableRow>(
    Session session, {
    Expression? where,
    int? limit,
    Transaction? transaction,
  }) async {
    var table = _getTableOrAssert<T>(session, operation: 'count');

    var query = CountQueryBuilder(
      table: table,
    ).withCountAlias('c').withWhere(where).withLimit(limit).build();

    var result = await _runQuery(session, query, transaction: transaction);

    if (result.isEmpty) return 0;
    if (result.length != 1) return 0;

    var firstRow = result.first;
    var val = firstRow.columnAt(0);
    if (val is int) return val;
    return 0;
  }

  @override
  Future<SqliteDatabaseResult> simpleQuery(
    Session session,
    String query, {
    int? timeoutInSeconds,
    Transaction? transaction,
  }) async {
    var result = await _runQuery(
      session,
      query,
      transaction: transaction,
    );
    return SqliteDatabaseResult(result);
  }

  @override
  Future<SqliteDatabaseResult> query(
    Session session,
    String query, {
    int? timeoutInSeconds,
    Transaction? transaction,
    QueryParameters? parameters,
  }) async {
    var (sql, params) = _convertParameters(query, parameters);
    var result = await _runQuery(
      session,
      sql,
      parameters: params,
      transaction: transaction,
    );
    return SqliteDatabaseResult(result);
  }

  @override
  Future<int> execute(
    Session session,
    String query, {
    int? timeoutInSeconds,
    Transaction? transaction,
    QueryParameters? parameters,
  }) async {
    var (sql, params) = _convertParameters(query, parameters);
    var result = await _runQuery(
      session,
      sql,
      parameters: params,
      transaction: transaction,
    );
    return result.length;
  }

  @override
  Future<int> simpleExecute(
    Session session,
    String query, {
    int? timeoutInSeconds,
    Transaction? transaction,
  }) async {
    var result = await _runQuery(
      session,
      query,
      transaction: transaction,
    );
    return result.length;
  }

  Future<ResultSet> _runQuery(
    Session session,
    String query, {
    List<Object?>? parameters,
    Transaction? transaction,
  }) async {
    parameters ??= const [];

    var sqliteTx = _castToSqliteTransaction(transaction);
    ResultSet? result;

    for (var statement in query.trim().split(';')) {
      statement = statement.trim();
      // Ignore transaction statements to avoid recursive locks.
      if (statement.isEmpty ||
          statement.startsWith('BEGIN') ||
          statement.startsWith('COMMIT')) {
        continue;
      }
      result = await _runSingleStatementQuery(
        session,
        statement,
        parameters: parameters,
        sqliteTx: sqliteTx,
      );
    }

    return result ?? ResultSet([], null, []);
  }

  Future<ResultSet> _runSingleStatementQuery(
    Session session,
    String statement, {
    List<Object?>? parameters,
    _SqliteTransaction? sqliteTx,
  }) async {
    var startTime = DateTime.now();
    parameters ??= const [];

    try {
      ResultSet? result;
      statement = statement.trim();
      if (statement.isEmpty) {
        return ResultSet([], null, []);
      }

      if (sqliteTx != null) {
        result = await sqliteTx.execute(statement, parameters);
      } else {
        if (_isSelectStatement(statement)) {
          result = await _db.getAll(statement, parameters);
        } else {
          result = await _db.execute(statement, parameters);
        }
      }

      session.serverpod.lastDatabaseOperationTime = startTime;
      _logQuery(session, statement, startTime, numRowsAffected: result.length);
      return result;
    } catch (exception, trace) {
      final serverpodException = exception is SqliteException
          ? _SqliteDatabaseQueryException.fromSqliteException(exception)
          : _SqliteDatabaseQueryException(exception.toString());
      _logQuery(
        session,
        statement,
        startTime,
        exception: serverpodException,
        trace: trace,
      );
      Error.throwWithStackTrace(serverpodException, trace);
    }
  }

  Future<Iterable<Map<String, dynamic>>> _mappedResultsQuery(
    Session session,
    String query, {
    List<Object?>? parameters,
    Transaction? transaction,
  }) async {
    var result = await _runQuery(
      session,
      query,
      parameters: parameters,
      transaction: transaction,
    );

    return result.map((row) => Map<String, dynamic>.from(row));
  }

  Future<List<T>> _deserializedMappedQuery<T extends TableRow>(
    Session session,
    String query, {
    required Table table,
    int? timeoutInSeconds,
    required Transaction? transaction,
    Include? include,
  }) async {
    var result = await _mappedResultsQuery(
      session,
      query,
      transaction: transaction,
    );

    var resolvedListRelations = await _queryIncludedLists(
      session,
      table,
      include,
      result,
      transaction,
    );

    return result
        .map(
          (rawRow) => resolvePrefixedQueryRow(
            table,
            rawRow,
            resolvedListRelations,
            include: include,
          ),
        )
        .whereType<Map<String, dynamic>>()
        .map(poolManager.serializationManager.deserialize<T>)
        .toList();
  }

  static void _logQuery(
    Session session,
    String query,
    DateTime startTime, {
    int? numRowsAffected,
    dynamic exception,
    StackTrace? trace,
  }) {
    var duration = DateTime.now().difference(startTime);
    trace ??= StackTrace.current;
    session.logManager?.logQuery(
      query: query,
      duration: duration,
      numRowsAffected: numRowsAffected,
      error: exception?.toString(),
      stackTrace: trace,
    );
  }

  @override
  Future<R> transaction<R>(
    TransactionFunction<R> transactionFunction, {
    required TransactionSettings settings,
    required Session session,
  }) {
    return _db.writeTransaction<R>((tx) async {
      var transaction = _SqliteTransaction(tx, session);
      return transactionFunction(transaction);
    });
  }

  Future<Map<String, Map<Object, List<Map<String, dynamic>>>>>
  _queryIncludedLists(
    Session session,
    Table table,
    Include? include,
    Iterable<Map<String, dynamic>> previousResultSet,
    Transaction? transaction,
  ) async {
    if (include == null) return {};

    Map<String, Map<Object, List<Map<String, dynamic>>>> resolvedListRelations =
        {};

    for (var entry in include.includes.entries) {
      var nestedInclude = entry.value;
      var relationFieldName = entry.key;

      var relativeRelationTable = table.getRelationTable(relationFieldName);
      var tableRelation = relativeRelationTable?.tableRelation;
      if (relativeRelationTable == null || tableRelation == null) {
        throw StateError('Relation table is null.');
      }

      if (nestedInclude is IncludeList) {
        var ids = _extractPrimaryKeyForRelation<Object>(
          previousResultSet,
          tableRelation,
        );

        if (ids.isEmpty) continue;

        var relationTable = nestedInclude.table;

        var orderBy = _resolveOrderBy(
          nestedInclude.orderByList,
          nestedInclude.orderBy,
          nestedInclude.orderDescending,
        );

        var query = SelectQueryBuilder(table: relationTable)
            .withSelectFields(relationTable.columns)
            .withWhere(nestedInclude.where)
            .withOrderBy(orderBy)
            .withLimit(nestedInclude.limit)
            .withOffset(nestedInclude.offset)
            .withWhereRelationInResultSet(ids, relativeRelationTable)
            .withInclude(nestedInclude.include)
            .build();

        var includeListResult = await _mappedResultsQuery(
          session,
          query,
          transaction: transaction,
        );

        var resolvedLists = await _queryIncludedLists(
          session,
          nestedInclude.table,
          nestedInclude,
          includeListResult,
          transaction,
        );

        var resolvedList = includeListResult
            .map(
              (rawRow) => resolvePrefixedQueryRow(
                relationTable,
                rawRow,
                resolvedLists,
                include: nestedInclude,
              ),
            )
            .whereType<Map<String, dynamic>>()
            .toList();

        resolvedListRelations.addAll(
          mapListToQueryById(
            resolvedList,
            relativeRelationTable,
            tableRelation.foreignFieldName,
          ),
        );
      } else {
        var resolvedNestedListRelations = await _queryIncludedLists(
          session,
          relativeRelationTable,
          nestedInclude,
          previousResultSet,
          transaction,
        );

        resolvedListRelations.addAll(resolvedNestedListRelations);
      }
    }

    return resolvedListRelations;
  }

  void _validateColumnsExists(Set<Column> columns, Set<Column> tableColumns) {
    var additionalColumns = columns.difference(tableColumns);
    if (additionalColumns.isNotEmpty) {
      throw ArgumentError.value(
        additionalColumns.toList().toString(),
        'columns',
        'Columns do not exist in table',
      );
    }
  }

  List<Order>? _resolveOrderBy(
    List<Order>? orderByList,
    Column<dynamic>? orderBy,
    bool orderDescending,
  ) {
    assert(orderByList == null || orderBy == null);
    if (orderBy != null) {
      return [Order(column: orderBy, orderDescending: orderDescending)];
    }
    return orderByList;
  }

  List<Map<String, dynamic>> Function(Iterable<Map<String, dynamic>>)
  _mergeResultsWithNonPersistedFields<T extends TableRow>(List<T> rows) {
    return (Iterable<Map<String, dynamic>> dbResults) =>
        List<Map<String, dynamic>>.generate(dbResults.length, (i) {
          return {
            ...rows[i].toJson(),
            ...dbResults.elementAt(i),
          };
        });
  }

  /// Converts Postgres-style parameters ($1, $2 or @name) to SQLite ? and list.
  (String, List<Object?>) _convertParameters(
    String query,
    QueryParameters? parameters,
  ) {
    if (parameters == null) return (query, const []);

    if (parameters is QueryParametersPositional) {
      var list = parameters.parameters;
      var sql = query;
      for (var i = 0; i < list.length; i++) {
        sql = sql.replaceFirst(RegExp(r'\$' + (i + 1).toString()), '?');
      }
      return (sql, list);
    }

    if (parameters is QueryParametersNamed) {
      var map = parameters.parameters;
      var paramNames = <String>[];
      var sql = query;
      final namePattern = RegExp(r'@(\w+)');
      for (var m in namePattern.allMatches(query)) {
        var name = m.group(1)!;
        if (!paramNames.contains(name)) paramNames.add(name);
        sql = sql.replaceFirst(m.group(0)!, '?');
      }
      var list = paramNames.map((n) => map[n]).toList();
      return (sql, list);
    }

    return (query, const []);
  }

  /// Returns true if [sql] is parsed as a SELECT (or compound SELECT) statement.
  /// Falls back to false on parse errors to avoid incorrectly using read path.
  static bool _isSelectStatement(String sql) {
    final trimmed = sql.trim();
    if (trimmed.isEmpty) return false;
    final result = _sqlEngine.parse(trimmed);
    if (result.errors.isNotEmpty) return false;
    return result.rootNode is BaseSelectStatement;
  }
}

Table _getTableOrAssert<T>(Session session, {required String operation}) {
  var table = session.serverpod.serializationManager.getTableForType(T);
  assert(table is Table, '''
You need to specify a template type that is a subclass of TableRow.
E.g. myRows = await session.db.$operation<MyTableClass>(where: ...);
Current type was $T''');
  return table!;
}

_SqliteTransaction? _castToSqliteTransaction(Transaction? transaction) {
  if (transaction == null) return null;
  if (transaction is! _SqliteTransaction) {
    throw ArgumentError.value(
      transaction,
      'transaction',
      'Transaction type does not match the required database transaction type, '
          '_SqliteTransaction. You need to create the transaction from the '
          'database by calling session.db.transaction();',
    );
  }
  return transaction;
}

class _SqliteSavepoint implements Savepoint {
  @override
  final String id;
  final _SqliteTransaction _transaction;

  _SqliteSavepoint(this.id, this._transaction);

  @override
  Future<void> release() async {
    await _transaction._execute('RELEASE SAVEPOINT $id');
  }

  @override
  Future<void> rollback() async {
    await _transaction._execute('ROLLBACK TO SAVEPOINT $id');
  }
}

class _SqliteTransaction implements Transaction {
  final SqliteWriteContext _ctx;

  @override
  final Map<String, dynamic> runtimeParameters = {};

  _SqliteTransaction(this._ctx, Session session);

  @override
  Future<void> cancel() async {
    await _ctx.execute('ROLLBACK');
  }

  Future<ResultSet> execute(
    String query, [
    List<Object?> parameters = const [],
  ]) {
    return _ctx.execute(query, parameters);
  }

  Future<void> _execute(
    String sql, [
    List<Object?> parameters = const [],
  ]) async {
    await _ctx.execute(sql, parameters);
  }

  @override
  Future<Savepoint> createSavepoint() async {
    var id = 'savepoint_${const Uuid().v4().replaceAll(RegExp(r'-'), '_')}';
    await _execute('SAVEPOINT $id');
    return _SqliteSavepoint(id, this);
  }

  @override
  Future<void> setRuntimeParameters(
    RuntimeParametersListBuilder builder,
  ) async {
    final parameters = builder(RuntimeParametersBuilder());
    for (var group in parameters) {
      for (var statement in group.buildStatements(isLocal: true)) {
        await _execute(statement);
      }
      runtimeParameters.addAll(group.options);
    }
  }
}

Set<T> _extractPrimaryKeyForRelation<T>(
  Iterable<Map<String, dynamic>> resultSet,
  TableRelation tableRelation,
) {
  var idFieldName = tableRelation.fieldQueryAliasWithJoins;
  return resultSet.map((e) => e[idFieldName] as T?).whereType<T>().toSet();
}
