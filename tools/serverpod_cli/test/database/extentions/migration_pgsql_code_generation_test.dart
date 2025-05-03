import 'package:serverpod_cli/analyzer.dart';
import 'package:serverpod_service_client/serverpod_service_client.dart';
import 'package:test/test.dart';

import '../../test_util/builders/database/column_definition_builder.dart';
import '../../test_util/builders/database/database_definition_builder.dart';
import '../../test_util/builders/database/table_definition_builder.dart';
import '../../test_util/builders/model_source_builder.dart';
import '../../test_util/database_definition_helpers.dart';

void main() {
  group(
      'Given a table that is not managed by serverpod that changes to be managed',
      () {
    var tableName = 'example_table';

    var sourceDefinition = DatabaseDefinitionBuilder()
        .withDefaultModules()
        .withTable(TableDefinitionBuilder()
            .withName(tableName)
            .withManaged(false)
            .build())
        .build();

    var targetDefinition = DatabaseDefinitionBuilder()
        .withDefaultModules()
        .withTable(TableDefinitionBuilder()
            .withName(tableName)
            .withManaged(true)
            .build())
        .build();

    var migration = generateDatabaseMigration(
      databaseSource: sourceDefinition,
      databaseTarget: targetDefinition,
    );

    var psql = migration.toPgSql(installedModules: [], removedModules: []);

    test(
        'Given a table transitioning from none manage to manage then the psql code contains a create table if not exists.',
        () {
      expect(psql, contains('CREATE TABLE IF NOT EXISTS "example_table"'));
    });

    const createVectorExtension = '''
DO \$\$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_available_extensions WHERE name = 'vector') THEN
    EXECUTE 'CREATE EXTENSION IF NOT EXISTS vector';
  ELSE
    RAISE NOTICE 'Extension "vector" not available on this instance';
  END IF;
END
\$\$;
''';

    test(
        'Given a migration with no vector field changes, then the code for creating vector extension is not generated.',
        () {
      var migration = DatabaseMigration(
        actions: [],
        warnings: [],
        migrationApiVersion: 1,
      );
      var pgsql = migration.toPgSql(installedModules: [], removedModules: []);

      expect(pgsql, isNot(contains(createVectorExtension)));
    });

    test(
        'Given a migration that adds a table with a vector field, then the code for creating vector extension is generated.',
        () {
      var sourceDefinition = DatabaseDefinitionBuilder().build();

      var targetDefinition = DatabaseDefinitionBuilder()
          .withTable(TableDefinitionBuilder()
              .withName('vector_table')
              .withColumn(ColumnDefinitionBuilder()
                  .withName('embedding')
                  .withColumnType(ColumnType.vector)
                  .withVectorDimension(512)
                  .build())
              .build())
          .build();

      var migration = generateDatabaseMigration(
        databaseSource: sourceDefinition,
        databaseTarget: targetDefinition,
      );

      var pgsql = migration.toPgSql(installedModules: [], removedModules: []);

      expect(pgsql, contains(createVectorExtension));
    });

    test(
        'Given a migration that adds a vector column to existing table, then the code for creating vector extension is generated.',
        () {
      var sourceDefinition = DatabaseDefinitionBuilder()
          .withTable(
              TableDefinitionBuilder().withName('existing_table').build())
          .build();

      var targetDefinition = DatabaseDefinitionBuilder()
          .withTable(TableDefinitionBuilder()
              .withName('existing_table')
              .withColumn(ColumnDefinitionBuilder()
                  .withName('embedding')
                  .withColumnType(ColumnType.vector)
                  .withVectorDimension(512)
                  .build())
              .build())
          .build();

      var migration = generateDatabaseMigration(
        databaseSource: sourceDefinition,
        databaseTarget: targetDefinition,
      );

      var pgsql = migration.toPgSql(installedModules: [], removedModules: []);

      expect(pgsql, contains(createVectorExtension));
    });

    test(
        'Given a migration that removes a table with a vector field, then the code for creating vector extension is not generated.',
        () {
      var sourceDefinition = DatabaseDefinitionBuilder()
          .withTable(TableDefinitionBuilder()
              .withName('vector_table')
              .withColumn(ColumnDefinitionBuilder()
                  .withName('embedding')
                  .withColumnType(ColumnType.vector)
                  .withVectorDimension(512)
                  .build())
              .build())
          .build();

      var targetDefinition = DatabaseDefinitionBuilder().build();

      var migration = generateDatabaseMigration(
        databaseSource: sourceDefinition,
        databaseTarget: targetDefinition,
      );

      var pgsql = migration.toPgSql(installedModules: [], removedModules: []);

      expect(pgsql, isNot(contains(createVectorExtension)));
    });
  });

  /// Issue: https://github.com/serverpod/serverpod/issues/3503
  test(
      'Given an existing table that that references a new table with a name lexically sorted before the existing one, when creating migraion sql then the migration code should create the table before defining the foreign key',
      () {
    var sourceModels = [
      ModelSourceBuilder().withFileName('existing_table').withYaml(
        '''
class: ExistingModel
table: a_existing_table
fields:
  name: String
          ''',
      ).build(),
    ];

    var targetModels = [
      ModelSourceBuilder().withFileName('new_model').withYaml(
        '''
class: NewModel
table: z_new_model
fields:
  name: String
          ''',
      ).build(),
      ModelSourceBuilder().withFileName('existing_table').withYaml(
        '''
class: ExistingModel
table: a_existing_table
fields:
  name: String
  newModel: NewModel?, relation(optional)
          ''',
      ).build(),
    ];

    var (:sourceDefinition, :targetDefinition) = databaseDefinitionsFromModels(
      sourceModels,
      targetModels,
    );

    var migration = generateDatabaseMigration(
      databaseSource: sourceDefinition,
      databaseTarget: targetDefinition,
    );

    var psql = migration.toPgSql(installedModules: [], removedModules: []);

    var createNewModelTable = psql.indexOf('CREATE TABLE "z_new_model"');
    var addForeignKeyToExistingTable =
        psql.indexOf('ADD CONSTRAINT "a_existing_table_fk_0"');

    expect(createNewModelTable, greaterThanOrEqualTo(0));
    expect(addForeignKeyToExistingTable, greaterThanOrEqualTo(0));

    expect(createNewModelTable, lessThan(addForeignKeyToExistingTable));
  });
}
