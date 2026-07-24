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
import 'package:serverpod_client/serverpod_client.dart' as _i1;
import 'package:serverpod_test_shared/serverpod_test_shared.dart' as _i2;

abstract class CustomClassRoundtripTable
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
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

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
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
