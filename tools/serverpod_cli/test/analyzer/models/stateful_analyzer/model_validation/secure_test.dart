import 'package:serverpod_cli/src/analyzer/models/definitions.dart';
import 'package:serverpod_cli/src/analyzer/models/stateful_analyzer.dart';
import 'package:serverpod_cli/src/generator/code_generation_collector.dart';
import 'package:test/test.dart';

import '../../../../test_util/builders/generator_config_builder.dart';
import '../../../../test_util/builders/model_source_builder.dart';

void main() {
  var config = GeneratorConfigBuilder().build();

  test(
    'Given a class without a secure property, '
    'when validating, '
    'then no row security conditions are defined.',
    () {
      var models = [
        ModelSourceBuilder().withYaml('''
        class: Example
        table: example
        fields:
          author: UuidValue
        ''').build(),
      ];

      var collector = CodeGenerationCollector();
      var analyzer = StatefulAnalyzer(
        config,
        models,
        onErrorsCollector(collector),
      );
      var definitions = analyzer.validateAll();
      var definition = definitions.first as ModelClassDefinition;

      expect(collector.errors, isEmpty);
      expect(definition.securityConditions, isEmpty);
    },
  );

  test(
    'Given a class with secure matching a UuidValue field, '
    'when validating, '
    'then the row security condition is accepted.',
    () {
      var models = [
        ModelSourceBuilder().withYaml('''
        class: Example
        table: example
        secure: userIdentifier=author
        fields:
          author: UuidValue
        ''').build(),
      ];

      var collector = CodeGenerationCollector();
      var analyzer = StatefulAnalyzer(
        config,
        models,
        onErrorsCollector(collector),
      );
      var definitions = analyzer.validateAll();
      var definition = definitions.first as ModelClassDefinition;

      expect(collector.errors, isEmpty, reason: 'Expected no errors.');
      expect(definition.securityConditions, hasLength(1));
      expect(
        definition.securityConditions.first.authField,
        RowSecurityAuthField.userIdentifier,
      );
      expect(definition.securityConditions.first.fieldName, 'author');
    },
  );

  test(
    'Given a class with multiple secure conditions, '
    'when validating, '
    'then all row security conditions are accepted.',
    () {
      var models = [
        ModelSourceBuilder().withYaml('''
        class: Example
        table: example
        secure: userIdentifier=author, userIdentifier=owner
        fields:
          author: UuidValue
          owner: UuidValue
        ''').build(),
      ];

      var collector = CodeGenerationCollector();
      var analyzer = StatefulAnalyzer(
        config,
        models,
        onErrorsCollector(collector),
      );
      var definitions = analyzer.validateAll();
      var definition = definitions.first as ModelClassDefinition;

      expect(collector.errors, isEmpty, reason: 'Expected no errors.');
      expect(definition.securityConditions, hasLength(2));
    },
  );

  test(
    'Given a secure property without a table, '
    'when validating, '
    'then an error is reported.',
    () {
      var models = [
        ModelSourceBuilder().withYaml('''
        class: Example
        secure: userIdentifier=author
        fields:
          author: UuidValue
        ''').build(),
      ];

      var collector = CodeGenerationCollector();
      var analyzer = StatefulAnalyzer(
        config,
        models,
        onErrorsCollector(collector),
      );
      analyzer.validateAll();

      expect(collector.errors, isNotEmpty);
      expect(
        collector.errors.first.message,
        contains('can only be used on classes with a "table" property'),
      );
    },
  );

  test(
    'Given a secure property referencing a non-existent field, '
    'when validating, '
    'then an error is reported.',
    () {
      var models = [
        ModelSourceBuilder().withYaml('''
        class: Example
        table: example
        secure: userIdentifier=missing
        fields:
          author: UuidValue
        ''').build(),
      ];

      var collector = CodeGenerationCollector();
      var analyzer = StatefulAnalyzer(
        config,
        models,
        onErrorsCollector(collector),
      );
      analyzer.validateAll();

      expect(collector.errors, isNotEmpty);
      expect(
        collector.errors.first.message,
        contains('does not exist on this model'),
      );
    },
  );

  test(
    'Given a secure property matching a non-UUID field, '
    'when validating, '
    'then an error is reported.',
    () {
      var models = [
        ModelSourceBuilder().withYaml('''
        class: Example
        table: example
        secure: userIdentifier=author
        fields:
          author: int
        ''').build(),
      ];

      var collector = CodeGenerationCollector();
      var analyzer = StatefulAnalyzer(
        config,
        models,
        onErrorsCollector(collector),
      );
      analyzer.validateAll();

      expect(collector.errors, isNotEmpty);
      expect(
        collector.errors.first.message,
        contains('must be of type "UuidValue"'),
      );
    },
  );

  test(
    'Given a secure property using the unsupported scope field, '
    'when validating, '
    'then an error is reported.',
    () {
      var models = [
        ModelSourceBuilder().withYaml('''
        class: Example
        table: example
        secure: scope=admin
        fields:
          author: UuidValue
        ''').build(),
      ];

      var collector = CodeGenerationCollector();
      var analyzer = StatefulAnalyzer(
        config,
        models,
        onErrorsCollector(collector),
      );
      analyzer.validateAll();

      expect(collector.errors, isNotEmpty);
      expect(
        collector.errors.first.message,
        contains('"scope" authentication field is not yet supported'),
      );
    },
  );

  test(
    'Given a malformed secure condition, '
    'when validating, '
    'then an error is reported.',
    () {
      var models = [
        ModelSourceBuilder().withYaml('''
        class: Example
        table: example
        secure: userIdentifier
        fields:
          author: UuidValue
        ''').build(),
      ];

      var collector = CodeGenerationCollector();
      var analyzer = StatefulAnalyzer(
        config,
        models,
        onErrorsCollector(collector),
      );
      analyzer.validateAll();

      expect(collector.errors, isNotEmpty);
      expect(
        collector.errors.first.message,
        contains('Expected the format "authField=fieldName"'),
      );
    },
  );
}
