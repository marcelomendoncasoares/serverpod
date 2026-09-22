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
import '../../models_with_relations/generated_relation_field/generated_relation_company.dart'
    as _ipeijyfj;

abstract class GeneratedRelationEmployee
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  GeneratedRelationEmployee._({
    this.id,
    required this.name,
    required this.customCompanyId,
    this.company,
    this.customPreviousCompanyId,
    Object? previousCompany = #serverpodUnloadedRelation,
  }) : _previousCompany$loaded = !identical(
         previousCompany,
         #serverpodUnloadedRelation,
       ),
       _previousCompany =
           !identical(
             previousCompany,
             #serverpodUnloadedRelation,
           )
           ? (previousCompany as _ipeijyfj.GeneratedRelationCompany?)
           : null;

  factory GeneratedRelationEmployee({
    int? id,
    required String name,
    required int customCompanyId,
    _ipeijyfj.GeneratedRelationCompany? company,
    int? customPreviousCompanyId,
    _ipeijyfj.GeneratedRelationCompany? previousCompany,
  }) = _GeneratedRelationEmployeeImpl;

  factory GeneratedRelationEmployee.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return _GeneratedRelationEmployeeImpl(
      id: jsonSerialization['id'] as int?,
      name: jsonSerialization['name'] as String,
      customCompanyId: jsonSerialization['customCompanyId'] as int,
      company: jsonSerialization['company'] == null
          ? null
          : _iza9lbb5.Protocol()
                .deserialize<_ipeijyfj.GeneratedRelationCompany>(
                  jsonSerialization['company'],
                ),
      customPreviousCompanyId:
          jsonSerialization['customPreviousCompanyId'] as int?,
      previousCompany: jsonSerialization.containsKey('previousCompany')
          ? jsonSerialization['previousCompany'] == null
                ? null
                : _iza9lbb5.Protocol()
                      .deserialize<_ipeijyfj.GeneratedRelationCompany>(
                        jsonSerialization['previousCompany'],
                      )
          : #serverpodUnloadedRelation,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String name;

  /// The foreign key of the [company] relation.
  int customCompanyId;

  _ipeijyfj.GeneratedRelationCompany? company;

  /// The foreign key of the [previousCompany] relation.
  int? customPreviousCompanyId;

  bool _previousCompany$loaded;

  _ipeijyfj.GeneratedRelationCompany? _previousCompany;

  /// Throws `RelationNotLoadedError` if this relation was not loaded.
  _ipeijyfj.GeneratedRelationCompany? get previousCompany {
    final value = _previousCompany;
    if (!_previousCompany$loaded) {
      throw _iss.RelationNotLoadedError(
        model: 'GeneratedRelationEmployee',
        relation: 'previousCompany',
      );
    }
    return value;
  }

  set previousCompany(_ipeijyfj.GeneratedRelationCompany? value) {
    _previousCompany = value;
    _previousCompany$loaded = true;
  }

  /// Returns a shallow copy of this [GeneratedRelationEmployee]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  GeneratedRelationEmployee copyWith({
    int? id,
    String? name,
    int? customCompanyId,
    _ipeijyfj.GeneratedRelationCompany? company,
    int? customPreviousCompanyId,
    Object? previousCompany = _Undefined,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'GeneratedRelationEmployee',
      if (id != null) 'id': id,
      'name': name,
      'customCompanyId': customCompanyId,
      if (company != null) 'company': company?.toJson(),
      if (customPreviousCompanyId != null)
        'customPreviousCompanyId': customPreviousCompanyId,
      if (_previousCompany$loaded)
        'previousCompany': _previousCompany?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'GeneratedRelationEmployee',
      if (id != null) 'id': id,
      'name': name,
      'customCompanyId': customCompanyId,
      if (company != null) 'company': company?.toJsonForProtocol(),
      if (customPreviousCompanyId != null)
        'customPreviousCompanyId': customPreviousCompanyId,
      if (_previousCompany$loaded)
        'previousCompany': _previousCompany?.toJsonForProtocol(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _GeneratedRelationEmployeeImpl extends GeneratedRelationEmployee {
  _GeneratedRelationEmployeeImpl({
    int? id,
    required String name,
    required int customCompanyId,
    _ipeijyfj.GeneratedRelationCompany? company,
    int? customPreviousCompanyId,
    Object? previousCompany = #serverpodUnloadedRelation,
  }) : super._(
         id: id,
         name: name,
         customCompanyId: customCompanyId,
         company: company,
         customPreviousCompanyId: customPreviousCompanyId,
         previousCompany: previousCompany,
       );

  /// Returns a shallow copy of this [GeneratedRelationEmployee]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  GeneratedRelationEmployee copyWith({
    Object? id = _Undefined,
    String? name,
    int? customCompanyId,
    Object? company = _Undefined,
    Object? customPreviousCompanyId = _Undefined,
    Object? previousCompany = _Undefined,
  }) {
    return _GeneratedRelationEmployeeImpl(
      id: id is int? ? id : this.id,
      name: name ?? this.name,
      customCompanyId: customCompanyId ?? this.customCompanyId,
      company: company is _ipeijyfj.GeneratedRelationCompany?
          ? company
          : this.company?.copyWith(),
      customPreviousCompanyId: customPreviousCompanyId is int?
          ? customPreviousCompanyId
          : this.customPreviousCompanyId,
      previousCompany: previousCompany is _ipeijyfj.GeneratedRelationCompany?
          ? previousCompany?.copyWith()
          : _previousCompany$loaded
          ? this._previousCompany?.copyWith()
          : #serverpodUnloadedRelation,
    );
  }
}
