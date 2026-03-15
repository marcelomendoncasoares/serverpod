import '../../../serverpod_database.dart';

/// Converts PostgreSQL column_default SQL to dialect-neutral abstract default.
String? pgSqlToAbstractDefault(
  String? sql,
  ColumnType columnType,
) {
  if (sql == null || sql.isEmpty) return null;

  // nextval('...'::regclass)
  if (RegExp(r"nextval\s*\(\s*'[^']*'::regclass\s*\)").hasMatch(sql)) {
    return defaultIntSerial;
  }
  if (sql == 'CURRENT_TIMESTAMP') return defaultDateTimeValueNow;
  if (sql == 'gen_random_uuid()') return defaultUuidValueRandom;
  if (sql == 'gen_random_uuid_v7()') return defaultUuidValueRandomV7;

  // Literal: Remove the type cast and preserve the value that is inside the
  // quotes (with quotes included).
  var literal = sql;
  final match = RegExp(r"('[^']*')::[^']+").firstMatch(sql);
  if (match != null) {
    literal = match.group(1)!;
  }

  // Remove the quotes from literals to match the original value.
  if ((literal.startsWith('\'') && literal.endsWith('\'')) &&
      [
        ColumnType.timestampWithoutTimeZone,
        ColumnType.bigint,
      ].contains(columnType)) {
    literal = literal.substring(1, literal.length - 1);
  }

  // For timestamp without time zone, convert to DateTime.
  if (columnType == ColumnType.timestampWithoutTimeZone) {
    literal = DateTime.parse('${literal}Z').toIso8601String();
  }

  return literal;
}
