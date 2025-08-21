import 'package:serverpod_cli/analyzer.dart';
import 'package:serverpod_cli/src/analyzer/dart/definitions.dart';
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
              .withParameters([
            ParameterDefinition(
                name: 'name',
                type: TypeDefinitionBuilder().withClassName('String').build(),
                required: true)
          ]).buildMethodCallDefinition()
        ]).build()
      ],
      models: [],
    );

    var codeMap = generator.generateProtocolCode(
      protocolDefinition: protocolDefinition,
      config: config,
    );

    late var clientCode = codeMap.values
        .where((code) => code.contains('unauthenticatedEndpoints'))
        .first;

    test('then client code overrides the unauthenticatedEndpoints property.',
        () {
      expect(
        clientCode,
        contains('@override\n  Set<String> get unauthenticatedEndpoints =>'),
      );
    });

    test('then unauthenticatedEndpoints is empty.', () {
      var clientCode = codeMap.values
          .where((code) => code.contains('unauthenticatedEndpoints'))
          .firstOrNull;

      expect(clientCode, contains('unauthenticatedEndpoints => {}'));
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
              .withName('world')
              .withReturnType(
                  TypeDefinitionBuilder().withFutureOf('String').build())
              .buildMethodCallDefinition()
        ]).build()
      ],
      models: [],
    );

    var codeMap = generator.generateProtocolCode(
      protocolDefinition: protocolDefinition,
      config: config,
    );

    test('then unauthenticatedEndpoints contains all endpoint method.', () {
      var clientCode = codeMap.values
          .where((code) => code.contains('unauthenticatedEndpoints'))
          .first;

      expect(
        clientCode,
        contains(
          'unauthenticatedEndpoints => {\n'
          "        'example.hello',\n"
          "        'example.world',\n"
          '      };\n',
        ),
      );
    });
  });

  group(
      'Given an endpoint with only one method annotated as @unauthenticated when generating client code',
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
              .buildMethodCallDefinition()
        ]).build()
      ],
      models: [],
    );

    var codeMap = generator.generateProtocolCode(
      protocolDefinition: protocolDefinition,
      config: config,
    );

    test(
        'then unauthenticatedEndpoints contains only the unauthenticated method.',
        () {
      var clientCode = codeMap.values
          .where((code) => code.contains('unauthenticatedEndpoints'))
          .first;

      expect(
        clientCode,
        contains('unauthenticatedEndpoints => {\'example.hello\'}'),
      );
    });
  });
}
