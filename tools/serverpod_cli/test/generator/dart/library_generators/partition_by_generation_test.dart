import 'package:path/path.dart' as path;
import 'package:serverpod_cli/analyzer.dart';
import 'package:serverpod_cli/src/analyzer/models/definitions.dart';
import 'package:serverpod_cli/src/generator/dart/server_code_generator.dart';
import 'package:serverpod_service_client/serverpod_service_client.dart';
import 'package:test/test.dart';

import '../../../test_util/builders/generator_config_builder.dart';
import '../../../test_util/builders/model_class_definition_builder.dart';

const projectName = 'example_project';
final config = GeneratorConfigBuilder().withName(projectName).build();
const generator = DartServerCodeGenerator();

void main() {
  var expectedFileName = path.join(
    'lib',
    'src',
    'generated',
    'protocol.dart',
  );

  group(
    'Given a model with partitionBy when generating protocol files',
    () {
      var models = [
        ModelClassDefinitionBuilder()
            .withClassName('PartitionedModel')
            .withFileName('partitioned_model')
            .withTableName('partitioned_model')
            .withSimpleField('source', 'String')
            .withPartitioning(
              const TablePartitioningDefinition(
                columns: ['source'],
                method: PartitionMethod.list,
              ),
            )
            .build(),
      ];

      var protocolDefinition = ProtocolDefinition(
        endpoints: [],
        models: models,
      );

      var codeMap = generator.generateProtocolCode(
        protocolDefinition: protocolDefinition,
        config: config,
      );

      test('then the protocol.dart file is created.', () {
        expect(codeMap[expectedFileName], isNotNull);
      });

      late var content = codeMap[expectedFileName]!;

      test(
        'then the protocol contains partitionBy field in targetTableDefinitions.',
        () {
          expect(content, contains('partitionBy:'));
          expect(content, contains('\'source\''));
        },
      );

      test(
        'then the protocol contains partitionMethod field in targetTableDefinitions.',
        () {
          expect(content, contains('partitionMethod:'));
          expect(content, contains('PartitionMethod.list'));
        },
      );
    },
  );

  group(
    'Given a model with partitionBy using multiple columns when generating protocol files',
    () {
      var models = [
        ModelClassDefinitionBuilder()
            .withClassName('MultiPartitionedModel')
            .withFileName('multi_partitioned_model')
            .withTableName('multi_partitioned_model')
            .withSimpleField('source', 'String')
            .withSimpleField('category', 'String')
            .withPartitioning(
              const TablePartitioningDefinition(
                columns: ['source', 'category'],
                method: PartitionMethod.list,
              ),
            )
            .build(),
      ];

      var protocolDefinition = ProtocolDefinition(
        endpoints: [],
        models: models,
      );

      var codeMap = generator.generateProtocolCode(
        protocolDefinition: protocolDefinition,
        config: config,
      );

      test('then the protocol.dart file is created.', () {
        expect(codeMap[expectedFileName], isNotNull);
      });

      late var content = codeMap[expectedFileName]!;

      test(
        'then the protocol contains all partitionBy columns in targetTableDefinitions.',
        () {
          expect(content, contains('partitionBy:'));
          expect(content, contains('\'source\''));
          expect(content, contains('\'category\''));
        },
      );
    },
  );

  group(
    'Given a model with partitionBy using range method when generating protocol files',
    () {
      var models = [
        ModelClassDefinitionBuilder()
            .withClassName('RangePartitionedModel')
            .withFileName('range_partitioned_model')
            .withTableName('range_partitioned_model')
            .withSimpleField('created', 'DateTime')
            .withPartitioning(
              const TablePartitioningDefinition(
                columns: ['created'],
                method: PartitionMethod.range,
              ),
            )
            .build(),
      ];

      var protocolDefinition = ProtocolDefinition(
        endpoints: [],
        models: models,
      );

      var codeMap = generator.generateProtocolCode(
        protocolDefinition: protocolDefinition,
        config: config,
      );

      test('then the protocol.dart file is created.', () {
        expect(codeMap[expectedFileName], isNotNull);
      });

      late var content = codeMap[expectedFileName]!;

      test(
        'then the protocol contains partitionMethod.range in targetTableDefinitions.',
        () {
          expect(content, contains('partitionMethod:'));
          expect(content, contains('PartitionMethod.range'));
        },
      );
    },
  );

  group(
    'Given a model with partitionBy using hash method when generating protocol files',
    () {
      var models = [
        ModelClassDefinitionBuilder()
            .withClassName('HashPartitionedModel')
            .withFileName('hash_partitioned_model')
            .withTableName('hash_partitioned_model')
            .withSimpleField('userId', 'int')
            .withPartitioning(
              const TablePartitioningDefinition(
                columns: ['userId'],
                method: PartitionMethod.hash,
              ),
            )
            .build(),
      ];

      var protocolDefinition = ProtocolDefinition(
        endpoints: [],
        models: models,
      );

      var codeMap = generator.generateProtocolCode(
        protocolDefinition: protocolDefinition,
        config: config,
      );

      test('then the protocol.dart file is created.', () {
        expect(codeMap[expectedFileName], isNotNull);
      });

      late var content = codeMap[expectedFileName]!;

      test(
        'then the protocol contains partitionMethod.hash in targetTableDefinitions.',
        () {
          expect(content, contains('partitionMethod:'));
          expect(content, contains('PartitionMethod.hash'));
        },
      );
    },
  );

  group(
    'Given a model without partitionBy when generating protocol files',
    () {
      var models = [
        ModelClassDefinitionBuilder()
            .withClassName('NonPartitionedModel')
            .withFileName('non_partitioned_model')
            .withTableName('non_partitioned_model')
            .withSimpleField('name', 'String')
            .build(),
      ];

      var protocolDefinition = ProtocolDefinition(
        endpoints: [],
        models: models,
      );

      var codeMap = generator.generateProtocolCode(
        protocolDefinition: protocolDefinition,
        config: config,
      );

      test('then the protocol.dart file is created.', () {
        expect(codeMap[expectedFileName], isNotNull);
      });

      late var content = codeMap[expectedFileName]!;

      test(
        'then the protocol does not contain partitionBy field in targetTableDefinitions.',
        () {
          // The partitionBy field should not be present when it's null
          // We check that partitionBy: is not followed by a list literal
          expect(
            content,
            isNot(contains('partitionBy: [')),
          );
        },
      );

      test(
        'then the protocol does not contain partitionMethod field in targetTableDefinitions.',
        () {
          // The partitionMethod field should not be present when it's null
          expect(
            content,
            isNot(contains('partitionMethod:')),
          );
        },
      );
    },
  );
}
