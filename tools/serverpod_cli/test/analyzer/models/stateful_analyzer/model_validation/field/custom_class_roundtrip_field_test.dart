import 'package:serverpod_cli/src/analyzer/models/definitions.dart';
import 'package:serverpod_cli/src/analyzer/models/serialization_data_type.dart';
import 'package:serverpod_cli/src/analyzer/models/stateful_analyzer.dart';
import 'package:serverpod_cli/src/database/create_definition.dart';
import 'package:serverpod_cli/src/generator/code_generation_collector.dart';
import 'package:serverpod_cli/src/generator/types.dart';
import 'package:test/test.dart';

import '../../../../../test_util/builders/generator_config_builder.dart';
import '../../../../../test_util/builders/model_source_builder.dart';

void main() {
  final mapSerializationType = TypeDefinition(
    className: 'dynamic',
    nullable: false,
  );

  final customClassBySerializationType = {
    'int': TypeDefinition(
      className: 'IntCustomClass',
      nullable: false,
      url: 'package:serverpod_test_shared/serverpod_test_shared.dart',
      customClass: true,
      customClassSerializationType: TypeDefinition.int,
    ),
    'double': TypeDefinition(
      className: 'DoubleCustomClass',
      nullable: false,
      url: 'package:serverpod_test_shared/serverpod_test_shared.dart',
      customClass: true,
      customClassSerializationType: TypeDefinition(
        className: 'double',
        nullable: false,
      ),
    ),
    'String': TypeDefinition(
      className: 'CustomClass',
      nullable: false,
      url: 'package:serverpod_test_shared/serverpod_test_shared.dart',
      customClass: true,
      customClassSerializationType: TypeDefinition(
        className: 'String',
        nullable: false,
      ),
    ),
    'bool': TypeDefinition(
      className: 'BoolCustomClass',
      nullable: false,
      url: 'package:serverpod_test_shared/serverpod_test_shared.dart',
      customClass: true,
      customClassSerializationType: TypeDefinition(
        className: 'bool',
        nullable: false,
      ),
    ),
    'DateTime': TypeDefinition(
      className: 'DateTimeCustomClass',
      nullable: false,
      url: 'package:serverpod_test_shared/serverpod_test_shared.dart',
      customClass: true,
      customClassSerializationType: TypeDefinition(
        className: 'DateTime',
        nullable: false,
      ),
    ),
    'Map': TypeDefinition(
      className: 'CustomClass2',
      nullable: false,
      url: 'package:serverpod_test_shared/serverpod_test_shared.dart',
      customClass: true,
      customClassSerializationType: mapSerializationType,
    ),
  };

  final declaredTypeCases = <({
    String fieldType,
    String? serializationDataType,
    String databaseType,
    String columnType,
  })>[
    (
      fieldType: 'int',
      serializationDataType: null,
      databaseType: 'bigint',
      columnType: 'ColumnInt',
    ),
    (
      fieldType: 'double',
      serializationDataType: null,
      databaseType: 'double precision',
      columnType: 'ColumnDouble',
    ),
    (
      fieldType: 'String',
      serializationDataType: null,
      databaseType: 'text',
      columnType: 'ColumnString',
    ),
    (
      fieldType: 'bool',
      serializationDataType: null,
      databaseType: 'boolean',
      columnType: 'ColumnBool',
    ),
    (
      fieldType: 'DateTime',
      serializationDataType: null,
      databaseType: 'timestamp without time zone',
      columnType: 'ColumnDateTime',
    ),
    (
      fieldType: 'Map<String, String>',
      serializationDataType: 'json',
      databaseType: 'json',
      columnType: 'ColumnSerializable',
    ),
    (
      fieldType: 'Map<String, String>',
      serializationDataType: 'jsonb',
      databaseType: 'jsonb',
      columnType: 'ColumnStructured',
    ),
    (
      fieldType: 'int?',
      serializationDataType: null,
      databaseType: 'bigint',
      columnType: 'ColumnInt',
    ),
    (
      fieldType: 'Map<String, String>?',
      serializationDataType: 'json',
      databaseType: 'json',
      columnType: 'ColumnSerializable',
    ),
  ];

  final customClassFieldCases = <({
    String fieldName,
    String customClassName,
    String serializationKey,
    String? serializationDataType,
  })>[
    (
      fieldName: 'intData',
      customClassName: 'IntCustomClass',
      serializationKey: 'int',
      serializationDataType: null,
    ),
    (
      fieldName: 'doubleData',
      customClassName: 'DoubleCustomClass',
      serializationKey: 'double',
      serializationDataType: null,
    ),
    (
      fieldName: 'stringData',
      customClassName: 'CustomClass',
      serializationKey: 'String',
      serializationDataType: null,
    ),
    (
      fieldName: 'boolData',
      customClassName: 'BoolCustomClass',
      serializationKey: 'bool',
      serializationDataType: null,
    ),
    (
      fieldName: 'dateTimeData',
      customClassName: 'DateTimeCustomClass',
      serializationKey: 'DateTime',
      serializationDataType: null,
    ),
    (
      fieldName: 'mapData',
      customClassName: 'CustomClass2',
      serializationKey: 'Map',
      serializationDataType: 'json',
    ),
    (
      fieldName: 'jsonbMapData',
      customClassName: 'CustomClass2',
      serializationKey: 'Map',
      serializationDataType: 'jsonb',
    ),
    (
      fieldName: 'nullableIntData',
      customClassName: 'IntCustomClass',
      serializationKey: 'int',
      serializationDataType: null,
    ),
    (
      fieldName: 'nullableMapData',
      customClassName: 'CustomClass2',
      serializationKey: 'Map',
      serializationDataType: 'json',
    ),
  ];

  group('custom class database column resolution', () {
    for (final declaredCase in declaredTypeCases) {
      final serializationSuffix = declaredCase.serializationDataType == null
          ? ''
          : ', serializationDataType=${declaredCase.serializationDataType}';

      test(
        'declared ${declaredCase.fieldType}$serializationSuffix resolves to '
        '(${declaredCase.databaseType}, ${declaredCase.columnType})',
        () {
          final config = GeneratorConfigBuilder().build();
          final models = [
            ModelSourceBuilder().withYaml('''
class: Example
table: example
fields:
  data: ${declaredCase.fieldType}$serializationSuffix
''').build(),
          ];

          final collector = CodeGenerationCollector();
          final analyzer = StatefulAnalyzer(
            config,
            models,
            onErrorsCollector(collector),
          );

          final definitions = analyzer.validateAll();
          expect(collector.errors, isEmpty);

          final definition = definitions.first as ModelClassDefinition;
          final field = definition.fields.firstWhere((f) => f.name == 'data');

          expect(field.type.databaseType, declaredCase.databaseType);
          expect(field.type.columnType, declaredCase.columnType);
        },
      );
    }

    for (final customCase in customClassFieldCases) {
      final isNullable = customCase.fieldName.startsWith('nullable');
      final declaredCase = declaredTypeCases.firstWhere((declaredCase) {
        if (customCase.serializationKey == 'Map') {
          return declaredCase.serializationDataType ==
                  customCase.serializationDataType &&
              declaredCase.fieldType.contains('?') == isNullable;
        }
        return declaredCase.fieldType ==
            (isNullable
                ? '${customCase.serializationKey}?'
                : customCase.serializationKey);
      });

      final fieldType = customCase.serializationDataType == null
          ? '${customCase.customClassName}${isNullable ? '?' : ''}'
          : '${customCase.customClassName}${isNullable ? '?' : ''}, '
              'serializationDataType=${customCase.serializationDataType}';

      test(
        'custom class $fieldType matches declared ${declaredCase.fieldType}',
        () {
          final config = GeneratorConfigBuilder()
              .withExtraClasses(customClassBySerializationType.values.toList())
              .build();
          final models = [
            ModelSourceBuilder().withYaml('''
class: Example
table: example
fields:
  ${customCase.fieldName}: $fieldType
''').build(),
          ];

          final collector = CodeGenerationCollector();
          final analyzer = StatefulAnalyzer(
            config,
            models,
            onErrorsCollector(collector),
          );

          final definitions = analyzer.validateAll();
          expect(collector.errors, isEmpty);

          final definition = definitions.first as ModelClassDefinition;
          final field = definition.fields.firstWhere(
            (f) => f.name == customCase.fieldName,
          );

          expect(field.type.databaseType, declaredCase.databaseType);
          expect(field.type.columnType, declaredCase.columnType);
          expect(field.type.className, customCase.customClassName);
          expect(field.type.customClass, isTrue);
        },
      );
    }

    for (final customCase in customClassFieldCases) {
      final isNullable = customCase.fieldName.startsWith('nullable');
      final declaredCase = declaredTypeCases.firstWhere((declaredCase) {
        if (customCase.serializationKey == 'Map') {
          return declaredCase.serializationDataType ==
                  customCase.serializationDataType &&
              declaredCase.fieldType.contains('?') == isNullable;
        }
        return declaredCase.fieldType ==
            (isNullable
                ? '${customCase.serializationKey}?'
                : customCase.serializationKey);
      });

      final fieldType = customCase.serializationDataType == null
          ? '${customCase.customClassName}${isNullable ? '?' : ''}'
          : '${customCase.customClassName}${isNullable ? '?' : ''}, '
              'serializationDataType=${customCase.serializationDataType}';

      test(
        'custom class $fieldType column is '
        '${isNullable ? 'nullable' : 'non-nullable'} in migration DDL',
        () {
          final config = GeneratorConfigBuilder()
              .withExtraClasses(customClassBySerializationType.values.toList())
              .build();
          final models = [
            ModelSourceBuilder().withYaml('''
class: Example
table: example
fields:
  ${customCase.fieldName}: $fieldType
''').build(),
          ];

          final collector = CodeGenerationCollector();
          final analyzer = StatefulAnalyzer(
            config,
            models,
            onErrorsCollector(collector),
          );

          final definitions = analyzer.validateAll();
          expect(collector.errors, isEmpty);

          final modelDefinition = definitions.first as ModelClassDefinition;
          final field = modelDefinition.fields.firstWhere(
            (f) => f.name == customCase.fieldName,
          );

          final definition = createDatabaseDefinitionFromModels(
            definitions,
            'example',
            [],
          );
          final column = definition.tables.single.columns.firstWhere(
            (c) => c.fieldName == customCase.fieldName,
          );

          expect(field.type.databaseType, declaredCase.databaseType);
          expect(column.columnType.name, field.type.databaseTypeEnum);
          expect(column.isNullable, isNullable);
        },
      );
    }
  });

  test(
    'Given scalar custom class field with serializationDataType, '
    'then validation rejects it with a sensible message',
    () {
      final config = GeneratorConfigBuilder()
          .withExtraClasses([customClassBySerializationType['int']!])
          .build();
      final models = [
        ModelSourceBuilder().withYaml('''
class: Example
table: example
fields:
  intData: IntCustomClass, serializationDataType=jsonb
''').build(),
      ];

      final collector = CodeGenerationCollector();
      final analyzer = StatefulAnalyzer(
        config,
        models,
        onErrorsCollector(collector),
      );

      analyzer.validateAll();

      expect(collector.errors, hasLength(1));
      expect(
        collector.errors.single.message,
        contains('serializationDataType'),
      );
      expect(
        collector.errors.single.message,
        contains('serializable field types'),
      );
    },
  );

  test(
    'Given map custom class field with serializationDataType json, '
    'then column type is ColumnSerializable and database type is json',
    () {
      final config = GeneratorConfigBuilder()
          .withExtraClasses([customClassBySerializationType['Map']!])
          .build();
      final models = [
        ModelSourceBuilder().withYaml('''
class: Example
table: example
fields:
  mapData: CustomClass2, serializationDataType=json
  jsonbMapData: CustomClass2, serializationDataType=jsonb
''').build(),
      ];

      final collector = CodeGenerationCollector();
      final analyzer = StatefulAnalyzer(
        config,
        models,
        onErrorsCollector(collector),
      );

      final definitions = analyzer.validateAll();
      expect(collector.errors, isEmpty);

      final definition = definitions.first as ModelClassDefinition;
      final mapField = definition.fields.firstWhere((f) => f.name == 'mapData');
      final jsonbField = definition.fields.firstWhere(
        (f) => f.name == 'jsonbMapData',
      );

      expect(mapField.type.serializationDataType, SerializationDataType.json);
      expect(mapField.type.databaseType, 'json');
      expect(mapField.type.columnType, 'ColumnSerializable');

      expect(
        jsonbField.type.serializationDataType,
        SerializationDataType.jsonb,
      );
      expect(jsonbField.type.databaseType, 'jsonb');
      expect(jsonbField.type.columnType, 'ColumnStructured');
    },
  );
}
