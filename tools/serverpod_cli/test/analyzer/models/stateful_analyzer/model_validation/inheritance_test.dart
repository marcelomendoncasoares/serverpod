import 'package:serverpod_cli/src/analyzer/models/definitions.dart';
import 'package:serverpod_cli/src/analyzer/models/stateful_analyzer.dart';
import 'package:serverpod_cli/src/config/experimental_feature.dart';
import 'package:serverpod_cli/src/generator/code_generation_collector.dart';
import 'package:test/test.dart';

import '../../../../test_util/builders/generator_config_builder.dart';
import '../../../../test_util/builders/model_source_builder.dart';

void main() {
  var config = GeneratorConfigBuilder().withEnabledExperimentalFeatures(
      [ExperimentalFeature.inheritance]).build();

  group('Extends property tests', () {
    group('Given a child-class of an existing class', () {
      var modelSources = [
        ModelSourceBuilder().withYaml(
          '''
          class: Example
          fields:
            name: String
          ''',
        ).build(),
        ModelSourceBuilder().withFileName('example2').withYaml(
          '''
          class: ExampleChildClass
          extends: Example
          fields:
            age: int
          ''',
        ).build(),
      ];

      var collector = CodeGenerationCollector();
      var models =
          StatefulAnalyzer(config, modelSources, onErrorsCollector(collector))
              .validateAll();

      test('Then no errors are collected', () {
        expect(
          collector.errors,
          isEmpty,
        );
      });

      test('Then the child-class is resolved', () {
        var parent = models.first as ModelClassDefinition;
        var childClasses = parent.childClasses;
        var isChildResolved =
            childClasses.first is ResolvedInheritanceDefinition;

        expect(isChildResolved, isTrue);
      });

      test('Then extendsClass is resolved', () {
        var child = models.last as ModelClassDefinition;
        var extendsClass = child.extendsClass;
        var isExtendsResolved = extendsClass is ResolvedInheritanceDefinition;

        expect(isExtendsResolved, isTrue);
      });
    });

    test(
        'Given a child-class of a not existing class, then collect an error that no class was found in models',
        () {
      var modelSources = [
        ModelSourceBuilder().withYaml(
          '''
          class: Example
          extends: NotExistingClass
          fields:
            name: String
          ''',
        ).build(),
      ];

      var collector = CodeGenerationCollector();
      StatefulAnalyzer(config, modelSources, onErrorsCollector(collector))
          .validateAll();

      expect(
        collector.errors,
        isNotEmpty,
        reason: 'Expected an error but none was generated.',
      );

      var error = collector.errors.first;
      expect(
        error.message,
        'The class "NotExistingClass" was not found in any model.',
      );
    });

    test(
        'Given a child-class that extends an external class, then an error is collected that only classes from within the project can be extended',
        () {
      var modelSources = [
        ModelSourceBuilder()
            .withYaml(
              '''
          class: ExampleForeignClass
          fields:
            name: String
          ''',
            )
            .withModuleAlias('ModelSourceBuilder')
            .build(),
        ModelSourceBuilder().withFileName('example2').withYaml(
          '''
          class: ExampleChildClass
          extends: ExampleForeignClass
          fields:
            age: int
          ''',
        ).build(),
      ];

      var collector = CodeGenerationCollector();
      StatefulAnalyzer(config, modelSources, onErrorsCollector(collector))
          .validateAll();

      expect(
        collector.errors,
        isNotEmpty,
        reason: 'Expected an error but none was generated.',
      );

      var error = collector.errors.first;
      expect(
        error.message,
        'You can only extend classes from your own project.',
      );
    });

    test(
        'Given a child-class when inheritance is not enabled, then error is collected that the "extends" property is not allowed',
        () {
      var modelSources = [
        ModelSourceBuilder().withYaml(
          '''
          class: Example
          fields:
            name: String
          ''',
        ).build(),
        ModelSourceBuilder().withFileName('example2').withYaml(
          '''
          class: ExampleChildClass
          extends: Example
          fields:
            age: int
          ''',
        ).build(),
      ];

      var generatorConfig = GeneratorConfigBuilder().build();

      var collector = CodeGenerationCollector();
      StatefulAnalyzer(
              generatorConfig, modelSources, onErrorsCollector(collector))
          .validateAll();

      expect(
        collector.errors,
        isNotEmpty,
        reason: 'Expected an error but none was generated.',
      );

      var error = collector.errors.first;
      expect(
        error.message,
        'The "extends" property is not allowed for class type. Valid keys are {class, table, managedMigration, serverOnly, fields, indexes}.',
      );
    });

    group(
        'Given a child-class with table and a parent-class without table, then the parent-class fields are inherited and no error is collected',
        () {
      var modelSources = [
        ModelSourceBuilder().withYaml(
          '''
          class: Example
          fields:
            name: String
          ''',
        ).build(),
        ModelSourceBuilder().withFileName('example2').withYaml(
          '''
          class: ExampleChildClass
          table: example_child_table
          extends: Example
          fields:
            age: int
          ''',
        ).build(),
      ];

      var collector = CodeGenerationCollector();
      StatefulAnalyzer(config, modelSources, onErrorsCollector(collector))
          .validateAll();

      var errors = collector.errors;
      test('then no errors are collected.', () {
        expect(errors, isEmpty);
      });
    });

    group(
        'Given a child-class with table that have an index on a field created by a parent-class without table, then no error is collected and the index is defined',
        () {
      var modelSources = [
        ModelSourceBuilder().withYaml(
          '''
          class: Example
          fields:
            name: String
          ''',
        ).build(),
        ModelSourceBuilder().withFileName('example2').withYaml(
          '''
          class: ExampleChildClass
          table: example_child_table
          extends: Example
          fields:
            age: int
          indexes:
            example_index:
              fields: name
              unique: true
          ''',
        ).build(),
      ];

      var collector = CodeGenerationCollector();
      var models =
          StatefulAnalyzer(config, modelSources, onErrorsCollector(collector))
              .validateAll();

      var errors = collector.errors;
      test('then no errors are collected.', () {
        expect(errors, isEmpty);
      });

      var child = models.last as ModelClassDefinition;
      test('then the index definition contains the fields of the index.', () {
        var index = child.indexes.first;
        var indexFields = index.fields;
        expect(indexFields, ['name']);
      }, skip: errors.isNotEmpty);

      test('then the field definition contains index.', () {
        var field = child.fieldsIncludingInherited
            .firstWhere((field) => field.name == 'name');
        var index = field.indexes.firstOrNull;

        expect(index?.name, 'example_index');
      }, skip: errors.isNotEmpty);
    });

    test(
        'Given a child-class with table, When the parent-class also has a table, then error is collected that only one class in hierarchy can have a table',
        () {
      var modelSources = [
        ModelSourceBuilder().withYaml(
          '''
          class: Example
          table: example_table
          fields:
            name: String
          ''',
        ).build(),
        ModelSourceBuilder().withFileName('example2').withYaml(
          '''
          class: ExampleChildClass
          table: example_child_table
          extends: Example
          fields:
            age: int
          ''',
        ).build(),
      ];

      var collector = CodeGenerationCollector();
      StatefulAnalyzer(config, modelSources, onErrorsCollector(collector))
          .validateAll();

      expect(
        collector.errors,
        isNotEmpty,
        reason: 'Expected an error but none was generated.',
      );

      var error = collector.errors.first;
      expect(
        error.message,
        'The "table" property is not allowed because another class, "Example", in the class hierarchy already has one defined. Only one table definition is allowed when using inheritance.',
      );
    });

    test(
        'Given a child-class, when a field name already exists within the hierarchy, then an error is collected that child-class cannot be declared with this field.',
        () {
      var modelSources = [
        ModelSourceBuilder().withYaml(
          '''
          class: Example
          fields:
            name: String
          ''',
        ).build(),
        ModelSourceBuilder().withFileName('example2').withYaml(
          '''
          class: ExampleChildClass
          extends: Example
          fields:
            name: String
          ''',
        ).build(),
      ];

      var collector = CodeGenerationCollector();
      StatefulAnalyzer(config, modelSources, onErrorsCollector(collector))
          .validateAll();

      expect(
        collector.errors,
        isNotEmpty,
        reason: 'Expected an error but none was generated.',
      );

      var error = collector.errors.first;
      expect(
        error.message,
        'The field name "name" is already defined in an inherited class ("Example").',
      );
    });

    test(
        'Given a child-class, When the parent-class is serverOnly but the child-class is not, then error is collected that a client class cannot extend a serverOnly class',
        () {
      var modelSources = [
        ModelSourceBuilder().withYaml(
          '''
          class: Example
          serverOnly: true
          fields:
            name: String
          ''',
        ).build(),
        ModelSourceBuilder().withFileName('example2').withYaml(
          '''
          class: ExampleChildClass
          extends: Example
          fields:
            age: int
          ''',
        ).build(),
      ];

      var collector = CodeGenerationCollector();
      StatefulAnalyzer(config, modelSources, onErrorsCollector(collector))
          .validateAll();

      expect(
        collector.errors,
        isNotEmpty,
        reason: 'Expected an error but none was generated.',
      );

      var error = collector.errors.first;
      expect(
        error.message,
        'Cannot extend a "serverOnly" class in the inheritance chain ("Example") unless class is marked as "serverOnly".',
      );
    });

    test(
        'Given a serverOnly child-class, When the parent-class is not serverOnly but the grandparent-class is, then error is collected that a client class cannot extend a serverOnly class',
        () {
      var modelSources = [
        ModelSourceBuilder().withYaml(
          '''
          class: ExampleGrandparentClass
          serverOnly: true
          fields:
            name: String
          ''',
        ).build(),
        ModelSourceBuilder().withFileName('example1').withYaml(
          '''
          class: Example
          extends: ExampleGrandparentClass
          fields:
            name: String
          ''',
        ).build(),
        ModelSourceBuilder().withFileName('example2').withYaml(
          '''
          class: ExampleChildClass
          extends: Example
          fields:
            age: int
          ''',
        ).build(),
      ];

      var collector = CodeGenerationCollector();
      StatefulAnalyzer(config, modelSources, onErrorsCollector(collector))
          .validateAll();

      expect(
        collector.errors,
        isNotEmpty,
        reason: 'Expected an error but none was generated.',
      );

      var error = collector.errors.first;
      expect(
        error.message,
        'Cannot extend a "serverOnly" class in the inheritance chain ("ExampleGrandparentClass") unless class is marked as "serverOnly".',
      );
    });
  });

  test(
      'Given a class, when the sealed property is explicitly set to false, no errors are collected',
      () {
    var modelSources = [
      ModelSourceBuilder().withFileName('example1').withYaml(
        '''
          class: Example
          sealed: false
          fields:
            name: String
          ''',
      ).build(),
    ];

    var collector = CodeGenerationCollector();
    StatefulAnalyzer(config, modelSources, onErrorsCollector(collector))
        .validateAll();

    expect(
      collector.errors,
      isEmpty,
      reason: 'Expected no error but one was generated.',
    );
  });

  test(
      'Given a class, when the sealed property is set to a non-boolean value, then an error is collected that the value must be a boolean.',
      () {
    var modelSources = [
      ModelSourceBuilder().withFileName('example1').withYaml(
        '''
          class: Example
          sealed: 'unexpected string'
          fields:
            name: String
          ''',
      ).build(),
    ];

    var collector = CodeGenerationCollector();
    StatefulAnalyzer(config, modelSources, onErrorsCollector(collector))
        .validateAll();

    expect(
      collector.errors,
      isNotEmpty,
      reason: 'Expected no error but one was generated.',
    );

    var error = collector.errors.first;
    expect(
      error.message,
      'The value must be a boolean.',
    );
  });

  test(
      'Given a class using the sealed keyword, when inheritance is not enabled, then an error is collected that the "sealed" property is not allowed',
      () {
    var modelSources = [
      ModelSourceBuilder().withFileName('example1').withYaml(
        '''
          class: Example
          sealed: true
          fields:
            name: String
          ''',
      ).build(),
    ];

    var generatorConfig = GeneratorConfigBuilder().build();

    var collector = CodeGenerationCollector();
    StatefulAnalyzer(
            generatorConfig, modelSources, onErrorsCollector(collector))
        .validateAll();

    expect(
      collector.errors,
      isNotEmpty,
      reason: 'Expected no error but one was generated.',
    );

    var error = collector.errors.first;
    expect(
      error.message,
      'The "sealed" property is not allowed for class type. Valid keys are {class, table, managedMigration, serverOnly, fields, indexes}.',
    );
  });

  test(
      'Given a sealed class with a table defined, then an error is collected that "sealed" and "table" properties are mutually exclusive',
      () {
    var modelSources = [
      ModelSourceBuilder().withFileName('example1').withYaml(
        '''
          class: Example
          sealed: true
          table: example_table
          fields:
            name: String
          ''',
      ).build(),
    ];

    var collector = CodeGenerationCollector();
    StatefulAnalyzer(config, modelSources, onErrorsCollector(collector))
        .validateAll();

    expect(
      collector.errors,
      isNotEmpty,
      reason: 'Expected an error but none was generated.',
    );

    var error = collector.errors.first;
    expect(
      error.message,
      'The "sealed" property is mutually exclusive with the "table" property.',
    );
  });

  group('ID field inheritance tests', () {
    group('Given a parent class without table and child class with table', () {
      var modelSources = [
        ModelSourceBuilder().withYaml(
          '''
          class: ParentClass
          fields:
            name: String
          ''',
        ).build(),
        ModelSourceBuilder().withFileName('child_class').withYaml(
          '''
          class: ChildClass
          table: child_table
          extends: ParentClass
          fields:
            age: int
          ''',
        ).build(),
      ];

      var collector = CodeGenerationCollector();
      var models =
          StatefulAnalyzer(config, modelSources, onErrorsCollector(collector))
              .validateAll();

      test('then no errors are collected', () {
        expect(collector.errors, isEmpty);
      });

      late var childClass = models.last as ModelClassDefinition;

      test('then child class has an id field', () {
        expect(childClass.fields.first.name, 'id');
      });

      test('then child class id field has default int type', () {
        expect(childClass.fields.first.type.className, 'int');
        expect(childClass.fields.first.type.nullable, true);
      });

      test('then parent class fields are inherited (excluding id)', () {
        var inheritedFields = childClass.inheritedFields;
        expect(inheritedFields.length, 1);
        expect(inheritedFields.first.name, 'name');
      });
    });

    group('Given a parent class with table and child class without table', () {
      var modelSources = [
        ModelSourceBuilder().withYaml(
          '''
          class: ParentClass
          table: parent_table
          fields:
            name: String
          ''',
        ).build(),
        ModelSourceBuilder().withFileName('child_class').withYaml(
          '''
          class: ChildClass
          extends: ParentClass
          fields:
            age: int
          ''',
        ).build(),
      ];

      var collector = CodeGenerationCollector();
      var models =
          StatefulAnalyzer(config, modelSources, onErrorsCollector(collector))
              .validateAll();

      test('then no errors are collected', () {
        expect(collector.errors, isEmpty);
      });

      late var childClass = models.last as ModelClassDefinition;

      test('then child class inherits all parent fields including id', () {
        var inheritedFields = childClass.inheritedFields;
        expect(inheritedFields.length, 2); // id and name
        expect(inheritedFields.any((f) => f.name == 'id'), true);
        expect(inheritedFields.any((f) => f.name == 'name'), true);
      });

      test('then child class does not have its own id field', () {
        var ownFields = childClass.fields;
        expect(ownFields.any((f) => f.name == 'id'), false);
      });
    });

    group('Given a parent class with UuidValue id and child class with table',
        () {
      var modelSources = [
        ModelSourceBuilder().withYaml(
          '''
          class: ParentClass
          fields:
            id: UuidValue?, defaultPersist=random
            name: String
          ''',
        ).build(),
        ModelSourceBuilder().withFileName('child_class').withYaml(
          '''
          class: ChildClass
          table: child_table
          extends: ParentClass
          fields:
            age: int
          ''',
        ).build(),
      ];

      var collector = CodeGenerationCollector();
      var models =
          StatefulAnalyzer(config, modelSources, onErrorsCollector(collector))
              .validateAll();

      test('then no errors are collected', () {
        expect(collector.errors, isEmpty);
      });

      late var childClass = models.last as ModelClassDefinition;

      test('then child class inherits UuidValue id type', () {
        expect(childClass.fields.first.name, 'id');
        expect(childClass.fields.first.type.className, 'UuidValue');
        expect(childClass.fields.first.type.nullable, true);
      });

      test('then child class id field has inherited default value', () {
        expect(childClass.fields.first.defaultPersistValue, 'random');
      });
    });

    group('Given a child class with explicit different id type', () {
      var modelSources = [
        ModelSourceBuilder().withYaml(
          '''
          class: ParentClass
          fields:
            id: int?
            name: String
          ''',
        ).build(),
        ModelSourceBuilder().withFileName('child_class').withYaml(
          '''
          class: ChildClass
          table: child_table
          extends: ParentClass
          fields:
            id: UuidValue?, defaultPersist=random
            age: int
          ''',
        ).build(),
      ];

      var collector = CodeGenerationCollector();
      StatefulAnalyzer(config, modelSources, onErrorsCollector(collector))
          .validateAll();

      test('then an error is collected due to id field already defined', () {
        expect(collector.errors, isNotEmpty);
        expect(
          collector.errors.first.message,
          'The field name "id" is already defined in an inherited class ("ParentClass").',
        );
      });
    });

    group(
        'Given multi-level inheritance with id at top level and table at bottom level',
        () {
      var modelSources = [
        ModelSourceBuilder().withYaml(
          '''
          class: GrandparentClass
          fields:
            id: UuidValue?, defaultPersist=random
            grandparentField: String
          ''',
        ).build(),
        ModelSourceBuilder().withFileName('parent_class').withYaml(
          '''
          class: ParentClass
          extends: GrandparentClass
          fields:
            parentField: String
          ''',
        ).build(),
        ModelSourceBuilder().withFileName('child_class').withYaml(
          '''
          class: ChildClass
          table: child_table
          extends: ParentClass
          fields:
            childField: int
          ''',
        ).build(),
      ];

      var collector = CodeGenerationCollector();
      var models =
          StatefulAnalyzer(config, modelSources, onErrorsCollector(collector))
              .validateAll();

      test('then no errors are collected', () {
        expect(collector.errors, isEmpty);
      });

      late var childClass = models.last as ModelClassDefinition;

      test('then child class inherits id field from grandparent', () {
        expect(childClass.fields.first.name, 'id');
        expect(childClass.fields.first.type.className, 'UuidValue');
      });

      test('then child class inherits all ancestor fields except id', () {
        var inheritedFields = childClass.inheritedFields;
        expect(inheritedFields.length, 2);
        expect(inheritedFields.any((f) => f.name == 'grandparentField'), true);
        expect(inheritedFields.any((f) => f.name == 'parentField'), true);
        expect(inheritedFields.any((f) => f.name == 'id'), false);
      });

      test('then all fields including inherited are accessible', () {
        var allFields = childClass.fieldsIncludingInherited;
        expect(allFields.length, 4);
        expect(allFields.first.name, 'id');
        expect(allFields.any((f) => f.name == 'grandparentField'), true);
        expect(allFields.any((f) => f.name == 'parentField'), true);
        expect(allFields.any((f) => f.name == 'childField'), true);
      });
    });
  });
}
