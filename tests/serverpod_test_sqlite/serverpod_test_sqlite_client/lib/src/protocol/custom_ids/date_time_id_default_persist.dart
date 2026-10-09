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

abstract class DateTimeIdDefaultPersist
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  DateTimeIdDefaultPersist._({
    this.id,
    required this.value,
  });

  factory DateTimeIdDefaultPersist({
    DateTime? id,
    required String value,
  }) = _DateTimeIdDefaultPersistImpl;

  factory DateTimeIdDefaultPersist.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return DateTimeIdDefaultPersist(
      id: jsonSerialization['id'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['id']),
      value: jsonSerialization['value'] as String,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  DateTime? id;

  String value;

  /// Returns a shallow copy of this [DateTimeIdDefaultPersist]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  DateTimeIdDefaultPersist copyWith({
    DateTime? id = const _isc.$UndefinedDateTime(),
    String? value,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'DateTimeIdDefaultPersist',
      if (id != null) 'id': id?.toJson(),
      'value': value,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'DateTimeIdDefaultPersist',
      if (id != null) 'id': id?.toJson(),
      'value': value,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _DateTimeIdDefaultPersistImpl extends DateTimeIdDefaultPersist {
  _DateTimeIdDefaultPersistImpl({
    DateTime? id,
    required String value,
  }) : super._(
         id: id,
         value: value,
       );

  /// Returns a shallow copy of this [DateTimeIdDefaultPersist]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  DateTimeIdDefaultPersist copyWith({
    DateTime? id = const _isc.$UndefinedDateTime(),
    String? value,
  }) {
    return DateTimeIdDefaultPersist(
      id: id is _isc.UndefinedSentinel ? this.id : id,
      value: value ?? this.value,
    );
  }
}
