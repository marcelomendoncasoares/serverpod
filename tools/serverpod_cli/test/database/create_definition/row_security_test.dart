import 'package:serverpod_cli/src/analyzer/models/definitions.dart';
import 'package:serverpod_cli/src/database/create_definition.dart';
import 'package:serverpod_cli/src/database/extensions.dart';
import 'package:serverpod_cli/src/database/migration.dart';
import 'package:serverpod_database/serverpod_database.dart';
import 'package:test/test.dart';

import '../../test_util/builders/model_class_definition_builder.dart';

void main() {
  DatabaseDefinition fromModel(ModelClassDefinition model) =>
      createDatabaseDefinitionFromModels([model], 'example', []);

  ModelClassDefinition unsecuredModel() => ModelClassDefinitionBuilder()
      .withTableName('channel')
      .withSimpleField('author', 'UuidValue')
      .build();

  ModelClassDefinition securedModel() => ModelClassDefinitionBuilder()
      .withTableName('channel')
      .withSimpleField('author', 'UuidValue')
      .withSecurityConditions(const [
        RowSecurityCondition(
          authField: RowSecurityAuthField.userIdentifier,
          fieldName: 'author',
        ),
      ])
      .build();

  test(
    'Given a model without row security, '
    'when converted to a database definition, '
    'then the table has no row security policies.',
    () {
      var table = fromModel(unsecuredModel()).tables.single;
      expect(table.rowSecurityPolicies, isNull);
    },
  );

  test(
    'Given a model with row security, '
    'when converted to a database definition, '
    'then the table has a row security policy for the secured field.',
    () {
      var table = fromModel(securedModel()).tables.single;
      expect(table.rowSecurityPolicies, hasLength(1));
      var policy = table.rowSecurityPolicies!.single;
      expect(policy.name, 'channel_author_rls');
      expect(policy.column, 'author');
      expect(policy.sessionVariable, 'serverpod.user_id');
      expect(policy.castType, 'uuid');
    },
  );

  group('Given a secured model, ', () {
    late String sql;

    setUp(() => sql = fromModel(securedModel()).toPgSql(installedModules: []));

    test(
      'when PostgreSQL schema SQL is generated, '
      'then row level security is enabled and forced.',
      () {
        expect(
          sql,
          contains('ALTER TABLE "channel" ENABLE ROW LEVEL SECURITY;'),
        );
        expect(
          sql,
          contains('ALTER TABLE "channel" FORCE ROW LEVEL SECURITY;'),
        );
      },
    );

    test(
      'when PostgreSQL schema SQL is generated, '
      'then a policy comparing the column to the session variable is created.',
      () {
        expect(
          sql,
          contains('CREATE POLICY "channel_author_rls" ON "channel"'),
        );
        expect(
          sql,
          contains(
            '"author" = '
            'NULLIF(current_setting(\'serverpod.user_id\', true), \'\')::uuid',
          ),
        );
      },
    );
  });

  group('Given a database migration, ', () {
    String migrationSql({
      required DatabaseDefinition source,
      required DatabaseDefinition target,
    }) {
      var migration = generateDatabaseMigration(
        databaseSource: source,
        databaseTarget: target,
      );
      return migration.toPgSql(
        databaseDefinition: target,
        installedModules: [],
        removedModules: [],
      );
    }

    test(
      'when security is added to a model, '
      'then RLS is enabled and the policy is created.',
      () {
        var sql = migrationSql(
          source: fromModel(unsecuredModel()),
          target: fromModel(securedModel()),
        );
        expect(sql, contains('ENABLE ROW LEVEL SECURITY'));
        expect(sql, contains('CREATE POLICY "channel_author_rls"'));
      },
    );

    test(
      'when security is removed from a model, '
      'then the policy is dropped and RLS is disabled.',
      () {
        var sql = migrationSql(
          source: fromModel(securedModel()),
          target: fromModel(unsecuredModel()),
        );
        expect(
          sql,
          contains('DROP POLICY IF EXISTS "channel_author_rls" ON "channel";'),
        );
        expect(sql, contains('DISABLE ROW LEVEL SECURITY'));
      },
    );

    test(
      'when security is unchanged, '
      'then no migration is produced.',
      () {
        var migration = generateDatabaseMigration(
          databaseSource: fromModel(securedModel()),
          databaseTarget: fromModel(securedModel()),
        );
        expect(migration.isEmpty, isTrue);
      },
    );
  });

  test(
    'Given a secured model and the SQLite dialect, '
    'when the database definition is adapted, '
    'then row security policies are stripped and a warning is logged.',
    () {
      var warnings = <String>[];
      var filtered = fromModel(securedModel()).forDialect(
        DatabaseDialect.sqlite,
        logWarnings: warnings.add,
      );

      var table = filtered.tables.firstWhere((t) => t.name == 'channel');
      expect(table.rowSecurityPolicies, anyOf(isNull, isEmpty));
      expect(
        warnings.join('\n'),
        contains('Row-level security is not supported'),
      );
    },
  );
}
