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
import 'package:serverpod_test_sqlite_client/src/protocol/protocol.dart'
    as _i0ntutnq;
import '../custom_ids/custom_id_related.dart' as _i2m035mh;

abstract class StringIdModel
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
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
          : _i0ntutnq.Protocol().deserialize<List<_i2m035mh.CustomIdRelated>>(
              jsonSerialization['related'],
            ),
    );
  }

  /// The id of the object.
  String id;

  String value;

  List<_i2m035mh.CustomIdRelated>? related;

  /// Returns a shallow copy of this [StringIdModel]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  StringIdModel copyWith({
    String? id,
    String? value,
    List<_i2m035mh.CustomIdRelated>? related =
        const _isc.$UndefinedList<_i2m035mh.CustomIdRelated>(),
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

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
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
  @_isc.useResult
  @override
  StringIdModel copyWith({
    String? id,
    String? value,
    List<_i2m035mh.CustomIdRelated>? related =
        const _isc.$UndefinedList<_i2m035mh.CustomIdRelated>(),
  }) {
    return StringIdModel(
      id: id ?? this.id,
      value: value ?? this.value,
      related: related is _isc.UndefinedSentinel
          ? this.related?.map((e0) => e0.copyWith()).toList()
          : related,
    );
  }
}
