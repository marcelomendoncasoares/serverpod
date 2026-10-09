/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member
// ignore_for_file: dead_code, unnecessary_null_comparison

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _ida;
import 'package:serverpod/serverpod.dart' as _is;
import 'package:serverpod_test_sqlite_server/src/generated/protocol.dart'
    as _i08l111i;
import '../custom_ids/custom_id_related.dart' as _i2m035mh;

abstract class DateTimeIdModel
    implements _is.TableRow<DateTime>, _is.ProtocolSerialization {
  DateTimeIdModel._({
    required this.id,
    required this.value,
    this.related,
  });

  factory DateTimeIdModel({
    required DateTime id,
    required String value,
    List<_i2m035mh.CustomIdRelated>? related,
  }) = _DateTimeIdModelImpl;

  factory DateTimeIdModel.fromJson(Map<String, dynamic> jsonSerialization) {
    return DateTimeIdModel(
      id: _is.DateTimeJsonExtension.fromJson(jsonSerialization['id']),
      value: jsonSerialization['value'] as String,
      related: jsonSerialization['related'] == null
          ? null
          : _i08l111i.Protocol().deserialize<List<_i2m035mh.CustomIdRelated>>(
              jsonSerialization['related'],
            ),
    );
  }

  static final t = DateTimeIdModelTable();

  static const db = DateTimeIdModelRepository._();

  @override
  DateTime id;

  String value;

  List<_i2m035mh.CustomIdRelated>? related;

  @override
  _is.Table<DateTime> get table => t;

  /// Returns a shallow copy of this [DateTimeIdModel]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  DateTimeIdModel copyWith({
    DateTime? id,
    String? value,
    List<_i2m035mh.CustomIdRelated>? related =
        const _is.$UndefinedList<_i2m035mh.CustomIdRelated>(),
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'DateTimeIdModel',
      'id': id.toJson(),
      'value': value,
      if (related != null)
        'related': related?.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'DateTimeIdModel',
      'id': id.toJson(),
      'value': value,
      if (related != null)
        'related': related?.toJson(valueToJson: (v) => v.toJsonForProtocol()),
    };
  }

  static DateTimeIdModelInclude include({
    _i2m035mh.CustomIdRelatedIncludeList? related,
  }) {
    return DateTimeIdModelInclude._(related: related);
  }

  static DateTimeIdModelIncludeList includeList({
    _is.WhereExpressionBuilder<DateTimeIdModelTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<DateTimeIdModelTable>? orderBy,
    _is.OrderByListBuilder<DateTimeIdModelTable>? orderByList,
    DateTimeIdModelInclude? include,
  }) {
    return DateTimeIdModelIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(DateTimeIdModel.t),
      orderByList: orderByList?.call(DateTimeIdModel.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _DateTimeIdModelImpl extends DateTimeIdModel {
  _DateTimeIdModelImpl({
    required DateTime id,
    required String value,
    List<_i2m035mh.CustomIdRelated>? related,
  }) : super._(
         id: id,
         value: value,
         related: related,
       );

  /// Returns a shallow copy of this [DateTimeIdModel]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  DateTimeIdModel copyWith({
    DateTime? id,
    String? value,
    List<_i2m035mh.CustomIdRelated>? related =
        const _is.$UndefinedList<_i2m035mh.CustomIdRelated>(),
  }) {
    return DateTimeIdModel(
      id: id ?? this.id,
      value: value ?? this.value,
      related: related is _is.UndefinedSentinel
          ? this.related?.map((e0) => e0.copyWith()).toList()
          : related,
    );
  }
}

class DateTimeIdModelUpdateTable extends _is.UpdateTable<DateTimeIdModelTable> {
  DateTimeIdModelUpdateTable(super.table);

  _is.ColumnValue<String, String> value(String value) => _is.ColumnValue(
    table.value,
    value,
  );
}

class DateTimeIdModelTable extends _is.Table<DateTime> {
  DateTimeIdModelTable({super.tableRelation})
    : super(
        tableName: 'date_time_id_model',
        idHasDefault: false,
      ) {
    updateTable = DateTimeIdModelUpdateTable(this);
    value = _is.ColumnString(
      'value',
      this,
    );
  }

