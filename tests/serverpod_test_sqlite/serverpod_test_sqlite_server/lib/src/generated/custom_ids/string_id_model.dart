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

abstract class StringIdModel
    implements _is.TableRow<String>, _is.ProtocolSerialization {
  StringIdModel._({
    required this.id,
    required this.value,
    this.related,
  });

  factory StringIdModel({
    required String id,
    required String value,
    List<_i2m035mh.CustomIdRelated>? related,
  }) = _StringIdModelImpl;

  factory StringIdModel.fromJson(Map<String, dynamic> jsonSerialization) {
    return StringIdModel(
      id: jsonSerialization['id'] as String,
      value: jsonSerialization['value'] as String,
      related: jsonSerialization['related'] == null
          ? null
          : _i08l111i.Protocol().deserialize<List<_i2m035mh.CustomIdRelated>>(
              jsonSerialization['related'],
            ),
    );
  }

  static final t = StringIdModelTable();

  static const db = StringIdModelRepository._();

  @override
  String id;

  String value;

  List<_i2m035mh.CustomIdRelated>? related;

  @override
  _is.Table<String> get table => t;

  /// Returns a shallow copy of this [StringIdModel]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  StringIdModel copyWith({
    String? id,
    String? value,
    List<_i2m035mh.CustomIdRelated>? related =
        const _is.$UndefinedList<_i2m035mh.CustomIdRelated>(),
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'StringIdModel',
      'id': id,
      'value': value,
      if (related != null)
        'related': related?.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'StringIdModel',
      'id': id,
      'value': value,
      if (related != null)
        'related': related?.toJson(valueToJson: (v) => v.toJsonForProtocol()),
    };
  }

  static StringIdModelInclude include({
    _i2m035mh.CustomIdRelatedIncludeList? related,
  }) {
    return StringIdModelInclude._(related: related);
  }

  static StringIdModelIncludeList includeList({
    _is.WhereExpressionBuilder<StringIdModelTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<StringIdModelTable>? orderBy,
    _is.OrderByListBuilder<StringIdModelTable>? orderByList,
    StringIdModelInclude? include,
  }) {
    return StringIdModelIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(StringIdModel.t),
      orderByList: orderByList?.call(StringIdModel.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _StringIdModelImpl extends StringIdModel {
  _StringIdModelImpl({
    required String id,
    required String value,
    List<_i2m035mh.CustomIdRelated>? related,
  }) : super._(
         id: id,
         value: value,
         related: related,
       );

  /// Returns a shallow copy of this [StringIdModel]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  StringIdModel copyWith({
    String? id,
    String? value,
    List<_i2m035mh.CustomIdRelated>? related =
        const _is.$UndefinedList<_i2m035mh.CustomIdRelated>(),
  }) {
    return StringIdModel(
      id: id ?? this.id,
      value: value ?? this.value,
      related: related is _is.UndefinedSentinel
          ? this.related?.map((e0) => e0.copyWith()).toList()
          : related,
    );
  }
}

class StringIdModelUpdateTable extends _is.UpdateTable<StringIdModelTable> {
  StringIdModelUpdateTable(super.table);

  _is.ColumnValue<String, String> value(String value) => _is.ColumnValue(
    table.value,
    value,
  );
}

class StringIdModelTable extends _is.Table<String> {
  StringIdModelTable({super.tableRelation})
    : super(
        tableName: 'string_id_model',
        idHasDefault: false,
      ) {
    updateTable = StringIdModelUpdateTable(this);
    value = _is.ColumnString(
      'value',
      this,
    );
  }

  late final StringIdModelUpdateTable updateTable;

  late final _is.ColumnString value;

  _i2m035mh.CustomIdRelatedTable? ___related;

  _is.ManyRelation<_i2m035mh.CustomIdRelatedTable>? _related;

