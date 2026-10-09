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
import 'package:serverpod_client/serverpod_client.dart' as _isc;

abstract class UuidIdModel
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  UuidIdModel._({
    required this.id,
    required this.value,
  });

  factory UuidIdModel({
    required _isc.UuidValue id,
    required String value,
  }) = _UuidIdModelImpl;

  factory UuidIdModel.fromJson(Map<String, dynamic> jsonSerialization) {
    return UuidIdModel(
      id: _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      value: jsonSerialization['value'] as String,
    );
  }

  /// The id of the object.
  _isc.UuidValue id;

  String value;

  /// Returns a shallow copy of this [UuidIdModel]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  UuidIdModel copyWith({
    _isc.UuidValue? id,
    String? value,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'UuidIdModel',
      'id': id.toJson(),
      'value': value,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'UuidIdModel',
      'id': id.toJson(),
      'value': value,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _UuidIdModelImpl extends UuidIdModel {
  _UuidIdModelImpl({
    required _isc.UuidValue id,
    required String value,
  }) : super._(
         id: id,
         value: value,
       );

  /// Returns a shallow copy of this [UuidIdModel]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  UuidIdModel copyWith({
    _isc.UuidValue? id,
    String? value,
  }) {
    return UuidIdModel(
      id: id ?? this.id,
      value: value ?? this.value,
    );
  }
}
