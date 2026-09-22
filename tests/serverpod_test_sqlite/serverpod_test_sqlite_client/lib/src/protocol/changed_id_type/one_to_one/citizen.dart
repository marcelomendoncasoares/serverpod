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
import '../../changed_id_type/one_to_one/address.dart' as _ih0efjtk;
import '../../changed_id_type/one_to_one/company.dart' as _i441ok8u;

abstract class CitizenInt
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  CitizenInt._({
    this.id,
    required this.name,
    Object? address = #serverpodUnloadedRelation,
    required this.companyId,
    this.company,
    this.oldCompanyId,
    Object? oldCompany = #serverpodUnloadedRelation,
  }) : _address$loaded = !identical(
         address,
         #serverpodUnloadedRelation,
       ),
       _address =
           !identical(
             address,
             #serverpodUnloadedRelation,
           )
           ? (address as _ih0efjtk.AddressUuid?)
           : null,
       _oldCompany$loaded = !identical(
         oldCompany,
         #serverpodUnloadedRelation,
       ),
       _oldCompany =
           !identical(
             oldCompany,
             #serverpodUnloadedRelation,
           )
           ? (oldCompany as _i441ok8u.CompanyUuid?)
           : null;

  factory CitizenInt({
    int? id,
    required String name,
    _ih0efjtk.AddressUuid? address,
    required _isc.UuidValue companyId,
    _i441ok8u.CompanyUuid? company,
    _isc.UuidValue? oldCompanyId,
    _i441ok8u.CompanyUuid? oldCompany,
  }) = _CitizenIntImpl;

  factory CitizenInt.fromJson(Map<String, dynamic> jsonSerialization) {
    return _CitizenIntImpl(
      id: jsonSerialization['id'] as int?,
      name: jsonSerialization['name'] as String,
      address: jsonSerialization.containsKey('address')
          ? jsonSerialization['address'] == null
                ? null
                : _i0ntutnq.Protocol().deserialize<_ih0efjtk.AddressUuid>(
                    jsonSerialization['address'],
                  )
          : #serverpodUnloadedRelation,
      companyId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['companyId'],
      ),
      company: jsonSerialization['company'] == null
          ? null
          : _i0ntutnq.Protocol().deserialize<_i441ok8u.CompanyUuid>(
              jsonSerialization['company'],
            ),
      oldCompanyId: jsonSerialization['oldCompanyId'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(
              jsonSerialization['oldCompanyId'],
            ),
      oldCompany: jsonSerialization.containsKey('oldCompany')
          ? jsonSerialization['oldCompany'] == null
                ? null
                : _i0ntutnq.Protocol().deserialize<_i441ok8u.CompanyUuid>(
                    jsonSerialization['oldCompany'],
                  )
          : #serverpodUnloadedRelation,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String name;

  bool _address$loaded;

  _ih0efjtk.AddressUuid? _address;

  _isc.UuidValue companyId;

  _i441ok8u.CompanyUuid? company;

  _isc.UuidValue? oldCompanyId;

  bool _oldCompany$loaded;

  _i441ok8u.CompanyUuid? _oldCompany;

  /// Throws `RelationNotLoadedError` if this relation was not loaded.
  _ih0efjtk.AddressUuid? get address {
    final value = _address;
    if (!_address$loaded) {
      throw _iss.RelationNotLoadedError(
        model: 'CitizenInt',
        relation: 'address',
      );
    }
    return value;
  }

  set address(_ih0efjtk.AddressUuid? value) {
    _address = value;
    _address$loaded = true;
  }

  /// Throws `RelationNotLoadedError` if this relation was not loaded.
  _i441ok8u.CompanyUuid? get oldCompany {
    final value = _oldCompany;
    if (!_oldCompany$loaded) {
      throw _iss.RelationNotLoadedError(
        model: 'CitizenInt',
        relation: 'oldCompany',
      );
    }
    return value;
  }

  set oldCompany(_i441ok8u.CompanyUuid? value) {
    _oldCompany = value;
    _oldCompany$loaded = true;
  }

  /// Returns a shallow copy of this [CitizenInt]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CitizenInt copyWith({
    int? id,
    String? name,
    Object? address = _Undefined,
    _isc.UuidValue? companyId,
    _i441ok8u.CompanyUuid? company,
    _isc.UuidValue? oldCompanyId,
    Object? oldCompany = _Undefined,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CitizenInt',
      if (id != null) 'id': id,
      'name': name,
      if (_address$loaded) 'address': _address?.toJson(),
      'companyId': companyId.toJson(),
      if (company != null) 'company': company?.toJson(),
      if (oldCompanyId != null) 'oldCompanyId': oldCompanyId?.toJson(),
      if (_oldCompany$loaded) 'oldCompany': _oldCompany?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'CitizenInt',
      if (id != null) 'id': id,
      'name': name,
      if (_address$loaded) 'address': _address?.toJsonForProtocol(),
      'companyId': companyId.toJson(),
      if (company != null) 'company': company?.toJsonForProtocol(),
      if (oldCompanyId != null) 'oldCompanyId': oldCompanyId?.toJson(),
      if (_oldCompany$loaded) 'oldCompany': _oldCompany?.toJsonForProtocol(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CitizenIntImpl extends CitizenInt {
  _CitizenIntImpl({
    int? id,
    required String name,
    Object? address = #serverpodUnloadedRelation,
    required _isc.UuidValue companyId,
    _i441ok8u.CompanyUuid? company,
    _isc.UuidValue? oldCompanyId,
    Object? oldCompany = #serverpodUnloadedRelation,
  }) : super._(
         id: id,
         name: name,
         address: address,
         companyId: companyId,
         company: company,
         oldCompanyId: oldCompanyId,
         oldCompany: oldCompany,
       );

  /// Returns a shallow copy of this [CitizenInt]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CitizenInt copyWith({
    Object? id = _Undefined,
    String? name,
    Object? address = _Undefined,
    _isc.UuidValue? companyId,
    Object? company = _Undefined,
    Object? oldCompanyId = _Undefined,
    Object? oldCompany = _Undefined,
  }) {
    return _CitizenIntImpl(
      id: id is int? ? id : this.id,
      name: name ?? this.name,
      address: address is _ih0efjtk.AddressUuid?
          ? address?.copyWith()
          : _address$loaded
          ? this._address?.copyWith()
          : #serverpodUnloadedRelation,
      companyId: companyId ?? this.companyId,
      company: company is _i441ok8u.CompanyUuid?
          ? company
          : this.company?.copyWith(),
      oldCompanyId: oldCompanyId is _isc.UuidValue?
          ? oldCompanyId
          : this.oldCompanyId,
      oldCompany: oldCompany is _i441ok8u.CompanyUuid?
          ? oldCompany?.copyWith()
          : _oldCompany$loaded
          ? this._oldCompany?.copyWith()
          : #serverpodUnloadedRelation,
    );
  }
}
