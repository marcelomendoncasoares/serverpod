import 'package:serverpod_cli/src/analyzer/models/stateful_analyzer.dart';
import 'package:serverpod_cli/src/generator/code_generation_collector.dart';
import 'package:test/test.dart';

import '../../../../../test_util/builders/generator_config_builder.dart';
import '../../../../../test_util/builders/model_source_builder.dart';

void main() {
  var config = GeneratorConfigBuilder().build();

  const duplicateShapeMessage =
      'Duplicate indexes with the same shape are not allowed.';

  test(
    'Given a table-backed model with two explicit indexes on the same columns, '
    'when parsed, '
    'then an error is collected.',
    () {
      var models = [
        ModelSourceBuilder().withYaml(
          '''
          class: Example
          table: example
          fields:
            name: String
          indexes:
            first_index:
              fields: name
            second_index:
              fields: name
          ''',
        ).build(),
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
        collector.errors.any(
          (error) => error.message.contains(duplicateShapeMessage),
        ),
        isTrue,
      );
    },
  );

  test(
    'Given a table-backed model with a unique field and an explicit unique index on the same column, '
    'when parsed, '
    'then an error is collected.',
    () {
      var models = [
        ModelSourceBuilder().withYaml(
          '''
          class: Example
          table: example
          fields:
            email: String, unique
          indexes:
            email_index:
              fields: email
              unique: true
          ''',
        ).build(),
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
        collector.errors.any(
          (error) =>
              error.message.contains(duplicateShapeMessage) &&
              error.message.contains('example__email__unique_idx'),
        ),
        isTrue,
      );
    },
  );

  test(
    'Given a table-backed model with unique(per=category) and an explicit unique index on the same columns, '
    'when parsed, '
    'then an error is collected.',
    () {
      var models = [
        ModelSourceBuilder().withYaml(
          '''
          class: Example
          table: example
          fields:
            category: String
            value: String, unique(per=category)
          indexes:
            category_value_index:
              fields: category, value
              unique: true
          ''',
        ).build(),
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
        collector.errors.any(
          (error) =>
              error.message.contains(duplicateShapeMessage) &&
              error.message.contains('example__category__value__unique_idx'),
        ),
        isTrue,
      );
    },
  );

  test(
    'Given a table-backed model with two indexes on the same columns where only one is unique, '
    'when parsed, '
    'then no duplicate shape error is collected.',
    () {
      var models = [
        ModelSourceBuilder().withYaml(
          '''
          class: Example
          table: example
          fields:
            name: String
          indexes:
            plain_index:
              fields: name
            unique_index:
              fields: name
              unique: true
          ''',
        ).build(),
      ];

      var collector = CodeGenerationCollector();
      var analyzer = StatefulAnalyzer(
        config,
        models,
        onErrorsCollector(collector),
      );
      analyzer.validateAll();

      expect(
        collector.errors.where(
          (error) => error.message.contains(duplicateShapeMessage),
        ),
        isEmpty,
      );
    },
  );

  test(
    'Given a table-backed model with two indexes on the same columns in different order, '
    'when parsed, '
    'then no duplicate shape error is collected.',
    () {
      var models = [
        ModelSourceBuilder().withYaml(
          '''
          class: Example
          table: example
          fields:
            first: String
            second: String
          indexes:
            first_second_index:
              fields: first, second
            second_first_index:
              fields: second, first
          ''',
        ).build(),
      ];

      var collector = CodeGenerationCollector();
      var analyzer = StatefulAnalyzer(
        config,
        models,
        onErrorsCollector(collector),
      );
      analyzer.validateAll();

      expect(
        collector.errors.where(
          (error) => error.message.contains(duplicateShapeMessage),
        ),
        isEmpty,
      );
    },
  );

  test(
    'Given a child table that inherits an index and declares the same index shape, '
    'when parsed, '
    'then an error is collected.',
    () {
      var models = [
        ModelSourceBuilder().withYaml(
          '''
          class: ParentBase
          fields:
            indexed: int
          indexes:
            base_index:
              fields: indexed
          ''',
        ).build(),
        ModelSourceBuilder().withFileName('child_table').withYaml(
          '''
          class: ChildTable
          table: child_table
          extends: ParentBase
          fields:
            ownField: String
          indexes:
            duplicate_index:
              fields: indexed
          ''',
        ).build(),
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
        collector.errors.any(
          (error) =>
              error.message.contains(duplicateShapeMessage) &&
              error.message.contains('child_table_base_index'),
        ),
        isTrue,
      );
    },
  );
}
