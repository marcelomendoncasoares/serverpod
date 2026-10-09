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

abstract class DateTimeIdDefaultPersist
    implements _is.TableRow<DateTime?>, _is.ProtocolSerialization {
  DateTimeIdDefaultPersist._({
    this.id,
    required this.value,
  });

  factory DateTimeIdDefaultPersist({
    DateTime? id,
    required String value,
  }) = _DateTimeIdDefaultPersistImpl;

  factory DateTimeIdDefaultPersist.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return DateTimeIdDefaultPersist(
      id: jsonSerialization['id'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['id']),
      value: jsonSerialization['value'] as String,
    );
  }

  static final t = DateTimeIdDefaultPersistTable();

  static const db = DateTimeIdDefaultPersistRepository._();

  @override
  DateTime? id;

  String value;

  @override
  _is.Table<DateTime?> get table => t;

  /// Returns a shallow copy of this [DateTimeIdDefaultPersist]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  DateTimeIdDefaultPersist copyWith({
    DateTime? id = const _is.$UndefinedDateTime(),
    String? value,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'DateTimeIdDefaultPersist',
      if (id != null) 'id': id?.toJson(),
      'value': value,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'DateTimeIdDefaultPersist',
      if (id != null) 'id': id?.toJson(),
      'value': value,
    };
  }

  static DateTimeIdDefaultPersistInclude include() {
    return DateTimeIdDefaultPersistInclude._();
  }

  static DateTimeIdDefaultPersistIncludeList includeList({
    _is.WhereExpressionBuilder<DateTimeIdDefaultPersistTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<DateTimeIdDefaultPersistTable>? orderBy,
    _is.OrderByListBuilder<DateTimeIdDefaultPersistTable>? orderByList,
    DateTimeIdDefaultPersistInclude? include,
  }) {
    return DateTimeIdDefaultPersistIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(DateTimeIdDefaultPersist.t),
      orderByList: orderByList?.call(DateTimeIdDefaultPersist.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _DateTimeIdDefaultPersistImpl extends DateTimeIdDefaultPersist {
  _DateTimeIdDefaultPersistImpl({
    DateTime? id,
    required String value,
  }) : super._(
         id: id,
         value: value,
       );

  /// Returns a shallow copy of this [DateTimeIdDefaultPersist]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  DateTimeIdDefaultPersist copyWith({
    DateTime? id = const _is.$UndefinedDateTime(),
    String? value,
  }) {
    return DateTimeIdDefaultPersist(
      id: id is _is.UndefinedSentinel ? this.id : id,
      value: value ?? this.value,
    );
  }
}

class DateTimeIdDefaultPersistUpdateTable
    extends _is.UpdateTable<DateTimeIdDefaultPersistTable> {
  DateTimeIdDefaultPersistUpdateTable(super.table);

  _is.ColumnValue<String, String> value(String value) => _is.ColumnValue(
    table.value,
    value,
  );
}

class DateTimeIdDefaultPersistTable extends _is.Table<DateTime?> {
  DateTimeIdDefaultPersistTable({super.tableRelation})
    : super(tableName: 'date_time_id_default_persist') {
    updateTable = DateTimeIdDefaultPersistUpdateTable(this);
    value = _is.ColumnString(
      'value',
      this,
    );
  }

  late final DateTimeIdDefaultPersistUpdateTable updateTable;

  late final _is.ColumnString value;

  @override
  List<_is.Column> get columns => [
    id,
    value,
  ];
}

class DateTimeIdDefaultPersistInclude extends _is.IncludeObject {
  DateTimeIdDefaultPersistInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<DateTime?> get table => DateTimeIdDefaultPersist.t;
}

