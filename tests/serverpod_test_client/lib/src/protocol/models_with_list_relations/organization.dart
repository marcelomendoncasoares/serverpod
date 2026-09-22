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
import '../models_with_list_relations/city.dart' as _i64066zp;
import '../models_with_list_relations/person.dart' as _ijqkgw0m;

abstract class Organization
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  Organization._({
    this.id,
    required this.name,
    this.people,
    this.cityId,
    Object? city = #serverpodUnloadedRelation,
  }) : _city$loaded = !identical(
         city,
         #serverpodUnloadedRelation,
       ),
       _city =
           !identical(
             city,
             #serverpodUnloadedRelation,
           )
           ? (city as _i64066zp.City?)
           : null;

  factory Organization({
    int? id,
    required String name,
    List<_ijqkgw0m.Person>? people,
    int? cityId,
    _i64066zp.City? city,
  }) = _OrganizationImpl;

  factory Organization.fromJson(Map<String, dynamic> jsonSerialization) {
    return _OrganizationImpl(
      id: jsonSerialization['id'] as int?,
      name: jsonSerialization['name'] as String,
      people: jsonSerialization['people'] == null
          ? null
          : _iza9lbb5.Protocol().deserialize<List<_ijqkgw0m.Person>>(
              jsonSerialization['people'],
            ),
      cityId: jsonSerialization['cityId'] as int?,
      city: jsonSerialization.containsKey('city')
          ? jsonSerialization['city'] == null
                ? null
                : _iza9lbb5.Protocol().deserialize<_i64066zp.City>(
                    jsonSerialization['city'],
                  )
          : #serverpodUnloadedRelation,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String name;

  List<_ijqkgw0m.Person>? people;

  int? cityId;

  bool _city$loaded;

  _i64066zp.City? _city;

  /// Throws `RelationNotLoadedError` if this relation was not loaded.
  _i64066zp.City? get city {
    final value = _city;
    if (!_city$loaded) {
      throw _iss.RelationNotLoadedError(
        model: 'Organization',
        relation: 'city',
      );
    }
    return value;
  }

  set city(_i64066zp.City? value) {
    _city = value;
    _city$loaded = true;
  }

  /// Returns a shallow copy of this [Organization]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  Organization copyWith({
    int? id,
    String? name,
    List<_ijqkgw0m.Person>? people,
    int? cityId,
    Object? city = _Undefined,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Organization',
      if (id != null) 'id': id,
      'name': name,
      if (people != null)
        'people': people?.toJson(valueToJson: (v) => v.toJson()),
      if (cityId != null) 'cityId': cityId,
      if (_city$loaded) 'city': _city?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Organization',
      if (id != null) 'id': id,
      'name': name,
      if (people != null)
        'people': people?.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      if (cityId != null) 'cityId': cityId,
      if (_city$loaded) 'city': _city?.toJsonForProtocol(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _OrganizationImpl extends Organization {
  _OrganizationImpl({
    int? id,
    required String name,
    List<_ijqkgw0m.Person>? people,
    int? cityId,
    Object? city = #serverpodUnloadedRelation,
  }) : super._(
         id: id,
         name: name,
         people: people,
         cityId: cityId,
         city: city,
       );

  /// Returns a shallow copy of this [Organization]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  Organization copyWith({
    Object? id = _Undefined,
    String? name,
    Object? people = _Undefined,
    Object? cityId = _Undefined,
    Object? city = _Undefined,
  }) {
    return _OrganizationImpl(
      id: id is int? ? id : this.id,
      name: name ?? this.name,
      people: people is List<_ijqkgw0m.Person>?
          ? people
          : this.people?.map((e0) => e0.copyWith()).toList(),
      cityId: cityId is int? ? cityId : this.cityId,
      city: city is _i64066zp.City?
          ? city?.copyWith()
          : _city$loaded
          ? this._city?.copyWith()
          : #serverpodUnloadedRelation,
    );
  }
}
