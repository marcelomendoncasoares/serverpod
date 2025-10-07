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
import 'package:serverpod/serverpod.dart' as _i1;
import '../../inheritance/polymorphism/child.dart' as _i2;

/// A class that holds child objects.
abstract class PolymorphicChildContainer
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  PolymorphicChildContainer._({
    required this.child,
    required this.childrenList,
    required this.childrenMap,
  });

  factory PolymorphicChildContainer({
    required _i2.PolymorphicChild child,
    required List<_i2.PolymorphicChild> childrenList,
    required Map<String, _i2.PolymorphicChild> childrenMap,
  }) = _PolymorphicChildContainerImpl;

  factory PolymorphicChildContainer.fromJson(
      Map<String, dynamic> jsonSerialization) {
    return PolymorphicChildContainer(
      child: _i2.PolymorphicChild.fromJson(
          (jsonSerialization['child'] as Map<String, dynamic>)),
      childrenList: (jsonSerialization['childrenList'] as List)
          .map(
              (e) => _i2.PolymorphicChild.fromJson((e as Map<String, dynamic>)))
          .toList(),
      childrenMap:
          (jsonSerialization['childrenMap'] as Map).map((k, v) => MapEntry(
                k as String,
                _i2.PolymorphicChild.fromJson((v as Map<String, dynamic>)),
              )),
    );
  }

  /// Direct contained child.
  _i2.PolymorphicChild child;

  /// List of children.
  List<_i2.PolymorphicChild> childrenList;

  /// Map of children.
  Map<String, _i2.PolymorphicChild> childrenMap;

  /// Returns a shallow copy of this [PolymorphicChildContainer]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  PolymorphicChildContainer copyWith({
    _i2.PolymorphicChild? child,
    List<_i2.PolymorphicChild>? childrenList,
    Map<String, _i2.PolymorphicChild>? childrenMap,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      'child': child.toJson(),
      'childrenList': childrenList.toJson(valueToJson: (v) => v.toJson()),
      'childrenMap': childrenMap.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      'child': child.toJsonForProtocol(),
      'childrenList':
          childrenList.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      'childrenMap':
          childrenMap.toJson(valueToJson: (v) => v.toJsonForProtocol()),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _PolymorphicChildContainerImpl extends PolymorphicChildContainer {
  _PolymorphicChildContainerImpl({
    required _i2.PolymorphicChild child,
    required List<_i2.PolymorphicChild> childrenList,
    required Map<String, _i2.PolymorphicChild> childrenMap,
  }) : super._(
          child: child,
          childrenList: childrenList,
          childrenMap: childrenMap,
        );

  /// Returns a shallow copy of this [PolymorphicChildContainer]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  PolymorphicChildContainer copyWith({
    _i2.PolymorphicChild? child,
    List<_i2.PolymorphicChild>? childrenList,
    Map<String, _i2.PolymorphicChild>? childrenMap,
  }) {
    return PolymorphicChildContainer(
      child: child ?? this.child.copyWith(),
      childrenList:
          childrenList ?? this.childrenList.map((e0) => e0.copyWith()).toList(),
      childrenMap: childrenMap ??
          this.childrenMap.map((
                key0,
                value0,
              ) =>
                  MapEntry(
                    key0,
                    value0.copyWith(),
                  )),
    );
  }
}
