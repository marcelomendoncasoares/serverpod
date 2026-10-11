import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:path/path.dart' as path;
import 'package:serverpod_cli/src/analyzer/models/definitions.dart';
import 'package:serverpod_cli/src/analyzer/models/stateful_analyzer.dart';
import 'package:serverpod_cli/src/generator/code_generation_collector.dart';
import 'package:serverpod_cli/src/generator/dart/client_code_generator.dart';
import 'package:serverpod_cli/src/generator/dart/server_code_generator.dart';
import 'package:test/test.dart';

import '../../test_util/builders/generator_config_builder.dart';
import '../../test_util/builders/model_source_builder.dart';
import '../../test_util/compilation_unit_helpers.dart';

void main() {
  final config = GeneratorConfigBuilder().withName('example_project').build();

  group('Given a table model inheriting a required String ID,', () {
    late List<SerializableModelDefinition> models;

    setUpAll(() {
      final collector = CodeGenerationCollector();
      models = StatefulAnalyzer(
        config,
        [
          ModelSourceBuilder().withFileName('base').withYaml('''
class: Base
fields:
  id: String
  name: String
''').build(),
          ModelSourceBuilder().withFileName('child').withYaml('''
class: Child
extends: Base
table: child
fields:
  age: int
''').build(),
        ],
        onErrorsCollector(collector),
      ).validateAll();

      if (collector.errors.isNotEmpty) {
        throw StateError(collector.errors.toString());
      }
    });

    test(
      'when generating server code, '
      'then the constructor forwards the ID to its parent.',
      () {
        final code = const DartServerCodeGenerator()
            .generateSerializableModelsCode(models: models, config: config);
        final unit = parseString(
          content: code[path.join('lib', 'src', 'generated', 'child.dart')]!,
        ).unit;
        final child = CompilationUnitHelpers.tryFindClassDeclaration(
          unit,
          name: 'Child',
        )!;
        final constructor =
            CompilationUnitHelpers.tryFindConstructorDeclaration(
              child,
              name: '_',
            )!;

        expect(
          constructor.initializers.map((initializer) => initializer.toSource()),
          ['super(id: id)'],
        );
      },
    );

    test(
      'when generating client code, '
      'then the constructor forwards the ID to its parent.',
      () {
        final code = const DartClientCodeGenerator()
            .generateSerializableModelsCode(models: models, config: config);
        final unit = parseString(
          content:
              code[path.join(
                '..',
                'example_project_client',
                'lib',
                'src',
                'protocol',
                'child.dart',
              )]!,
        ).unit;
        final child = CompilationUnitHelpers.tryFindClassDeclaration(
          unit,
          name: 'Child',
        )!;
        final constructor =
            CompilationUnitHelpers.tryFindConstructorDeclaration(
              child,
              name: '_',
            )!;

        expect(
          constructor.initializers.map((initializer) => initializer.toSource()),
          ['super(id: id)'],
        );
      },
    );
  });
}