  late final DateTimeIdModelUpdateTable updateTable;

  late final _is.ColumnString value;

  _i2m035mh.CustomIdRelatedTable? ___related;

  _is.ManyRelation<_i2m035mh.CustomIdRelatedTable>? _related;

  _i2m035mh.CustomIdRelatedTable get __related {
    if (___related != null) return ___related!;
    ___related = _is.createRelationTable(
      relationFieldName: '__related',
      field: DateTimeIdModel.t.id,
      foreignField: _i2m035mh.CustomIdRelated.t.dateTimeId,
      tableRelation: tableRelation,
      createTable: (foreignTableRelation) =>
          _i2m035mh.CustomIdRelatedTable(tableRelation: foreignTableRelation),
    );
    return ___related!;
  }

  _is.ManyRelation<_i2m035mh.CustomIdRelatedTable> get related {
    if (_related != null) return _related!;
    var relationTable = _is.createRelationTable(
      relationFieldName: 'related',
      field: DateTimeIdModel.t.id,
      foreignField: _i2m035mh.CustomIdRelated.t.dateTimeId,
      tableRelation: tableRelation,
      createTable: (foreignTableRelation) =>
          _i2m035mh.CustomIdRelatedTable(tableRelation: foreignTableRelation),
    );
    _related = _is.ManyRelation<_i2m035mh.CustomIdRelatedTable>(
      tableWithRelations: relationTable,
      table: _i2m035mh.CustomIdRelatedTable(
        tableRelation: relationTable.tableRelation!.lastRelation,
      ),
    );
    return _related!;
  }

  @override
  List<_is.Column> get columns => [
    id,
    value,
  ];

  @override
  _is.Table? getRelationTable(String relationField) {
    if (relationField == 'related') {
      return __related;
    }
    return null;
  }
}

class DateTimeIdModelInclude extends _is.IncludeObject {
  DateTimeIdModelInclude._({_i2m035mh.CustomIdRelatedIncludeList? related}) {
    _related = related;
  }

  _i2m035mh.CustomIdRelatedIncludeList? _related;

  @override
  Map<String, _is.Include?> get includes => {'related': _related};

  @override
  _is.Table<DateTime> get table => DateTimeIdModel.t;
}

