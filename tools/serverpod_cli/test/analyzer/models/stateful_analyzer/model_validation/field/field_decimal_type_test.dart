import 'package:serverpod_cli/src/analyzer/models/stateful_analyzer.dart';
import 'package:serverpod_cli/src/generator/code_generation_collector.dart';
import 'package:test/test.dart';

import '../../../../../test_util/builders/generator_config_builder.dart';
import '../../../../../test_util/builders/model_source_builder.dart';

void main() {
  var config = GeneratorConfigBuilder().build();

  test(
    'Given a class with a Decimal field with no parameters, '
    'when parsing, '
    'then no errors are generated.',
    () {
      var models = [
        ModelSourceBuilder().withYaml(
          '''
          class: Example
          fields:
            amount: Decimal
          ''',
        ).build(),
      ];

      var collector = CodeGenerationCollector();
      StatefulAnalyzer(
        config,
        models,
        onErrorsCollector(collector),
      ).validateAll();

      expect(collector.errors, isEmpty);
    },
  );

  test(
    'Given a class with a Decimal field that is nullable, '
    'when parsing, '
    'then no errors are generated.',
    () {
      var models = [
        ModelSourceBuilder().withYaml(
          '''
          class: Example
          fields:
            amount: Decimal?
          ''',
        ).build(),
      ];

      var collector = CodeGenerationCollector();
      StatefulAnalyzer(
        config,
        models,
        onErrorsCollector(collector),
      ).validateAll();

      expect(collector.errors, isEmpty);
    },
  );

  test(
    'Given a class with a Decimal field with valid precision and scale, '
    'when parsing, '
    'then no errors are generated.',
    () {
      var models = [
        ModelSourceBuilder().withYaml(
          '''
          class: Example
          fields:
            price: Decimal(10,2)
          ''',
        ).build(),
      ];

      var collector = CodeGenerationCollector();
      StatefulAnalyzer(
        config,
        models,
        onErrorsCollector(collector),
      ).validateAll();

      expect(collector.errors, isEmpty);
    },
  );

  test(
    'Given a class with a nullable Decimal field with valid precision and scale, '
    'when parsing, '
    'then no errors are generated.',
    () {
      var models = [
        ModelSourceBuilder().withYaml(
          '''
          class: Example
          fields:
            price: Decimal(10,2)?
          ''',
        ).build(),
      ];

      var collector = CodeGenerationCollector();
      StatefulAnalyzer(
        config,
        models,
        onErrorsCollector(collector),
      ).validateAll();

      expect(collector.errors, isEmpty);
    },
  );

  test(
    'Given a class with a Decimal field with valid precision only, '
    'when parsing, '
    'then no errors are generated.',
    () {
      var models = [
        ModelSourceBuilder().withYaml(
          '''
          class: Example
          fields:
            value: Decimal(19)
          ''',
        ).build(),
      ];

      var collector = CodeGenerationCollector();
      StatefulAnalyzer(
        config,
        models,
        onErrorsCollector(collector),
      ).validateAll();

      expect(collector.errors, isEmpty);
    },
  );

  test(
    'Given a class with a Decimal field with scale equals precision, '
    'when parsing, '
    'then no errors are generated.',
    () {
      var models = [
        ModelSourceBuilder().withYaml(
          '''
          class: Example
          fields:
            value: Decimal(5,5)
          ''',
        ).build(),
      ];

      var collector = CodeGenerationCollector();
      StatefulAnalyzer(
        config,
        models,
        onErrorsCollector(collector),
      ).validateAll();

      expect(collector.errors, isEmpty);
    },
  );

  test(
    'Given a class with a Decimal field with precision 0, '
    'when parsing, '
    'then an error is collected.',
    () {
      var models = [
        ModelSourceBuilder().withYaml(
          '''
          class: Example
          fields:
            price: Decimal(0,2)
          ''',
        ).build(),
      ];

      var collector = CodeGenerationCollector();
      StatefulAnalyzer(
        config,
        models,
        onErrorsCollector(collector),
      ).validateAll();

      expect(
        collector.errors,
        isNotEmpty,
        reason: 'Expected an error, but none was generated.',
      );

      var error = collector.errors.first;
      expect(
        error.message,
        'Invalid decimal precision "0". '
        'Precision must be an integer greater than 0.',
      );
    },
  );

  test(
    'Given a class with a Decimal field with scale negative, '
    'when parsing, '
    'then an error is collected.',
    () {
      var models = [
        ModelSourceBuilder().withYaml(
          '''
          class: Example
          fields:
            price: Decimal(10,-1)
          ''',
        ).build(),
      ];

      var collector = CodeGenerationCollector();
      StatefulAnalyzer(
        config,
        models,
        onErrorsCollector(collector),
      ).validateAll();

      expect(
        collector.errors,
        isNotEmpty,
        reason: 'Expected an error, but none was generated.',
      );

      var error = collector.errors.first;
      expect(
        error.message,
        'Invalid decimal scale "-1". '
        'Scale must be an integer greater than or equal to 0.',
      );
    },
  );

  test(
    'Given a class with a Decimal field with scale greater than precision, '
    'when parsing, '
    'then an error is collected.',
    () {
      var models = [
        ModelSourceBuilder().withYaml(
          '''
          class: Example
          fields:
            price: Decimal(10,11)
          ''',
        ).build(),
      ];

      var collector = CodeGenerationCollector();
      StatefulAnalyzer(
        config,
        models,
        onErrorsCollector(collector),
      ).validateAll();

      expect(
        collector.errors,
        isNotEmpty,
        reason: 'Expected an error, but none was generated.',
      );

      var error = collector.errors.first;
      expect(
        error.message,
        'Invalid decimal scale "11". '
        'Scale must be less than or equal to precision "10".',
      );
    },
  );
}
