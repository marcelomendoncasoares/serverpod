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
import '../custom_ids/date_time_id_model.dart' as _iddrsmux;
import '../custom_ids/duration_id_model.dart' as _ipwirpu1;
import '../custom_ids/string_id_model.dart' as _i7tbipax;

abstract class CustomIdRelated
    implements _is.TableRow<String>, _is.ProtocolSerialization {
  CustomIdRelated._({
    required this.id,
    required this.stringId,
    this.string,
    required this.dateTimeId,
    this.dateTime,
    required this.durationId,
    this.duration,
  });

  factory CustomIdRelated({
    required String id,
    required String stringId,
    _i7tbipax.StringIdModel? string,
    required DateTime dateTimeId,
    _iddrsmux.DateTimeIdModel? dateTime,
    required Duration durationId,
    _ipwirpu1.DurationIdModel? duration,
  }) = _CustomIdRelatedImpl;

  factory CustomIdRelated.fromJson(Map<String, dynamic> jsonSerialization) {
    return CustomIdRelated(
      id: jsonSerialization['id'] as String,
      stringId: jsonSerialization['stringId'] as String,
      string: jsonSerialization['string'] == null
          ? null
          : _i08l111i.Protocol().deserialize<_i7tbipax.StringIdModel>(
              jsonSerialization['string'],
            ),
      dateTimeId: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['dateTimeId'],
      ),
      dateTime: jsonSerialization['dateTime'] == null
          ? null
          : _i08l111i.Protocol().deserialize<_iddrsmux.DateTimeIdModel>(
              jsonSerialization['dateTime'],
            ),
      durationId: _is.DurationJsonExtension.fromJson(
        jsonSerialization['durationId'],
      ),
      duration: jsonSerialization['duration'] == null
          ? null
          : _i08l111i.Protocol().deserialize<_ipwirpu1.DurationIdModel>(
              jsonSerialization['duration'],
            ),
    );
  }

  static final t = CustomIdRelatedTable();

  static const db = CustomIdRelatedRepository._();

  @override
  String id;

  String stringId;

  _i7tbipax.StringIdModel? string;

  DateTime dateTimeId;

  _iddrsmux.DateTimeIdModel? dateTime;

  Duration durationId;

  _ipwirpu1.DurationIdModel? duration;

  @override
  _is.Table<String> get table => t;

  /// Returns a shallow copy of this [CustomIdRelated]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CustomIdRelated copyWith({
    String? id,
    String? stringId,
    _i7tbipax.StringIdModel? string = const _UndefinedCustomIdRelated$string(),
    DateTime? dateTimeId,
    _iddrsmux.DateTimeIdModel? dateTime =
        const _UndefinedCustomIdRelated$dateTime(),
    Duration? durationId,
    _ipwirpu1.DurationIdModel? duration =
        const _UndefinedCustomIdRelated$duration(),
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CustomIdRelated',
      'id': id,
      'stringId': stringId,
      if (string != null) 'string': string?.toJson(),
      'dateTimeId': dateTimeId.toJson(),
      if (dateTime != null) 'dateTime': dateTime?.toJson(),
      'durationId': durationId.toJson(),
      if (duration != null) 'duration': duration?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'CustomIdRelated',
      'id': id,
      'stringId': stringId,
      if (string != null) 'string': string?.toJsonForProtocol(),
      'dateTimeId': dateTimeId.toJson(),
      if (dateTime != null) 'dateTime': dateTime?.toJsonForProtocol(),
      'durationId': durationId.toJson(),
      if (duration != null) 'duration': duration?.toJsonForProtocol(),
    };
  }

  static CustomIdRelatedInclude include({
    _i7tbipax.StringIdModelInclude? string,
    _iddrsmux.DateTimeIdModelInclude? dateTime,
    _ipwirpu1.DurationIdModelInclude? duration,
  }) {
    return CustomIdRelatedInclude._(
      string: string,
      dateTime: dateTime,
      duration: duration,
    );
  }

  static CustomIdRelatedIncludeList includeList({
    _is.WhereExpressionBuilder<CustomIdRelatedTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CustomIdRelatedTable>? orderBy,
    _is.OrderByListBuilder<CustomIdRelatedTable>? orderByList,
    CustomIdRelatedInclude? include,
  }) {
    return CustomIdRelatedIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CustomIdRelated.t),
      orderByList: orderByList?.call(CustomIdRelated.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _UndefinedCustomIdRelated$string extends _is.UndefinedSentinel
    implements _i7tbipax.StringIdModel {
  const _UndefinedCustomIdRelated$string();
}

class _UndefinedCustomIdRelated$dateTime extends _is.UndefinedSentinel
    implements _iddrsmux.DateTimeIdModel {
  const _UndefinedCustomIdRelated$dateTime();
}

class _UndefinedCustomIdRelated$duration extends _is.UndefinedSentinel
    implements _ipwirpu1.DurationIdModel {
  const _UndefinedCustomIdRelated$duration();
}

class _CustomIdRelatedImpl extends CustomIdRelated {
  _CustomIdRelatedImpl({
    required String id,
    required String stringId,
    _i7tbipax.StringIdModel? string,
    required DateTime dateTimeId,
    _iddrsmux.DateTimeIdModel? dateTime,
    required Duration durationId,
    _ipwirpu1.DurationIdModel? duration,
  }) : super._(
         id: id,
         stringId: stringId,
         string: string,
         dateTimeId: dateTimeId,
         dateTime: dateTime,
         durationId: durationId,
         duration: duration,
       );

  /// Returns a shallow copy of this [CustomIdRelated]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CustomIdRelated copyWith({
    String? id,
    String? stringId,
    _i7tbipax.StringIdModel? string = const _UndefinedCustomIdRelated$string(),
    DateTime? dateTimeId,
    _iddrsmux.DateTimeIdModel? dateTime =
        const _UndefinedCustomIdRelated$dateTime(),
    Duration? durationId,
    _ipwirpu1.DurationIdModel? duration =
        const _UndefinedCustomIdRelated$duration(),
  }) {
    return CustomIdRelated(
      id: id ?? this.id,
      stringId: stringId ?? this.stringId,
      string: string is _is.UndefinedSentinel
          ? this.string?.copyWith()
          : string,
      dateTimeId: dateTimeId ?? this.dateTimeId,
      dateTime: dateTime is _is.UndefinedSentinel
          ? this.dateTime?.copyWith()
          : dateTime,
      durationId: durationId ?? this.durationId,
      duration: duration is _is.UndefinedSentinel
          ? this.duration?.copyWith()
          : duration,
    );
  }
}

