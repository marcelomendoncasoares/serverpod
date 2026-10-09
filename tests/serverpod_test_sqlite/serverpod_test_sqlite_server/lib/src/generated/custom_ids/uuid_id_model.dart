/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _ida;
import 'package:serverpod/serverpod.dart' as _is;

abstract class UuidIdModel
    implements _is.TableRow<_is.UuidValue>, _is.ProtocolSerialization {
  UuidIdModel._({
    required this.id,
    required this.value,
  });

  factory UuidIdModel({
    required _is.UuidValue id,
    required String value,
  }) = _UuidIdModelImpl;

  factory UuidIdModel.fromJson(Map<String, dynamic> jsonSerialization) {
    return UuidIdModel(
      id: _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      value: jsonSerialization['value'] as String,
    );
  }

  static final t = UuidIdModelTable();

  static const db = UuidIdModelRepository._();

  @override
  _is.UuidValue id;

  String value;

  @override
  _is.Table<_is.UuidValue> get table => t;

  /// Returns a shallow copy of this [UuidIdModel]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  UuidIdModel copyWith({
    _is.UuidValue? id,
    String? value,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'UuidIdModel',
      'id': id.toJson(),
      'value': value,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'UuidIdModel',
      'id': id.toJson(),
      'value': value,
    };
  }

  static UuidIdModelInclude include() {
    return UuidIdModelInclude._();
  }

  static UuidIdModelIncludeList includeList({
    _is.WhereExpressionBuilder<UuidIdModelTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<UuidIdModelTable>? orderBy,
    _is.OrderByListBuilder<UuidIdModelTable>? orderByList,
    UuidIdModelInclude? include,
  }) {
    return UuidIdModelIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(UuidIdModel.t),
      orderByList: orderByList?.call(UuidIdModel.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _UuidIdModelImpl extends UuidIdModel {
  _UuidIdModelImpl({
    required _is.UuidValue id,
    required String value,
  }) : super._(
         id: id,
         value: value,
       );

  /// Returns a shallow copy of this [UuidIdModel]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  UuidIdModel copyWith({
    _is.UuidValue? id,
    String? value,
  }) {
    return UuidIdModel(
      id: id ?? this.id,
      value: value ?? this.value,
    );
  }
}

class UuidIdModelUpdateTable extends _is.UpdateTable<UuidIdModelTable> {
  UuidIdModelUpdateTable(super.table);

  _is.ColumnValue<String, String> value(String value) => _is.ColumnValue(
    table.value,
    value,
  );
}

class UuidIdModelTable extends _is.Table<_is.UuidValue> {
  UuidIdModelTable({super.tableRelation})
    : super(
        tableName: 'uuid_id_model',
        idHasDefault: false,
      ) {
    updateTable = UuidIdModelUpdateTable(this);
    value = _is.ColumnString(
      'value',
      this,
    );
  }

  late final UuidIdModelUpdateTable updateTable;

  late final _is.ColumnString value;

  @override
  List<_is.Column> get columns => [
    id,
    value,
  ];
}

class UuidIdModelInclude extends _is.IncludeObject {
  UuidIdModelInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue> get table => UuidIdModel.t;
}

