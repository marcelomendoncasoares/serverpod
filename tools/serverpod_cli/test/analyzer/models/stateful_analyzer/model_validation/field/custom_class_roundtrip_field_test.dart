import 'package:serverpod_cli/src/analyzer/models/definitions.dart';
import 'package:serverpod_cli/src/analyzer/models/serialization_data_type.dart';
import 'package:serverpod_cli/src/analyzer/models/stateful_analyzer.dart';
import 'package:serverpod_cli/src/database/create_definition.dart';
import 'package:serverpod_cli/src/generator/code_generation_collector.dart';
import 'package:serverpod_cli/src/generator/types.dart';
import 'package:serverpod_service_client/serverpod_service_client.dart';
import 'package:test/test.dart';

import '../../../../../test_util/builders/generator_config_builder.dart';
import '../../../../../test_util/builders/model_source_builder.dart';

void main() {
  group('Given an IntCustomClass table field,', () {
    var extraClass = _extraClass(
      className: 'IntCustomClass',
      serializationType: TypeDefinition.int,
    );
    var fieldName = 'intData';
    var fieldYaml = 'intData: IntCustomClass';

    group('when the model is validated,', () {
      late CodeGenerationCollector collector;
      late SerializableModelFieldDefinition field;

      setUp(() {
        var analysis = _analyzeTableField(
          extraClass: extraClass,
          fieldName: fieldName,
          fieldYaml: fieldYaml,
        );
        collector = analysis.collector;
        field = analysis.field;
      });

      test('then no errors are reported.', () {
        expect(collector.errors, isEmpty);
      });

      test('then the database type is bigint.', () {
        expect(field.type.databaseType, 'bigint');
      });

      test('then the column type is ColumnInt.', () {
        expect(field.type.columnType, 'ColumnInt');
      });

      test('then the field type is IntCustomClass.', () {
        expect(field.type.className, 'IntCustomClass');
        expect(field.type.customClass, isTrue);
      });
    });

    group('when creating the database definition,', () {
      late ColumnDefinition column;

      setUp(() {
        column = _columnFromDatabaseDefinition(
          extraClass: extraClass,
          fieldName: fieldName,
          fieldYaml: fieldYaml,
        );
      });

      test('then the column is non-nullable.', () {
        expect(column.isNullable, isFalse);
      });

      test('then the column type is bigint.', () {
        expect(column.columnType.name, 'bigint');
      });
    });
  });

  group('Given a DoubleCustomClass table field,', () {
    var extraClass = _extraClass(
      className: 'DoubleCustomClass',
      serializationType: TypeDefinition(className: 'double', nullable: false),
    );
    var fieldName = 'doubleData';
    var fieldYaml = 'doubleData: DoubleCustomClass';

    group('when the model is validated,', () {
      late CodeGenerationCollector collector;
      late SerializableModelFieldDefinition field;

      setUp(() {
        var analysis = _analyzeTableField(
          extraClass: extraClass,
          fieldName: fieldName,
          fieldYaml: fieldYaml,
        );
        collector = analysis.collector;
        field = analysis.field;
      });

      test('then no errors are reported.', () {
        expect(collector.errors, isEmpty);
      });

      test('then the database type is double precision.', () {
        expect(field.type.databaseType, 'double precision');
      });

      test('then the column type is ColumnDouble.', () {
        expect(field.type.columnType, 'ColumnDouble');
      });
    });

    group('when creating the database definition,', () {
      late ColumnDefinition column;

      setUp(() {
        column = _columnFromDatabaseDefinition(
          extraClass: extraClass,
          fieldName: fieldName,
          fieldYaml: fieldYaml,
        );
      });

      test('then the column is non-nullable.', () {
        expect(column.isNullable, isFalse);
      });

      test('then the column type is doublePrecision.', () {
        expect(column.columnType.name, 'doublePrecision');
      });
    });
  });

  group('Given a CustomClass table field that serializes as String,', () {
    var extraClass = _extraClass(
      className: 'CustomClass',
      serializationType: TypeDefinition(className: 'String', nullable: false),
    );
    var fieldName = 'stringData';
    var fieldYaml = 'stringData: CustomClass';

    group('when the model is validated,', () {
      late CodeGenerationCollector collector;
      late SerializableModelFieldDefinition field;

      setUp(() {
        var analysis = _analyzeTableField(
          extraClass: extraClass,
          fieldName: fieldName,
          fieldYaml: fieldYaml,
        );
        collector = analysis.collector;
        field = analysis.field;
      });

      test('then no errors are reported.', () {
        expect(collector.errors, isEmpty);
      });

      test('then the database type is text.', () {
        expect(field.type.databaseType, 'text');
      });

      test('then the column type is ColumnString.', () {
        expect(field.type.columnType, 'ColumnString');
      });
    });

    group('when creating the database definition,', () {
      late ColumnDefinition column;

      setUp(() {
        column = _columnFromDatabaseDefinition(
          extraClass: extraClass,
          fieldName: fieldName,
          fieldYaml: fieldYaml,
        );
      });

      test('then the column is non-nullable.', () {
        expect(column.isNullable, isFalse);
      });

      test('then the column type is text.', () {
        expect(column.columnType.name, 'text');
      });
    });
  });

  group('Given a BoolCustomClass table field,', () {
    var extraClass = _extraClass(
      className: 'BoolCustomClass',
      serializationType: TypeDefinition(className: 'bool', nullable: false),
    );
    var fieldName = 'boolData';
    var fieldYaml = 'boolData: BoolCustomClass';

    group('when the model is validated,', () {
      late CodeGenerationCollector collector;
      late SerializableModelFieldDefinition field;

      setUp(() {
        var analysis = _analyzeTableField(
          extraClass: extraClass,
          fieldName: fieldName,
          fieldYaml: fieldYaml,
        );
        collector = analysis.collector;
        field = analysis.field;
      });

      test('then no errors are reported.', () {
        expect(collector.errors, isEmpty);
      });

      test('then the database type is boolean.', () {
        expect(field.type.databaseType, 'boolean');
      });

      test('then the column type is ColumnBool.', () {
        expect(field.type.columnType, 'ColumnBool');
      });
    });

    group('when creating the database definition,', () {
      late ColumnDefinition column;

      setUp(() {
        column = _columnFromDatabaseDefinition(
          extraClass: extraClass,
          fieldName: fieldName,
          fieldYaml: fieldYaml,
        );
      });

      test('then the column is non-nullable.', () {
        expect(column.isNullable, isFalse);
      });

      test('then the column type is boolean.', () {
        expect(column.columnType.name, 'boolean');
      });
    });
  });

  group('Given a DateTimeCustomClass table field,', () {
    var extraClass = _extraClass(
      className: 'DateTimeCustomClass',
      serializationType: TypeDefinition(className: 'DateTime', nullable: false),
    );
    var fieldName = 'dateTimeData';
    var fieldYaml = 'dateTimeData: DateTimeCustomClass';

    group('when the model is validated,', () {
      late CodeGenerationCollector collector;
      late SerializableModelFieldDefinition field;

      setUp(() {
        var analysis = _analyzeTableField(
          extraClass: extraClass,
          fieldName: fieldName,
          fieldYaml: fieldYaml,
        );
        collector = analysis.collector;
        field = analysis.field;
      });

      test('then no errors are reported.', () {
        expect(collector.errors, isEmpty);
      });

      test('then the database type is timestamp without time zone.', () {
        expect(field.type.databaseType, 'timestamp without time zone');
      });

      test('then the column type is ColumnDateTime.', () {
        expect(field.type.columnType, 'ColumnDateTime');
      });
    });

    group('when creating the database definition,', () {
      late ColumnDefinition column;

      setUp(() {
        column = _columnFromDatabaseDefinition(
          extraClass: extraClass,
          fieldName: fieldName,
          fieldYaml: fieldYaml,
        );
      });

      test('then the column is non-nullable.', () {
        expect(column.isNullable, isFalse);
      });

      test('then the column type is timestampWithoutTimeZone.', () {
        expect(column.columnType.name, 'timestampWithoutTimeZone');
      });
    });
  });

  group(
    'Given a CustomClass2 table field with serializationDataType json,',
    () {
      var extraClass = _extraClass(
        className: 'CustomClass2',
        serializationType: TypeDefinition(
          className: 'dynamic',
          nullable: false,
        ),
      );
      var fieldName = 'mapData';
      var fieldYaml = 'mapData: CustomClass2, serializationDataType=json';

      group('when the model is validated,', () {
        late CodeGenerationCollector collector;
        late SerializableModelFieldDefinition field;

        setUp(() {
          var analysis = _analyzeTableField(
            extraClass: extraClass,
            fieldName: fieldName,
            fieldYaml: fieldYaml,
          );
          collector = analysis.collector;
          field = analysis.field;
        });

        test('then no errors are reported.', () {
          expect(collector.errors, isEmpty);
        });

        test('then the database type is json.', () {
          expect(field.type.databaseType, 'json');
        });

        test('then the column type is ColumnSerializable.', () {
          expect(field.type.columnType, 'ColumnSerializable');
        });

        test('then the serializationDataType is json.', () {
          expect(field.type.serializationDataType, SerializationDataType.json);
        });
      });

      group('when creating the database definition,', () {
        late ColumnDefinition column;

        setUp(() {
          column = _columnFromDatabaseDefinition(
            extraClass: extraClass,
            fieldName: fieldName,
            fieldYaml: fieldYaml,
          );
        });

        test('then the column is non-nullable.', () {
          expect(column.isNullable, isFalse);
        });

        test('then the column type is json.', () {
          expect(column.columnType.name, 'json');
        });
      });
    },
  );

  group(
    'Given a CustomClass2 table field with serializationDataType jsonb,',
    () {
      var extraClass = _extraClass(
        className: 'CustomClass2',
        serializationType: TypeDefinition(
          className: 'dynamic',
          nullable: false,
        ),
      );
      var fieldName = 'jsonbMapData';
      var fieldYaml = 'jsonbMapData: CustomClass2, serializationDataType=jsonb';

      group('when the model is validated,', () {
        late CodeGenerationCollector collector;
        late SerializableModelFieldDefinition field;

        setUp(() {
          var analysis = _analyzeTableField(
            extraClass: extraClass,
            fieldName: fieldName,
            fieldYaml: fieldYaml,
          );
          collector = analysis.collector;
          field = analysis.field;
        });

        test('then no errors are reported.', () {
          expect(collector.errors, isEmpty);
        });

        test('then the database type is jsonb.', () {
          expect(field.type.databaseType, 'jsonb');
        });

        test('then the column type is ColumnStructured.', () {
          expect(field.type.columnType, 'ColumnStructured');
        });

        test('then the serializationDataType is jsonb.', () {
          expect(field.type.serializationDataType, SerializationDataType.jsonb);
        });
      });

      group('when creating the database definition,', () {
        late ColumnDefinition column;

        setUp(() {
          column = _columnFromDatabaseDefinition(
            extraClass: extraClass,
            fieldName: fieldName,
            fieldYaml: fieldYaml,
          );
        });

        test('then the column is non-nullable.', () {
          expect(column.isNullable, isFalse);
        });

        test('then the column type is jsonb.', () {
          expect(column.columnType.name, 'jsonb');
        });
      });
    },
  );

  group('Given a nullable IntCustomClass table field,', () {
    var extraClass = _extraClass(
      className: 'IntCustomClass',
      serializationType: TypeDefinition.int,
    );
    var fieldName = 'nullableIntData';
    var fieldYaml = 'nullableIntData: IntCustomClass?';

    group('when the model is validated,', () {
      late CodeGenerationCollector collector;
      late SerializableModelFieldDefinition field;

      setUp(() {
        var analysis = _analyzeTableField(
          extraClass: extraClass,
          fieldName: fieldName,
          fieldYaml: fieldYaml,
        );
        collector = analysis.collector;
        field = analysis.field;
      });

      test('then no errors are reported.', () {
        expect(collector.errors, isEmpty);
      });

      test('then the database type is bigint.', () {
        expect(field.type.databaseType, 'bigint');
      });

      test('then the column type is ColumnInt.', () {
        expect(field.type.columnType, 'ColumnInt');
      });
    });

    group('when creating the database definition,', () {
      late ColumnDefinition column;

      setUp(() {
        column = _columnFromDatabaseDefinition(
          extraClass: extraClass,
          fieldName: fieldName,
          fieldYaml: fieldYaml,
        );
      });

      test('then the column is nullable.', () {
        expect(column.isNullable, isTrue);
      });

      test('then the column type is bigint.', () {
        expect(column.columnType.name, 'bigint');
      });
    });
  });

  group(
    'Given a nullable CustomClass2 table field with serializationDataType json,',
    () {
      var extraClass = _extraClass(
        className: 'CustomClass2',
        serializationType: TypeDefinition(
          className: 'dynamic',
          nullable: false,
        ),
      );
      var fieldName = 'nullableMapData';
      var fieldYaml =
          'nullableMapData: CustomClass2?, serializationDataType=json';

      group('when the model is validated,', () {
        late CodeGenerationCollector collector;
        late SerializableModelFieldDefinition field;

        setUp(() {
          var analysis = _analyzeTableField(
            extraClass: extraClass,
            fieldName: fieldName,
            fieldYaml: fieldYaml,
          );
          collector = analysis.collector;
          field = analysis.field;
        });

        test('then no errors are reported.', () {
          expect(collector.errors, isEmpty);
        });

        test('then the database type is json.', () {
          expect(field.type.databaseType, 'json');
        });

        test('then the column type is ColumnSerializable.', () {
          expect(field.type.columnType, 'ColumnSerializable');
        });
      });

      group('when creating the database definition,', () {
        late ColumnDefinition column;

        setUp(() {
          column = _columnFromDatabaseDefinition(
            extraClass: extraClass,
            fieldName: fieldName,
            fieldYaml: fieldYaml,
          );
        });

        test('then the column is nullable.', () {
          expect(column.isNullable, isTrue);
        });

        test('then the column type is json.', () {
          expect(column.columnType.name, 'json');
        });
      });
    },
  );

  group(
    'Given an IntCustomClass table field with serializationDataType jsonb,',
    () {
      var extraClass = _extraClass(
        className: 'IntCustomClass',
        serializationType: TypeDefinition.int,
      );

      group('when the model is validated,', () {
        late CodeGenerationCollector collector;

        setUp(() {
          var config = GeneratorConfigBuilder().withExtraClasses([
            extraClass,
          ]).build();
          var models = [
            ModelSourceBuilder().withYaml('''
class: Example
table: example
fields:
  intData: IntCustomClass, serializationDataType=jsonb
''').build(),
          ];

          collector = CodeGenerationCollector();
          StatefulAnalyzer(
            config,
            models,
            onErrorsCollector(collector),
          ).validateAll();
        });

        test(
          'then an error is reported that serializationDataType is only valid on serializable field types.',
          () {
            expect(collector.errors, hasLength(1));
            expect(
              collector.errors.single.message,
              'The "serializationDataType" key is only valid on serializable '
              'field types (e.g. lists, maps, serializable models or custom classes).',
            );
          },
        );
      });
    },
  );
}

