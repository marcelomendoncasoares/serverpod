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
import '../../models_with_relations/one_to_one/address.dart' as _i5rzbc0r;
import '../../models_with_relations/one_to_one/company.dart' as _i2fdza8t;

abstract class Citizen
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  Citizen._({
    this.id,
    required this.name,
    _i5rzbc0r.Address? address = const _UndefinedCitizen$address(),
    required this.companyId,
    this.company,
    this.oldCompanyId,
    _i2fdza8t.Company? oldCompany = const _UndefinedCitizen$company(),
  }) : _address = address,
       _oldCompany = oldCompany;

  factory Citizen({
    int? id,
    required String name,
    _i5rzbc0r.Address? address,
    required int companyId,
    _i2fdza8t.Company? company,
    int? oldCompanyId,
    _i2fdza8t.Company? oldCompany,
  }) = _CitizenImpl;

  factory Citizen.fromJson(Map<String, dynamic> jsonSerialization) {
    return _CitizenImpl(
      id: jsonSerialization['id'] as int?,
      name: jsonSerialization['name'] as String,
      address: jsonSerialization.containsKey('address')
          ? jsonSerialization['address'] == null
                ? null
                : _iza9lbb5.Protocol().deserialize<_i5rzbc0r.Address>(
                    jsonSerialization['address'],
                  )
          : const _UndefinedCitizen$address(),
      companyId: jsonSerialization['companyId'] as int,
      company: jsonSerialization['company'] == null
          ? null
          : _iza9lbb5.Protocol().deserialize<_i2fdza8t.Company>(
              jsonSerialization['company'],
            ),
      oldCompanyId: jsonSerialization['oldCompanyId'] as int?,
      oldCompany: jsonSerialization.containsKey('oldCompany')
          ? jsonSerialization['oldCompany'] == null
                ? null
                : _iza9lbb5.Protocol().deserialize<_i2fdza8t.Company>(
                    jsonSerialization['oldCompany'],
                  )
          : const _UndefinedCitizen$company(),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String name;

  _i5rzbc0r.Address? _address;

  int companyId;

  _i2fdza8t.Company? company;

  int? oldCompanyId;

  _i2fdza8t.Company? _oldCompany;

  /// Throws `RelationNotLoadedError` if this relation was not loaded.
  _i5rzbc0r.Address? get address {
    final value = _address;
    if (value is _issu.UndefinedSentinel) {
      throw _iss.RelationNotLoadedError(
        model: 'Citizen',
        relation: 'address',
      );
    }
    return value;
  }

  set address(_i5rzbc0r.Address? value) {
    _address = value;
  }

  /// Throws `RelationNotLoadedError` if this relation was not loaded.
  _i2fdza8t.Company? get oldCompany {
    final value = _oldCompany;
    if (value is _issu.UndefinedSentinel) {
      throw _iss.RelationNotLoadedError(
        model: 'Citizen',
        relation: 'oldCompany',
      );
    }
    return value;
  }

  set oldCompany(_i2fdza8t.Company? value) {
    _oldCompany = value;
  }

  /// Returns a shallow copy of this [Citizen]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  Citizen copyWith({
    int? id,
    String? name,
    _i5rzbc0r.Address? address = const _UndefinedCitizen$address(),
    int? companyId,
    _i2fdza8t.Company? company = const _UndefinedCitizen$company(),
    int? oldCompanyId,
    _i2fdza8t.Company? oldCompany = const _UndefinedCitizen$company(),
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Citizen',
      if (id != null) 'id': id,
      'name': name,
      if (_address is! _issu.UndefinedSentinel) 'address': _address?.toJson(),
      'companyId': companyId,
      if (company != null) 'company': company?.toJson(),
      if (oldCompanyId != null) 'oldCompanyId': oldCompanyId,
      if (_oldCompany is! _issu.UndefinedSentinel)
        'oldCompany': _oldCompany?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Citizen',
      if (id != null) 'id': id,
      'name': name,
      if (_address is! _issu.UndefinedSentinel)
        'address': _address?.toJsonForProtocol(),
      'companyId': companyId,
      if (company != null) 'company': company?.toJsonForProtocol(),
      if (oldCompanyId != null) 'oldCompanyId': oldCompanyId,
      if (_oldCompany is! _issu.UndefinedSentinel)
        'oldCompany': _oldCompany?.toJsonForProtocol(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _UndefinedCitizen$address extends _issu.UndefinedSentinel
    implements _i5rzbc0r.Address {
  const _UndefinedCitizen$address();
}

class _UndefinedCitizen$company extends _issu.UndefinedSentinel
    implements _i2fdza8t.Company {
  const _UndefinedCitizen$company();
}

class _CitizenImpl extends Citizen {
  _CitizenImpl({
    int? id,
    required String name,
    _i5rzbc0r.Address? address = const _UndefinedCitizen$address(),
    required int companyId,
    _i2fdza8t.Company? company,
    int? oldCompanyId,
    _i2fdza8t.Company? oldCompany = const _UndefinedCitizen$company(),
  }) : super._(
         id: id,
         name: name,
         address: address,
         companyId: companyId,
         company: company,
         oldCompanyId: oldCompanyId,
         oldCompany: oldCompany,
       );

  /// Returns a shallow copy of this [Citizen]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  Citizen copyWith({
    Object? id = _Undefined,
    String? name,
    _i5rzbc0r.Address? address = const _UndefinedCitizen$address(),
    int? companyId,
    _i2fdza8t.Company? company = const _UndefinedCitizen$company(),
    Object? oldCompanyId = _Undefined,
    _i2fdza8t.Company? oldCompany = const _UndefinedCitizen$company(),
  }) {
    return _CitizenImpl(
      id: id is int? ? id : this.id,
      name: name ?? this.name,
      address: address is _issu.UndefinedSentinel
          ? _address is _issu.UndefinedSentinel
                ? _address
                : this._address?.copyWith()
          : address?.copyWith(),
      companyId: companyId ?? this.companyId,
      company: company is _issu.UndefinedSentinel
          ? this.company?.copyWith()
          : company,
      oldCompanyId: oldCompanyId is int? ? oldCompanyId : this.oldCompanyId,
      oldCompany: oldCompany is _issu.UndefinedSentinel
          ? _oldCompany is _issu.UndefinedSentinel
                ? _oldCompany
                : this._oldCompany?.copyWith()
          : oldCompany?.copyWith(),
    );
  }
}
