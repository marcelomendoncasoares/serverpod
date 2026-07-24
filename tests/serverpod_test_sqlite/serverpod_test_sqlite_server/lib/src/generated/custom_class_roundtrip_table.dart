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
import 'package:serverpod/serverpod.dart' as _i1;
import 'package:serverpod_test_shared/serverpod_test_shared.dart' as _i2;

abstract class CustomClassRoundtripTable
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  CustomClassRoundtripTable._({
    this.id,
    required this.intData,
    required this.doubleData,
    required this.stringData,
    required this.boolData,
    required this.dateTimeData,
    required this.mapData,
    required this.jsonbMapData,
    this.nullableIntData,
    this.nullableMapData,
  });

  factory CustomClassRoundtripTable({
    int? id,
    required _i2.IntCustomClass intData,
    required _i2.DoubleCustomClass doubleData,
    required _i2.CustomClass stringData,
    required _i2.BoolCustomClass boolData,
    required _i2.DateTimeCustomClass dateTimeData,
    required _i2.CustomClass2 mapData,
    required _i2.CustomClass2 jsonbMapData,
    _i2.IntCustomClass? nullableIntData,
    _i2.CustomClass2? nullableMapData,
  }) = _CustomClassRoundtripTableImpl;

  factory CustomClassRoundtripTable.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CustomClassRoundtripTable(
      id: jsonSerialization['id'] as int?,
      intData: _i2.IntCustomClass.fromJson(jsonSerialization['intData']),
      doubleData: _i2.DoubleCustomClass.fromJson(
        jsonSerialization['doubleData'],
      ),
      stringData: _i2.CustomClass.fromJson(jsonSerialization['stringData']),
      boolData: _i2.BoolCustomClass.fromJson(jsonSerialization['boolData']),
      dateTimeData: _i2.DateTimeCustomClass.fromJson(
        jsonSerialization['dateTimeData'],
      ),
      mapData: _i2.CustomClass2.fromJson(jsonSerialization['mapData']),
      jsonbMapData: _i2.CustomClass2.fromJson(
        jsonSerialization['jsonbMapData'],
      ),
      nullableIntData: jsonSerialization['nullableIntData'] == null
          ? null
          : _i2.IntCustomClass.fromJson(jsonSerialization['nullableIntData']),
      nullableMapData: jsonSerialization['nullableMapData'] == null
          ? null
          : _i2.CustomClass2.fromJson(jsonSerialization['nullableMapData']),
    );
  }

  static final t = CustomClassRoundtripTableTable();

  static const db = CustomClassRoundtripTableRepository._();

  @override
  int? id;

  _i2.IntCustomClass intData;

  _i2.DoubleCustomClass doubleData;

  _i2.CustomClass stringData;

  _i2.BoolCustomClass boolData;

  _i2.DateTimeCustomClass dateTimeData;

  _i2.CustomClass2 mapData;

  _i2.CustomClass2 jsonbMapData;

  _i2.IntCustomClass? nullableIntData;

  _i2.CustomClass2? nullableMapData;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [CustomClassRoundtripTable]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  CustomClassRoundtripTable copyWith({
    int? id,
    _i2.IntCustomClass? intData,
    _i2.DoubleCustomClass? doubleData,
    _i2.CustomClass? stringData,
    _i2.BoolCustomClass? boolData,
    _i2.DateTimeCustomClass? dateTimeData,
    _i2.CustomClass2? mapData,
    _i2.CustomClass2? jsonbMapData,
    _i2.IntCustomClass? nullableIntData,
    _i2.CustomClass2? nullableMapData,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CustomClassRoundtripTable',
      if (id != null) 'id': id,
      'intData': intData.toJson(),
      'doubleData': doubleData.toJson(),
      'stringData': stringData.toJson(),
      'boolData': boolData.toJson(),
      'dateTimeData': dateTimeData.toJson(),
      'mapData': mapData.toJson(),
      'jsonbMapData': jsonbMapData.toJson(),
      if (nullableIntData != null) 'nullableIntData': nullableIntData?.toJson(),
      if (nullableMapData != null) 'nullableMapData': nullableMapData?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'CustomClassRoundtripTable',
      if (id != null) 'id': id,
      'intData':
          // ignore: unnecessary_type_check
          intData is _i1.ProtocolSerialization
          ? (intData as _i1.ProtocolSerialization).toJsonForProtocol()
          :
            // ignore: dead_code
            intData.toJson(),
      'doubleData':
          // ignore: unnecessary_type_check
          doubleData is _i1.ProtocolSerialization
          ? (doubleData as _i1.ProtocolSerialization).toJsonForProtocol()
          :
            // ignore: dead_code
            doubleData.toJson(),
      'stringData':
          // ignore: unnecessary_type_check
          stringData is _i1.ProtocolSerialization
          ? (stringData as _i1.ProtocolSerialization).toJsonForProtocol()
          :
            // ignore: dead_code
            stringData.toJson(),
      'boolData':
          // ignore: unnecessary_type_check
          boolData is _i1.ProtocolSerialization
          ? (boolData as _i1.ProtocolSerialization).toJsonForProtocol()
          :
            // ignore: dead_code
            boolData.toJson(),
      'dateTimeData':
          // ignore: unnecessary_type_check
          dateTimeData is _i1.ProtocolSerialization
          ? (dateTimeData as _i1.ProtocolSerialization).toJsonForProtocol()
          :
            // ignore: dead_code
            dateTimeData.toJson(),
      'mapData':
          // ignore: unnecessary_type_check
          mapData is _i1.ProtocolSerialization
          ? (mapData as _i1.ProtocolSerialization).toJsonForProtocol()
          :
            // ignore: dead_code
            mapData.toJson(),
      'jsonbMapData':
          // ignore: unnecessary_type_check
          jsonbMapData is _i1.ProtocolSerialization
          ? (jsonbMapData as _i1.ProtocolSerialization).toJsonForProtocol()
          :
            // ignore: dead_code
            jsonbMapData.toJson(),
      if (nullableIntData != null)
        'nullableIntData':
            // ignore: unnecessary_type_check
            nullableIntData is _i1.ProtocolSerialization
            ? (nullableIntData as _i1.ProtocolSerialization).toJsonForProtocol()
            :
              // ignore: dead_code
              nullableIntData?.toJson(),
      if (nullableMapData != null)
        'nullableMapData':
            // ignore: unnecessary_type_check
            nullableMapData is _i1.ProtocolSerialization
            ? (nullableMapData as _i1.ProtocolSerialization).toJsonForProtocol()
            :
              // ignore: dead_code
              nullableMapData?.toJson(),
    };
  }

  static CustomClassRoundtripTableInclude include() {
    return CustomClassRoundtripTableInclude._();
  }

  static CustomClassRoundtripTableIncludeList includeList({
    _i1.WhereExpressionBuilder<CustomClassRoundtripTableTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<CustomClassRoundtripTableTable>? orderBy,
    @Deprecated('Use desc() on the orderBy column instead.')
    bool orderDescending = false,
    _i1.OrderByListBuilder<CustomClassRoundtripTableTable>? orderByList,
    CustomClassRoundtripTableInclude? include,
  }) {
    return CustomClassRoundtripTableIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CustomClassRoundtripTable.t),
      orderDescending: // ignore: deprecated_member_use_from_same_package
          orderDescending,
      orderByList: orderByList?.call(CustomClassRoundtripTable.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CustomClassRoundtripTableImpl extends CustomClassRoundtripTable {
  _CustomClassRoundtripTableImpl({
    int? id,
    required _i2.IntCustomClass intData,
    required _i2.DoubleCustomClass doubleData,
    required _i2.CustomClass stringData,
    required _i2.BoolCustomClass boolData,
    required _i2.DateTimeCustomClass dateTimeData,
    required _i2.CustomClass2 mapData,
    required _i2.CustomClass2 jsonbMapData,
    _i2.IntCustomClass? nullableIntData,
    _i2.CustomClass2? nullableMapData,
  }) : super._(
         id: id,
         intData: intData,
         doubleData: doubleData,
         stringData: stringData,
         boolData: boolData,
         dateTimeData: dateTimeData,
         mapData: mapData,
         jsonbMapData: jsonbMapData,
         nullableIntData: nullableIntData,
         nullableMapData: nullableMapData,
       );

  /// Returns a shallow copy of this [CustomClassRoundtripTable]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  CustomClassRoundtripTable copyWith({
    Object? id = _Undefined,
    _i2.IntCustomClass? intData,
    _i2.DoubleCustomClass? doubleData,
    _i2.CustomClass? stringData,
    _i2.BoolCustomClass? boolData,
    _i2.DateTimeCustomClass? dateTimeData,
    _i2.CustomClass2? mapData,
    _i2.CustomClass2? jsonbMapData,
    Object? nullableIntData = _Undefined,
    Object? nullableMapData = _Undefined,
  }) {
    return CustomClassRoundtripTable(
      id: id is int? ? id : this.id,
      intData: intData ?? this.intData.copyWith(),
      doubleData: doubleData ?? this.doubleData.copyWith(),
      stringData: stringData ?? this.stringData.copyWith(),
      boolData: boolData ?? this.boolData.copyWith(),
      dateTimeData: dateTimeData ?? this.dateTimeData.copyWith(),
      mapData: mapData ?? this.mapData.copyWith(),
      jsonbMapData: jsonbMapData ?? this.jsonbMapData.copyWith(),
      nullableIntData: nullableIntData is _i2.IntCustomClass?
          ? nullableIntData
          : this.nullableIntData?.copyWith(),
      nullableMapData: nullableMapData is _i2.CustomClass2?
          ? nullableMapData
          : this.nullableMapData?.copyWith(),
    );
  }
}

