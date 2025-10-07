import 'package:serverpod/serverpod.dart';
import 'package:serverpod_test_server/src/generated/protocol.dart';

/// Endpoint for testing polymorphism functionality.
class InheritancePolymorphismTestEndpoint extends Endpoint {
  /// Receives a PolymorphicParent object for testing serialization.
  ///
  /// Returns the runtime type and the object itself. The object must retain
  /// its class when received by the client.
  Future<(String, PolymorphicParent)> polymorphicRoundtrip(
    Session session,
    PolymorphicParent parent,
  ) async {
    var runtimeType = parent.runtimeType.toString();
    return (runtimeType, parent);
  }

  /// Receives a PolymorphicChildContainer object for testing serialization.
  ///
  /// Returns the container object itself. All nested polymorphic objects must
  /// retain their runtime types when received by the client.
  Future<PolymorphicChildContainer> polymorphicContainerRoundtrip(
    Session session,
    PolymorphicChildContainer container,
  ) async {
    return container;
  }
}
