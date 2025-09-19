import 'package:serverpod/serverpod.dart';

/// TODO: As this class is marked as [doNotGenerate], it will not generate any
/// client code - not even an abstract class.
@doNotGenerate
class HiddenBaseClass extends Endpoint {
  /// This method will be exposed in the [PublicExtensibleClass].
  Future<String> publicMethod(final Session session) async => 'public';
}

/// TODO: As this class is abstract, it will generate a corresponding abstract
/// class on the client without method bodies to work as an interface. But the
/// generated class will not extend [HiddenBaseClass] as that is not exposed
/// to the client.
abstract class PublicExtensibleClass extends HiddenBaseClass {
  /// This method will be exposed in the [PublicExtensibleClass].
  Future<void> virtualMethod();
}

/// TODO: This class should be generated in the client as a normal class that
/// extends [PublicExtensibleClass]. It must have both [publicMethod] and
/// [virtualMethod] implemented.
class PublicImplementationClass extends PublicExtensibleClass {
  @override
  Future<String> virtualMethod() async => 'virtual';
}
