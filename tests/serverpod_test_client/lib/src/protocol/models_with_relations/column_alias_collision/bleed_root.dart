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
import 'package:serverpod_test_client/src/protocol/protocol.dart' as _iza9lbb5;
import '../../models_with_relations/column_alias_collision/bleed_child.dart'
    as _i2rsfnut;

/// Root model used to reproduce the include column-alias collision in
/// https://github.com/serverpod/serverpod/issues/5287
///
/// Two relations point at the same child table (`bleed_child`). Their relation
/// field names are intentionally long so the generated relation/column aliases
/// are truncated to the Postgres 63 character identifier limit. With these exact
/// names the truncated SELECT alias of the first relation's `id` column collides
/// with the second relation's `bleedingText` column, so the string value bleeds
/// into the int `id` field on deserialization.
///
/// The two relations are declared with explicit `field=` foreign keys so the FK
/// column names stay short (the long names only affect the relation aliases).
abstract class BleedRoot
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  BleedRoot._({
    this.id,
    required this.name,
    this.firstChildId,
    _i2rsfnut.BleedChild? childRelationWithExtremelyLongFieldNameForcingTrun24 =
        const _UndefinedBleedRoot$childRelationWithExtremelyLongFieldNameForcingTrun24(),
    this.secondChildId,
    _i2rsfnut.BleedChild? childRelationWithExtremelyLongFieldNameForcingTrun23 =
        const _UndefinedBleedRoot$childRelationWithExtremelyLongFieldNameForcingTrun24(),
  }) : _childRelationWithExtremelyLongFieldNameForcingTrun24 =
           childRelationWithExtremelyLongFieldNameForcingTrun24,
       _childRelationWithExtremelyLongFieldNameForcingTrun23 =
           childRelationWithExtremelyLongFieldNameForcingTrun23;

  factory BleedRoot({
    int? id,
    required String name,
    int? firstChildId,
    _i2rsfnut.BleedChild? childRelationWithExtremelyLongFieldNameForcingTrun24,
    int? secondChildId,
    _i2rsfnut.BleedChild? childRelationWithExtremelyLongFieldNameForcingTrun23,
  }) = _BleedRootImpl;

  factory BleedRoot.fromJson(Map<String, dynamic> jsonSerialization) {
    return _BleedRootImpl(
      id: jsonSerialization['id'] as int?,
      name: jsonSerialization['name'] as String,
      firstChildId: jsonSerialization['firstChildId'] as int?,
      childRelationWithExtremelyLongFieldNameForcingTrun24:
          jsonSerialization.containsKey(
            'childRelationWithExtremelyLongFieldNameForcingTrun24',
          )
          ? jsonSerialization['childRelationWithExtremelyLongFieldNameForcingTrun24'] ==
                    null
                ? null
                : _iza9lbb5.Protocol().deserialize<_i2rsfnut.BleedChild>(
                    jsonSerialization['childRelationWithExtremelyLongFieldNameForcingTrun24'],
                  )
          : const _UndefinedBleedRoot$childRelationWithExtremelyLongFieldNameForcingTrun24(),
      secondChildId: jsonSerialization['secondChildId'] as int?,
      childRelationWithExtremelyLongFieldNameForcingTrun23:
          jsonSerialization.containsKey(
            'childRelationWithExtremelyLongFieldNameForcingTrun23',
          )
          ? jsonSerialization['childRelationWithExtremelyLongFieldNameForcingTrun23'] ==
                    null
                ? null
                : _iza9lbb5.Protocol().deserialize<_i2rsfnut.BleedChild>(
                    jsonSerialization['childRelationWithExtremelyLongFieldNameForcingTrun23'],
                  )
          : const _UndefinedBleedRoot$childRelationWithExtremelyLongFieldNameForcingTrun24(),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String name;

  int? firstChildId;

  _i2rsfnut.BleedChild? _childRelationWithExtremelyLongFieldNameForcingTrun24;

  int? secondChildId;

  _i2rsfnut.BleedChild? _childRelationWithExtremelyLongFieldNameForcingTrun23;

  /// Throws `RelationNotLoadedError` if this relation was not loaded.
  _i2rsfnut.BleedChild?
  get childRelationWithExtremelyLongFieldNameForcingTrun24 {
    final value = _childRelationWithExtremelyLongFieldNameForcingTrun24;
    if (value is _issu.UndefinedSentinel) {
      throw _iss.RelationNotLoadedError(
        model: 'BleedRoot',
        relation: 'childRelationWithExtremelyLongFieldNameForcingTrun24',
      );
    }
    return value;
  }

  set childRelationWithExtremelyLongFieldNameForcingTrun24(
    _i2rsfnut.BleedChild? value,
  ) {
    _childRelationWithExtremelyLongFieldNameForcingTrun24 = value;
  }

  /// Throws `RelationNotLoadedError` if this relation was not loaded.
  _i2rsfnut.BleedChild?
  get childRelationWithExtremelyLongFieldNameForcingTrun23 {
    final value = _childRelationWithExtremelyLongFieldNameForcingTrun23;
    if (value is _issu.UndefinedSentinel) {
      throw _iss.RelationNotLoadedError(
        model: 'BleedRoot',
        relation: 'childRelationWithExtremelyLongFieldNameForcingTrun23',
      );
    }
    return value;
  }

  set childRelationWithExtremelyLongFieldNameForcingTrun23(
    _i2rsfnut.BleedChild? value,
  ) {
    _childRelationWithExtremelyLongFieldNameForcingTrun23 = value;
  }

  /// Returns a shallow copy of this [BleedRoot]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  BleedRoot copyWith({
    int? id,
    String? name,
    int? firstChildId,
    _i2rsfnut.BleedChild? childRelationWithExtremelyLongFieldNameForcingTrun24 =
        const _UndefinedBleedRoot$childRelationWithExtremelyLongFieldNameForcingTrun24(),
    int? secondChildId,
    _i2rsfnut.BleedChild? childRelationWithExtremelyLongFieldNameForcingTrun23 =
        const _UndefinedBleedRoot$childRelationWithExtremelyLongFieldNameForcingTrun24(),
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'BleedRoot',
      if (id != null) 'id': id,
      'name': name,
      if (firstChildId != null) 'firstChildId': firstChildId,
      if (_childRelationWithExtremelyLongFieldNameForcingTrun24
          is! _issu.UndefinedSentinel)
        'childRelationWithExtremelyLongFieldNameForcingTrun24':
            _childRelationWithExtremelyLongFieldNameForcingTrun24?.toJson(),
      if (secondChildId != null) 'secondChildId': secondChildId,
      if (_childRelationWithExtremelyLongFieldNameForcingTrun23
          is! _issu.UndefinedSentinel)
        'childRelationWithExtremelyLongFieldNameForcingTrun23':
            _childRelationWithExtremelyLongFieldNameForcingTrun23?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'BleedRoot',
      if (id != null) 'id': id,
      'name': name,
      if (firstChildId != null) 'firstChildId': firstChildId,
      if (_childRelationWithExtremelyLongFieldNameForcingTrun24
          is! _issu.UndefinedSentinel)
        'childRelationWithExtremelyLongFieldNameForcingTrun24':
            _childRelationWithExtremelyLongFieldNameForcingTrun24
                ?.toJsonForProtocol(),
      if (secondChildId != null) 'secondChildId': secondChildId,
      if (_childRelationWithExtremelyLongFieldNameForcingTrun23
          is! _issu.UndefinedSentinel)
        'childRelationWithExtremelyLongFieldNameForcingTrun23':
            _childRelationWithExtremelyLongFieldNameForcingTrun23
                ?.toJsonForProtocol(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _UndefinedBleedRoot$childRelationWithExtremelyLongFieldNameForcingTrun24
    extends _issu.UndefinedSentinel
    implements _i2rsfnut.BleedChild {
  const _UndefinedBleedRoot$childRelationWithExtremelyLongFieldNameForcingTrun24();
}

class _BleedRootImpl extends BleedRoot {
  _BleedRootImpl({
    int? id,
    required String name,
    int? firstChildId,
    _i2rsfnut.BleedChild? childRelationWithExtremelyLongFieldNameForcingTrun24 =
        const _UndefinedBleedRoot$childRelationWithExtremelyLongFieldNameForcingTrun24(),
    int? secondChildId,
    _i2rsfnut.BleedChild? childRelationWithExtremelyLongFieldNameForcingTrun23 =
        const _UndefinedBleedRoot$childRelationWithExtremelyLongFieldNameForcingTrun24(),
  }) : super._(
         id: id,
         name: name,
         firstChildId: firstChildId,
         childRelationWithExtremelyLongFieldNameForcingTrun24:
             childRelationWithExtremelyLongFieldNameForcingTrun24,
         secondChildId: secondChildId,
         childRelationWithExtremelyLongFieldNameForcingTrun23:
             childRelationWithExtremelyLongFieldNameForcingTrun23,
       );

  /// Returns a shallow copy of this [BleedRoot]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  BleedRoot copyWith({
    Object? id = _Undefined,
    String? name,
    Object? firstChildId = _Undefined,
    _i2rsfnut.BleedChild? childRelationWithExtremelyLongFieldNameForcingTrun24 =
        const _UndefinedBleedRoot$childRelationWithExtremelyLongFieldNameForcingTrun24(),
    Object? secondChildId = _Undefined,
    _i2rsfnut.BleedChild? childRelationWithExtremelyLongFieldNameForcingTrun23 =
        const _UndefinedBleedRoot$childRelationWithExtremelyLongFieldNameForcingTrun24(),
  }) {
    return _BleedRootImpl(
      id: id is int? ? id : this.id,
      name: name ?? this.name,
      firstChildId: firstChildId is int? ? firstChildId : this.firstChildId,
      childRelationWithExtremelyLongFieldNameForcingTrun24:
          childRelationWithExtremelyLongFieldNameForcingTrun24
              is _issu.UndefinedSentinel
          ? _childRelationWithExtremelyLongFieldNameForcingTrun24
                    is _issu.UndefinedSentinel
                ? _childRelationWithExtremelyLongFieldNameForcingTrun24
                : this._childRelationWithExtremelyLongFieldNameForcingTrun24
                      ?.copyWith()
          : childRelationWithExtremelyLongFieldNameForcingTrun24?.copyWith(),
      secondChildId: secondChildId is int? ? secondChildId : this.secondChildId,
      childRelationWithExtremelyLongFieldNameForcingTrun23:
          childRelationWithExtremelyLongFieldNameForcingTrun23
              is _issu.UndefinedSentinel
          ? _childRelationWithExtremelyLongFieldNameForcingTrun23
                    is _issu.UndefinedSentinel
                ? _childRelationWithExtremelyLongFieldNameForcingTrun23
                : this._childRelationWithExtremelyLongFieldNameForcingTrun23
                      ?.copyWith()
          : childRelationWithExtremelyLongFieldNameForcingTrun23?.copyWith(),
    );
  }
}