TypeDefinition _extraClass({
  required String className,
  required TypeDefinition serializationType,
}) {
  return TypeDefinition(
    className: className,
    nullable: false,
    url: 'package:serverpod_test_shared/serverpod_test_shared.dart',
    customClass: true,
    customClassSerializationType: serializationType,
  );
}

({
  CodeGenerationCollector collector,
  SerializableModelFieldDefinition field,
  List<SerializableModelDefinition> definitions,
})
_analyzeTableField({
  required TypeDefinition extraClass,
  required String fieldName,
  required String fieldYaml,
}) {
  var config = GeneratorConfigBuilder().withExtraClasses([extraClass]).build();
  var models = [
    ModelSourceBuilder().withYaml('''
class: Example
table: example
fields:
  $fieldYaml
''').build(),
  ];

  var collector = CodeGenerationCollector();
  var definitions = StatefulAnalyzer(
    config,
    models,
    onErrorsCollector(collector),
  ).validateAll();

  var definition = definitions.first as ModelClassDefinition;

  return (
    collector: collector,
    field: definition.fields.firstWhere((field) => field.name == fieldName),
    definitions: definitions,
  );
}

ColumnDefinition _columnFromDatabaseDefinition({
  required TypeDefinition extraClass,
  required String fieldName,
  required String fieldYaml,
}) {
  var analysis = _analyzeTableField(
    extraClass: extraClass,
    fieldName: fieldName,
    fieldYaml: fieldYaml,
  );
  expect(analysis.collector.errors, isEmpty);

  var databaseDefinition = createDatabaseDefinitionFromModels(
    analysis.definitions,
    'example',
    [],
  );

  return databaseDefinition.tables.single.columns.firstWhere(
    (column) => column.fieldName == fieldName,
  );
}