class CustomClassRoundtripTableUpdateTable
    extends _i1.UpdateTable<CustomClassRoundtripTableTable> {
  CustomClassRoundtripTableUpdateTable(super.table);

  _i1.ColumnValue<int, int> intData(_i2.IntCustomClass value) =>
      _i1.ColumnValue(
        table.intData,
        value.toJson(),
      );

  _i1.ColumnValue<double, double> doubleData(_i2.DoubleCustomClass value) =>
      _i1.ColumnValue(
        table.doubleData,
        value.toJson(),
      );

  _i1.ColumnValue<String, String> stringData(_i2.CustomClass value) =>
      _i1.ColumnValue(
        table.stringData,
        value.toJson(),
      );

  _i1.ColumnValue<bool, bool> boolData(_i2.BoolCustomClass value) =>
      _i1.ColumnValue(
        table.boolData,
        value.toJson(),
      );

  _i1.ColumnValue<DateTime, DateTime> dateTimeData(
    _i2.DateTimeCustomClass value,
  ) => _i1.ColumnValue(
    table.dateTimeData,
    value.toJson(),
  );

  _i1.ColumnValue<_i2.CustomClass2, _i2.CustomClass2> mapData(
    _i2.CustomClass2 value,
  ) => _i1.ColumnValue(
    table.mapData,
    value,
  );

  _i1.ColumnValue<_i2.CustomClass2, _i2.CustomClass2> jsonbMapData(
    _i2.CustomClass2 value,
  ) => _i1.ColumnValue(
    table.jsonbMapData,
    value,
  );

  _i1.ColumnValue<int, int> nullableIntData(_i2.IntCustomClass? value) =>
      _i1.ColumnValue(
        table.nullableIntData,
        value?.toJson(),
      );

  _i1.ColumnValue<_i2.CustomClass2, _i2.CustomClass2> nullableMapData(
    _i2.CustomClass2? value,
  ) => _i1.ColumnValue(
    table.nullableMapData,
    value,
  );
}

