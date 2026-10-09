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

abstract class DurationIdModel
    implements _is.TableRow<Duration>, _is.ProtocolSerialization {
  DurationIdModel._({
    required this.id,
    required this.value,
    this.related,
  });

  factory DurationIdModel({
    required Duration id,
    required String value,
    List<_i2m035mh.CustomIdRelated>? related,
  }) = _DurationIdModelImpl;

  factory DurationIdModel.fromJson(Map<String, dynamic> jsonSerialization) {
    return DurationIdModel(
      id: _is.DurationJsonExtension.fromJson(jsonSerialization['id']),
      value: jsonSerialization['value'] as String,
      related: jsonSerialization['related'] == null
          ? null
          : _i08l111i.Protocol().deserialize<List<_i2m035mh.CustomIdRelated>>(
              jsonSerialization['related'],
            ),
    );
  }

  static final t = DurationIdModelTable();

  static const db = DurationIdModelRepository._();

  @override
  Duration id;

  String value;

  List<_i2m035mh.CustomIdRelated>? related;

  @override
  _is.Table<Duration> get table => t;

  /// Returns a shallow copy of this [DurationIdModel]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  DurationIdModel copyWith({
    Duration? id,
    String? value,
    List<_i2m035mh.CustomIdRelated>? related =
        const _is.$UndefinedList<_i2m035mh.CustomIdRelated>(),
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'DurationIdModel',
      'id': id.toJson(),
      'value': value,
      if (related != null)
        'related': related?.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'DurationIdModel',
      'id': id.toJson(),
      'value': value,
      if (related != null)
        'related': related?.toJson(valueToJson: (v) => v.toJsonForProtocol()),
    };
  }

  static DurationIdModelInclude include({
    _i2m035mh.CustomIdRelatedIncludeList? related,
  }) {
    return DurationIdModelInclude._(related: related);
  }

  static DurationIdModelIncludeList includeList({
    _is.WhereExpressionBuilder<DurationIdModelTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<DurationIdModelTable>? orderBy,
    _is.OrderByListBuilder<DurationIdModelTable>? orderByList,
    DurationIdModelInclude? include,
  }) {
    return DurationIdModelIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(DurationIdModel.t),
      orderByList: orderByList?.call(DurationIdModel.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _DurationIdModelImpl extends DurationIdModel {
  _DurationIdModelImpl({
    required Duration id,
    required String value,
    List<_i2m035mh.CustomIdRelated>? related,
  }) : super._(
         id: id,
         value: value,
         related: related,
       );

  /// Returns a shallow copy of this [DurationIdModel]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  DurationIdModel copyWith({
    Duration? id,
    String? value,
    List<_i2m035mh.CustomIdRelated>? related =
        const _is.$UndefinedList<_i2m035mh.CustomIdRelated>(),
  }) {
    return DurationIdModel(
      id: id ?? this.id,
      value: value ?? this.value,
      related: related is _is.UndefinedSentinel
          ? this.related?.map((e0) => e0.copyWith()).toList()
          : related,
    );
  }
}

class DurationIdModelUpdateTable extends _is.UpdateTable<DurationIdModelTable> {
  DurationIdModelUpdateTable(super.table);

  _is.ColumnValue<String, String> value(String value) => _is.ColumnValue(
    table.value,
    value,
  );
}

class DurationIdModelTable extends _is.Table<Duration> {
  DurationIdModelTable({super.tableRelation})
    : super(
        tableName: 'duration_id_model',
        idHasDefault: false,
      ) {
    updateTable = DurationIdModelUpdateTable(this);
    value = _is.ColumnString(
      'value',
      this,
    );
  }

  late final DurationIdModelUpdateTable updateTable;

  late final _is.ColumnString value;

  _i2m035mh.CustomIdRelatedTable? ___related;

  _is.ManyRelation<_i2m035mh.CustomIdRelatedTable>? _related;

