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
import '../../changed_id_type/nested_one_to_many/team.dart' as _i9bz1am4;

abstract class PlayerUuid
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  PlayerUuid._({
    this.id,
    required this.name,
    this.teamId,
    _i9bz1am4.TeamInt? team = const _UndefinedPlayerUuid$team(),
  }) : _team = team;

  factory PlayerUuid({
    _isc.UuidValue? id,
    required String name,
    int? teamId,
    _i9bz1am4.TeamInt? team,
  }) = _PlayerUuidImpl;

  factory PlayerUuid.fromJson(Map<String, dynamic> jsonSerialization) {
    return _PlayerUuidImpl(
      id: jsonSerialization['id'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      name: jsonSerialization['name'] as String,
      teamId: jsonSerialization['teamId'] as int?,
      team: jsonSerialization.containsKey('team')
          ? jsonSerialization['team'] == null
                ? null
                : _i0ntutnq.Protocol().deserialize<_i9bz1am4.TeamInt>(
                    jsonSerialization['team'],
                  )
          : const _UndefinedPlayerUuid$team(),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  _isc.UuidValue? id;

  String name;

  int? teamId;

  _i9bz1am4.TeamInt? _team;

  /// Throws `RelationNotLoadedError` if this relation was not loaded.
  _i9bz1am4.TeamInt? get team {
    final value = _team;
    if (value is _issu.UndefinedSentinel) {
      throw _iss.RelationNotLoadedError(
        model: 'PlayerUuid',
        relation: 'team',
      );
    }
    return value;
  }

  set team(_i9bz1am4.TeamInt? value) {
    _team = value;
  }

  /// Returns a shallow copy of this [PlayerUuid]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  PlayerUuid copyWith({
    _isc.UuidValue? id = const _issu.$UndefinedUuidValue(),
    String? name,
    int? teamId,
    _i9bz1am4.TeamInt? team = const _UndefinedPlayerUuid$team(),
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PlayerUuid',
      if (id != null) 'id': id?.toJson(),
      'name': name,
      if (teamId != null) 'teamId': teamId,
      if (_team is! _issu.UndefinedSentinel) 'team': _team?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'PlayerUuid',
      if (id != null) 'id': id?.toJson(),
      'name': name,
      if (teamId != null) 'teamId': teamId,
      if (_team is! _issu.UndefinedSentinel) 'team': _team?.toJsonForProtocol(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _UndefinedPlayerUuid$team extends _issu.UndefinedSentinel
    implements _i9bz1am4.TeamInt {
  const _UndefinedPlayerUuid$team();
}

class _PlayerUuidImpl extends PlayerUuid {
  _PlayerUuidImpl({
    _isc.UuidValue? id,
    required String name,
    int? teamId,
    _i9bz1am4.TeamInt? team = const _UndefinedPlayerUuid$team(),
  }) : super._(
         id: id,
         name: name,
         teamId: teamId,
         team: team,
       );

  /// Returns a shallow copy of this [PlayerUuid]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  PlayerUuid copyWith({
    _isc.UuidValue? id = const _issu.$UndefinedUuidValue(),
    String? name,
    Object? teamId = _Undefined,
    _i9bz1am4.TeamInt? team = const _UndefinedPlayerUuid$team(),
  }) {
    return _PlayerUuidImpl(
      id: id is _issu.UndefinedSentinel ? this.id : id,
      name: name ?? this.name,
      teamId: teamId is int? ? teamId : this.teamId,
      team: team is _issu.UndefinedSentinel
          ? _team is _issu.UndefinedSentinel
                ? _team
                : this._team?.copyWith()
          : team?.copyWith(),
    );
  }
}
