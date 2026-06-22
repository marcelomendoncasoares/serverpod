import 'package:serverpod_cli/src/analyzer/models/definitions.dart';
import 'package:serverpod_cli/src/analyzer/models/utils/row_security_parser.dart';
import 'package:test/test.dart';

void main() {
  test('Given a single condition then it is parsed without errors.', () {
    var result = RowSecurityParser.parse('userIdentifier=author');
    expect(result.errors, isEmpty);
    expect(result.conditions, hasLength(1));
    expect(
      result.conditions.first.authField,
      RowSecurityAuthField.userIdentifier,
    );
    expect(result.conditions.first.fieldName, 'author');
  });

  test('Given multiple comma-separated conditions then all are parsed.', () {
    var result = RowSecurityParser.parse(
      'userIdentifier=author, userIdentifier=owner',
    );
    expect(result.errors, isEmpty);
    expect(result.conditions.map((c) => c.fieldName), ['author', 'owner']);
  });

  test('Given surrounding whitespace then it is trimmed.', () {
    var result = RowSecurityParser.parse('  userIdentifier = author  ');
    expect(result.errors, isEmpty);
    expect(result.conditions.single.fieldName, 'author');
  });

  test('Given an empty value then an error is reported.', () {
    var result = RowSecurityParser.parse('');
    expect(result.conditions, isEmpty);
    expect(result.errors, isNotEmpty);
  });

  test('Given a condition without "=" then an error is reported.', () {
    var result = RowSecurityParser.parse('userIdentifier');
    expect(result.conditions, isEmpty);
    expect(result.errors.single, contains('authField=fieldName'));
  });

  test('Given the reserved scope field then a specific error is reported.', () {
    var result = RowSecurityParser.parse('scope=admin');
    expect(result.conditions, isEmpty);
    expect(result.errors.single, contains('not yet supported'));
  });

  test('Given an unknown auth field then an error is reported.', () {
    var result = RowSecurityParser.parse('unknown=author');
    expect(result.conditions, isEmpty);
    expect(result.errors.single, contains('Unknown authentication field'));
  });

  test('Given one valid and one invalid condition then both are reported.', () {
    var result = RowSecurityParser.parse('userIdentifier=author, broken');
    expect(result.conditions, hasLength(1));
    expect(result.errors, hasLength(1));
  });
}