  _i2m035mh.CustomIdRelatedTable get __related {
    if (___related != null) return ___related!;
    ___related = _is.createRelationTable(
      relationFieldName: '__related',
      field: DurationIdModel.t.id,
      foreignField: _i2m035mh.CustomIdRelated.t.durationId,
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
      field: DurationIdModel.t.id,
      foreignField: _i2m035mh.CustomIdRelated.t.durationId,
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

class DurationIdModelInclude extends _is.IncludeObject {
  DurationIdModelInclude._({_i2m035mh.CustomIdRelatedIncludeList? related}) {
    _related = related;
  }

  _i2m035mh.CustomIdRelatedIncludeList? _related;

  @override
  Map<String, _is.Include?> get includes => {'related': _related};

  @override
  _is.Table<Duration> get table => DurationIdModel.t;
}

class DurationIdModelIncludeList extends _is.IncludeList {
  DurationIdModelIncludeList._({
    _is.WhereExpressionBuilder<DurationIdModelTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(DurationIdModel.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<Duration> get table => DurationIdModel.t;
}

class DurationIdModelRepository {
  const DurationIdModelRepository._();

  final attach = const DurationIdModelAttachRepository._();

  final attachRow = const DurationIdModelAttachRowRepository._();

  /// Returns a list of [DurationIdModel]s matching the given query parameters.
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
  Future<List<DurationIdModel>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<DurationIdModelTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<DurationIdModelTable>? orderBy,
    _is.OrderByListBuilder<DurationIdModelTable>? orderByList,
    _is.Transaction? transaction,
    DurationIdModelInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<DurationIdModel>(
      where: where?.call(DurationIdModel.t),
      orderBy: orderBy?.call(DurationIdModel.t),
      orderByList: orderByList?.call(DurationIdModel.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [DurationIdModel]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `DurationIdModel.t`.
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
  _ida.Stream<List<DurationIdModel>> watch(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<DurationIdModelTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<DurationIdModelTable>? orderBy,
    _is.OrderByListBuilder<DurationIdModelTable>? orderByList,
    DurationIdModelInclude? include,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<DurationIdModel>(
      where: where?.call(DurationIdModel.t),
      orderBy: orderBy?.call(DurationIdModel.t),
      orderByList: orderByList?.call(DurationIdModel.t),
      limit: limit,
      offset: offset,
      include: include,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [DurationIdModel] matching the given query parameters.
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
  Future<DurationIdModel?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<DurationIdModelTable>? where,
    int? offset,
    _is.OrderByBuilder<DurationIdModelTable>? orderBy,
    _is.OrderByListBuilder<DurationIdModelTable>? orderByList,
    _is.Transaction? transaction,
    DurationIdModelInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<DurationIdModel>(
      where: where?.call(DurationIdModel.t),
      orderBy: orderBy?.call(DurationIdModel.t),
      orderByList: orderByList?.call(DurationIdModel.t),
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [DurationIdModel] by its [id] or null if no such row exists.
  Future<DurationIdModel?> findById(
    _is.DatabaseSession session,
    Duration id, {
    _is.Transaction? transaction,
    DurationIdModelInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<DurationIdModel>(
      id,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [DurationIdModel]s in the list and returns the inserted rows.
  ///
  /// The returned [DurationIdModel]s will have their `id` fields set.
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
  Future<List<DurationIdModel>> insert(
    _is.DatabaseSession session,
    List<DurationIdModel> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<DurationIdModel>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [DurationIdModel] and returns the inserted row.
  ///
  /// The returned [DurationIdModel] will have its `id` field set.
  Future<DurationIdModel> insertRow(
    _is.DatabaseSession session,
    DurationIdModel row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<DurationIdModel>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [DurationIdModel]s in the list and returns the resulting rows.
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
  /// The returned [DurationIdModel]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<DurationIdModel>> upsert(
    _is.DatabaseSession session,
    List<DurationIdModel> rows, {
    required _is.ColumnSelections<DurationIdModelTable> conflictColumns,
    _is.ColumnSelections<DurationIdModelTable>? updateColumns,
    _is.WhereExpressionBuilder<DurationIdModelTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<DurationIdModel>(
      rows,
      conflictColumns: conflictColumns(DurationIdModel.t),
      updateColumns: updateColumns?.call(DurationIdModel.t),
      updateWhere: updateWhere?.call(DurationIdModel.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [DurationIdModel] and returns the resulting row.
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
  /// The returned [DurationIdModel] will have its `id` field set.
  Future<DurationIdModel?> upsertRow(
    _is.DatabaseSession session,
    DurationIdModel row, {
    required _is.ColumnSelections<DurationIdModelTable> conflictColumns,
    _is.ColumnSelections<DurationIdModelTable>? updateColumns,
    _is.WhereExpressionBuilder<DurationIdModelTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<DurationIdModel>(
      row,
      conflictColumns: conflictColumns(DurationIdModel.t),
      updateColumns: updateColumns?.call(DurationIdModel.t),
      updateWhere: updateWhere?.call(DurationIdModel.t),
      transaction: transaction,
    );
  }

  /// Updates all [DurationIdModel]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<DurationIdModel>> update(
    _is.DatabaseSession session,
    List<DurationIdModel> rows, {
    _is.ColumnSelections<DurationIdModelTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<DurationIdModel>(
      rows,
      columns: columns?.call(DurationIdModel.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [DurationIdModel]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<DurationIdModel> updateRow(
    _is.DatabaseSession session,
    DurationIdModel row, {
    _is.ColumnSelections<DurationIdModelTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<DurationIdModel>(
      row,
      columns: columns?.call(DurationIdModel.t),
      transaction: transaction,
    );
  }

  /// Updates a single [DurationIdModel] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<DurationIdModel?> updateById(
    _is.DatabaseSession session,
    Duration id, {
    required _is.ColumnValueListBuilder<DurationIdModelUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<DurationIdModel>(
      id,
      columnValues: columnValues(DurationIdModel.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [DurationIdModel]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<DurationIdModel>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<DurationIdModelUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<DurationIdModelTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<DurationIdModelTable>? orderBy,
    _is.OrderByListBuilder<DurationIdModelTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<DurationIdModel>(
      columnValues: columnValues(DurationIdModel.t.updateTable),
      where: where(DurationIdModel.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(DurationIdModel.t),
      orderByList: orderByList?.call(DurationIdModel.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [DurationIdModel]s in the list and returns the deleted rows.
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
  Future<List<DurationIdModel>> delete(
    _is.DatabaseSession session,
    List<DurationIdModel> rows, {
    _is.OrderByBuilder<DurationIdModelTable>? orderBy,
    _is.OrderByListBuilder<DurationIdModelTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<DurationIdModel>(
      rows,
      orderBy: orderBy?.call(DurationIdModel.t),
      orderByList: orderByList?.call(DurationIdModel.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [DurationIdModel].
  Future<DurationIdModel> deleteRow(
    _is.DatabaseSession session,
    DurationIdModel row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<DurationIdModel>(
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
  Future<List<DurationIdModel>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<DurationIdModelTable> where,
    _is.OrderByBuilder<DurationIdModelTable>? orderBy,
    _is.OrderByListBuilder<DurationIdModelTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<DurationIdModel>(
      where: where(DurationIdModel.t),
      orderBy: orderBy?.call(DurationIdModel.t),
      orderByList: orderByList?.call(DurationIdModel.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<DurationIdModelTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<DurationIdModel>(
      where: where?.call(DurationIdModel.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [DurationIdModel] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<DurationIdModelTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<DurationIdModel>(
      where: where(DurationIdModel.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}

class DurationIdModelAttachRepository {
  const DurationIdModelAttachRepository._();

  /// Creates a relation between this [DurationIdModel] and the given [CustomIdRelated]s
  /// by setting each [CustomIdRelated]'s foreign key `durationId` to refer to this [DurationIdModel].
  Future<void> related(
    _is.DatabaseSession session,
    DurationIdModel durationIdModel,
    List<_i2m035mh.CustomIdRelated> customIdRelated, {
    _is.Transaction? transaction,
  }) async {
    if (customIdRelated.any((e) => e.id == null)) {
      throw ArgumentError.notNull('customIdRelated.id');
    }
    if (durationIdModel.id == null) {
      throw ArgumentError.notNull('durationIdModel.id');
    }

    var $customIdRelated = customIdRelated
        .map((e) => e.copyWith(durationId: durationIdModel.id))
        .toList();
    await session.db.update<_i2m035mh.CustomIdRelated>(
      $customIdRelated,
      columns: [_i2m035mh.CustomIdRelated.t.durationId],
      transaction: transaction,
    );
  }
}

class DurationIdModelAttachRowRepository {
  const DurationIdModelAttachRowRepository._();

  /// Creates a relation between this [DurationIdModel] and the given [CustomIdRelated]
  /// by setting the [CustomIdRelated]'s foreign key `durationId` to refer to this [DurationIdModel].
  Future<void> related(
    _is.DatabaseSession session,
    DurationIdModel durationIdModel,
    _i2m035mh.CustomIdRelated customIdRelated, {
    _is.Transaction? transaction,
  }) async {
    if (customIdRelated.id == null) {
      throw ArgumentError.notNull('customIdRelated.id');
    }
    if (durationIdModel.id == null) {
      throw ArgumentError.notNull('durationIdModel.id');
    }

    var $customIdRelated = customIdRelated.copyWith(
      durationId: durationIdModel.id,
    );
    await session.db.updateRow<_i2m035mh.CustomIdRelated>(
      $customIdRelated,
      columns: [_i2m035mh.CustomIdRelated.t.durationId],
      transaction: transaction,
    );
  }
}
