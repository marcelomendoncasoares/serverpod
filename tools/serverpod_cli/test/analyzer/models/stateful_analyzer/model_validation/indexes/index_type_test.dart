import 'package:serverpod_cli/src/analyzer/models/definitions.dart';
import 'package:serverpod_cli/src/analyzer/models/stateful_analyzer.dart';
import 'package:serverpod_cli/src/generator/code_generation_collector.dart';
import 'package:test/test.dart';

import '../../../../../test_util/builders/generator_config_builder.dart';
import '../../../../../test_util/builders/model_source_builder.dart';

void main() {
  var config = GeneratorConfigBuilder().build();

  var validIndexTypes = [
    'btree',
    'hash',
    'gist',
    'spgist',
    'gin',
    'brin',
  ];

  for (var indexType in validIndexTypes) {
    test(
        'Given a class with an index type explicitly set to $indexType, then use that type',
        () {
      var models = [
        ModelSourceBuilder().withYaml(
          '''
            class: Example
            table: example
            fields:
              name: String
            indexes:
              example_index:
                fields: name
                type: $indexType
            ''',
        ).build(),
      ];

      var collector = CodeGenerationCollector();
      var analyzer = StatefulAnalyzer(
        config,
        models,
        onErrorsCollector(collector),
      );
      var definitions = analyzer.validateAll();

      var definition = definitions.first as ModelClassDefinition;

      var index = definition.indexes.first;

      expect(index.type, indexType);
    });
  }

  test(
      'Given a class with an index without a type set, then default to type btree',
      () {
    var models = [
      ModelSourceBuilder().withYaml(
        '''
          class: Example
          table: example
          fields:
            name: String
          indexes:
            example_index:
              fields: name
          ''',
      ).build(),
    ];

    var collector = CodeGenerationCollector();
    var analyzer =
        StatefulAnalyzer(config, models, onErrorsCollector(collector));
    var definitions = analyzer.validateAll();

    var definition = definitions.first as ModelClassDefinition;

    var index = definition.indexes.first;

    expect(index.type, 'btree');
  });

  test(
      'Given a class with an index type explicitly set to an invalid type, then collect an error that only the defined index types can be used.',
      () {
    var models = [
      ModelSourceBuilder().withYaml(
        '''
          class: Example
          table: example
          fields:
            name: String
          indexes:
            example_index:
              fields: name
              type: invalid_pgsql_type
          ''',
      ).build()
    ];

    var collector = CodeGenerationCollector();
    var analyzer =
        StatefulAnalyzer(config, models, onErrorsCollector(collector));
    analyzer.validateAll();

    expect(
      collector.errors,
      isNotEmpty,
      reason: 'Expected an error, but none was collected.',
    );

    var error = collector.errors.first;
    expect(
      error.message,
      'The "type" property must be one of: btree, hash, gin, gist, spgist, brin.',
    );
  });

  test(
      'Given a class with an index with an invalid type, then collect an error indicating that the type is invalid.',
      () {
    var models = [
      ModelSourceBuilder().withYaml(
        '''
          class: Example
          table: example
          fields:
            name: String
          indexes:
            example_index:
              fields: name
              type: 1
          ''',
      ).build()
    ];

    var collector = CodeGenerationCollector();
    var analyzer =
        StatefulAnalyzer(config, models, onErrorsCollector(collector));
    analyzer.validateAll();

    expect(
      collector.errors,
      isNotEmpty,
      reason: 'Expected an error, but none was collected.',
    );

    var error = collector.errors.first;
    expect(
      error.message,
      'The "type" property must be one of: btree, hash, gin, gist, spgist, brin.',
    );
  });

  test(
      'Given a class with an index on vector fields and no explicit type, then default to type "hnsw".',
      () {
    var models = [
      ModelSourceBuilder().withYaml(
        '''
          class: Example
          table: example
          fields:
            embedding: Vector(1536)
          indexes:
            example_index:
              fields: embedding
          ''',
      ).build(),
    ];

    var collector = CodeGenerationCollector();
    var analyzer =
        StatefulAnalyzer(config, models, onErrorsCollector(collector));
    var definitions = analyzer.validateAll();

    var definition = definitions.first as ModelClassDefinition;
    var index = definition.indexes.first;

    expect(index.type, 'hnsw');
  });

  test(
      'Given a class with an index on vector fields with explicit type "hnsw", then use that type.',
      () {
    var models = [
      ModelSourceBuilder().withYaml(
        '''
          class: Example
          table: example
          fields:
            embedding: Vector(1536)
          indexes:
            example_index:
              fields: embedding
              type: hnsw
          ''',
      ).build(),
    ];

    var collector = CodeGenerationCollector();
    var analyzer =
        StatefulAnalyzer(config, models, onErrorsCollector(collector));
    var definitions = analyzer.validateAll();

    var definition = definitions.first as ModelClassDefinition;
    var index = definition.indexes.first;

    expect(index.type, 'hnsw');
  });

  test(
      'Given a class with an index on vector fields with explicit type "ivfflat", then use that type.',
      () {
    var models = [
      ModelSourceBuilder().withYaml(
        '''
          class: Example
          table: example
          fields:
            embedding: Vector(1536)
          indexes:
            example_index:
              fields: embedding
              type: ivfflat
          ''',
      ).build(),
    ];

    var collector = CodeGenerationCollector();
    var analyzer =
        StatefulAnalyzer(config, models, onErrorsCollector(collector));
    var definitions = analyzer.validateAll();

    var definition = definitions.first as ModelClassDefinition;
    var index = definition.indexes.first;

    expect(index.type, 'ivfflat');
  });

  test(
      'Given a class with a vector field and an index type explicitly set to an invalid type, then collect an error that only vector index types can be used.',
      () {
    var models = [
      ModelSourceBuilder().withYaml(
        '''
          class: Example
          table: example
          fields:
            embedding: Vector(1536)
          indexes:
            example_index:
              fields: embedding
              type: invalid_pgsql_type
          ''',
      ).build()
    ];

    var collector = CodeGenerationCollector();
    var analyzer =
        StatefulAnalyzer(config, models, onErrorsCollector(collector));
    analyzer.validateAll();

    expect(
      collector.errors,
      isNotEmpty,
      reason: 'Expected an error, but none was collected.',
    );

    var error = collector.errors.first;
    expect(
      error.message,
      'The "type" property must be one of: hnsw, ivfflat.',
    );
  });

  test(
      'Given a class with a non-vector field and parameters, then collect an error that parameters can only be used with vector indexes.',
      () {
    var models = [
      ModelSourceBuilder().withYaml(
        '''
          class: Example
          table: example
          fields:
            name: String
          indexes:
            example_index:
              fields: name
              type: btree
              parameters:
                m: 16
          ''',
      ).build()
    ];

    var collector = CodeGenerationCollector();
    var analyzer =
        StatefulAnalyzer(config, models, onErrorsCollector(collector));
    analyzer.validateAll();

    expect(
      collector.errors,
      isNotEmpty,
      reason: 'Expected an error, but none was collected.',
    );

    var error = collector.errors.first;
    expect(
      error.message,
      'The "parameters" property can only be used with vector indexes of type "hnsw, ivfflat".',
    );
  });

  test(
      'Given a class with a vector field and hnsw index with valid parameters, then no errors should be collected.',
      () {
    var models = [
      ModelSourceBuilder().withYaml(
        '''
          class: Example
          table: example
          fields:
            embedding: Vector(1536)
          indexes:
            example_index:
              fields: embedding
              type: hnsw
              parameters:
                m: 16
                ef_construction: 64
                distance: l2
          ''',
      ).build()
    ];

    var collector = CodeGenerationCollector();
    var analyzer =
        StatefulAnalyzer(config, models, onErrorsCollector(collector));
    analyzer.validateAll();

    expect(
      collector.errors,
      isEmpty,
      reason: 'Expected no errors, but errors were collected.',
    );
  });

  test(
      'Given a class with a vector field and hnsw index with invalid parameter name, then collect an error about unknown parameters.',
      () {
    var models = [
      ModelSourceBuilder().withYaml(
        '''
          class: Example
          table: example
          fields:
            embedding: Vector(1536)
          indexes:
            example_index:
              fields: embedding
              type: hnsw
              parameters:
                invalid_param: 16
          ''',
      ).build()
    ];

    var collector = CodeGenerationCollector();
    var analyzer =
        StatefulAnalyzer(config, models, onErrorsCollector(collector));
    analyzer.validateAll();

    expect(
      collector.errors,
      isNotEmpty,
      reason: 'Expected an error, but none was collected.',
    );

    var error = collector.errors.first;
    expect(
      error.message,
      'Unknown parameters for hnsw index: "invalid_param". Allowed parameters '
      'are: "m", "ef_construction", "distance".',
    );
  });

  test(
      'Given a class with a vector field and ivfflat index with valid parameters, then no errors should be collected.',
      () {
    var models = [
      ModelSourceBuilder().withYaml(
        '''
          class: Example
          table: example
          fields:
            embedding: Vector(1536)
          indexes:
            example_index:
              fields: embedding
              type: ivfflat
              parameters:
                lists: 100
                distance: cosine
          ''',
      ).build()
    ];

    var collector = CodeGenerationCollector();
    var analyzer =
        StatefulAnalyzer(config, models, onErrorsCollector(collector));
    analyzer.validateAll();

    expect(
      collector.errors,
      isEmpty,
      reason: 'Expected no errors, but errors were collected.',
    );
  });

  test(
      'Given a class with a vector field and ivfflat index with invalid parameter name, then collect an error about unknown parameters.',
      () {
    var models = [
      ModelSourceBuilder().withYaml(
        '''
          class: Example
          table: example
          fields:
            embedding: Vector(1536)
          indexes:
            example_index:
              fields: embedding
              type: ivfflat
              parameters:
                ef_construction: 64
          ''',
      ).build()
    ];

    var collector = CodeGenerationCollector();
    var analyzer =
        StatefulAnalyzer(config, models, onErrorsCollector(collector));
    analyzer.validateAll();

    expect(
      collector.errors,
      isNotEmpty,
      reason: 'Expected an error, but none was collected.',
    );

    var error = collector.errors.first;
    expect(
      error.message,
      'Unknown parameters for ivfflat index: "ef_construction". Allowed '
      'parameters are: "lists", "distance".',
    );
  });

  test(
      'Given a class with a vector field and hnsw index with incorrect parameter type, then collect an error about parameter type.',
      () {
    var models = [
      ModelSourceBuilder().withYaml(
        '''
          class: Example
          table: example
          fields:
            embedding: Vector(1536)
          indexes:
            example_index:
              fields: embedding
              type: hnsw
              parameters:
                m: "16"
                ef_construction: true
          ''',
      ).build()
    ];

    var collector = CodeGenerationCollector();
    var analyzer =
        StatefulAnalyzer(config, models, onErrorsCollector(collector));
    analyzer.validateAll();

    expect(
      collector.errors.length,
      equals(2),
      reason: 'Expected two errors, but got ${collector.errors.length}.',
    );

    expect(
      collector.errors[0].message,
      'The "m" parameter must be a int.',
    );

    expect(
      collector.errors[1].message,
      'The "ef_construction" parameter must be a int.',
    );
  });

  test(
      'Given a class with a vector field and index with invalid distance parameter value, then collect an error about invalid distance value.',
      () {
    var models = [
      ModelSourceBuilder().withYaml(
        '''
          class: Example
          table: example
          fields:
            embedding: Vector(1536)
          indexes:
            example_index:
              fields: embedding
              type: hnsw
              parameters:
                distance: invalid_distance
          ''',
      ).build()
    ];

    var collector = CodeGenerationCollector();
    var analyzer =
        StatefulAnalyzer(config, models, onErrorsCollector(collector));
    analyzer.validateAll();

    expect(
      collector.errors,
      isNotEmpty,
      reason: 'Expected an error, but none was collected.',
    );

    var error = collector.errors.first;
    expect(
      error.message,
      'Invalid value for the "distance" parameter: "invalid_distance". Valid '
      'options are: "l2", "ip", "cosine", "l1", "hamming", "jaccard".',
    );
  });

  test(
      'Given a class with a vector field and index with non-string distance parameter, then collect an error about parameter type.',
      () {
    var models = [
      ModelSourceBuilder().withYaml(
        '''
          class: Example
          table: example
          fields:
            embedding: Vector(1536)
          indexes:
            example_index:
              fields: embedding
              type: hnsw
              parameters:
                distance: 123
          ''',
      ).build()
    ];

    var collector = CodeGenerationCollector();
    var analyzer =
        StatefulAnalyzer(config, models, onErrorsCollector(collector));
    analyzer.validateAll();

    expect(
      collector.errors,
      isNotEmpty,
      reason: 'Expected an error, but none was collected.',
    );

    var error = collector.errors.first;
    expect(
      error.message,
      'The "distance" parameter must be a string.',
    );
  });
}
