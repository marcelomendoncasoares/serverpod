import 'dart:convert';
import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:serverpod_serialization/serverpod_serialization.dart';

import '../../../serverpod_database.dart';

/// A [SerializationManagerServer] that reverts values stored by
/// [SqliteValueEncoder] when deserializing rows from SQLite.
///
/// SQLite returns some types differently than JSON/protocol encoding expects:
/// - Booleans are stored as 0/1 and returned as [int]
/// - [ByteData] is stored as BLOB (X'hex') and returned as [Uint8List]
///
/// This manager converts those values back before delegating to the underlying
/// [SerializationManagerServer].
@internal
class SqliteSerializationManager extends SerializationManagerServer {
  final SerializationManagerServer _delegate;

  SqliteSerializationManager(this._delegate);

  @override
  T deserialize<T>(dynamic data, [Type? t]) {
    t ??= T;
    data = _revertSqliteValue(data, t);
    data = _revertRowMapByteDataColumns(data, t);
    return _delegate.deserialize<T>(data, t);
  }

  /// Reverts SQLite-specific encodings from [SqliteValueEncoder] back to
  /// the format expected by the standard deserialization (JSON/protocol).
  static dynamic _revertSqliteValue(dynamic data, Type t) {
    if (data == null) return null;

    // SQLite has no native boolean; we store 1/0 and get int back.
    if (_isBoolType(t) && data is int) {
      return data == 1;
    }

    if (_isDateTimeType(t) && data is int) {
      return DateTime.fromMillisecondsSinceEpoch(data, isUtc: true);
    }

    if (_isUuidType(t)) {
      if (data is String) return UuidValueJsonExtension.fromJson(data);
      // BLOB columns return Uint8List or List (List<int>/List<dynamic> from sqlite3).
      if (data is Uint8List && data.length == 16) {
        return UuidValueJsonExtension.fromJson(data);
      }
      if (data is List && data.length == 16) {
        return UuidValueJsonExtension.fromJson(
          Uint8List.fromList(data.map((e) => e as int).toList()),
        );
      }
    }

    // Recursively revert row maps/lists so nested JSON strings become Map/List.
    // SQLite returns JSON columns as text; protocol expects nested Map/list.
    data = _revertSqliteValueInRow(data);

    // ByteData is stored as BLOB (X'hex'); sqlite3 returns Uint8List or List.
    // Legacy: also support base64 text for backwards compatibility.
    if (_isByteDataType(t)) {
      if (data is Uint8List) {
        return ByteData.view(data.buffer, data.offsetInBytes, data.length);
      }
      if (data is List && data.isNotEmpty && data.first is int) {
        return ByteData.view(
          Uint8List.fromList(data.map((e) => e as int).toList()).buffer,
        );
      }
      if (data is String && !data.startsWith('decode(')) {
        return ByteData.view(base64Decode(data).buffer);
      }
    }

    return data;
  }

  /// Recursively parses JSON strings in row data (Map/List) so that nested
  /// object and list columns from SQLite (stored as text) become Map/List
  /// as expected by Protocol deserialization. Returns [Map<String, dynamic>]
  /// and [List] so protocol deserialization gets the expected types (jsonDecode
  /// returns [Map<dynamic, dynamic>]).
  ///
  /// Strings that look like JSON but fail to parse (e.g. SparseVector/Vector
  /// text format like "{1:1.0}/3") are left unchanged so protocol
  /// deserialization can handle them (e.g. SparseVectorJsonExtension.fromJson).
  static dynamic _revertSqliteValueInRow(dynamic data) {
    if (data == null) return null;
    if (data is String) {
      final trimmed = data.trim();
      if (trimmed.startsWith('{') || trimmed.startsWith('[')) {
        try {
          return _revertSqliteValueInRow(jsonDecode(data));
        } on FormatException {
          // Not valid JSON; leave as string (e.g. SparseVector/Vector text format).
          return data;
        }
      }
      return data;
    }
    if (data is Map) {
      return Map<String, dynamic>.from(
        data.map(
          (k, v) => MapEntry(
            k is String ? k : k.toString(),
            _revertSqliteValueInRow(v),
          ),
        ),
      );
    }
    if (data is List) {
      return data.map(_revertSqliteValueInRow).toList();
    }
    return data;
  }

  static bool _isBoolType(Type t) => t == bool || t == _typeOfNullableBool;

  static bool _isDateTimeType(Type t) =>
      t == DateTime || t == _typeOfNullableDateTime;

  static bool _isUuidType(Type t) => t == UuidValue || t == _typeOfNullableUuid;

  static bool _isByteDataType(Type t) =>
      t == ByteData || t == _typeOfNullableByteData;

  static Type get _typeOfNullableBool => _typeOf<bool?>();
  static Type get _typeOfNullableDateTime => _typeOf<DateTime?>();
  static Type get _typeOfNullableByteData => _typeOf<ByteData?>();
  static Type get _typeOfNullableUuid => _typeOf<UuidValue?>();
  static Type _typeOf<T>() => T;

  /// For row maps (TableRow), convert BLOB columns (List/Uint8List from SQLite)
  /// to ByteData so protocol deserialization receives the expected type.
  dynamic _revertRowMapByteDataColumns(dynamic data, Type t) {
    if (data is! Map<String, dynamic>) return data;
    final table = getTableForType(t);
    if (table == null) return data;
    final result = Map<String, dynamic>.from(data);
    for (final col in table.columns) {
      if (col is! ColumnByteData) continue;
      final key = col.fieldName;
      final v = result[key];
      if (v == null) continue;
      if (v is Uint8List) {
        result[key] = ByteData.view(v.buffer, v.offsetInBytes, v.length);
      } else if (v is List && v.isNotEmpty && v.first is int) {
        result[key] = ByteData.view(
          Uint8List.fromList(v.map((e) => e as int).toList()).buffer,
        );
      }
    }
    return result;
  }

  @override
  String getModuleName() => _delegate.getModuleName();

  @override
  Table? getTableForType(Type t) => _delegate.getTableForType(t);

  @override
  List<TableDefinition> getTargetTableDefinitions() =>
      _delegate.getTargetTableDefinitions();
}
