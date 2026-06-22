import 'package:serverpod_cli/analyzer.dart';
import 'package:serverpod_cli/src/analyzer/models/definitions.dart';
import 'package:serverpod_cli/src/analyzer/models/stateful_analyzer.dart';
import 'package:serverpod_cli/src/generator/code_generation_collector.dart';
import 'package:test/test.dart';

import '../../../../test_util/builders/generator_config_builder.dart';
import '../../../../test_util/builders/model_source_builder.dart';

void main() {
  var config = GeneratorConfigBuilder().build();

  ModelClassDefinition? validate(
    String yaml,
    CodeGenerationCollector collector,
  ) {
    var models = [ModelSourceBuilder().withYaml(yaml).build()];
    var analyzer = StatefulAnalyzer(config, models, onErrorsCollector(collector));
    var definitions = analyzer.validateAll();
    return definitions.firstOrNull as ModelClassDefinition?;
  }

  test('Given a class without a secure property then securityConditions is empty.', () {
    var collector = CodeGenerationCollector();
    var definition = validate(
      '''
      class: Example
      table: example
      fields:
        author: UuidValue
      ''',
      collector,
    );

    expect(collector.errors, isEmpty);
    expect(definition?.securityConditions, isEmpty);
  });

  test('Given a class with secure matching a UuidValue field then the condition is parsed without errors.', () {
    var collector = CodeGenerationCollector();
    var definition = validate(
      '''
      class: Example
      table: example
      secure: userIdentifier=author
      fields:
        author: UuidValue
      ''',
      collector,
    );

    expect(collector.errors, isEmpty, reason: 'Expected no errors.');
    expect(definition?.securityConditions, hasLength(1));
    expect(
      definition?.securityConditions.first.authField,
      RowSecurityAuthField.userIdentifier,
    );
    expect(definition?.securityConditions.first.fieldName, 'author');
  });

  test('Given a class with multiple secure conditions then all are parsed.', () {
    var collector = CodeGenerationCollector();
    var definition = validate(
      '''
      class: Example
      table: example
      secure: userIdentifier=author, userIdentifier=owner
      fields:
        author: UuidValue
        owner: UuidValue
      ''',
      collector,
    );

    expect(collector.errors, isEmpty, reason: 'Expected no errors.');
    expect(definition?.securityConditions, hasLength(2));
  });

  test('Given a secure property without a table then an error is reported.', () {
    var collector = CodeGenerationCollector();
    validate(
      '''
      class: Example
      secure: userIdentifier=author
      fields:
        author: UuidValue
      ''',
      collector,
    );

    expect(collector.errors, isNotEmpty);
    expect(
      collector.errors.first.message,
      contains('can only be used on classes with a "table" property'),
    );
  });

  test('Given a secure property referencing a non-existent field then an error is reported.', () {
    var collector = CodeGenerationCollector();
    validate(
      '''
      class: Example
      table: example
      secure: userIdentifier=missing
      fields:
        author: UuidValue
      ''',
      collector,
    );

    expect(collector.errors, isNotEmpty);
    expect(
      collector.errors.first.message,
      contains('does not exist on this model'),
    );
  });

  test('Given a secure property matching a non-UUID field then an error is reported.', () {
    var collector = CodeGenerationCollector();
    validate(
      '''
      class: Example
      table: example
      secure: userIdentifier=author
      fields:
        author: int
      ''',
      collector,
    );

    expect(collector.errors, isNotEmpty);
    expect(
      collector.errors.first.message,
      contains('must be of type "UuidValue"'),
    );
  });

  test('Given a secure property using the unsupported scope field then an error is reported.', () {
    var collector = CodeGenerationCollector();
    validate(
      '''
      class: Example
      table: example
      secure: scope=admin
      fields:
        author: UuidValue
      ''',
      collector,
    );

    expect(collector.errors, isNotEmpty);
    expect(
      collector.errors.first.message,
      contains('"scope" authentication field is not yet supported'),
    );
  });

  test('Given a malformed secure condition then an error is reported.', () {
    var collector = CodeGenerationCollector();
    validate(
      '''
      class: Example
      table: example
      secure: userIdentifier
      fields:
        author: UuidValue
      ''',
      collector,
    );

    expect(collector.errors, isNotEmpty);
    expect(
      collector.errors.first.message,
      contains('Expected the format "authField=fieldName"'),
    );
  });
}
