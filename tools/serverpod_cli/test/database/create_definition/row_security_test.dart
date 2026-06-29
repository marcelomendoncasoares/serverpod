import 'package:serverpod_cli/src/analyzer/models/definitions.dart';
import 'package:serverpod_cli/src/database/create_definition.dart';
import 'package:test/test.dart';

import '../../test_util/builders/model_class_definition_builder.dart';

void main() {
  test(
    'Given an unsecured model, '
    'when converted to a database definition, '
    'then the table has no row security policies.',
    () {
      var model = ModelClassDefinitionBuilder()
          .withTableName('channel')
          .withSimpleField('author', 'UuidValue')
          .build();

      var definition = createDatabaseDefinitionFromModels(
        [model],
        'example',
        [],
      );

      expect(definition.tables.single.rowSecurityPolicies, isNull);
    },
  );

  test(
    'Given a secured model, '
    'when converted to a database definition, '
    'then the table has a row security policy for the secured field.',
    () {
      var model = ModelClassDefinitionBuilder()
          .withTableName('channel')
          .withSimpleField('author', 'UuidValue')
          .withSecurityConditions([
            const RowSecurityCondition(
              authField: RowSecurityAuthField.userIdentifier,
              fieldName: 'author',
            ),
          ])
          .build();

      var definition = createDatabaseDefinitionFromModels(
        [model],
        'example',
        [],
      );

      var policies = definition.tables.single.rowSecurityPolicies;
      expect(policies, hasLength(1));

      var policy = policies!.single;
      expect(policy.name, 'channel_author_rls');
      expect(policy.column, 'author');
      expect(policy.sessionVariable, 'serverpod.user_id');
      expect(policy.castType, 'uuid');
    },
  );
}
