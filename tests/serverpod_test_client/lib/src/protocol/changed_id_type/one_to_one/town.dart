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
import 'package:serverpod_serialization/serverpod_serialization.dart' as _iss;
import 'package:serverpod_test_client/src/protocol/protocol.dart' as _iza9lbb5;
import '../../changed_id_type/one_to_one/citizen.dart' as _i7hzilwf;

abstract class TownInt
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  TownInt._({
    this.id,
    required this.name,
    this.mayorId,
    Object? mayor = #serverpodUnloadedRelation,
  }) : _mayor$loaded = !identical(
         mayor,
         #serverpodUnloadedRelation,
       ),
       _mayor =
           !identical(
             mayor,
             #serverpodUnloadedRelation,
           )
           ? (mayor as _i7hzilwf.CitizenInt?)
           : null;

  factory TownInt({
    int? id,
    required String name,
    int? mayorId,
    _i7hzilwf.CitizenInt? mayor,
  }) = _TownIntImpl;

  factory TownInt.fromJson(Map<String, dynamic> jsonSerialization) {
    return _TownIntImpl(
      id: jsonSerialization['id'] as int?,
      name: jsonSerialization['name'] as String,
      mayorId: jsonSerialization['mayorId'] as int?,
      mayor: jsonSerialization.containsKey('mayor')
          ? jsonSerialization['mayor'] == null
                ? null
                : _iza9lbb5.Protocol().deserialize<_i7hzilwf.CitizenInt>(
                    jsonSerialization['mayor'],
                  )
          : #serverpodUnloadedRelation,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String name;

  int? mayorId;

  bool _mayor$loaded;

  _i7hzilwf.CitizenInt? _mayor;

  /// Throws `RelationNotLoadedError` if this relation was not loaded.
  _i7hzilwf.CitizenInt? get mayor {
    final value = _mayor;
    if (!_mayor$loaded) {
      throw _iss.RelationNotLoadedError(
        model: 'TownInt',
        relation: 'mayor',
      );
    }
    return value;
  }

  set mayor(_i7hzilwf.CitizenInt? value) {
    _mayor = value;
    _mayor$loaded = true;
  }

  /// Returns a shallow copy of this [TownInt]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  TownInt copyWith({
    int? id,
    String? name,
    int? mayorId,
    Object? mayor = _Undefined,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'TownInt',
      if (id != null) 'id': id,
      'name': name,
      if (mayorId != null) 'mayorId': mayorId,
      if (_mayor$loaded) 'mayor': _mayor?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'TownInt',
      if (id != null) 'id': id,
      'name': name,
      if (mayorId != null) 'mayorId': mayorId,
      if (_mayor$loaded) 'mayor': _mayor?.toJsonForProtocol(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _TownIntImpl extends TownInt {
  _TownIntImpl({
    int? id,
    required String name,
    int? mayorId,
    Object? mayor = #serverpodUnloadedRelation,
  }) : super._(
         id: id,
         name: name,
         mayorId: mayorId,
         mayor: mayor,
       );

  /// Returns a shallow copy of this [TownInt]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  TownInt copyWith({
    Object? id = _Undefined,
    String? name,
    Object? mayorId = _Undefined,
    Object? mayor = _Undefined,
  }) {
    return _TownIntImpl(
      id: id is int? ? id : this.id,
      name: name ?? this.name,
      mayorId: mayorId is int? ? mayorId : this.mayorId,
      mayor: mayor is _i7hzilwf.CitizenInt?
          ? mayor?.copyWith()
          : _mayor$loaded
          ? this._mayor?.copyWith()
          : #serverpodUnloadedRelation,
    );
  }
}
