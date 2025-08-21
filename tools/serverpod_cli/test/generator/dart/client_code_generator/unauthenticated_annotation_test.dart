import 'package:serverpod_cli/analyzer.dart';
import 'package:serverpod_cli/src/generator/dart/client_code_generator.dart';
import 'package:test/test.dart';

import '../../../test_util/builders/annotation_definition_builder.dart';
import '../../../test_util/builders/endpoint_definition_builder.dart';
import '../../../test_util/builders/generator_config_builder.dart';
import '../../../test_util/builders/method_definition_builder.dart';
import '../../../test_util/builders/type_definition_builder.dart';

const generator = DartClientCodeGenerator();

void main() {
  var config = GeneratorConfigBuilder().build();

  group(
      'Given an endpoint without @unauthenticated annotation when generating client code',
      () {
    var protocolDefinition = ProtocolDefinition(
      endpoints: [
        EndpointDefinitionBuilder()
            .withClassName('ExampleEndpoint')
            .withName('example')
            .withFilePath('lib/src/endpoints/example_endpoint.dart')
            .withMethods([
          MethodDefinitionBuilder()
              .withName('hello')
              .withReturnType(
                  TypeDefinitionBuilder().withFutureOf('String').build())
              .buildMethodCallDefinition(),
          MethodDefinitionBuilder()
              .withName('streaming')
              .withReturnType(
                  TypeDefinitionBuilder().withStreamOf('String').build())
              .buildMethodStreamDefinition()
        ]).build()
      ],
      models: [],
    );

    var codeMap = generator.generateProtocolCode(
      protocolDefinition: protocolDefinition,
      config: config,
    );

    test('then method calls have no authenticated parameter.', () {
      var clientCode = codeMap.values
          .where((code) => code.contains('callServerEndpoint'))
          .first;

      expect(clientCode, contains('''\
  Future<String> hello() => caller.callServerEndpoint<String>(
        'example',
        'hello',
        {},
      );
'''));
    });

    test('then streaming method calls have no authenticated parameter.', () {
      var clientCode = codeMap.values
          .where((code) => code.contains('callStreamingServerEndpoint'))
          .first;

      expect(clientCode, contains('''\
  Stream<String> streaming() =>
      caller.callStreamingServerEndpoint<Stream<String>, String>(
        'example',
        'streaming',
        {},
        {},
      );
'''));
    });
  });

  group(
      'Given an endpoint annotated as @unauthenticated with more than one method when generating client code',
      () {
    var protocolDefinition = ProtocolDefinition(
      endpoints: [
        EndpointDefinitionBuilder()
            .withClassName('ExampleEndpoint')
            .withName('example')
            .withFilePath('lib/src/endpoints/example_endpoint.dart')
            .withAnnotations([
          AnnotationDefinitionBuilder().withName('unauthenticated').build()
        ]).withMethods([
          MethodDefinitionBuilder()
              .withName('hello')
              .withReturnType(
                  TypeDefinitionBuilder().withFutureOf('String').build())
              .buildMethodCallDefinition(),
          MethodDefinitionBuilder()
              .withName('streaming')
              .withReturnType(
                  TypeDefinitionBuilder().withStreamOf('String').build())
              .buildMethodStreamDefinition()
        ]).build()
      ],
      models: [],
    );

    var codeMap = generator.generateProtocolCode(
      protocolDefinition: protocolDefinition,
      config: config,
    );

    test('then method calls have the authenticated parameter.', () {
      var clientCode = codeMap.values
          .where((code) => code.contains('callServerEndpoint'))
          .first;

      expect(clientCode, contains('''\
  Future<String> hello() => caller.callServerEndpoint<String>(
        'example',
        'hello',
        {},
        authenticated: false,
      );
'''));
    });

    test('then streaming method calls have the authenticated parameter.', () {
      var clientCode = codeMap.values
          .where((code) => code.contains('callStreamingServerEndpoint'))
          .first;

      expect(clientCode, contains('''\
  Stream<String> streaming() =>
      caller.callStreamingServerEndpoint<Stream<String>, String>(
        'example',
        'streaming',
        {},
        {},
        authenticated: false,
      );
'''));
    });
  });

  group(
      'Given an endpoint with only a few methods annotated as @unauthenticated when generating client code',
      () {
    var protocolDefinition = ProtocolDefinition(
      endpoints: [
        EndpointDefinitionBuilder()
            .withClassName('ExampleEndpoint')
            .withName('example')
            .withFilePath('lib/src/endpoints/example_endpoint.dart')
            .withMethods([
          MethodDefinitionBuilder()
              .withName('hello')
              .withReturnType(
                  TypeDefinitionBuilder().withFutureOf('String').build())
              .withAnnotations([
            AnnotationDefinitionBuilder().withName('unauthenticated').build()
          ]).buildMethodCallDefinition(),
          MethodDefinitionBuilder()
              .withName('authenticated')
              .withReturnType(
                  TypeDefinitionBuilder().withFutureOf('String').build())
              .buildMethodCallDefinition(),
          MethodDefinitionBuilder()
              .withName('streaming')
              .withReturnType(
                  TypeDefinitionBuilder().withStreamOf('String').build())
              .withAnnotations([
            AnnotationDefinitionBuilder().withName('unauthenticated').build()
          ]).buildMethodStreamDefinition(),
          MethodDefinitionBuilder()
              .withName('streamingAuthenticated')
              .withReturnType(
                  TypeDefinitionBuilder().withStreamOf('String').build())
              .buildMethodStreamDefinition(),
        ]).build()
      ],
      models: [],
    );

    var codeMap = generator.generateProtocolCode(
      protocolDefinition: protocolDefinition,
      config: config,
    );

    test('then hello method call have the authenticated parameter.', () {
      var clientCode =
          codeMap.values.where((code) => code.contains('hello')).first;

      expect(clientCode, contains('''\
  Future<String> hello() => caller.callServerEndpoint<String>(
        'example',
        'hello',
        {},
        authenticated: false,
      );
'''));
    });

    test('then streaming method call have the authenticated parameter.', () {
      var clientCode =
          codeMap.values.where((code) => code.contains('streaming')).first;

      expect(clientCode, contains('''\
  Stream<String> streaming() =>
      caller.callStreamingServerEndpoint<Stream<String>, String>(
        'example',
        'streaming',
        {},
        {},
        authenticated: false,
      );
'''));
    });

    test(
        'then authenticated method call does not have the authenticated parameter.',
        () {
      var clientCode =
          codeMap.values.where((code) => code.contains('authenticated')).first;

      expect(clientCode, contains('''\
  Future<String> authenticated() => caller.callServerEndpoint<String>(
        'example',
        'authenticated',
        {},
      );
'''));
    });

    test(
        'then streamingAuthenticated method call does not have the authenticated parameter.',
        () {
      var clientCode = codeMap.values
          .where((code) => code.contains('streamingAuthenticated'))
          .first;

      expect(clientCode, contains('''\
  Stream<String> streamingAuthenticated() =>
      caller.callStreamingServerEndpoint<Stream<String>, String>(
        'example',
        'streamingAuthenticated',
        {},
        {},
      );
'''));
    });
  });
}