class UuidIdModelIncludeList extends _is.IncludeList {
  UuidIdModelIncludeList._({
    _is.WhereExpressionBuilder<UuidIdModelTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(UuidIdModel.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue> get table => UuidIdModel.t;
}

class UuidIdModelRepository {
  const UuidIdModelRepository._();

  /// Returns a list of [UuidIdModel]s matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order of the items use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// The maximum number of items can be set by [limit]. If no limit is set,
  /// all items matching the query will be returned.
  ///
  /// [offset] defines how many items to skip, after which [limit] (or all)
  /// items are read from the database.
  ///
  /// ```dart
  /// var persons = await Persons.db.find(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.firstName,
  ///   limit: 100,
  /// );
  /// ```
  Future<List<UuidIdModel>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<UuidIdModelTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<UuidIdModelTable>? orderBy,
    _is.OrderByListBuilder<UuidIdModelTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<UuidIdModel>(
      where: where?.call(UuidIdModel.t),
      orderBy: orderBy?.call(UuidIdModel.t),
      orderByList: orderByList?.call(UuidIdModel.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [UuidIdModel]s matching the given query parameters every time the
  /// source tables are modified.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order of the items use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// The maximum number of items can be set by [limit]. If no limit is set,
  /// all items matching the query will be returned.
  ///
  /// [offset] defines how many items to skip, after which [limit] (or all)
  /// items are read from the database.
  ///
  /// Use [throttle] to specify the minimum interval between queries. It can
  /// also be set to `null`, in which case the stream will only be throttled
  /// when its subscription is paused.
  ///
  /// Source tables are collected from the queried table, [where], [orderBy],
  /// [orderByList], and the [include] graph. [alsoTriggerOnTables] is added
  /// to that set. Pass [Table] instances such as `UuidIdModel.t`.
  ///
  /// Raw [Expression] SQL is not inspected. Tables referenced only in raw
  /// SQL must be passed via [alsoTriggerOnTables].
  ///
  /// The stream always reads committed state and never joins an ambient
  /// [Transaction]. Emissions for a write fire after that write commits.
  ///
  /// Currently only supported on SQLite. Calling this method on PostgreSQL
  /// throws an [UnsupportedError].
  ///
  /// ```dart
  /// var subscription = Persons.db.watch(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.firstName,
  ///   limit: 100,
  /// ).listen((persons) {
  ///   // Handle the latest matching rows.
  /// });
  /// ```
  _ida.Stream<List<UuidIdModel>> watch(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<UuidIdModelTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<UuidIdModelTable>? orderBy,
    _is.OrderByListBuilder<UuidIdModelTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<UuidIdModel>(
      where: where?.call(UuidIdModel.t),
      orderBy: orderBy?.call(UuidIdModel.t),
      orderByList: orderByList?.call(UuidIdModel.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [UuidIdModel] matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// [offset] defines how many items to skip, after which the next one will be picked.
  ///
  /// ```dart
  /// var youngestPerson = await Persons.db.findFirstRow(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.age,
  /// );
  /// ```
  Future<UuidIdModel?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<UuidIdModelTable>? where,
    int? offset,
    _is.OrderByBuilder<UuidIdModelTable>? orderBy,
    _is.OrderByListBuilder<UuidIdModelTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<UuidIdModel>(
      where: where?.call(UuidIdModel.t),
      orderBy: orderBy?.call(UuidIdModel.t),
      orderByList: orderByList?.call(UuidIdModel.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [UuidIdModel] by its [id] or null if no such row exists.
  Future<UuidIdModel?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<UuidIdModel>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [UuidIdModel]s in the list and returns the inserted rows.
  ///
  /// The returned [UuidIdModel]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  ///
  /// If [noReturn] is set to `true`, the inserted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<UuidIdModel>> insert(
    _is.DatabaseSession session,
    List<UuidIdModel> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<UuidIdModel>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [UuidIdModel] and returns the inserted row.
  ///
  /// The returned [UuidIdModel] will have its `id` field set.
  Future<UuidIdModel> insertRow(
    _is.DatabaseSession session,
    UuidIdModel row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<UuidIdModel>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [UuidIdModel]s in the list and returns the resulting rows.
  ///
  /// If a row conflicts on the given [conflictColumns], the existing row is
  /// updated with the new values. Otherwise, a new row is inserted.
  ///
  /// If [updateColumns] is provided, only those columns will be updated on
  /// conflict. If null, all non-conflict, non-id columns are updated.
  ///
  /// If [updateWhere] is provided, the update only applies to rows matching the
  /// given expression. Conflicting rows that don't match are skipped and not
  /// returned, so the resulting list may be shorter than [rows].
  ///
  /// The returned [UuidIdModel]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<UuidIdModel>> upsert(
    _is.DatabaseSession session,
    List<UuidIdModel> rows, {
    required _is.ColumnSelections<UuidIdModelTable> conflictColumns,
    _is.ColumnSelections<UuidIdModelTable>? updateColumns,
    _is.WhereExpressionBuilder<UuidIdModelTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<UuidIdModel>(
      rows,
      conflictColumns: conflictColumns(UuidIdModel.t),
      updateColumns: updateColumns?.call(UuidIdModel.t),
      updateWhere: updateWhere?.call(UuidIdModel.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [UuidIdModel] and returns the resulting row.
  ///
  /// If the row conflicts on the given [conflictColumns], the existing row is
  /// updated. Otherwise, a new row is inserted.
  ///
  /// If [updateColumns] is provided, only those columns will be updated on
  /// conflict. If null, all non-conflict, non-id columns are updated.
  ///
  /// If [updateWhere] is provided, the update only applies when the existing
  /// row matches the expression. Returns `null` if no row was affected — for
  /// example when [updateWhere] does not match the conflicting row.
  ///
  /// The returned [UuidIdModel] will have its `id` field set.
  Future<UuidIdModel?> upsertRow(
    _is.DatabaseSession session,
    UuidIdModel row, {
    required _is.ColumnSelections<UuidIdModelTable> conflictColumns,
    _is.ColumnSelections<UuidIdModelTable>? updateColumns,
    _is.WhereExpressionBuilder<UuidIdModelTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<UuidIdModel>(
      row,
      conflictColumns: conflictColumns(UuidIdModel.t),
      updateColumns: updateColumns?.call(UuidIdModel.t),
      updateWhere: updateWhere?.call(UuidIdModel.t),
      transaction: transaction,
    );
  }

  /// Updates all [UuidIdModel]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<UuidIdModel>> update(
    _is.DatabaseSession session,
    List<UuidIdModel> rows, {
    _is.ColumnSelections<UuidIdModelTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<UuidIdModel>(
      rows,
      columns: columns?.call(UuidIdModel.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [UuidIdModel]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<UuidIdModel> updateRow(
    _is.DatabaseSession session,
    UuidIdModel row, {
    _is.ColumnSelections<UuidIdModelTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<UuidIdModel>(
      row,
      columns: columns?.call(UuidIdModel.t),
      transaction: transaction,
    );
  }

  /// Updates a single [UuidIdModel] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<UuidIdModel?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<UuidIdModelUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<UuidIdModel>(
      id,
      columnValues: columnValues(UuidIdModel.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [UuidIdModel]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<UuidIdModel>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<UuidIdModelUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<UuidIdModelTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<UuidIdModelTable>? orderBy,
    _is.OrderByListBuilder<UuidIdModelTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<UuidIdModel>(
      columnValues: columnValues(UuidIdModel.t.updateTable),
      where: where(UuidIdModel.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(UuidIdModel.t),
      orderByList: orderByList?.call(UuidIdModel.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [UuidIdModel]s in the list and returns the deleted rows.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  ///
  /// If [noReturn] is set to `true`, the deleted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<UuidIdModel>> delete(
    _is.DatabaseSession session,
    List<UuidIdModel> rows, {
    _is.OrderByBuilder<UuidIdModelTable>? orderBy,
    _is.OrderByListBuilder<UuidIdModelTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<UuidIdModel>(
      rows,
      orderBy: orderBy?.call(UuidIdModel.t),
      orderByList: orderByList?.call(UuidIdModel.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [UuidIdModel].
  Future<UuidIdModel> deleteRow(
    _is.DatabaseSession session,
    UuidIdModel row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<UuidIdModel>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// If [noReturn] is set to `true`, the deleted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<UuidIdModel>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<UuidIdModelTable> where,
    _is.OrderByBuilder<UuidIdModelTable>? orderBy,
    _is.OrderByListBuilder<UuidIdModelTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<UuidIdModel>(
      where: where(UuidIdModel.t),
      orderBy: orderBy?.call(UuidIdModel.t),
      orderByList: orderByList?.call(UuidIdModel.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<UuidIdModelTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<UuidIdModel>(
      where: where?.call(UuidIdModel.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [UuidIdModel] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<UuidIdModelTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<UuidIdModel>(
      where: where(UuidIdModel.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
