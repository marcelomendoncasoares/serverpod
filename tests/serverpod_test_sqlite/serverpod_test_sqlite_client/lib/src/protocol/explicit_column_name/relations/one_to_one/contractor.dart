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
import '../../../explicit_column_name/relations/one_to_one/service.dart'
    as _iml73r3x;

abstract class Contractor
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  Contractor._({
    this.id,
    required this.name,
    this.serviceIdField,
    Object? service = _Undefined,
  }) : _serviceLoaded = !identical(
         service,
         _Undefined,
       ),
       _service =
           !identical(
             service,
             _Undefined,
           )
           ? (service as _iml73r3x.Service?)
           : null;

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
          : _Undefined,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String name;

  int? serviceIdField;

  bool _serviceLoaded;

  _iml73r3x.Service? _service;

  /// Throws `RelationNotLoadedError` if this relation was not loaded.
  _iml73r3x.Service? get service {
    final value = _service;
    if (!_serviceLoaded) {
      throw _iss.RelationNotLoadedError(
        model: 'Contractor',
        relation: 'service',
      );
    }
    return value;
  }

  set service(_iml73r3x.Service? value) {
    _service = value;
    _serviceLoaded = true;
  }

  /// Returns a shallow copy of this [Contractor]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  Contractor copyWith({
    int? id,
    String? name,
    int? serviceIdField,
    Object? service = _Undefined,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Contractor',
      if (id != null) 'id': id,
      'name': name,
      if (serviceIdField != null) 'serviceIdField': serviceIdField,
      if (_serviceLoaded) 'service': _service?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Contractor',
      if (id != null) 'id': id,
      'name': name,
      if (serviceIdField != null) 'serviceIdField': serviceIdField,
      if (_serviceLoaded) 'service': _service?.toJsonForProtocol(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ContractorImpl extends Contractor {
  _ContractorImpl({
    int? id,
    required String name,
    int? serviceIdField,
    Object? service = _Undefined,
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
    Object? service = _Undefined,
  }) {
    return _ContractorImpl(
      id: id is int? ? id : this.id,
      name: name ?? this.name,
      serviceIdField: serviceIdField is int?
          ? serviceIdField
          : this.serviceIdField,
      service: service is _iml73r3x.Service?
          ? service?.copyWith()
          : _serviceLoaded
          ? this._service?.copyWith()
          : _Undefined,
    );
  }
}
