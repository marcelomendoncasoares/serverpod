import 'package:serverpod_cli/src/analyzer/models/definitions.dart';

/// The outcome of parsing the value of the `secure` keyword.
class RowSecurityParseResult {
  /// The successfully parsed conditions.
  final List<RowSecurityCondition> conditions;

  /// Human readable error messages for malformed or unsupported conditions.
  final List<String> errors;

  /// Create a new [RowSecurityParseResult].
  const RowSecurityParseResult(this.conditions, this.errors);
}

/// Parses the syntax of the `secure` keyword into a list of
/// [RowSecurityCondition]s.
///
/// The grammar is a comma separated list of `authField=fieldName` conditions,
/// e.g. `userIdentifier=author` or `userIdentifier=author, userIdentifier=owner`.
///
/// This only validates the syntax of the value; semantic checks (such as
/// whether the referenced field exists and is a UUID column) are performed by
/// the model restrictions.
abstract final class RowSecurityParser {
  /// Parses the raw `secure` value [content] into a [RowSecurityParseResult].
  static RowSecurityParseResult parse(String content) {
    var conditions = <RowSecurityCondition>[];
    var errors = <String>[];

    var parts = content
        .split(',')
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.isEmpty) {
      errors.add(
        'The "secure" property must contain at least one condition, '
        'e.g. "userIdentifier=fieldName".',
      );
      return RowSecurityParseResult(conditions, errors);
    }

    for (var part in parts) {
      var sides = part.split('=');
      if (sides.length != 2) {
        errors.add(
          'Invalid "secure" condition "$part". '
          'Expected the format "authField=fieldName".',
        );
        continue;
      }

      var lhs = sides[0].trim();
      var rhs = sides[1].trim();
      if (lhs.isEmpty || rhs.isEmpty) {
        errors.add(
          'Invalid "secure" condition "$part". '
          'Expected the format "authField=fieldName".',
        );
        continue;
      }

      var authField = RowSecurityAuthField.values
          .where((field) => field.name == lhs)
          .firstOrNull;
      if (authField == null) {
        if (lhs == 'scope') {
          errors.add(
            'The "scope" authentication field is not yet supported in '
            '"secure". Only "userIdentifier" is currently supported.',
          );
        } else {
          errors.add(
            'Unknown authentication field "$lhs" in "secure". '
            'Supported fields: '
            '${RowSecurityAuthField.values.map((e) => e.name).join(', ')}.',
          );
        }
        continue;
      }

      conditions.add(
        RowSecurityCondition(authField: authField, fieldName: rhs),
      );
    }

    return RowSecurityParseResult(conditions, errors);
  }
}
