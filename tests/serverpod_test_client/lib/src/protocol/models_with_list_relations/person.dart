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
import '../models_with_list_relations/organization.dart' as _i0ptycc3;

abstract class Person
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  Person._({
    this.id,
    required this.name,
    this.organizationId,
    Object? organization = #serverpodUnloadedRelation,
  }) : _organization$loaded = !identical(
         organization,
         #serverpodUnloadedRelation,
       ),
       _organization =
           !identical(
             organization,
             #serverpodUnloadedRelation,
           )
           ? (organization as _i0ptycc3.Organization?)
           : null;

  factory Person({
    int? id,
    required String name,
    int? organizationId,
    _i0ptycc3.Organization? organization,
  }) = _PersonImpl;

  factory Person.fromJson(Map<String, dynamic> jsonSerialization) {
    return _PersonImpl(
      id: jsonSerialization['id'] as int?,
      name: jsonSerialization['name'] as String,
      organizationId: jsonSerialization['organizationId'] as int?,
      organization: jsonSerialization.containsKey('organization')
          ? jsonSerialization['organization'] == null
                ? null
                : _iza9lbb5.Protocol().deserialize<_i0ptycc3.Organization>(
                    jsonSerialization['organization'],
                  )
          : #serverpodUnloadedRelation,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String name;

  int? organizationId;

  bool _organization$loaded;

  _i0ptycc3.Organization? _organization;

  /// Throws `RelationNotLoadedError` if this relation was not loaded.
  _i0ptycc3.Organization? get organization {
    final value = _organization;
    if (!_organization$loaded) {
      throw _iss.RelationNotLoadedError(
        model: 'Person',
        relation: 'organization',
      );
    }
    return value;
  }

  set organization(_i0ptycc3.Organization? value) {
    _organization = value;
    _organization$loaded = true;
  }

  /// Returns a shallow copy of this [Person]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  Person copyWith({
    int? id,
    String? name,
    int? organizationId,
    Object? organization = _Undefined,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Person',
      if (id != null) 'id': id,
      'name': name,
      if (organizationId != null) 'organizationId': organizationId,
      if (_organization$loaded) 'organization': _organization?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Person',
      if (id != null) 'id': id,
      'name': name,
      if (organizationId != null) 'organizationId': organizationId,
      if (_organization$loaded)
        'organization': _organization?.toJsonForProtocol(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PersonImpl extends Person {
  _PersonImpl({
    int? id,
    required String name,
    int? organizationId,
    Object? organization = #serverpodUnloadedRelation,
  }) : super._(
         id: id,
         name: name,
         organizationId: organizationId,
         organization: organization,
       );

  /// Returns a shallow copy of this [Person]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  Person copyWith({
    Object? id = _Undefined,
    String? name,
    Object? organizationId = _Undefined,
    Object? organization = _Undefined,
  }) {
    return _PersonImpl(
      id: id is int? ? id : this.id,
      name: name ?? this.name,
      organizationId: organizationId is int?
          ? organizationId
          : this.organizationId,
      organization: organization is _i0ptycc3.Organization?
          ? organization?.copyWith()
          : _organization$loaded
          ? this._organization?.copyWith()
          : #serverpodUnloadedRelation,
    );
  }
}