class CustomIdRelatedUpdateTable extends _is.UpdateTable<CustomIdRelatedTable> {
  CustomIdRelatedUpdateTable(super.table);

  _is.ColumnValue<String, String> stringId(String value) => _is.ColumnValue(
    table.stringId,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> dateTimeId(DateTime value) =>
      _is.ColumnValue(
        table.dateTimeId,
        value,
      );

  _is.ColumnValue<Duration, Duration> durationId(Duration value) =>
      _is.ColumnValue(
        table.durationId,
        value,
      );
}

class CustomIdRelatedTable extends _is.Table<String> {
  CustomIdRelatedTable({super.tableRelation})
    : super(
        tableName: 'custom_id_related',
        idHasDefault: false,
      ) {
    updateTable = CustomIdRelatedUpdateTable(this);
    stringId = _is.ColumnString(
      'stringId',
      this,
    );
    dateTimeId = _is.ColumnDateTime(
      'dateTimeId',
      this,
    );
    durationId = _is.ColumnDuration(
      'durationId',
      this,
    );
  }

  late final CustomIdRelatedUpdateTable updateTable;

  late final _is.ColumnString stringId;

  _i7tbipax.StringIdModelTable? _string;

  late final _is.ColumnDateTime dateTimeId;

  _iddrsmux.DateTimeIdModelTable? _dateTime;

  late final _is.ColumnDuration durationId;

  _ipwirpu1.DurationIdModelTable? _duration;

