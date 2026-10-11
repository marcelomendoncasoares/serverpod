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
import 'package:serverpod/serverpod.dart' as _is;

class StringIdBase implements _is.SerializableModel, _is.ProtocolSerialization {
  StringIdBase({required this.id});

  factory StringIdBase.fromJson(Map<String, dynamic> jsonSerialization) {
    return StringIdBase(id: jsonSerialization['id'] as String);
  }

  String id;

  /// Returns a shallow copy of this [StringIdBase]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  StringIdBase copyWith({String? id}) {
    return StringIdBase(id: id ?? this.id);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'StringIdBase',
      'id': id,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'StringIdBase',
      'id': id,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}
