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
import '../../models_with_relations/nested_one_to_many/team.dart' as _iaks25tn;

abstract class Player
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  Player._({
    this.id,
    required this.name,
    this.teamId,
    Object? team = #serverpodUnloadedRelation,
  }) : _team$loaded = !identical(
         team,
         #serverpodUnloadedRelation,
       ),
       _team =
           !identical(
             team,
             #serverpodUnloadedRelation,
           )
           ? (team as _iaks25tn.Team?)
           : null;

  factory Player({
    int? id,
    required String name,
    int? teamId,
    _iaks25tn.Team? team,
  }) = _PlayerImpl;

  factory Player.fromJson(Map<String, dynamic> jsonSerialization) {
    return _PlayerImpl(
      id: jsonSerialization['id'] as int?,
      name: jsonSerialization['name'] as String,
      teamId: jsonSerialization['teamId'] as int?,
      team: jsonSerialization.containsKey('team')
          ? jsonSerialization['team'] == null
                ? null
                : _iza9lbb5.Protocol().deserialize<_iaks25tn.Team>(
                    jsonSerialization['team'],
                  )
          : #serverpodUnloadedRelation,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String name;

  int? teamId;

  bool _team$loaded;

  _iaks25tn.Team? _team;

  /// Throws `RelationNotLoadedError` if this relation was not loaded.
  _iaks25tn.Team? get team {
    final value = _team;
    if (!_team$loaded) {
      throw _iss.RelationNotLoadedError(
        model: 'Player',
        relation: 'team',
      );
    }
    return value;
  }

  set team(_iaks25tn.Team? value) {
    _team = value;
    _team$loaded = true;
  }

  /// Returns a shallow copy of this [Player]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  Player copyWith({
    int? id,
    String? name,
    int? teamId,
    Object? team = _Undefined,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Player',
      if (id != null) 'id': id,
      'name': name,
      if (teamId != null) 'teamId': teamId,
      if (_team$loaded) 'team': _team?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Player',
      if (id != null) 'id': id,
      'name': name,
      if (teamId != null) 'teamId': teamId,
      if (_team$loaded) 'team': _team?.toJsonForProtocol(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PlayerImpl extends Player {
  _PlayerImpl({
    int? id,
    required String name,
    int? teamId,
    Object? team = #serverpodUnloadedRelation,
  }) : super._(
         id: id,
         name: name,
         teamId: teamId,
         team: team,
       );

  /// Returns a shallow copy of this [Player]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  Player copyWith({
    Object? id = _Undefined,
    String? name,
    Object? teamId = _Undefined,
    Object? team = _Undefined,
  }) {
    return _PlayerImpl(
      id: id is int? ? id : this.id,
      name: name ?? this.name,
      teamId: teamId is int? ? teamId : this.teamId,
      team: team is _iaks25tn.Team?
          ? team?.copyWith()
          : _team$loaded
          ? this._team?.copyWith()
          : #serverpodUnloadedRelation,
    );
  }
}
