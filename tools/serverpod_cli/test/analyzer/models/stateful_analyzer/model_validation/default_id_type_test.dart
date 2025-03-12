import 'package:serverpod_cli/src/analyzer/models/definitions.dart';
import 'package:serverpod_cli/src/analyzer/models/stateful_analyzer.dart';
import 'package:serverpod_cli/src/generator/code_generation_collector.dart';
import 'package:serverpod_cli/src/generator/types.dart';
import 'package:test/test.dart';

import '../../../../test_util/builders/generator_config_builder.dart';
import '../../../../test_util/builders/model_source_builder.dart';


void main() {
  GeneratorConfigBuilder configBuilder() => GeneratorConfigBuilder();

  test('Given no change in default id type, the id of the table is int.', () {
    var yamlSource = ModelSourceBuilder().withYaml(
      '''
      class: Example
      table: example
      fields:
        name: String
      ''',
    ).build();

    var config = configBuilder().build();
    var statefulAnalyzer = StatefulAnalyzer(config, [yamlSource]);
    var model = statefulAnalyzer.validateAll().first as ModelClassDefinition;

    expect(model.idField.type.className, 'int');
  });

  group('Given the default id type is "int"', () {
    var yamlSource = ModelSourceBuilder().withYaml(
      '''
        class: Example
        table: example
        fields:
          name: String
        ''',
    ).build();

    var collector = CodeGenerationCollector();
    var config = configBuilder().withDefaultIdType(SupportedIdType.int).build();
    var statefulAnalyzer = StatefulAnalyzer(config, [yamlSource]);
    var model = statefulAnalyzer.validateAll().first as ModelClassDefinition;
    var errors = collector.errors;

    test('then no errors are collected.', () {
      expect(errors, isEmpty);
    });

    test('then the id of the table is "int".', () {
      expect(model.idField.type.className, 'int');
    });

    test('then the id type is nullable.', () {
      expect(model.idField.type.nullable, true);
    });

    test('then the default persist value is "serial"', () {
      expect(model.idField.defaultPersistValue, defaultIntSerial);
    });
  });

  group('Given the default id type is "uuidV4"', () {
    var yamlSource = ModelSourceBuilder().withYaml(
      '''
        class: Example
        table: example
        fields:
          name: String
        ''',
    ).build();

    var collector = CodeGenerationCollector();
    var config =
        configBuilder().withDefaultIdType(SupportedIdType.uuidV4).build();
    var statefulAnalyzer = StatefulAnalyzer(config, [yamlSource]);
    var model = statefulAnalyzer.validateAll().first as ModelClassDefinition;
    var errors = collector.errors;

    test('then no errors are collected.', () {
      expect(errors, isEmpty);
    });

    test('then the id of the table is "UuidValue".', () {
      expect(model.idField.type.className, 'UuidValue');
    });

    test('then the id type is nullable.', () {
      expect(model.idField.type.nullable, true);
    });

    test('then the default persist value is "random"', () {
      expect(model.idField.defaultPersistValue, defaultUuidValueRandom);
    });
  });
}
