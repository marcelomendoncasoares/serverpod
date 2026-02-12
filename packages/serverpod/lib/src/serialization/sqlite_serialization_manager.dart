import 'dart:convert';
import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:serverpod/protocol.dart';
import 'package:serverpod/serverpod.dart';

/// A [SerializationManagerServer] that reverts values stored by
/// [SqliteValueEncoder] when deserializing rows from SQLite.
///
/// SQLite returns some types differently than JSON/protocol encoding expects:
/// - Booleans are stored as 0/1 and returned as [int]
/// - [ByteData] is stored as raw base64 and returned as [String]
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

    // We store ByteData as raw base64; protocol expects "decode('...','base64')".
    // ByteDataJsonExtension.fromJson(string) uses base64DecodedNullSafeByteData()
    // which expects that wrapper. So convert raw base64 to ByteData here.
    if (_isByteDataType(t) && data is String && !data.startsWith('decode(')) {
      return ByteData.view(base64Decode(data).buffer);
    }

    return data;
  }

  static bool _isBoolType(Type t) => t == bool || t == _typeOfNullableBool;

  static bool _isByteDataType(Type t) =>
      t == ByteData || t == _typeOfNullableByteData;

  static Type get _typeOfNullableBool => _typeOf<bool?>();
  static Type get _typeOfNullableByteData => _typeOf<ByteData?>();
  static Type _typeOf<T>() => T;

  @override
  String getModuleName() => _delegate.getModuleName();

  @override
  Table? getTableForType(Type t) => _delegate.getTableForType(t);

  @override
  List<TableDefinition> getTargetTableDefinitions() =>
      _delegate.getTargetTableDefinitions();
}
