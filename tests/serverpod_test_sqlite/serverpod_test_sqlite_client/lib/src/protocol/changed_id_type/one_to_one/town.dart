/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member
// ignore_for_file: depend_on_referenced_packages

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import 'package:serverpod_serialization/serverpod_serialization.dart' as _iss;
import 'package:serverpod_serialization/undefined_sentinel.dart' as _issu;
import 'package:serverpod_test_sqlite_client/src/protocol/protocol.dart'
    as _i0ntutnq;
import '../../changed_id_type/one_to_one/citizen.dart' as _i7hzilwf;

@_isc.immutable
abstract class TownInt
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  const TownInt._({
    this.id,
    required this.name,
    this.mayorId,
    _i7hzilwf.CitizenInt? mayor = const _UndefinedTownInt$mayor(),
  }) : _mayor = mayor;

  const factory TownInt({
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
                : _i0ntutnq.Protocol().deserialize<_i7hzilwf.CitizenInt>(
                    jsonSerialization['mayor'],
                  )
          : const _UndefinedTownInt$mayor(),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  final int? id;

  final String name;

  final int? mayorId;

  final _i7hzilwf.CitizenInt? _mayor;

  /// Throws `RelationNotLoadedError` if this relation was not loaded.
  _i7hzilwf.CitizenInt? get mayor {
    final value = _mayor;
    if (value is _issu.UndefinedSentinel) {
      throw _iss.RelationNotLoadedError(
        model: 'TownInt',
        relation: 'mayor',
      );
    }
    return value;
  }

  /// Returns a shallow copy of this [TownInt]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  TownInt copyWith({
    int? id,
    String? name,
    int? mayorId,
    _i7hzilwf.CitizenInt? mayor = const _UndefinedTownInt$mayor(),
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is TownInt &&
            (identical(
                  other.id,
                  id,
                ) ||
                other.id == id) &&
            (identical(
                  other.name,
                  name,
                ) ||
                other.name == name) &&
            (identical(
                  other.mayorId,
                  mayorId,
                ) ||
                other.mayorId == mayorId) &&
            (_mayor is _issu.UndefinedSentinel
                ? other._mayor is _issu.UndefinedSentinel
                : other._mayor is! _issu.UndefinedSentinel &&
                      (identical(
                            other._mayor,
                            _mayor,
                          ) ||
                          other._mayor == _mayor));
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      id,
      name,
      mayorId,
      _mayor is _issu.UndefinedSentinel ? _issu.UndefinedSentinel : _mayor,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'TownInt',
      if (id != null) 'id': id,
      'name': name,
      if (mayorId != null) 'mayorId': mayorId,
      if (_mayor is! _issu.UndefinedSentinel) 'mayor': _mayor?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'TownInt',
      if (id != null) 'id': id,
      'name': name,
      if (mayorId != null) 'mayorId': mayorId,
      if (_mayor is! _issu.UndefinedSentinel)
        'mayor': _mayor?.toJsonForProtocol(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _UndefinedTownInt$mayor extends _issu.UndefinedSentinel
    implements _i7hzilwf.CitizenInt {
  const _UndefinedTownInt$mayor();
}

class _TownIntImpl extends TownInt {
  const _TownIntImpl({
    int? id,
    required String name,
    int? mayorId,
    _i7hzilwf.CitizenInt? mayor = const _UndefinedTownInt$mayor(),
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
    _i7hzilwf.CitizenInt? mayor = const _UndefinedTownInt$mayor(),
  }) {
    return _TownIntImpl(
      id: id is int? ? id : this.id,
      name: name ?? this.name,
      mayorId: mayorId is int? ? mayorId : this.mayorId,
      mayor: mayor is _issu.UndefinedSentinel
          ? _mayor is _issu.UndefinedSentinel
                ? _mayor
                : this._mayor?.copyWith()
          : mayor?.copyWith(),
    );
  }
}
