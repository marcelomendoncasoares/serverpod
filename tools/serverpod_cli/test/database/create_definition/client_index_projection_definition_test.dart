import 'package:serverpod_cli/src/analyzer/models/definitions.dart';
import 'package:serverpod_cli/src/analyzer/models/stateful_analyzer.dart';
import 'package:serverpod_cli/src/database/create_definition.dart';
import 'package:serverpod_cli/src/generator/code_generation_collector.dart';
import 'package:test/test.dart';

import '../../test_util/builders/generator_config_builder.dart';
import '../../test_util/builders/model_class_definition_builder.dart';
import '../../test_util/builders/model_source_builder.dart';
import '../../test_util/builders/serializable_entity_field_definition_builder.dart';

void main() {
  const moduleName = 'example';
  final config = GeneratorConfigBuilder().build();

  group(
    'Given a model with indexes on client-visible and server-only fields, '
    'when creating the client database definition,',
    () {
      late ModelClassDefinition model;

      setUp(() {
        model = ModelClassDefinitionBuilder()
            .withClassName('Example')
            .withTableName('example')
            .withDatabase(ModelDatabaseDefinition.all)
            .withField(
              FieldDefinitionBuilder()
                  .withName('name')
                  .withTypeDefinition('String')
                  .build(),
            )
            .withField(
              FieldDefinitionBuilder()
                  .withName('secret')
                  .withTypeDefinition('String', true)
                  .withScope(ModelFieldScopeDefinition.serverOnly)
                  .build(),
            )
            .withIndexes([
              SerializableModelIndexDefinition(
                name: 'name_idx',
                type: 'btree',
                unique: false,
                fields: ['name'],
              ),
              SerializableModelIndexDefinition(
                name: 'secret_idx',
                type: 'btree',
                unique: false,
                fields: ['secret'],
              ),
              SerializableModelIndexDefinition(
                name: 'mixed_idx',
                type: 'btree',
                unique: false,
                fields: ['name', 'secret'],
              ),
              SerializableModelIndexDefinition(
                name: 'internal_idx',
                type: 'btree',
                unique: false,
                fields: ['name'],
                serverOnly: true,
              ),
            ])
            .build();
      });

      test(
        'then indexes are projected onto the client-visible column set.',
        () {
          final databaseDefinition = createDatabaseDefinitionFromModels(
            [model],
            moduleName,
            [],
            serverCode: false,
          );

          final table = databaseDefinition.tables.single;
          final indexNames = table.indexes.map((index) => index.indexName);

          expect(indexNames, containsAll(['name_idx', 'mixed_idx']));
          expect(indexNames, isNot(contains('secret_idx')));
          expect(indexNames, isNot(contains('internal_idx')));

          final mixedIndex = table.indexes.firstWhere(
            (index) => index.indexName == 'mixed_idx',
          );
          expect(
            mixedIndex.elements.map((element) => element.definition).toList(),
            ['name'],
          );
        },
      );
    },
  );

  group(
    'Given a model with indexes on client-visible and server-only fields, '
    'when creating the server database definition,',
    () {
      test('then all indexes are included with their full field lists.', () {
        final model = ModelClassDefinitionBuilder()
            .withClassName('Example')
            .withTableName('example')
            .withField(
              FieldDefinitionBuilder()
                  .withName('name')
                  .withTypeDefinition('String')
                  .build(),
            )
            .withField(
              FieldDefinitionBuilder()
                  .withName('secret')
                  .withTypeDefinition('String', true)
                  .withScope(ModelFieldScopeDefinition.serverOnly)
                  .build(),
            )
            .withIndexes([
              SerializableModelIndexDefinition(
                name: 'mixed_idx',
                type: 'btree',
                unique: false,
                fields: ['name', 'secret'],
              ),
            ])
            .build();

        final databaseDefinition = createDatabaseDefinitionFromModels(
          [model],
          moduleName,
          [],
        );

        final mixedIndex = databaseDefinition.tables.single.indexes.single;

        expect(
          mixedIndex.elements.map((element) => element.definition).toList(),
          ['name', 'secret'],
        );
      });
    },
  );

  test(
    'Given a model yaml with serverOnly on an index, '
    'when parsing the model definition, '
    'then the index serverOnly flag is set.',
    () {
      final models = [
        ModelSourceBuilder().withYaml('''
          class: Example
          table: example
          database: all
          fields:
            name: String
          indexes:
            internal_idx:
              serverOnly: true
              fields: name
        ''').build(),
      ];
      final collector = CodeGenerationCollector();
      final definitions = StatefulAnalyzer(
        config,
        models,
        onErrorsCollector(collector),
      ).validateAll();

      expect(collector.errors, isEmpty);
      final model = definitions.single as ModelClassDefinition;
      final index = model.indexes.single;

      expect(index.serverOnly, isTrue);
    },
  );
}
