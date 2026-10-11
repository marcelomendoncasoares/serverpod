import 'package:serverpod_cli/src/analyzer/models/stateful_analyzer.dart';
import 'package:serverpod_cli/src/generator/code_generation_collector.dart';
import 'package:test/test.dart';

import '../../../../../test_util/builders/generator_config_builder.dart';
import '../../../../../test_util/builders/model_source_builder.dart';

void main() {
  test(
    'Given a String foreign key referencing an integer primary key, '
    'when analyzing the parent relation, '
    'then the type mismatch is rejected.',
    () {
      const foreignKeyType = 'String';
      const parentIdType = 'int';

      final collector = _analyzeParentRelation(foreignKeyType, parentIdType);

      expect(collector.errors.map((error) => error.message), [
        'The field "parentId" is of type "String" but reference field "id" '
            'on table "parent_table" is of type "int".',
      ]);
    },
  );

  test(
    'Given a DateTime foreign key referencing a String primary key, '
    'when analyzing the parent relation, '
    'then the type mismatch is rejected.',
    () {
      const foreignKeyType = 'DateTime';
      const parentIdType = 'String';

      final collector = _analyzeParentRelation(foreignKeyType, parentIdType);

      expect(collector.errors.map((error) => error.message), [
        'The field "parentId" is of type "DateTime" but reference field "id" '
            'on table "parent_table" is of type "String".',
      ]);
    },
  );

  test(
    'Given a nullable String foreign key referencing a String primary key, '
    'when analyzing the parent relation, '
    'then the matching relation is accepted.',
    () {
      const foreignKeyType = 'String?';
      const parentIdType = 'String';

      final collector = _analyzeParentRelation(foreignKeyType, parentIdType);

      expect(collector.errors, isEmpty);
    },
  );

  test(
    'Given a Duration foreign key referencing a Duration primary key, '
    'when analyzing the parent relation, '
    'then the matching relation is accepted.',
    () {
      const foreignKeyType = 'Duration';
      const parentIdType = 'Duration';

      final collector = _analyzeParentRelation(foreignKeyType, parentIdType);

      expect(collector.errors, isEmpty);
    },
  );
}

CodeGenerationCollector _analyzeParentRelation(
  String foreignKeyType,
  String parentIdType,
) {
  final collector = CodeGenerationCollector();
  StatefulAnalyzer(
    GeneratorConfigBuilder().build(),
    [
      ModelSourceBuilder().withFileName('child').withYaml('''
class: Child
table: child_table
fields:
  parentId: $foreignKeyType, relation(parent=parent_table)
''').build(),
      ModelSourceBuilder().withFileName('parent').withYaml('''
class: Parent
table: parent_table
fields:
  id: $parentIdType
''').build(),
    ],
    onErrorsCollector(collector),
  ).validateAll();

  return collector;
}
