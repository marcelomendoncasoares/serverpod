import 'package:serverpod_cli/src/analyzer/models/definitions.dart';
import 'package:serverpod_cli/src/analyzer/models/stateful_analyzer.dart';
import 'package:serverpod_cli/src/generator/code_generation_collector.dart';
import 'package:test/test.dart';

import '../../../../../test_util/builders/generator_config_builder.dart';
import '../../../../../test_util/builders/model_source_builder.dart';

void main() {
  test(
    'Given a table with an implicit ID, '
    'when analyzing the model, '
    'then the ID type and defaults are preserved.',
    () {
      const field = 'name: String';

      final (model, collector) = _analyzeId(field);

      expect(collector.errors, isEmpty);
      expect(model!.idField.type.className, 'int');
      expect(model.idField.type.nullable, true);
      expect(model.idField.defaultPersistValue, 'serial');
      expect(model.idField.defaultModelValue, isNull);
    },
  );

  test(
    'Given a table with a nullable integer ID without an explicit default, '
    'when analyzing the model, '
    'then the ID type and defaults are preserved.',
    () {
      const field = 'id: int?';

      final (model, collector) = _analyzeId(field);

      expect(collector.errors, isEmpty);
      expect(model!.idField.type.className, 'int');
      expect(model.idField.type.nullable, true);
      expect(model.idField.defaultPersistValue, 'serial');
      expect(model.idField.defaultModelValue, isNull);
    },
  );

  test(
    'Given a table with a required integer ID without a default, '
    'when analyzing the model, '
    'then the ID type and defaults are preserved.',
    () {
      const field = 'id: int';

      final (model, collector) = _analyzeId(field);

      expect(collector.errors, isEmpty);
      expect(model!.idField.type.className, 'int');
      expect(model.idField.type.nullable, false);
      expect(model.idField.defaultPersistValue, isNull);
      expect(model.idField.defaultModelValue, isNull);
    },
  );

  test(
    'Given a table with a required UUID ID without a default, '
    'when analyzing the model, '
    'then the ID type and defaults are preserved.',
    () {
      const field = 'id: UuidValue';

      final (model, collector) = _analyzeId(field);

      expect(collector.errors, isEmpty);
      expect(model!.idField.type.className, 'UuidValue');
      expect(model.idField.type.nullable, false);
      expect(model.idField.defaultPersistValue, isNull);
      expect(model.idField.defaultModelValue, isNull);
    },
  );

  test(
    'Given a table with a required String ID without a default, '
    'when analyzing the model, '
    'then the ID type and defaults are preserved.',
    () {
      const field = 'id: String';

      final (model, collector) = _analyzeId(field);

      expect(collector.errors, isEmpty);
      expect(model!.idField.type.className, 'String');
      expect(model.idField.type.nullable, false);
      expect(model.idField.defaultPersistValue, isNull);
      expect(model.idField.defaultModelValue, isNull);
    },
  );

  test(
    'Given a table with a required DateTime ID without a default, '
    'when analyzing the model, '
    'then the ID type and defaults are preserved.',
    () {
      const field = 'id: DateTime';

      final (model, collector) = _analyzeId(field);

      expect(collector.errors, isEmpty);
      expect(model!.idField.type.className, 'DateTime');
      expect(model.idField.type.nullable, false);
      expect(model.idField.defaultPersistValue, isNull);
      expect(model.idField.defaultModelValue, isNull);
    },
  );

  test(
    'Given a table with a required Duration ID without a default, '
    'when analyzing the model, '
    'then the ID type and defaults are preserved.',
    () {
      const field = 'id: Duration';

      final (model, collector) = _analyzeId(field);

      expect(collector.errors, isEmpty);
      expect(model!.idField.type.className, 'Duration');
      expect(model.idField.type.nullable, false);
      expect(model.idField.defaultPersistValue, isNull);
      expect(model.idField.defaultModelValue, isNull);
    },
  );

  test(
    'Given a table with a nullable UUID ID with a random generator, '
    'when analyzing the model, '
    'then the ID type and defaults are preserved.',
    () {
      const field = 'id: UuidValue?, defaultPersist=random';

      final (model, collector) = _analyzeId(field);

      expect(collector.errors, isEmpty);
      expect(model!.idField.type.className, 'UuidValue');
      expect(model.idField.type.nullable, true);
      expect(model.idField.defaultPersistValue, 'random');
      expect(model.idField.defaultModelValue, isNull);
    },
  );

  test(
    'Given a table with a required UUID ID with a random_v7 generator, '
    'when analyzing the model, '
    'then the ID type and defaults are preserved.',
    () {
      const field = 'id: UuidValue, defaultModel=random_v7';

      final (model, collector) = _analyzeId(field);

      expect(collector.errors, isEmpty);
      expect(model!.idField.type.className, 'UuidValue');
      expect(model.idField.type.nullable, false);
      expect(model.idField.defaultPersistValue, 'random_v7');
      expect(model.idField.defaultModelValue, 'random_v7');
    },
  );

  test(
    'Given a table with a nullable DateTime ID with a database now generator, '
    'when analyzing the model, '
    'then the ID type and defaults are preserved.',
    () {
      const field = 'id: DateTime?, defaultPersist=now';

      final (model, collector) = _analyzeId(field);

      expect(collector.errors, isEmpty);
      expect(model!.idField.type.className, 'DateTime');
      expect(model.idField.type.nullable, true);
      expect(model.idField.defaultPersistValue, 'now');
      expect(model.idField.defaultModelValue, isNull);
    },
  );

  test(
    'Given a table with a required DateTime ID with a model now generator, '
    'when analyzing the model, '
    'then the ID type and defaults are preserved.',
    () {
      const field = 'id: DateTime, defaultModel=now';

      final (model, collector) = _analyzeId(field);

      expect(collector.errors, isEmpty);
      expect(model!.idField.type.className, 'DateTime');
      expect(model.idField.type.nullable, false);
      expect(model.idField.defaultPersistValue, 'now');
      expect(model.idField.defaultModelValue, 'now');
    },
  );

  test(
    'Given a nullable UuidValue ID without a default, '
    'when analyzing the model, '
    'then a missing default error is reported.',
    () {
      const field = 'id: UuidValue?';

      final (_, collector) = _analyzeId(field);

      expect(collector.errors, hasLength(1));
      expect(
        collector.errors.single.message,
        'The type "UuidValue" must have a default value. Use either the '
        '"defaultModel" key or the "defaultPersist" key to set it.',
      );
    },
  );

  test(
    'Given a nullable String ID without a default, '
    'when analyzing the model, '
    'then a missing default error is reported.',
    () {
      const field = 'id: String?';

      final (_, collector) = _analyzeId(field);

      expect(collector.errors, hasLength(1));
      expect(
        collector.errors.single.message,
        'The type "String" must have a default value. Use either the '
        '"defaultModel" key or the "defaultPersist" key to set it.',
      );
    },
  );

  test(
    'Given a nullable DateTime ID without a default, '
    'when analyzing the model, '
    'then a missing default error is reported.',
    () {
      const field = 'id: DateTime?';

      final (_, collector) = _analyzeId(field);

      expect(collector.errors, hasLength(1));
      expect(
        collector.errors.single.message,
        'The type "DateTime" must have a default value. Use either the '
        '"defaultModel" key or the "defaultPersist" key to set it.',
      );
    },
  );

  test(
    'Given a nullable Duration ID without a default, '
    'when analyzing the model, '
    'then a missing default error is reported.',
    () {
      const field = 'id: Duration?';

      final (_, collector) = _analyzeId(field);

      expect(collector.errors, hasLength(1));
      expect(
        collector.errors.single.message,
        'The type "Duration" must have a default value. Use either the '
        '"defaultModel" key or the "defaultPersist" key to set it.',
      );
    },
  );

  test(
    'Given a String ID with a literal String default, '
    'when analyzing the model, '
    'then the constant default is rejected.',
    () {
      const field = 'id: String, defaultModel=\'constant\'';

      final (_, collector) = _analyzeId(field);

      expect(collector.errors, hasLength(1));
      expect(
        collector.errors.single.message,
        'The default value "\'constant\'" is not supported for the id type '
        '"String". This type does not support default generators.',
      );
    },
  );

  test(
    'Given a DateTime ID with a literal DateTime default, '
    'when analyzing the model, '
    'then the constant default is rejected.',
    () {
      const field = 'id: DateTime, defaultModel=2026-01-01T00:00:00.000Z';

      final (_, collector) = _analyzeId(field);

      expect(collector.errors, hasLength(1));
      expect(
        collector.errors.single.message,
        'The default value "2026-01-01T00:00:00.000Z" is not supported for the id type '
        '"DateTime". Valid options are: "now".',
      );
    },
  );

  test(
    'Given a Duration ID with a literal Duration default, '
    'when analyzing the model, '
    'then the constant default is rejected.',
    () {
      const field = 'id: Duration, defaultModel=1d';

      final (_, collector) = _analyzeId(field);

      expect(collector.errors, hasLength(1));
      expect(
        collector.errors.single.message,
        'The default value "1d" is not supported for the id type '
        '"Duration". This type does not support default generators.',
      );
    },
  );

  test(
    'Given a class without a table, '
    'when analyzing the model, '
    'then no ID field is added.',
    () {
      final source = ModelSourceBuilder().withYaml('''
class: Example
fields:
  name: String
''').build();
      final collector = CodeGenerationCollector();

      final definitions = StatefulAnalyzer(
        GeneratorConfigBuilder().build(),
        [source],
        onErrorsCollector(collector),
      ).validateAll();

      expect(collector.errors, isEmpty);
      expect(
        (definitions.single as ClassDefinition).fields.single.name,
        'name',
      );
    },
  );
}

(ModelClassDefinition?, CodeGenerationCollector) _analyzeId(String field) {
  final source = ModelSourceBuilder().withYaml('''
class: Example
table: example
fields:
  $field
''').build();
  final collector = CodeGenerationCollector();
  final definitions = StatefulAnalyzer(
    GeneratorConfigBuilder().build(),
    [source],
    onErrorsCollector(collector),
  ).validateAll();

  return (definitions.firstOrNull as ModelClassDefinition?, collector);
}