class CustomClassRoundtripTableTable extends _i1.Table<int?> {
  CustomClassRoundtripTableTable({super.tableRelation})
    : super(tableName: 'custom_class_roundtrip_table') {
    updateTable = CustomClassRoundtripTableUpdateTable(this);
    intData = _i1.ColumnInt(
      'intData',
      this,
    );
    doubleData = _i1.ColumnDouble(
      'doubleData',
      this,
    );
    stringData = _i1.ColumnString(
      'stringData',
      this,
    );
    boolData = _i1.ColumnBool(
      'boolData',
      this,
    );
    dateTimeData = _i1.ColumnDateTime(
      'dateTimeData',
      this,
    );
    mapData = _i1.ColumnSerializable<_i2.CustomClass2>(
      'mapData',
      this,
    );
    jsonbMapData = _i1.ColumnStructured<_i2.CustomClass2>(
      'jsonbMapData',
      this,
    );
    nullableIntData = _i1.ColumnInt(
      'nullableIntData',
      this,
    );
    nullableMapData = _i1.ColumnSerializable<_i2.CustomClass2>(
      'nullableMapData',
      this,
    );
  }

  late final CustomClassRoundtripTableUpdateTable updateTable;

  late final _i1.ColumnInt intData;

  late final _i1.ColumnDouble doubleData;

  late final _i1.ColumnString stringData;

  late final _i1.ColumnBool boolData;

  late final _i1.ColumnDateTime dateTimeData;

  late final _i1.ColumnSerializable<_i2.CustomClass2> mapData;

  late final _i1.ColumnStructured<_i2.CustomClass2> jsonbMapData;

  late final _i1.ColumnInt nullableIntData;

  late final _i1.ColumnSerializable<_i2.CustomClass2> nullableMapData;

