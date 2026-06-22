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
import 'package:serverpod_client/serverpod_client.dart' as _i1;

/// A table protected with row-level security, used to verify that rows are only
/// visible to the authenticated user that owns them (matched on `ownerId`).
abstract class SecuredRecord implements _i1.SerializableModel {
  SecuredRecord._({
    this.id,
    required this.ownerId,
    required this.name,
  });

  factory SecuredRecord({
    int? id,
    required _i1.UuidValue ownerId,
    required String name,
  }) = _SecuredRecordImpl;

  factory SecuredRecord.fromJson(Map<String, dynamic> jsonSerialization) {
    return SecuredRecord(
      id: jsonSerialization['id'] as int?,
      ownerId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['ownerId'],
      ),
      name: jsonSerialization['name'] as String,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  _i1.UuidValue ownerId;

  String name;

  /// Returns a shallow copy of this [SecuredRecord]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  SecuredRecord copyWith({
    int? id,
    _i1.UuidValue? ownerId,
    String? name,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'SecuredRecord',
      if (id != null) 'id': id,
      'ownerId': ownerId.toJson(),
      'name': name,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _SecuredRecordImpl extends SecuredRecord {
  _SecuredRecordImpl({
    int? id,
    required _i1.UuidValue ownerId,
    required String name,
  }) : super._(
         id: id,
         ownerId: ownerId,
         name: name,
       );

  /// Returns a shallow copy of this [SecuredRecord]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  SecuredRecord copyWith({
    Object? id = _Undefined,
    _i1.UuidValue? ownerId,
    String? name,
  }) {
    return SecuredRecord(
      id: id is int? ? id : this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
    );
  }
}
