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

abstract class DateTimeIdDefaultModel
    implements _is.TableRow<DateTime>, _is.ProtocolSerialization {
  DateTimeIdDefaultModel._({
    DateTime? id,
    required this.value,
  }) : id = id ?? DateTime.now();

  factory DateTimeIdDefaultModel({
    DateTime? id,
    required String value,
  }) = _DateTimeIdDefaultModelImpl;

  factory DateTimeIdDefaultModel.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return DateTimeIdDefaultModel(
      id: jsonSerialization['id'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['id']),
      value: jsonSerialization['value'] as String,
    );
  }

  static final t = DateTimeIdDefaultModelTable();

  static const db = DateTimeIdDefaultModelRepository._();

  @override
  DateTime id;

  String value;

  @override
  _is.Table<DateTime> get table => t;

  /// Returns a shallow copy of this [DateTimeIdDefaultModel]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  DateTimeIdDefaultModel copyWith({
    DateTime? id,
    String? value,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'DateTimeIdDefaultModel',
      'id': id.toJson(),
      'value': value,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'DateTimeIdDefaultModel',
      'id': id.toJson(),
      'value': value,
    };
  }

  static DateTimeIdDefaultModelInclude include() {
    return DateTimeIdDefaultModelInclude._();
  }

  static DateTimeIdDefaultModelIncludeList includeList({
    _is.WhereExpressionBuilder<DateTimeIdDefaultModelTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<DateTimeIdDefaultModelTable>? orderBy,
    _is.OrderByListBuilder<DateTimeIdDefaultModelTable>? orderByList,
    DateTimeIdDefaultModelInclude? include,
  }) {
    return DateTimeIdDefaultModelIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(DateTimeIdDefaultModel.t),
      orderByList: orderByList?.call(DateTimeIdDefaultModel.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _DateTimeIdDefaultModelImpl extends DateTimeIdDefaultModel {
  _DateTimeIdDefaultModelImpl({
    DateTime? id,
    required String value,
  }) : super._(
         id: id,
         value: value,
       );

  /// Returns a shallow copy of this [DateTimeIdDefaultModel]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  DateTimeIdDefaultModel copyWith({
    DateTime? id,
    String? value,
  }) {
    return DateTimeIdDefaultModel(
      id: id ?? this.id,
      value: value ?? this.value,
    );
  }
}

class DateTimeIdDefaultModelUpdateTable
    extends _is.UpdateTable<DateTimeIdDefaultModelTable> {
  DateTimeIdDefaultModelUpdateTable(super.table);

  _is.ColumnValue<String, String> value(String value) => _is.ColumnValue(
    table.value,
    value,
  );
}

class DateTimeIdDefaultModelTable extends _is.Table<DateTime> {
  DateTimeIdDefaultModelTable({super.tableRelation})
    : super(tableName: 'date_time_id_default_model') {
    updateTable = DateTimeIdDefaultModelUpdateTable(this);
    value = _is.ColumnString(
      'value',
      this,
    );
  }

  late final DateTimeIdDefaultModelUpdateTable updateTable;

  late final _is.ColumnString value;

  @override
  List<_is.Column> get columns => [
    id,
    value,
  ];
}

class DateTimeIdDefaultModelInclude extends _is.IncludeObject {
  DateTimeIdDefaultModelInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<DateTime> get table => DateTimeIdDefaultModel.t;
}

