import 'dart:typed_data';

import 'package:serverpod_serialization/serverpod_serialization.dart';

/// Optional capability implemented by protocols generated with typed routing.
///
/// Older protocols need no changes and retain their original fallback behavior.
abstract interface class ProtocolDeserializationProvider
    implements SerializationManager {
  /// Immutable typed handlers and module order for this protocol.
  ProtocolDeserialization get deserializationMetadata;
}

/// Immutable type declarations used to avoid probing unrelated protocols.
///
/// Generated protocols declare every local typed handler, including nullable
/// and container types, and their dependencies in deserialization order.
/// This metadata never changes class names or caches deserialized values.
class ProtocolDeserialization {
  final Set<Type> _types;

  /// Module protocols in their original fallback order.
  final List<SerializationManager> modules;

  final Map<Type, List<SerializationManager>> _routes = {};
  final Set<Type> _resolving = {};

  /// Creates metadata for a generated protocol whose final fallback is
  /// [SerializationManager.deserialize].
  ///
  /// [types] must contain every locally handled type. Modules without metadata
  /// remain eligible for every type, allowing independently regenerated modules.
  ProtocolDeserialization({
    required Iterable<Type> types,
    required List<SerializationManager> modules,
  }) : _types = Set.unmodifiable(types),
       modules = List.unmodifiable(modules);

  /// Returns modules that may handle [type], preserving fallback order.
  ///
  /// Use the full [modules] list when routing by a class discriminator: an
  /// otherwise unrelated module may recognize that name. This method only
  /// answers questions about typed dispatch, independently of the payload.
  List<SerializationManager> modulesForType(Type type) {
    return _routes.putIfAbsent(
      type,
      () {
        _resolving.add(type);
        try {
          return List.unmodifiable(
            modules.where((module) {
              return module is! ProtocolDeserializationProvider ||
                  module.deserializationMetadata._mayDeserialize(type);
            }),
          );
        } finally {
          _resolving.remove(type);
        }
      },
    );
  }

  bool _mayDeserialize(Type type) {
    return _types.contains(type) ||
        _primitiveTypes.contains(type) ||
        _resolving.contains(type) ||
        modulesForType(type).isNotEmpty;
  }

  // These are the final fallback handlers in SerializationManager.deserialize.
  static final Set<Type> _primitiveTypes = {
    int,
    getType<int?>(),
    double,
    getType<double?>(),
    String,
    getType<String?>(),
    bool,
    getType<bool?>(),
    DateTime,
    getType<DateTime?>(),
    ByteData,
    getType<ByteData?>(),
    Duration,
    getType<Duration?>(),
    UuidValue,
    getType<UuidValue?>(),
    Vector,
    getType<Vector?>(),
    HalfVector,
    getType<HalfVector?>(),
    SparseVector,
    getType<SparseVector?>(),
    Bit,
    getType<Bit?>(),
    GeographyPoint,
    getType<GeographyPoint?>(),
    GeographyLineString,
    getType<GeographyLineString?>(),
    GeographyPolygon,
    getType<GeographyPolygon?>(),
    GeographyGeometryCollection,
    getType<GeographyGeometryCollection?>(),
    Uri,
    getType<Uri?>(),
    BigInt,
    getType<BigInt?>(),
  };
}
