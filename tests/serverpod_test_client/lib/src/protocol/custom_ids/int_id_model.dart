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

abstract class IntIdModel
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  IntIdModel._({
    required this.id,
    required this.value,
  });

  factory IntIdModel({
    required int id,
    required String value,
  }) = _IntIdModelImpl;

  factory IntIdModel.fromJson(Map<String, dynamic> jsonSerialization) {
    return IntIdModel(
      id: jsonSerialization['id'] as int,
      value: jsonSerialization['value'] as String,
    );
  }

  /// The id of the object.
  int id;

  String value;

  /// Returns a shallow copy of this [IntIdModel]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  IntIdModel copyWith({
    int? id,
    String? value,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'IntIdModel',
      'id': id,
      'value': value,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'IntIdModel',
      'id': id,
      'value': value,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _IntIdModelImpl extends IntIdModel {
  _IntIdModelImpl({
    required int id,
    required String value,
  }) : super._(
         id: id,
         value: value,
       );

  /// Returns a shallow copy of this [IntIdModel]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  IntIdModel copyWith({
    int? id,
    String? value,
  }) {
    return IntIdModel(
      id: id ?? this.id,
      value: value ?? this.value,
    );
  }
}