class DateTimeIdDefaultPersistIncludeList extends _is.IncludeList {
  DateTimeIdDefaultPersistIncludeList._({
    _is.WhereExpressionBuilder<DateTimeIdDefaultPersistTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(DateTimeIdDefaultPersist.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<DateTime?> get table => DateTimeIdDefaultPersist.t;
}

class DateTimeIdDefaultPersistRepository {
  const DateTimeIdDefaultPersistRepository._();

  /// Returns a list of [DateTimeIdDefaultPersist]s matching the given query parameters.
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
  Future<List<DateTimeIdDefaultPersist>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<DateTimeIdDefaultPersistTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<DateTimeIdDefaultPersistTable>? orderBy,
    _is.OrderByListBuilder<DateTimeIdDefaultPersistTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<DateTimeIdDefaultPersist>(
      where: where?.call(DateTimeIdDefaultPersist.t),
      orderBy: orderBy?.call(DateTimeIdDefaultPersist.t),
      orderByList: orderByList?.call(DateTimeIdDefaultPersist.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [DateTimeIdDefaultPersist]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `DateTimeIdDefaultPersist.t`.
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
  _ida.Stream<List<DateTimeIdDefaultPersist>> watch(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<DateTimeIdDefaultPersistTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<DateTimeIdDefaultPersistTable>? orderBy,
    _is.OrderByListBuilder<DateTimeIdDefaultPersistTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<DateTimeIdDefaultPersist>(
      where: where?.call(DateTimeIdDefaultPersist.t),
      orderBy: orderBy?.call(DateTimeIdDefaultPersist.t),
      orderByList: orderByList?.call(DateTimeIdDefaultPersist.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [DateTimeIdDefaultPersist] matching the given query parameters.
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
  Future<DateTimeIdDefaultPersist?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<DateTimeIdDefaultPersistTable>? where,
    int? offset,
    _is.OrderByBuilder<DateTimeIdDefaultPersistTable>? orderBy,
    _is.OrderByListBuilder<DateTimeIdDefaultPersistTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<DateTimeIdDefaultPersist>(
      where: where?.call(DateTimeIdDefaultPersist.t),
      orderBy: orderBy?.call(DateTimeIdDefaultPersist.t),
      orderByList: orderByList?.call(DateTimeIdDefaultPersist.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [DateTimeIdDefaultPersist] by its [id] or null if no such row exists.
  Future<DateTimeIdDefaultPersist?> findById(
    _is.DatabaseSession session,
    DateTime id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<DateTimeIdDefaultPersist>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [DateTimeIdDefaultPersist]s in the list and returns the inserted rows.
  ///
  /// The returned [DateTimeIdDefaultPersist]s will have their `id` fields set.
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
  Future<List<DateTimeIdDefaultPersist>> insert(
    _is.DatabaseSession session,
    List<DateTimeIdDefaultPersist> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<DateTimeIdDefaultPersist>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [DateTimeIdDefaultPersist] and returns the inserted row.
  ///
  /// The returned [DateTimeIdDefaultPersist] will have its `id` field set.
  Future<DateTimeIdDefaultPersist> insertRow(
    _is.DatabaseSession session,
    DateTimeIdDefaultPersist row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<DateTimeIdDefaultPersist>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [DateTimeIdDefaultPersist]s in the list and returns the resulting rows.
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
  /// The returned [DateTimeIdDefaultPersist]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<DateTimeIdDefaultPersist>> upsert(
    _is.DatabaseSession session,
    List<DateTimeIdDefaultPersist> rows, {
    required _is.ColumnSelections<DateTimeIdDefaultPersistTable>
    conflictColumns,
    _is.ColumnSelections<DateTimeIdDefaultPersistTable>? updateColumns,
    _is.WhereExpressionBuilder<DateTimeIdDefaultPersistTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<DateTimeIdDefaultPersist>(
      rows,
      conflictColumns: conflictColumns(DateTimeIdDefaultPersist.t),
      updateColumns: updateColumns?.call(DateTimeIdDefaultPersist.t),
      updateWhere: updateWhere?.call(DateTimeIdDefaultPersist.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [DateTimeIdDefaultPersist] and returns the resulting row.
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
  /// The returned [DateTimeIdDefaultPersist] will have its `id` field set.
  Future<DateTimeIdDefaultPersist?> upsertRow(
    _is.DatabaseSession session,
    DateTimeIdDefaultPersist row, {
    required _is.ColumnSelections<DateTimeIdDefaultPersistTable>
    conflictColumns,
    _is.ColumnSelections<DateTimeIdDefaultPersistTable>? updateColumns,
    _is.WhereExpressionBuilder<DateTimeIdDefaultPersistTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<DateTimeIdDefaultPersist>(
      row,
      conflictColumns: conflictColumns(DateTimeIdDefaultPersist.t),
      updateColumns: updateColumns?.call(DateTimeIdDefaultPersist.t),
      updateWhere: updateWhere?.call(DateTimeIdDefaultPersist.t),
      transaction: transaction,
    );
  }

  /// Updates all [DateTimeIdDefaultPersist]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<DateTimeIdDefaultPersist>> update(
    _is.DatabaseSession session,
    List<DateTimeIdDefaultPersist> rows, {
    _is.ColumnSelections<DateTimeIdDefaultPersistTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<DateTimeIdDefaultPersist>(
      rows,
      columns: columns?.call(DateTimeIdDefaultPersist.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [DateTimeIdDefaultPersist]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<DateTimeIdDefaultPersist> updateRow(
    _is.DatabaseSession session,
    DateTimeIdDefaultPersist row, {
    _is.ColumnSelections<DateTimeIdDefaultPersistTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<DateTimeIdDefaultPersist>(
      row,
      columns: columns?.call(DateTimeIdDefaultPersist.t),
      transaction: transaction,
    );
  }

  /// Updates a single [DateTimeIdDefaultPersist] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<DateTimeIdDefaultPersist?> updateById(
    _is.DatabaseSession session,
    DateTime id, {
    required _is.ColumnValueListBuilder<DateTimeIdDefaultPersistUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<DateTimeIdDefaultPersist>(
      id,
      columnValues: columnValues(DateTimeIdDefaultPersist.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [DateTimeIdDefaultPersist]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<DateTimeIdDefaultPersist>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<DateTimeIdDefaultPersistUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<DateTimeIdDefaultPersistTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<DateTimeIdDefaultPersistTable>? orderBy,
    _is.OrderByListBuilder<DateTimeIdDefaultPersistTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<DateTimeIdDefaultPersist>(
      columnValues: columnValues(DateTimeIdDefaultPersist.t.updateTable),
      where: where(DateTimeIdDefaultPersist.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(DateTimeIdDefaultPersist.t),
      orderByList: orderByList?.call(DateTimeIdDefaultPersist.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [DateTimeIdDefaultPersist]s in the list and returns the deleted rows.
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
  Future<List<DateTimeIdDefaultPersist>> delete(
    _is.DatabaseSession session,
    List<DateTimeIdDefaultPersist> rows, {
    _is.OrderByBuilder<DateTimeIdDefaultPersistTable>? orderBy,
    _is.OrderByListBuilder<DateTimeIdDefaultPersistTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<DateTimeIdDefaultPersist>(
      rows,
      orderBy: orderBy?.call(DateTimeIdDefaultPersist.t),
      orderByList: orderByList?.call(DateTimeIdDefaultPersist.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [DateTimeIdDefaultPersist].
  Future<DateTimeIdDefaultPersist> deleteRow(
    _is.DatabaseSession session,
    DateTimeIdDefaultPersist row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<DateTimeIdDefaultPersist>(
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
  Future<List<DateTimeIdDefaultPersist>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<DateTimeIdDefaultPersistTable> where,
    _is.OrderByBuilder<DateTimeIdDefaultPersistTable>? orderBy,
    _is.OrderByListBuilder<DateTimeIdDefaultPersistTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<DateTimeIdDefaultPersist>(
      where: where(DateTimeIdDefaultPersist.t),
      orderBy: orderBy?.call(DateTimeIdDefaultPersist.t),
      orderByList: orderByList?.call(DateTimeIdDefaultPersist.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<DateTimeIdDefaultPersistTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<DateTimeIdDefaultPersist>(
      where: where?.call(DateTimeIdDefaultPersist.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [DateTimeIdDefaultPersist] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<DateTimeIdDefaultPersistTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<DateTimeIdDefaultPersist>(
      where: where(DateTimeIdDefaultPersist.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
