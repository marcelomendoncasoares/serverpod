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

abstract class DateTimeIdDefaultModel
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  DateTimeIdDefaultModel._({
    DateTime? id,
    required this.value,
  }) : id = id ?? DateTime.now();

  factory DateTimeIdDefaultModel({
    DateTime? id,
    required String value,
  }) = _DateTimeIdDefaultModelImpl;

  factory DateTimeIdDefaultModel.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return DateTimeIdDefaultModel(
      id: jsonSerialization['id'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['id']),
      value: jsonSerialization['value'] as String,
    );
  }

  /// The id of the object.
  DateTime id;

  String value;

  /// Returns a shallow copy of this [DateTimeIdDefaultModel]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  DateTimeIdDefaultModel copyWith({
    DateTime? id,
    String? value,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'DateTimeIdDefaultModel',
      'id': id.toJson(),
      'value': value,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'DateTimeIdDefaultModel',
      'id': id.toJson(),
      'value': value,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _DateTimeIdDefaultModelImpl extends DateTimeIdDefaultModel {
  _DateTimeIdDefaultModelImpl({
    DateTime? id,
    required String value,
  }) : super._(
         id: id,
         value: value,
       );

  /// Returns a shallow copy of this [DateTimeIdDefaultModel]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  DateTimeIdDefaultModel copyWith({
    DateTime? id,
    String? value,
  }) {
    return DateTimeIdDefaultModel(
      id: id ?? this.id,
      value: value ?? this.value,
    );
  }
}