  _i7tbipax.StringIdModelTable get string {
    if (_string != null) return _string!;
    _string = _is.createRelationTable(
      relationFieldName: 'string',
      field: CustomIdRelated.t.stringId,
      foreignField: _i7tbipax.StringIdModel.t.id,
      tableRelation: tableRelation,
      createTable: (foreignTableRelation) =>
          _i7tbipax.StringIdModelTable(tableRelation: foreignTableRelation),
    );
    return _string!;
  }

  _iddrsmux.DateTimeIdModelTable get dateTime {
    if (_dateTime != null) return _dateTime!;
    _dateTime = _is.createRelationTable(
      relationFieldName: 'dateTime',
      field: CustomIdRelated.t.dateTimeId,
      foreignField: _iddrsmux.DateTimeIdModel.t.id,
      tableRelation: tableRelation,
      createTable: (foreignTableRelation) =>
          _iddrsmux.DateTimeIdModelTable(tableRelation: foreignTableRelation),
    );
    return _dateTime!;
  }

  _ipwirpu1.DurationIdModelTable get duration {
    if (_duration != null) return _duration!;
    _duration = _is.createRelationTable(
      relationFieldName: 'duration',
      field: CustomIdRelated.t.durationId,
      foreignField: _ipwirpu1.DurationIdModel.t.id,
      tableRelation: tableRelation,
      createTable: (foreignTableRelation) =>
          _ipwirpu1.DurationIdModelTable(tableRelation: foreignTableRelation),
    );
    return _duration!;
  }

  @override
  List<_is.Column> get columns => [
    id,
    stringId,
    dateTimeId,
    durationId,
  ];

  @override
  _is.Table? getRelationTable(String relationField) {
    if (relationField == 'string') {
      return string;
    }
    if (relationField == 'dateTime') {
      return dateTime;
    }
    if (relationField == 'duration') {
      return duration;
    }
    return null;
  }
}

class CustomIdRelatedInclude extends _is.IncludeObject {
  CustomIdRelatedInclude._({
    _i7tbipax.StringIdModelInclude? string,
    _iddrsmux.DateTimeIdModelInclude? dateTime,
    _ipwirpu1.DurationIdModelInclude? duration,
  }) {
    _string = string;
    _dateTime = dateTime;
    _duration = duration;
  }

  _i7tbipax.StringIdModelInclude? _string;

  _iddrsmux.DateTimeIdModelInclude? _dateTime;

  _ipwirpu1.DurationIdModelInclude? _duration;

  @override
  Map<String, _is.Include?> get includes => {
    'string': _string,
    'dateTime': _dateTime,
    'duration': _duration,
  };