  _i2m035mh.CustomIdRelatedTable get __related {
    if (___related != null) return ___related!;
    ___related = _is.createRelationTable(
      relationFieldName: '__related',
      field: StringIdModel.t.id,
      foreignField: _i2m035mh.CustomIdRelated.t.stringId,
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
      field: StringIdModel.t.id,
      foreignField: _i2m035mh.CustomIdRelated.t.stringId,
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

class StringIdModelInclude extends _is.IncludeObject {
  StringIdModelInclude._({_i2m035mh.CustomIdRelatedIncludeList? related}) {
    _related = related;
  }

  _i2m035mh.CustomIdRelatedIncludeList? _related;

  @override
  Map<String, _is.Include?> get includes => {'related': _related};

  @override
  _is.Table<String> get table => StringIdModel.t;
}

class StringIdModelIncludeList extends _is.IncludeList {
  StringIdModelIncludeList._({
    _is.WhereExpressionBuilder<StringIdModelTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(StringIdModel.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<String> get table => StringIdModel.t;
}

class StringIdModelRepository {
  const StringIdModelRepository._();

  final attach = const StringIdModelAttachRepository._();

  final attachRow = const StringIdModelAttachRowRepository._();

  /// Returns a list of [StringIdModel]s matching the given query parameters.
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
  Future<List<StringIdModel>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<StringIdModelTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<StringIdModelTable>? orderBy,
    _is.OrderByListBuilder<StringIdModelTable>? orderByList,
    _is.Transaction? transaction,
    StringIdModelInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<StringIdModel>(
      where: where?.call(StringIdModel.t),
      orderBy: orderBy?.call(StringIdModel.t),
      orderByList: orderByList?.call(StringIdModel.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [StringIdModel]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `StringIdModel.t`.
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
  _ida.Stream<List<StringIdModel>> watch(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<StringIdModelTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<StringIdModelTable>? orderBy,
    _is.OrderByListBuilder<StringIdModelTable>? orderByList,
    StringIdModelInclude? include,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<StringIdModel>(
      where: where?.call(StringIdModel.t),
      orderBy: orderBy?.call(StringIdModel.t),
      orderByList: orderByList?.call(StringIdModel.t),
      limit: limit,
      offset: offset,
      include: include,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [StringIdModel] matching the given query parameters.
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
  Future<StringIdModel?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<StringIdModelTable>? where,
    int? offset,
    _is.OrderByBuilder<StringIdModelTable>? orderBy,
    _is.OrderByListBuilder<StringIdModelTable>? orderByList,
    _is.Transaction? transaction,
    StringIdModelInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<StringIdModel>(
      where: where?.call(StringIdModel.t),
      orderBy: orderBy?.call(StringIdModel.t),
      orderByList: orderByList?.call(StringIdModel.t),
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [StringIdModel] by its [id] or null if no such row exists.
  Future<StringIdModel?> findById(
    _is.DatabaseSession session,
    String id, {
    _is.Transaction? transaction,
    StringIdModelInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<StringIdModel>(
      id,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [StringIdModel]s in the list and returns the inserted rows.
  ///
  /// The returned [StringIdModel]s will have their `id` fields set.
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
  Future<List<StringIdModel>> insert(
    _is.DatabaseSession session,
    List<StringIdModel> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<StringIdModel>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [StringIdModel] and returns the inserted row.
  ///
  /// The returned [StringIdModel] will have its `id` field set.
  Future<StringIdModel> insertRow(
    _is.DatabaseSession session,
    StringIdModel row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<StringIdModel>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [StringIdModel]s in the list and returns the resulting rows.
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
  /// The returned [StringIdModel]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<StringIdModel>> upsert(
    _is.DatabaseSession session,
    List<StringIdModel> rows, {
    required _is.ColumnSelections<StringIdModelTable> conflictColumns,
    _is.ColumnSelections<StringIdModelTable>? updateColumns,
    _is.WhereExpressionBuilder<StringIdModelTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<StringIdModel>(
      rows,
      conflictColumns: conflictColumns(StringIdModel.t),
      updateColumns: updateColumns?.call(StringIdModel.t),
      updateWhere: updateWhere?.call(StringIdModel.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [StringIdModel] and returns the resulting row.
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
  /// The returned [StringIdModel] will have its `id` field set.
  Future<StringIdModel?> upsertRow(
    _is.DatabaseSession session,
    StringIdModel row, {
    required _is.ColumnSelections<StringIdModelTable> conflictColumns,
    _is.ColumnSelections<StringIdModelTable>? updateColumns,
    _is.WhereExpressionBuilder<StringIdModelTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<StringIdModel>(
      row,
      conflictColumns: conflictColumns(StringIdModel.t),
      updateColumns: updateColumns?.call(StringIdModel.t),
      updateWhere: updateWhere?.call(StringIdModel.t),
      transaction: transaction,
    );
  }

  /// Updates all [StringIdModel]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<StringIdModel>> update(
    _is.DatabaseSession session,
    List<StringIdModel> rows, {
    _is.ColumnSelections<StringIdModelTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<StringIdModel>(
      rows,
      columns: columns?.call(StringIdModel.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [StringIdModel]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<StringIdModel> updateRow(
    _is.DatabaseSession session,
    StringIdModel row, {
    _is.ColumnSelections<StringIdModelTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<StringIdModel>(
      row,
      columns: columns?.call(StringIdModel.t),
      transaction: transaction,
    );
  }

  /// Updates a single [StringIdModel] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<StringIdModel?> updateById(
    _is.DatabaseSession session,
    String id, {
    required _is.ColumnValueListBuilder<StringIdModelUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<StringIdModel>(
      id,
      columnValues: columnValues(StringIdModel.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [StringIdModel]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<StringIdModel>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<StringIdModelUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<StringIdModelTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<StringIdModelTable>? orderBy,
    _is.OrderByListBuilder<StringIdModelTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<StringIdModel>(
      columnValues: columnValues(StringIdModel.t.updateTable),
      where: where(StringIdModel.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(StringIdModel.t),
      orderByList: orderByList?.call(StringIdModel.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [StringIdModel]s in the list and returns the deleted rows.
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
  Future<List<StringIdModel>> delete(
    _is.DatabaseSession session,
    List<StringIdModel> rows, {
    _is.OrderByBuilder<StringIdModelTable>? orderBy,
    _is.OrderByListBuilder<StringIdModelTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<StringIdModel>(
      rows,
      orderBy: orderBy?.call(StringIdModel.t),
      orderByList: orderByList?.call(StringIdModel.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [StringIdModel].
  Future<StringIdModel> deleteRow(
    _is.DatabaseSession session,
    StringIdModel row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<StringIdModel>(
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
  Future<List<StringIdModel>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<StringIdModelTable> where,
    _is.OrderByBuilder<StringIdModelTable>? orderBy,
    _is.OrderByListBuilder<StringIdModelTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<StringIdModel>(
      where: where(StringIdModel.t),
      orderBy: orderBy?.call(StringIdModel.t),
      orderByList: orderByList?.call(StringIdModel.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<StringIdModelTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<StringIdModel>(
      where: where?.call(StringIdModel.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [StringIdModel] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<StringIdModelTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<StringIdModel>(
      where: where(StringIdModel.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}

class StringIdModelAttachRepository {
  const StringIdModelAttachRepository._();

  /// Creates a relation between this [StringIdModel] and the given [CustomIdRelated]s
  /// by setting each [CustomIdRelated]'s foreign key `stringId` to refer to this [StringIdModel].
  Future<void> related(
    _is.DatabaseSession session,
    StringIdModel stringIdModel,
    List<_i2m035mh.CustomIdRelated> customIdRelated, {
    _is.Transaction? transaction,
  }) async {
    if (customIdRelated.any((e) => e.id == null)) {
      throw ArgumentError.notNull('customIdRelated.id');
    }
    if (stringIdModel.id == null) {
      throw ArgumentError.notNull('stringIdModel.id');
    }

    var $customIdRelated = customIdRelated
        .map((e) => e.copyWith(stringId: stringIdModel.id))
        .toList();
    await session.db.update<_i2m035mh.CustomIdRelated>(
      $customIdRelated,
      columns: [_i2m035mh.CustomIdRelated.t.stringId],
      transaction: transaction,
    );
  }
}

class StringIdModelAttachRowRepository {
  const StringIdModelAttachRowRepository._();

  /// Creates a relation between this [StringIdModel] and the given [CustomIdRelated]
  /// by setting the [CustomIdRelated]'s foreign key `stringId` to refer to this [StringIdModel].
  Future<void> related(
    _is.DatabaseSession session,
    StringIdModel stringIdModel,
    _i2m035mh.CustomIdRelated customIdRelated, {
    _is.Transaction? transaction,
  }) async {
    if (customIdRelated.id == null) {
      throw ArgumentError.notNull('customIdRelated.id');
    }
    if (stringIdModel.id == null) {
      throw ArgumentError.notNull('stringIdModel.id');
    }

    var $customIdRelated = customIdRelated.copyWith(stringId: stringIdModel.id);
    await session.db.updateRow<_i2m035mh.CustomIdRelated>(
      $customIdRelated,
      columns: [_i2m035mh.CustomIdRelated.t.stringId],
      transaction: transaction,
    );
  }
}