  @override
  List<_i1.Column> get columns => [
    id,
    intData,
    doubleData,
    stringData,
    boolData,
    dateTimeData,
    mapData,
    jsonbMapData,
    nullableIntData,
    nullableMapData,
  ];
}

class CustomClassRoundtripTableInclude extends _i1.IncludeObject {
  CustomClassRoundtripTableInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => CustomClassRoundtripTable.t;
}

class CustomClassRoundtripTableIncludeList extends _i1.IncludeList {
  CustomClassRoundtripTableIncludeList._({
    _i1.WhereExpressionBuilder<CustomClassRoundtripTableTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    @Deprecated('Use desc() on the orderBy column instead.')
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(CustomClassRoundtripTable.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => CustomClassRoundtripTable.t;
}

class CustomClassRoundtripTableRepository {
  const CustomClassRoundtripTableRepository._();

  /// Returns a list of [CustomClassRoundtripTable]s matching the given query parameters.
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
  Future<List<CustomClassRoundtripTable>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<CustomClassRoundtripTableTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<CustomClassRoundtripTableTable>? orderBy,
    @Deprecated('Use desc() on the orderBy column instead.')
    bool orderDescending = false,
    _i1.OrderByListBuilder<CustomClassRoundtripTableTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<CustomClassRoundtripTable>(
      where: where?.call(CustomClassRoundtripTable.t),
      orderBy: orderBy?.call(CustomClassRoundtripTable.t),
      orderByList: orderByList?.call(CustomClassRoundtripTable.t),
      orderDescending: // ignore: deprecated_member_use
          orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [CustomClassRoundtripTable] matching the given query parameters.
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
  Future<CustomClassRoundtripTable?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<CustomClassRoundtripTableTable>? where,
    int? offset,
    _i1.OrderByBuilder<CustomClassRoundtripTableTable>? orderBy,
    @Deprecated('Use desc() on the orderBy column instead.')
    bool orderDescending = false,
    _i1.OrderByListBuilder<CustomClassRoundtripTableTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<CustomClassRoundtripTable>(
      where: where?.call(CustomClassRoundtripTable.t),
      orderBy: orderBy?.call(CustomClassRoundtripTable.t),
      orderByList: orderByList?.call(CustomClassRoundtripTable.t),
      orderDescending: // ignore: deprecated_member_use
          orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [CustomClassRoundtripTable] by its [id] or null if no such row exists.
  Future<CustomClassRoundtripTable?> findById(
    _i1.DatabaseSession session,
    int id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<CustomClassRoundtripTable>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [CustomClassRoundtripTable]s in the list and returns the inserted rows.
  ///
  /// The returned [CustomClassRoundtripTable]s will have their `id` fields set.
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
  Future<List<CustomClassRoundtripTable>> insert(
    _i1.DatabaseSession session,
    List<CustomClassRoundtripTable> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<CustomClassRoundtripTable>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [CustomClassRoundtripTable] and returns the inserted row.
  ///
  /// The returned [CustomClassRoundtripTable] will have its `id` field set.
  Future<CustomClassRoundtripTable> insertRow(
    _i1.DatabaseSession session,
    CustomClassRoundtripTable row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<CustomClassRoundtripTable>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [CustomClassRoundtripTable]s in the list and returns the resulting rows.
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
  /// The returned [CustomClassRoundtripTable]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CustomClassRoundtripTable>> upsert(
    _i1.DatabaseSession session,
    List<CustomClassRoundtripTable> rows, {
    required _i1.ColumnSelections<CustomClassRoundtripTableTable>
    conflictColumns,
    _i1.ColumnSelections<CustomClassRoundtripTableTable>? updateColumns,
    _i1.WhereExpressionBuilder<CustomClassRoundtripTableTable>? updateWhere,
    _i1.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<CustomClassRoundtripTable>(
      rows,
      conflictColumns: conflictColumns(CustomClassRoundtripTable.t),
      updateColumns: updateColumns?.call(CustomClassRoundtripTable.t),
      updateWhere: updateWhere?.call(CustomClassRoundtripTable.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [CustomClassRoundtripTable] and returns the resulting row.
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
  /// The returned [CustomClassRoundtripTable] will have its `id` field set.
  Future<CustomClassRoundtripTable?> upsertRow(
    _i1.DatabaseSession session,
    CustomClassRoundtripTable row, {
    required _i1.ColumnSelections<CustomClassRoundtripTableTable>
    conflictColumns,
    _i1.ColumnSelections<CustomClassRoundtripTableTable>? updateColumns,
    _i1.WhereExpressionBuilder<CustomClassRoundtripTableTable>? updateWhere,
    _i1.Transaction? transaction,
  }) async {
    return session.db.upsertRow<CustomClassRoundtripTable>(
      row,
      conflictColumns: conflictColumns(CustomClassRoundtripTable.t),
      updateColumns: updateColumns?.call(CustomClassRoundtripTable.t),
      updateWhere: updateWhere?.call(CustomClassRoundtripTable.t),
      transaction: transaction,
    );
  }

  /// Updates all [CustomClassRoundtripTable]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CustomClassRoundtripTable>> update(
    _i1.DatabaseSession session,
    List<CustomClassRoundtripTable> rows, {
    _i1.ColumnSelections<CustomClassRoundtripTableTable>? columns,
    _i1.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<CustomClassRoundtripTable>(
      rows,
      columns: columns?.call(CustomClassRoundtripTable.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [CustomClassRoundtripTable]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<CustomClassRoundtripTable> updateRow(
    _i1.DatabaseSession session,
    CustomClassRoundtripTable row, {
    _i1.ColumnSelections<CustomClassRoundtripTableTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<CustomClassRoundtripTable>(
      row,
      columns: columns?.call(CustomClassRoundtripTable.t),
      transaction: transaction,
    );
  }

  /// Updates a single [CustomClassRoundtripTable] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<CustomClassRoundtripTable?> updateById(
    _i1.DatabaseSession session,
    int id, {
    required _i1.ColumnValueListBuilder<CustomClassRoundtripTableUpdateTable>
    columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<CustomClassRoundtripTable>(
      id,
      columnValues: columnValues(CustomClassRoundtripTable.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [CustomClassRoundtripTable]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CustomClassRoundtripTable>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<CustomClassRoundtripTableUpdateTable>
    columnValues,
    required _i1.WhereExpressionBuilder<CustomClassRoundtripTableTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<CustomClassRoundtripTableTable>? orderBy,
    _i1.OrderByListBuilder<CustomClassRoundtripTableTable>? orderByList,
    @Deprecated('Use desc() on the orderBy column instead.')
    bool orderDescending = false,
    _i1.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<CustomClassRoundtripTable>(
      columnValues: columnValues(CustomClassRoundtripTable.t.updateTable),
      where: where(CustomClassRoundtripTable.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CustomClassRoundtripTable.t),
      orderByList: orderByList?.call(CustomClassRoundtripTable.t),
      orderDescending: // ignore: deprecated_member_use
          orderDescending,
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [CustomClassRoundtripTable]s in the list and returns the deleted rows.
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
  Future<List<CustomClassRoundtripTable>> delete(
    _i1.DatabaseSession session,
    List<CustomClassRoundtripTable> rows, {
    _i1.OrderByBuilder<CustomClassRoundtripTableTable>? orderBy,
    @Deprecated('Use desc() on the orderBy column instead.')
    bool orderDescending = false,
    _i1.OrderByListBuilder<CustomClassRoundtripTableTable>? orderByList,
    _i1.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<CustomClassRoundtripTable>(
      rows,
      orderBy: orderBy?.call(CustomClassRoundtripTable.t),
      orderByList: orderByList?.call(CustomClassRoundtripTable.t),
      orderDescending: // ignore: deprecated_member_use
          orderDescending,
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [CustomClassRoundtripTable].
  Future<CustomClassRoundtripTable> deleteRow(
    _i1.DatabaseSession session,
    CustomClassRoundtripTable row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<CustomClassRoundtripTable>(
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
  Future<List<CustomClassRoundtripTable>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<CustomClassRoundtripTableTable> where,
    _i1.OrderByBuilder<CustomClassRoundtripTableTable>? orderBy,
    @Deprecated('Use desc() on the orderBy column instead.')
    bool orderDescending = false,
    _i1.OrderByListBuilder<CustomClassRoundtripTableTable>? orderByList,
    _i1.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<CustomClassRoundtripTable>(
      where: where(CustomClassRoundtripTable.t),
      orderBy: orderBy?.call(CustomClassRoundtripTable.t),
      orderByList: orderByList?.call(CustomClassRoundtripTable.t),
      orderDescending: // ignore: deprecated_member_use
          orderDescending,
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<CustomClassRoundtripTableTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<CustomClassRoundtripTable>(
      where: where?.call(CustomClassRoundtripTable.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [CustomClassRoundtripTable] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<CustomClassRoundtripTableTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<CustomClassRoundtripTable>(
      where: where(CustomClassRoundtripTable.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