class DateTimeIdDefaultModelIncludeList extends _is.IncludeList {
  DateTimeIdDefaultModelIncludeList._({
    _is.WhereExpressionBuilder<DateTimeIdDefaultModelTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(DateTimeIdDefaultModel.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<DateTime> get table => DateTimeIdDefaultModel.t;
}

class DateTimeIdDefaultModelRepository {
  const DateTimeIdDefaultModelRepository._();

  /// Returns a list of [DateTimeIdDefaultModel]s matching the given query parameters.
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
  Future<List<DateTimeIdDefaultModel>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<DateTimeIdDefaultModelTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<DateTimeIdDefaultModelTable>? orderBy,
    _is.OrderByListBuilder<DateTimeIdDefaultModelTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<DateTimeIdDefaultModel>(
      where: where?.call(DateTimeIdDefaultModel.t),
      orderBy: orderBy?.call(DateTimeIdDefaultModel.t),
      orderByList: orderByList?.call(DateTimeIdDefaultModel.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [DateTimeIdDefaultModel]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `DateTimeIdDefaultModel.t`.
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
  _ida.Stream<List<DateTimeIdDefaultModel>> watch(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<DateTimeIdDefaultModelTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<DateTimeIdDefaultModelTable>? orderBy,
    _is.OrderByListBuilder<DateTimeIdDefaultModelTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<DateTimeIdDefaultModel>(
      where: where?.call(DateTimeIdDefaultModel.t),
      orderBy: orderBy?.call(DateTimeIdDefaultModel.t),
      orderByList: orderByList?.call(DateTimeIdDefaultModel.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [DateTimeIdDefaultModel] matching the given query parameters.
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
  Future<DateTimeIdDefaultModel?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<DateTimeIdDefaultModelTable>? where,
    int? offset,
    _is.OrderByBuilder<DateTimeIdDefaultModelTable>? orderBy,
    _is.OrderByListBuilder<DateTimeIdDefaultModelTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<DateTimeIdDefaultModel>(
      where: where?.call(DateTimeIdDefaultModel.t),
      orderBy: orderBy?.call(DateTimeIdDefaultModel.t),
      orderByList: orderByList?.call(DateTimeIdDefaultModel.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [DateTimeIdDefaultModel] by its [id] or null if no such row exists.
  Future<DateTimeIdDefaultModel?> findById(
    _is.DatabaseSession session,
    DateTime id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<DateTimeIdDefaultModel>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [DateTimeIdDefaultModel]s in the list and returns the inserted rows.
  ///
  /// The returned [DateTimeIdDefaultModel]s will have their `id` fields set.
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
  Future<List<DateTimeIdDefaultModel>> insert(
    _is.DatabaseSession session,
    List<DateTimeIdDefaultModel> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<DateTimeIdDefaultModel>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [DateTimeIdDefaultModel] and returns the inserted row.
  ///
  /// The returned [DateTimeIdDefaultModel] will have its `id` field set.
  Future<DateTimeIdDefaultModel> insertRow(
    _is.DatabaseSession session,
    DateTimeIdDefaultModel row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<DateTimeIdDefaultModel>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [DateTimeIdDefaultModel]s in the list and returns the resulting rows.
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
  /// The returned [DateTimeIdDefaultModel]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<DateTimeIdDefaultModel>> upsert(
    _is.DatabaseSession session,
    List<DateTimeIdDefaultModel> rows, {
    required _is.ColumnSelections<DateTimeIdDefaultModelTable> conflictColumns,
    _is.ColumnSelections<DateTimeIdDefaultModelTable>? updateColumns,
    _is.WhereExpressionBuilder<DateTimeIdDefaultModelTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<DateTimeIdDefaultModel>(
      rows,
      conflictColumns: conflictColumns(DateTimeIdDefaultModel.t),
      updateColumns: updateColumns?.call(DateTimeIdDefaultModel.t),
      updateWhere: updateWhere?.call(DateTimeIdDefaultModel.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [DateTimeIdDefaultModel] and returns the resulting row.
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
  /// The returned [DateTimeIdDefaultModel] will have its `id` field set.
  Future<DateTimeIdDefaultModel?> upsertRow(
    _is.DatabaseSession session,
    DateTimeIdDefaultModel row, {
    required _is.ColumnSelections<DateTimeIdDefaultModelTable> conflictColumns,
    _is.ColumnSelections<DateTimeIdDefaultModelTable>? updateColumns,
    _is.WhereExpressionBuilder<DateTimeIdDefaultModelTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<DateTimeIdDefaultModel>(
      row,
      conflictColumns: conflictColumns(DateTimeIdDefaultModel.t),
      updateColumns: updateColumns?.call(DateTimeIdDefaultModel.t),
      updateWhere: updateWhere?.call(DateTimeIdDefaultModel.t),
      transaction: transaction,
    );
  }

  /// Updates all [DateTimeIdDefaultModel]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<DateTimeIdDefaultModel>> update(
    _is.DatabaseSession session,
    List<DateTimeIdDefaultModel> rows, {
    _is.ColumnSelections<DateTimeIdDefaultModelTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<DateTimeIdDefaultModel>(
      rows,
      columns: columns?.call(DateTimeIdDefaultModel.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [DateTimeIdDefaultModel]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<DateTimeIdDefaultModel> updateRow(
    _is.DatabaseSession session,
    DateTimeIdDefaultModel row, {
    _is.ColumnSelections<DateTimeIdDefaultModelTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<DateTimeIdDefaultModel>(
      row,
      columns: columns?.call(DateTimeIdDefaultModel.t),
      transaction: transaction,
    );
  }

  /// Updates a single [DateTimeIdDefaultModel] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<DateTimeIdDefaultModel?> updateById(
    _is.DatabaseSession session,
    DateTime id, {
    required _is.ColumnValueListBuilder<DateTimeIdDefaultModelUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<DateTimeIdDefaultModel>(
      id,
      columnValues: columnValues(DateTimeIdDefaultModel.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [DateTimeIdDefaultModel]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<DateTimeIdDefaultModel>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<DateTimeIdDefaultModelUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<DateTimeIdDefaultModelTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<DateTimeIdDefaultModelTable>? orderBy,
    _is.OrderByListBuilder<DateTimeIdDefaultModelTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<DateTimeIdDefaultModel>(
      columnValues: columnValues(DateTimeIdDefaultModel.t.updateTable),
      where: where(DateTimeIdDefaultModel.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(DateTimeIdDefaultModel.t),
      orderByList: orderByList?.call(DateTimeIdDefaultModel.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [DateTimeIdDefaultModel]s in the list and returns the deleted rows.
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
  Future<List<DateTimeIdDefaultModel>> delete(
    _is.DatabaseSession session,
    List<DateTimeIdDefaultModel> rows, {
    _is.OrderByBuilder<DateTimeIdDefaultModelTable>? orderBy,
    _is.OrderByListBuilder<DateTimeIdDefaultModelTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<DateTimeIdDefaultModel>(
      rows,
      orderBy: orderBy?.call(DateTimeIdDefaultModel.t),
      orderByList: orderByList?.call(DateTimeIdDefaultModel.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [DateTimeIdDefaultModel].
  Future<DateTimeIdDefaultModel> deleteRow(
    _is.DatabaseSession session,
    DateTimeIdDefaultModel row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<DateTimeIdDefaultModel>(
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
  Future<List<DateTimeIdDefaultModel>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<DateTimeIdDefaultModelTable> where,
    _is.OrderByBuilder<DateTimeIdDefaultModelTable>? orderBy,
    _is.OrderByListBuilder<DateTimeIdDefaultModelTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<DateTimeIdDefaultModel>(
      where: where(DateTimeIdDefaultModel.t),
      orderBy: orderBy?.call(DateTimeIdDefaultModel.t),
      orderByList: orderByList?.call(DateTimeIdDefaultModel.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<DateTimeIdDefaultModelTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<DateTimeIdDefaultModel>(
      where: where?.call(DateTimeIdDefaultModel.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [DateTimeIdDefaultModel] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<DateTimeIdDefaultModelTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<DateTimeIdDefaultModel>(
      where: where(DateTimeIdDefaultModel.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
