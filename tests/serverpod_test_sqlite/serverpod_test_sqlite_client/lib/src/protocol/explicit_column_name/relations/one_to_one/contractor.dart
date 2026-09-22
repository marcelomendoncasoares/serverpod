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
import '../../../explicit_column_name/relations/one_to_one/service.dart'
    as _iml73r3x;

abstract class Contractor
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  Contractor._({
    this.id,
    required this.name,
    this.serviceIdField,
    _iml73r3x.Service? service = const _UndefinedContractor$service(),
  }) : _service = service;

  factory Contractor({
    int? id,
    required String name,
    int? serviceIdField,
    _iml73r3x.Service? service,
  }) = _ContractorImpl;

  factory Contractor.fromJson(Map<String, dynamic> jsonSerialization) {
    return _ContractorImpl(
      id: jsonSerialization['id'] as int?,
      name: jsonSerialization['name'] as String,
      serviceIdField: jsonSerialization['serviceIdField'] as int?,
      service: jsonSerialization.containsKey('service')
          ? jsonSerialization['service'] == null
                ? null
                : _i0ntutnq.Protocol().deserialize<_iml73r3x.Service>(
                    jsonSerialization['service'],
                  )
          : const _UndefinedContractor$service(),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String name;

  int? serviceIdField;

  _iml73r3x.Service? _service;

  /// Throws `RelationNotLoadedError` if this relation was not loaded.
  _iml73r3x.Service? get service {
    final value = _service;
    if (value is _issu.UndefinedSentinel) {
      throw _iss.RelationNotLoadedError(
        model: 'Contractor',
        relation: 'service',
      );
    }
    return value;
  }

  set service(_iml73r3x.Service? value) {
    _service = value;
  }

  /// Returns a shallow copy of this [Contractor]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  Contractor copyWith({
    int? id,
    String? name,
    int? serviceIdField,
    _iml73r3x.Service? service = const _UndefinedContractor$service(),
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Contractor',
      if (id != null) 'id': id,
      'name': name,
      if (serviceIdField != null) 'serviceIdField': serviceIdField,
      if (_service is! _issu.UndefinedSentinel) 'service': _service?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Contractor',
      if (id != null) 'id': id,
      'name': name,
      if (serviceIdField != null) 'serviceIdField': serviceIdField,
      if (_service is! _issu.UndefinedSentinel)
        'service': _service?.toJsonForProtocol(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _UndefinedContractor$service extends _issu.UndefinedSentinel
    implements _iml73r3x.Service {
  const _UndefinedContractor$service();
}

class _ContractorImpl extends Contractor {
  _ContractorImpl({
    int? id,
    required String name,
    int? serviceIdField,
    _iml73r3x.Service? service = const _UndefinedContractor$service(),
  }) : super._(
         id: id,
         name: name,
         serviceIdField: serviceIdField,
         service: service,
       );

  /// Returns a shallow copy of this [Contractor]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  Contractor copyWith({
    Object? id = _Undefined,
    String? name,
    Object? serviceIdField = _Undefined,
    _iml73r3x.Service? service = const _UndefinedContractor$service(),
  }) {
    return _ContractorImpl(
      id: id is int? ? id : this.id,
      name: name ?? this.name,
      serviceIdField: serviceIdField is int?
          ? serviceIdField
          : this.serviceIdField,
      service: service is _issu.UndefinedSentinel
          ? _service is _issu.UndefinedSentinel
                ? _service
                : this._service?.copyWith()
          : service?.copyWith(),
    );
  }
}
