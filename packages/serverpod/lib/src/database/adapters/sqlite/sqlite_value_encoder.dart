import 'dart:convert';
import 'dart:typed_data';

import 'package:serverpod/serverpod.dart';
import 'package:serverpod/src/database/concepts/value_encoder.dart';

/// Encodes values for SQLite SQL literals.
/// Produces the same style of literals as the Postgres encoder for use in
/// shared query builders (no type casts; SQLite does not use ::type).
class SqliteValueEncoder implements ValueEncoder {
  @override
  String convert(
    dynamic input, {
    bool escapeStrings = true,
    bool hasDefaults = false,
  }) {
    if (input == null) {
      return hasDefaults ? 'DEFAULT' : 'NULL';
    }
    if (input is bool) {
      return input ? '1' : '0';
    }
    if (input is int) {
      return input.toString();
    }
    if (input is double) {
      if (input.isNaN) return 'NULL';
      if (input.isInfinite) return input.isNegative ? '-1e999' : '1e999';
      return input.toString();
    }
    if (input is String) {
      if (!escapeStrings) return input;
      return "'${_escapeString(input)}'";
    }
    if (input is ByteData) {
      final bytes = input.buffer.asUint8List(input.offsetInBytes, input.lengthInBytes);
      return "'${_escapeString(base64Encode(bytes))}'";
    }
    if (input is DateTime) {
      return "'${_escapeString(SerializationManager.encode(input))}'";
    }
    if (input is Duration) {
      return SerializationManager.encode(input).toString();
    }
    if (input is UuidValue) {
      return "'${input.uuid}'";
    }
    if (input is Uri) {
      return "'${_escapeString(input.toString())}'";
    }
    if (input is BigInt) {
      return "'${input.toString()}'";
    }
    if (input is String &&
        input.startsWith('decode(\'') &&
        input.endsWith('\', \'base64\')')) {
      return input;
    }
    // pgvector types: store as text for SQLite (no native vector support)
    if (input is Vector) {
      return '\'${_escapeString(input.toString().replaceAll(' ', ''))}\'';
    }
    if (input is HalfVector) {
      return '\'${_escapeString(input.toString().replaceAll(' ', ''))}\'';
    }
    if (input is SparseVector) {
      return '\'${_escapeString(input.toString())}\'';
    }
    if (input is Bit) {
      return '\'${_escapeString(input.toString())}\'';
    }
    if (input is SerializableModel && input is Enum) {
      return "'${_escapeString(SerializationManager.encode(input.toJson()))}'";
    }
    if (input is List || input is Map || input is Set) {
      return "'${_escapeString(SerializationManager.encode(input))}'";
    }

    try {
      return _convertScalar(input, escapeStrings: escapeStrings);
    } catch (_) {
      return "'${_escapeString(SerializationManager.encode(input))}'";
    }
  }

  String _convertScalar(dynamic input, {required bool escapeStrings}) {
    if (input is num) return input.toString();
    if (input is String) return "'${_escapeString(input)}'";
    return "'${_escapeString(SerializationManager.encode(input))}'";
  }

  static String _escapeString(String s) {
    return s.replaceAll("'", "''");
  }

  @override
  String? tryConvert(Object? input, {bool escapeStrings = false}) {
    try {
      return convert(input, escapeStrings: escapeStrings);
    } catch (_) {
      return null;
    }
  }
}
