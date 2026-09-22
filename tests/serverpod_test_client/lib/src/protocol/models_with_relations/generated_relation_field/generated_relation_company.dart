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
import '../../models_with_relations/generated_relation_field/generated_relation_employee.dart'
    as _inw8ul07;
import '../../models_with_relations/generated_relation_field/generated_relation_office.dart'
    as _im57bsix;

abstract class GeneratedRelationCompany
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  GeneratedRelationCompany._({
    this.id,
    required this.name,
    Object? office = #serverpodUnloadedRelation,
    this.employees,
  }) : _office$loaded = !identical(
         office,
         #serverpodUnloadedRelation,
       ),
       _office =
           !identical(
             office,
             #serverpodUnloadedRelation,
           )
           ? (office as _im57bsix.GeneratedRelationOffice?)
           : null;

  factory GeneratedRelationCompany({
    int? id,
    required String name,
    _im57bsix.GeneratedRelationOffice? office,
    List<_inw8ul07.GeneratedRelationEmployee>? employees,
  }) = _GeneratedRelationCompanyImpl;

  factory GeneratedRelationCompany.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return _GeneratedRelationCompanyImpl(
      id: jsonSerialization['id'] as int?,
      name: jsonSerialization['name'] as String,
      office: jsonSerialization.containsKey('office')
          ? jsonSerialization['office'] == null
                ? null
                : _iza9lbb5.Protocol()
                      .deserialize<_im57bsix.GeneratedRelationOffice>(
                        jsonSerialization['office'],
                      )
          : #serverpodUnloadedRelation,
      employees: jsonSerialization['employees'] == null
          ? null
          : _iza9lbb5.Protocol()
                .deserialize<List<_inw8ul07.GeneratedRelationEmployee>>(
                  jsonSerialization['employees'],
                ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String name;

  bool _office$loaded;

  _im57bsix.GeneratedRelationOffice? _office;

  List<_inw8ul07.GeneratedRelationEmployee>? employees;

  /// Throws `RelationNotLoadedError` if this relation was not loaded.
  _im57bsix.GeneratedRelationOffice? get office {
    final value = _office;
    if (!_office$loaded) {
      throw _iss.RelationNotLoadedError(
        model: 'GeneratedRelationCompany',
        relation: 'office',
      );
    }
    return value;
  }

  set office(_im57bsix.GeneratedRelationOffice? value) {
    _office = value;
    _office$loaded = true;
  }

  /// Returns a shallow copy of this [GeneratedRelationCompany]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  GeneratedRelationCompany copyWith({
    int? id,
    String? name,
    Object? office = _Undefined,
    List<_inw8ul07.GeneratedRelationEmployee>? employees,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'GeneratedRelationCompany',
      if (id != null) 'id': id,
      'name': name,
      if (_office$loaded) 'office': _office?.toJson(),
      if (employees != null)
        'employees': employees?.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'GeneratedRelationCompany',
      if (id != null) 'id': id,
      'name': name,
      if (_office$loaded) 'office': _office?.toJsonForProtocol(),
      if (employees != null)
        'employees': employees?.toJson(
          valueToJson: (v) => v.toJsonForProtocol(),
        ),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _GeneratedRelationCompanyImpl extends GeneratedRelationCompany {
  _GeneratedRelationCompanyImpl({
    int? id,
    required String name,
    Object? office = #serverpodUnloadedRelation,
    List<_inw8ul07.GeneratedRelationEmployee>? employees,
  }) : super._(
         id: id,
         name: name,
         office: office,
         employees: employees,
       );

  /// Returns a shallow copy of this [GeneratedRelationCompany]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  GeneratedRelationCompany copyWith({
    Object? id = _Undefined,
    String? name,
    Object? office = _Undefined,
    Object? employees = _Undefined,
  }) {
    return _GeneratedRelationCompanyImpl(
      id: id is int? ? id : this.id,
      name: name ?? this.name,
      office: office is _im57bsix.GeneratedRelationOffice?
          ? office?.copyWith()
          : _office$loaded
          ? this._office?.copyWith()
          : #serverpodUnloadedRelation,
      employees: employees is List<_inw8ul07.GeneratedRelationEmployee>?
          ? employees
          : this.employees?.map((e0) => e0.copyWith()).toList(),
    );
  }
}
