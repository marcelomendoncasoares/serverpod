import 'package:serverpod_cli/src/analyzer/models/definitions.dart';
import 'package:serverpod_cli/src/analyzer/models/utils/row_security_parser.dart';
import 'package:test/test.dart';

void main() {
  test(
    'Given a single valid condition, '
    'when parsed, '
    'then it is accepted without errors.',
    () {
      var result = RowSecurityParser.parse('userIdentifier=author');
      expect(result.errors, isEmpty);
      expect(result.conditions, hasLength(1));
      expect(
        result.conditions.first.authField,
        RowSecurityAuthField.userIdentifier,
      );
      expect(result.conditions.first.fieldName, 'author');
    },
  );

  test(
    'Given multiple comma-separated valid conditions, '
    'when parsed, '
    'then all conditions are accepted.',
    () {
      var result = RowSecurityParser.parse(
        'userIdentifier=author, userIdentifier=owner',
      );
      expect(result.errors, isEmpty);
      expect(result.conditions.map((c) => c.fieldName), ['author', 'owner']);
    },
  );

  test(
    'Given a condition with surrounding whitespace, '
    'when parsed, '
    'then the whitespace is trimmed.',
    () {
      var result = RowSecurityParser.parse('  userIdentifier = author  ');
      expect(result.errors, isEmpty);
      expect(result.conditions.single.fieldName, 'author');
    },
  );

  test(
    'Given an empty value, '
    'when parsed, '
    'then an error is reported.',
    () {
      var result = RowSecurityParser.parse('');
      expect(result.conditions, isEmpty);
      expect(result.errors, isNotEmpty);
    },
  );

  test(
    'Given a condition without "=", '
    'when parsed, '
    'then an error describing the expected format is reported.',
    () {
      var result = RowSecurityParser.parse('userIdentifier');
      expect(result.conditions, isEmpty);
      expect(result.errors.single, contains('authField=fieldName'));
    },
  );

  test(
    'Given the reserved scope field, '
    'when parsed, '
    'then an error that scope is not yet supported is reported.',
    () {
      var result = RowSecurityParser.parse('scope=admin');
      expect(result.conditions, isEmpty);
      expect(result.errors.single, contains('not yet supported'));
    },
  );

  test(
    'Given an unknown auth field, '
    'when parsed, '
    'then an error is reported.',
    () {
      var result = RowSecurityParser.parse('unknown=author');
      expect(result.conditions, isEmpty);
      expect(result.errors.single, contains('Unknown authentication field'));
    },
  );

  test(
    'Given one valid and one invalid condition, '
    'when parsed, '
    'then the valid condition is accepted and the invalid one is reported.',
    () {
      var result = RowSecurityParser.parse('userIdentifier=author, broken');
      expect(result.conditions, hasLength(1));
      expect(result.errors, hasLength(1));
    },
  );
}
