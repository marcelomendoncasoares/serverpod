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

  group('Given a model converted to a database definition', () {
    test('then an unsecured table has null rowSecurityPolicies.', () {
      var table = fromModel(unsecuredModel()).tables.single;
      expect(table.rowSecurityPolicies, isNull);
    });

    test('then a secured table has a row security policy for the field.', () {
      var table = fromModel(securedModel()).tables.single;
      expect(table.rowSecurityPolicies, hasLength(1));
      var policy = table.rowSecurityPolicies!.single;
      expect(policy.name, 'channel_author_rls');
      expect(policy.column, 'author');
      expect(policy.sessionVariable, 'serverpod.user_id');
      expect(policy.castType, 'uuid');
    });
  });

  group('Given the PostgreSQL schema SQL for a secured table', () {
    late String sql;
    setUp(() => sql = fromModel(securedModel()).toPgSql(installedModules: []));

    test('then row level security is enabled and forced.', () {
      expect(sql, contains('ALTER TABLE "channel" ENABLE ROW LEVEL SECURITY;'));
      expect(sql, contains('ALTER TABLE "channel" FORCE ROW LEVEL SECURITY;'));
    });

    test('then a policy comparing the column to the session variable is created.', () {
      expect(sql, contains('CREATE POLICY "channel_author_rls" ON "channel"'));
      expect(
        sql,
        contains('"author" = current_setting(\'serverpod.user_id\', true)::uuid'),
      );
    });
  });

  group('Given a migration', () {
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

    test('adding security enables RLS and creates the policy.', () {
      var sql = migrationSql(
        source: fromModel(unsecuredModel()),
        target: fromModel(securedModel()),
      );
      expect(sql, contains('ENABLE ROW LEVEL SECURITY'));
      expect(sql, contains('CREATE POLICY "channel_author_rls"'));
    });

    test('removing security drops the policy and disables RLS.', () {
      var sql = migrationSql(
        source: fromModel(securedModel()),
        target: fromModel(unsecuredModel()),
      );
      expect(sql, contains('DROP POLICY IF EXISTS "channel_author_rls" ON "channel";'));
      expect(sql, contains('DISABLE ROW LEVEL SECURITY'));
    });

    test('no security change produces no migration.', () {
      var migration = generateDatabaseMigration(
        databaseSource: fromModel(securedModel()),
        databaseTarget: fromModel(securedModel()),
      );
      expect(migration.isEmpty, isTrue);
    });
  });

  group('Given the SQLite dialect', () {
    test('then row security policies are stripped and a warning is logged.', () {
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
    });
  });
}