class DateTimeIdModelIncludeList extends _is.IncludeList {
  DateTimeIdModelIncludeList._({
    _is.WhereExpressionBuilder<DateTimeIdModelTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(DateTimeIdModel.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<DateTime> get table => DateTimeIdModel.t;
}

class DateTimeIdModelRepository {
  const DateTimeIdModelRepository._();

  final attach = const DateTimeIdModelAttachRepository._();

  final attachRow = const DateTimeIdModelAttachRowRepository._();

  /// Returns a list of [DateTimeIdModel]s matching the given query parameters.
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
  Future<List<DateTimeIdModel>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<DateTimeIdModelTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<DateTimeIdModelTable>? orderBy,
    _is.OrderByListBuilder<DateTimeIdModelTable>? orderByList,
    _is.Transaction? transaction,
    DateTimeIdModelInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<DateTimeIdModel>(
      where: where?.call(DateTimeIdModel.t),
      orderBy: orderBy?.call(DateTimeIdModel.t),
      orderByList: orderByList?.call(DateTimeIdModel.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [DateTimeIdModel]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `DateTimeIdModel.t`.
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
  _ida.Stream<List<DateTimeIdModel>> watch(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<DateTimeIdModelTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<DateTimeIdModelTable>? orderBy,
    _is.OrderByListBuilder<DateTimeIdModelTable>? orderByList,
    DateTimeIdModelInclude? include,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<DateTimeIdModel>(
      where: where?.call(DateTimeIdModel.t),
      orderBy: orderBy?.call(DateTimeIdModel.t),
      orderByList: orderByList?.call(DateTimeIdModel.t),
      limit: limit,
      offset: offset,
      include: include,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [DateTimeIdModel] matching the given query parameters.
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
  Future<DateTimeIdModel?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<DateTimeIdModelTable>? where,
    int? offset,
    _is.OrderByBuilder<DateTimeIdModelTable>? orderBy,
    _is.OrderByListBuilder<DateTimeIdModelTable>? orderByList,
    _is.Transaction? transaction,
    DateTimeIdModelInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<DateTimeIdModel>(
      where: where?.call(DateTimeIdModel.t),
      orderBy: orderBy?.call(DateTimeIdModel.t),
      orderByList: orderByList?.call(DateTimeIdModel.t),
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [DateTimeIdModel] by its [id] or null if no such row exists.
  Future<DateTimeIdModel?> findById(
    _is.DatabaseSession session,
    DateTime id, {
    _is.Transaction? transaction,
    DateTimeIdModelInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<DateTimeIdModel>(
      id,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [DateTimeIdModel]s in the list and returns the inserted rows.
  ///
  /// The returned [DateTimeIdModel]s will have their `id` fields set.
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
  Future<List<DateTimeIdModel>> insert(
    _is.DatabaseSession session,
    List<DateTimeIdModel> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<DateTimeIdModel>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [DateTimeIdModel] and returns the inserted row.
  ///
  /// The returned [DateTimeIdModel] will have its `id` field set.
  Future<DateTimeIdModel> insertRow(
    _is.DatabaseSession session,
    DateTimeIdModel row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<DateTimeIdModel>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [DateTimeIdModel]s in the list and returns the resulting rows.
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
  /// The returned [DateTimeIdModel]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<DateTimeIdModel>> upsert(
    _is.DatabaseSession session,
    List<DateTimeIdModel> rows, {
    required _is.ColumnSelections<DateTimeIdModelTable> conflictColumns,
    _is.ColumnSelections<DateTimeIdModelTable>? updateColumns,
    _is.WhereExpressionBuilder<DateTimeIdModelTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<DateTimeIdModel>(
      rows,
      conflictColumns: conflictColumns(DateTimeIdModel.t),
      updateColumns: updateColumns?.call(DateTimeIdModel.t),
      updateWhere: updateWhere?.call(DateTimeIdModel.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [DateTimeIdModel] and returns the resulting row.
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
  /// The returned [DateTimeIdModel] will have its `id` field set.
  Future<DateTimeIdModel?> upsertRow(
    _is.DatabaseSession session,
    DateTimeIdModel row, {
    required _is.ColumnSelections<DateTimeIdModelTable> conflictColumns,
    _is.ColumnSelections<DateTimeIdModelTable>? updateColumns,
    _is.WhereExpressionBuilder<DateTimeIdModelTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<DateTimeIdModel>(
      row,
      conflictColumns: conflictColumns(DateTimeIdModel.t),
      updateColumns: updateColumns?.call(DateTimeIdModel.t),
      updateWhere: updateWhere?.call(DateTimeIdModel.t),
      transaction: transaction,
    );
  }

  /// Updates all [DateTimeIdModel]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<DateTimeIdModel>> update(
    _is.DatabaseSession session,
    List<DateTimeIdModel> rows, {
    _is.ColumnSelections<DateTimeIdModelTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<DateTimeIdModel>(
      rows,
      columns: columns?.call(DateTimeIdModel.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [DateTimeIdModel]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<DateTimeIdModel> updateRow(
    _is.DatabaseSession session,
    DateTimeIdModel row, {
    _is.ColumnSelections<DateTimeIdModelTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<DateTimeIdModel>(
      row,
      columns: columns?.call(DateTimeIdModel.t),
      transaction: transaction,
    );
  }

  /// Updates a single [DateTimeIdModel] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<DateTimeIdModel?> updateById(
    _is.DatabaseSession session,
    DateTime id, {
    required _is.ColumnValueListBuilder<DateTimeIdModelUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<DateTimeIdModel>(
      id,
      columnValues: columnValues(DateTimeIdModel.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [DateTimeIdModel]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<DateTimeIdModel>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<DateTimeIdModelUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<DateTimeIdModelTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<DateTimeIdModelTable>? orderBy,
    _is.OrderByListBuilder<DateTimeIdModelTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<DateTimeIdModel>(
      columnValues: columnValues(DateTimeIdModel.t.updateTable),
      where: where(DateTimeIdModel.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(DateTimeIdModel.t),
      orderByList: orderByList?.call(DateTimeIdModel.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [DateTimeIdModel]s in the list and returns the deleted rows.
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
  Future<List<DateTimeIdModel>> delete(
    _is.DatabaseSession session,
    List<DateTimeIdModel> rows, {
    _is.OrderByBuilder<DateTimeIdModelTable>? orderBy,
    _is.OrderByListBuilder<DateTimeIdModelTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<DateTimeIdModel>(
      rows,
      orderBy: orderBy?.call(DateTimeIdModel.t),
      orderByList: orderByList?.call(DateTimeIdModel.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [DateTimeIdModel].
  Future<DateTimeIdModel> deleteRow(
    _is.DatabaseSession session,
    DateTimeIdModel row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<DateTimeIdModel>(
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
  Future<List<DateTimeIdModel>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<DateTimeIdModelTable> where,
    _is.OrderByBuilder<DateTimeIdModelTable>? orderBy,
    _is.OrderByListBuilder<DateTimeIdModelTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<DateTimeIdModel>(
      where: where(DateTimeIdModel.t),
      orderBy: orderBy?.call(DateTimeIdModel.t),
      orderByList: orderByList?.call(DateTimeIdModel.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<DateTimeIdModelTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<DateTimeIdModel>(
      where: where?.call(DateTimeIdModel.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [DateTimeIdModel] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<DateTimeIdModelTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<DateTimeIdModel>(
      where: where(DateTimeIdModel.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}

class DateTimeIdModelAttachRepository {
  const DateTimeIdModelAttachRepository._();

  /// Creates a relation between this [DateTimeIdModel] and the given [CustomIdRelated]s
  /// by setting each [CustomIdRelated]'s foreign key `dateTimeId` to refer to this [DateTimeIdModel].
  Future<void> related(
    _is.DatabaseSession session,
    DateTimeIdModel dateTimeIdModel,
    List<_i2m035mh.CustomIdRelated> customIdRelated, {
    _is.Transaction? transaction,
  }) async {
    if (customIdRelated.any((e) => e.id == null)) {
      throw ArgumentError.notNull('customIdRelated.id');
    }
    if (dateTimeIdModel.id == null) {
      throw ArgumentError.notNull('dateTimeIdModel.id');
    }

    var $customIdRelated = customIdRelated
        .map((e) => e.copyWith(dateTimeId: dateTimeIdModel.id))
        .toList();
    await session.db.update<_i2m035mh.CustomIdRelated>(
      $customIdRelated,
      columns: [_i2m035mh.CustomIdRelated.t.dateTimeId],
      transaction: transaction,
    );
  }
}

class DateTimeIdModelAttachRowRepository {
  const DateTimeIdModelAttachRowRepository._();

  /// Creates a relation between this [DateTimeIdModel] and the given [CustomIdRelated]
  /// by setting the [CustomIdRelated]'s foreign key `dateTimeId` to refer to this [DateTimeIdModel].
  Future<void> related(
    _is.DatabaseSession session,
    DateTimeIdModel dateTimeIdModel,
    _i2m035mh.CustomIdRelated customIdRelated, {
    _is.Transaction? transaction,
  }) async {
    if (customIdRelated.id == null) {
      throw ArgumentError.notNull('customIdRelated.id');
    }
    if (dateTimeIdModel.id == null) {
      throw ArgumentError.notNull('dateTimeIdModel.id');
    }

    var $customIdRelated = customIdRelated.copyWith(
      dateTimeId: dateTimeIdModel.id,
    );
    await session.db.updateRow<_i2m035mh.CustomIdRelated>(
      $customIdRelated,
      columns: [_i2m035mh.CustomIdRelated.t.dateTimeId],
      transaction: transaction,
    );
  }
}
