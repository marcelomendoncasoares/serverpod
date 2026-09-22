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
import '../../changed_id_type/nested_one_to_many/arena.dart' as _izqzqdtt;
import '../../changed_id_type/nested_one_to_many/player.dart' as _igtph8zx;

abstract class TeamInt
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  TeamInt._({
    this.id,
    required this.name,
    this.arenaId,
    _izqzqdtt.ArenaUuid? arena = const _UndefinedTeamInt$arena(),
    this.players,
  }) : _arena = arena;

  factory TeamInt({
    int? id,
    required String name,
    _isc.UuidValue? arenaId,
    _izqzqdtt.ArenaUuid? arena,
    List<_igtph8zx.PlayerUuid>? players,
  }) = _TeamIntImpl;

  factory TeamInt.fromJson(Map<String, dynamic> jsonSerialization) {
    return _TeamIntImpl(
      id: jsonSerialization['id'] as int?,
      name: jsonSerialization['name'] as String,
      arenaId: jsonSerialization['arenaId'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['arenaId']),
      arena: jsonSerialization.containsKey('arena')
          ? jsonSerialization['arena'] == null
                ? null
                : _iza9lbb5.Protocol().deserialize<_izqzqdtt.ArenaUuid>(
                    jsonSerialization['arena'],
                  )
          : const _UndefinedTeamInt$arena(),
      players: jsonSerialization['players'] == null
          ? null
          : _iza9lbb5.Protocol().deserialize<List<_igtph8zx.PlayerUuid>>(
              jsonSerialization['players'],
            ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String name;

  _isc.UuidValue? arenaId;

  _izqzqdtt.ArenaUuid? _arena;

  List<_igtph8zx.PlayerUuid>? players;

  /// Throws `RelationNotLoadedError` if this relation was not loaded.
  _izqzqdtt.ArenaUuid? get arena {
    final value = _arena;
    if (value is _issu.UndefinedSentinel) {
      throw _iss.RelationNotLoadedError(
        model: 'TeamInt',
        relation: 'arena',
      );
    }
    return value;
  }

  set arena(_izqzqdtt.ArenaUuid? value) {
    _arena = value;
  }

  /// Returns a shallow copy of this [TeamInt]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  TeamInt copyWith({
    int? id,
    String? name,
    _isc.UuidValue? arenaId = const _issu.$UndefinedUuidValue(),
    _izqzqdtt.ArenaUuid? arena = const _UndefinedTeamInt$arena(),
    List<_igtph8zx.PlayerUuid>? players =
        const _issu.$UndefinedList<_igtph8zx.PlayerUuid>(),
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'TeamInt',
      if (id != null) 'id': id,
      'name': name,
      if (arenaId != null) 'arenaId': arenaId?.toJson(),
      if (_arena is! _issu.UndefinedSentinel) 'arena': _arena?.toJson(),
      if (players != null)
        'players': players?.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'TeamInt',
      if (id != null) 'id': id,
      'name': name,
      if (arenaId != null) 'arenaId': arenaId?.toJson(),
      if (_arena is! _issu.UndefinedSentinel)
        'arena': _arena?.toJsonForProtocol(),
      if (players != null)
        'players': players?.toJson(valueToJson: (v) => v.toJsonForProtocol()),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _UndefinedTeamInt$arena extends _issu.UndefinedSentinel
    implements _izqzqdtt.ArenaUuid {
  const _UndefinedTeamInt$arena();
}

class _TeamIntImpl extends TeamInt {
  _TeamIntImpl({
    int? id,
    required String name,
    _isc.UuidValue? arenaId,
    _izqzqdtt.ArenaUuid? arena = const _UndefinedTeamInt$arena(),
    List<_igtph8zx.PlayerUuid>? players,
  }) : super._(
         id: id,
         name: name,
         arenaId: arenaId,
         arena: arena,
         players: players,
       );

  /// Returns a shallow copy of this [TeamInt]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  TeamInt copyWith({
    Object? id = _Undefined,
    String? name,
    _isc.UuidValue? arenaId = const _issu.$UndefinedUuidValue(),
    _izqzqdtt.ArenaUuid? arena = const _UndefinedTeamInt$arena(),
    List<_igtph8zx.PlayerUuid>? players =
        const _issu.$UndefinedList<_igtph8zx.PlayerUuid>(),
  }) {
    return _TeamIntImpl(
      id: id is int? ? id : this.id,
      name: name ?? this.name,
      arenaId: arenaId is _issu.UndefinedSentinel ? this.arenaId : arenaId,
      arena: arena is _issu.UndefinedSentinel
          ? _arena is _issu.UndefinedSentinel
                ? _arena
                : this._arena?.copyWith()
          : arena?.copyWith(),
      players: players is _issu.UndefinedSentinel
          ? this.players?.map((e0) => e0.copyWith()).toList()
          : players,
    );
  }
}