  @override
  _is.Table<String> get table => CustomIdRelated.t;
}

class CustomIdRelatedIncludeList extends _is.IncludeList {
  CustomIdRelatedIncludeList._({
    _is.WhereExpressionBuilder<CustomIdRelatedTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(CustomIdRelated.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<String> get table => CustomIdRelated.t;
}

class CustomIdRelatedRepository {
  const CustomIdRelatedRepository._();

  final attachRow = const CustomIdRelatedAttachRowRepository._();

  /// Returns a list of [CustomIdRelated]s matching the given query parameters.
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
  Future<List<CustomIdRelated>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CustomIdRelatedTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CustomIdRelatedTable>? orderBy,
    _is.OrderByListBuilder<CustomIdRelatedTable>? orderByList,
    _is.Transaction? transaction,
    CustomIdRelatedInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<CustomIdRelated>(
      where: where?.call(CustomIdRelated.t),
      orderBy: orderBy?.call(CustomIdRelated.t),
      orderByList: orderByList?.call(CustomIdRelated.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [CustomIdRelated]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `CustomIdRelated.t`.
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
  _ida.Stream<List<CustomIdRelated>> watch(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CustomIdRelatedTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CustomIdRelatedTable>? orderBy,
    _is.OrderByListBuilder<CustomIdRelatedTable>? orderByList,
    CustomIdRelatedInclude? include,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<CustomIdRelated>(
      where: where?.call(CustomIdRelated.t),
      orderBy: orderBy?.call(CustomIdRelated.t),
      orderByList: orderByList?.call(CustomIdRelated.t),
      limit: limit,
      offset: offset,
      include: include,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [CustomIdRelated] matching the given query parameters.
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
  Future<CustomIdRelated?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CustomIdRelatedTable>? where,
    int? offset,
    _is.OrderByBuilder<CustomIdRelatedTable>? orderBy,
    _is.OrderByListBuilder<CustomIdRelatedTable>? orderByList,
    _is.Transaction? transaction,
    CustomIdRelatedInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<CustomIdRelated>(
      where: where?.call(CustomIdRelated.t),
      orderBy: orderBy?.call(CustomIdRelated.t),
      orderByList: orderByList?.call(CustomIdRelated.t),
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [CustomIdRelated] by its [id] or null if no such row exists.
  Future<CustomIdRelated?> findById(
    _is.DatabaseSession session,
    String id, {
    _is.Transaction? transaction,
    CustomIdRelatedInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<CustomIdRelated>(
      id,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [CustomIdRelated]s in the list and returns the inserted rows.
  ///
  /// The returned [CustomIdRelated]s will have their `id` fields set.
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
  Future<List<CustomIdRelated>> insert(
    _is.DatabaseSession session,
    List<CustomIdRelated> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<CustomIdRelated>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [CustomIdRelated] and returns the inserted row.
  ///
  /// The returned [CustomIdRelated] will have its `id` field set.
  Future<CustomIdRelated> insertRow(
    _is.DatabaseSession session,
    CustomIdRelated row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<CustomIdRelated>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [CustomIdRelated]s in the list and returns the resulting rows.
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
  /// The returned [CustomIdRelated]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CustomIdRelated>> upsert(
    _is.DatabaseSession session,
    List<CustomIdRelated> rows, {
    required _is.ColumnSelections<CustomIdRelatedTable> conflictColumns,
    _is.ColumnSelections<CustomIdRelatedTable>? updateColumns,
    _is.WhereExpressionBuilder<CustomIdRelatedTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<CustomIdRelated>(
      rows,
      conflictColumns: conflictColumns(CustomIdRelated.t),
      updateColumns: updateColumns?.call(CustomIdRelated.t),
      updateWhere: updateWhere?.call(CustomIdRelated.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [CustomIdRelated] and returns the resulting row.
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
  /// The returned [CustomIdRelated] will have its `id` field set.
  Future<CustomIdRelated?> upsertRow(
    _is.DatabaseSession session,
    CustomIdRelated row, {
    required _is.ColumnSelections<CustomIdRelatedTable> conflictColumns,
    _is.ColumnSelections<CustomIdRelatedTable>? updateColumns,
    _is.WhereExpressionBuilder<CustomIdRelatedTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<CustomIdRelated>(
      row,
      conflictColumns: conflictColumns(CustomIdRelated.t),
      updateColumns: updateColumns?.call(CustomIdRelated.t),
      updateWhere: updateWhere?.call(CustomIdRelated.t),
      transaction: transaction,
    );
  }

  /// Updates all [CustomIdRelated]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CustomIdRelated>> update(
    _is.DatabaseSession session,
    List<CustomIdRelated> rows, {
    _is.ColumnSelections<CustomIdRelatedTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<CustomIdRelated>(
      rows,
      columns: columns?.call(CustomIdRelated.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [CustomIdRelated]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<CustomIdRelated> updateRow(
    _is.DatabaseSession session,
    CustomIdRelated row, {
    _is.ColumnSelections<CustomIdRelatedTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<CustomIdRelated>(
      row,
      columns: columns?.call(CustomIdRelated.t),
      transaction: transaction,
    );
  }

  /// Updates a single [CustomIdRelated] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<CustomIdRelated?> updateById(
    _is.DatabaseSession session,
    String id, {
    required _is.ColumnValueListBuilder<CustomIdRelatedUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<CustomIdRelated>(
      id,
      columnValues: columnValues(CustomIdRelated.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [CustomIdRelated]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CustomIdRelated>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<CustomIdRelatedUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<CustomIdRelatedTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CustomIdRelatedTable>? orderBy,
    _is.OrderByListBuilder<CustomIdRelatedTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<CustomIdRelated>(
      columnValues: columnValues(CustomIdRelated.t.updateTable),
      where: where(CustomIdRelated.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CustomIdRelated.t),
      orderByList: orderByList?.call(CustomIdRelated.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [CustomIdRelated]s in the list and returns the deleted rows.
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
  Future<List<CustomIdRelated>> delete(
    _is.DatabaseSession session,
    List<CustomIdRelated> rows, {
    _is.OrderByBuilder<CustomIdRelatedTable>? orderBy,
    _is.OrderByListBuilder<CustomIdRelatedTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<CustomIdRelated>(
      rows,
      orderBy: orderBy?.call(CustomIdRelated.t),
      orderByList: orderByList?.call(CustomIdRelated.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [CustomIdRelated].
  Future<CustomIdRelated> deleteRow(
    _is.DatabaseSession session,
    CustomIdRelated row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<CustomIdRelated>(
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
  Future<List<CustomIdRelated>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CustomIdRelatedTable> where,
    _is.OrderByBuilder<CustomIdRelatedTable>? orderBy,
    _is.OrderByListBuilder<CustomIdRelatedTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<CustomIdRelated>(
      where: where(CustomIdRelated.t),
      orderBy: orderBy?.call(CustomIdRelated.t),
      orderByList: orderByList?.call(CustomIdRelated.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CustomIdRelatedTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<CustomIdRelated>(
      where: where?.call(CustomIdRelated.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [CustomIdRelated] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CustomIdRelatedTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<CustomIdRelated>(
      where: where(CustomIdRelated.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}

class CustomIdRelatedAttachRowRepository {
  const CustomIdRelatedAttachRowRepository._();

  /// Creates a relation between the given [CustomIdRelated] and [StringIdModel]
  /// by setting the [CustomIdRelated]'s foreign key `stringId` to refer to the [StringIdModel].
  Future<void> string(
    _is.DatabaseSession session,
    CustomIdRelated customIdRelated,
    _i7tbipax.StringIdModel string, {
    _is.Transaction? transaction,
  }) async {
    if (customIdRelated.id == null) {
      throw ArgumentError.notNull('customIdRelated.id');
    }
    if (string.id == null) {
      throw ArgumentError.notNull('string.id');
    }

    var $customIdRelated = customIdRelated.copyWith(stringId: string.id);
    await session.db.updateRow<CustomIdRelated>(
      $customIdRelated,
      columns: [CustomIdRelated.t.stringId],
      transaction: transaction,
    );
  }

  /// Creates a relation between the given [CustomIdRelated] and [DateTimeIdModel]
  /// by setting the [CustomIdRelated]'s foreign key `dateTimeId` to refer to the [DateTimeIdModel].
  Future<void> dateTime(
    _is.DatabaseSession session,
    CustomIdRelated customIdRelated,
    _iddrsmux.DateTimeIdModel dateTime, {
    _is.Transaction? transaction,
  }) async {
    if (customIdRelated.id == null) {
      throw ArgumentError.notNull('customIdRelated.id');
    }
    if (dateTime.id == null) {
      throw ArgumentError.notNull('dateTime.id');
    }

    var $customIdRelated = customIdRelated.copyWith(dateTimeId: dateTime.id);
    await session.db.updateRow<CustomIdRelated>(
      $customIdRelated,
      columns: [CustomIdRelated.t.dateTimeId],
      transaction: transaction,
    );
  }

  /// Creates a relation between the given [CustomIdRelated] and [DurationIdModel]
  /// by setting the [CustomIdRelated]'s foreign key `durationId` to refer to the [DurationIdModel].
  Future<void> duration(
    _is.DatabaseSession session,
    CustomIdRelated customIdRelated,
    _ipwirpu1.DurationIdModel duration, {
    _is.Transaction? transaction,
  }) async {
    if (customIdRelated.id == null) {
      throw ArgumentError.notNull('customIdRelated.id');
    }
    if (duration.id == null) {
      throw ArgumentError.notNull('duration.id');
    }

    var $customIdRelated = customIdRelated.copyWith(durationId: duration.id);
    await session.db.updateRow<CustomIdRelated>(
      $customIdRelated,
      columns: [CustomIdRelated.t.durationId],
      transaction: transaction,
    );
  }
}
