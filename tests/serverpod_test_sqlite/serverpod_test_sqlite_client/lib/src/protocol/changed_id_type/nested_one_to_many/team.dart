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
import 'package:serverpod_test_sqlite_client/src/protocol/protocol.dart'
    as _i0ntutnq;
import '../../changed_id_type/nested_one_to_many/arena.dart' as _izqzqdtt;
import '../../changed_id_type/nested_one_to_many/player.dart' as _igtph8zx;

abstract class TeamInt
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  TeamInt._({
    this.id,
    required this.name,
    this.arenaId,
    Object? arena = _Undefined,
    this.players,
  }) : _arenaLoaded = !identical(
         arena,
         _Undefined,
       ),
       _arena =
           !identical(
             arena,
             _Undefined,
           )
           ? (arena as _izqzqdtt.ArenaUuid?)
           : null;

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
                : _i0ntutnq.Protocol().deserialize<_izqzqdtt.ArenaUuid>(
                    jsonSerialization['arena'],
                  )
          : _Undefined,
      players: jsonSerialization['players'] == null
          ? null
          : _i0ntutnq.Protocol().deserialize<List<_igtph8zx.PlayerUuid>>(
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

  bool _arenaLoaded;

  _izqzqdtt.ArenaUuid? _arena;

  List<_igtph8zx.PlayerUuid>? players;

  /// Throws `RelationNotLoadedError` if this relation was not loaded.
  _izqzqdtt.ArenaUuid? get arena {
    final value = _arena;
    if (!_arenaLoaded) {
      throw _iss.RelationNotLoadedError(
        model: 'TeamInt',
        relation: 'arena',
      );
    }
    return value;
  }

  set arena(_izqzqdtt.ArenaUuid? value) {
    _arena = value;
    _arenaLoaded = true;
  }

  /// Returns a shallow copy of this [TeamInt]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  TeamInt copyWith({
    int? id,
    String? name,
    _isc.UuidValue? arenaId,
    Object? arena = _Undefined,
    List<_igtph8zx.PlayerUuid>? players,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'TeamInt',
      if (id != null) 'id': id,
      'name': name,
      if (arenaId != null) 'arenaId': arenaId?.toJson(),
      if (_arenaLoaded) 'arena': _arena?.toJson(),
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
      if (_arenaLoaded) 'arena': _arena?.toJsonForProtocol(),
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

class _TeamIntImpl extends TeamInt {
  _TeamIntImpl({
    int? id,
    required String name,
    _isc.UuidValue? arenaId,
    Object? arena = _Undefined,
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
    Object? arenaId = _Undefined,
    Object? arena = _Undefined,
    Object? players = _Undefined,
  }) {
    return _TeamIntImpl(
      id: id is int? ? id : this.id,
      name: name ?? this.name,
      arenaId: arenaId is _isc.UuidValue? ? arenaId : this.arenaId,
      arena: arena is _izqzqdtt.ArenaUuid?
          ? arena?.copyWith()
          : _arenaLoaded
          ? this._arena?.copyWith()
          : _Undefined,
      players: players is List<_igtph8zx.PlayerUuid>?
          ? players
          : this.players?.map((e0) => e0.copyWith()).toList(),
    );
  }
}
