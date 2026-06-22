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
import 'package:serverpod_serialization/serverpod_serialization.dart' as _i1;

/// The definition of a (desired) row-level security policy in the database.
///
/// A policy restricts access to rows of a table to those where [column] matches
/// a session variable that Serverpod sets per transaction from the
/// authenticated user.
abstract class RowSecurityPolicyDefinition implements _i1.SerializableModel {
  RowSecurityPolicyDefinition._({
    required this.name,
    required this.column,
    required this.sessionVariable,
    this.castType,
  });

  factory RowSecurityPolicyDefinition({
    required String name,
    required String column,
    required String sessionVariable,
    String? castType,
  }) = _RowSecurityPolicyDefinitionImpl;

  factory RowSecurityPolicyDefinition.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return RowSecurityPolicyDefinition(
      name: jsonSerialization['name'] as String,
      column: jsonSerialization['column'] as String,
      sessionVariable: jsonSerialization['sessionVariable'] as String,
      castType: jsonSerialization['castType'] as String?,
    );
  }

  /// The user defined name of the policy.
  String name;

  /// The column that is matched against the [sessionVariable].
  String column;

  /// The PostgreSQL session variable (set with `SET LOCAL`) the [column] is
  /// matched against, e.g. `serverpod.user_id`.
  String sessionVariable;

  /// The type the [sessionVariable] is cast to before being compared with the
  /// [column], e.g. `uuid`. If null, the value is compared as text.
  String? castType;

  /// Returns a shallow copy of this [RowSecurityPolicyDefinition]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  RowSecurityPolicyDefinition copyWith({
    String? name,
    String? column,
    String? sessionVariable,
    String? castType,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod.RowSecurityPolicyDefinition',
      'name': name,
      'column': column,
      'sessionVariable': sessionVariable,
      if (castType != null) 'castType': castType,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _RowSecurityPolicyDefinitionImpl extends RowSecurityPolicyDefinition {
  _RowSecurityPolicyDefinitionImpl({
    required String name,
    required String column,
    required String sessionVariable,
    String? castType,
  }) : super._(
         name: name,
         column: column,
         sessionVariable: sessionVariable,
         castType: castType,
       );

  /// Returns a shallow copy of this [RowSecurityPolicyDefinition]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  RowSecurityPolicyDefinition copyWith({
    String? name,
    String? column,
    String? sessionVariable,
    Object? castType = _Undefined,
  }) {
    return RowSecurityPolicyDefinition(
      name: name ?? this.name,
      column: column ?? this.column,
      sessionVariable: sessionVariable ?? this.sessionVariable,
      castType: castType is String? ? castType : this.castType,
    );
  }
}
