import 'package:serverpod_cli/src/database/dialects/postgres.dart';
import 'package:serverpod_cli/src/database/dialects/sqlite.dart';
import 'package:serverpod_database/serverpod_database.dart';
import 'package:test/test.dart';

void main() {
  test(
    'Given a String primary key without a default, '
    'when generating PostgreSQL DDL, '
    'then it is a text primary key without a generator.',
    () {
      final table = _table(ColumnType.text);

      final sql = table.tableCreationToPgsql();

      expect(sql, contains('"id" text PRIMARY KEY'));
      expect(sql, isNot(contains('DEFAULT')));
    },
  );

  test(
    'Given a DateTime primary key with a now generator, '
    'when generating SQLite DDL, '
    'then its default is preserved and the ID cannot alias the rowid.',
    () {
      final table = _table(
        ColumnType.timestampWithoutTimeZone,
        defaultValue: defaultDateTimeValueNow,
      );

      final sql = table.tableCreationToSql();

      expect(sql, contains('"id" INTEGER PRIMARY KEY DEFAULT ('));
      expect(sql, contains('STRICT, WITHOUT ROWID'));
    },
  );

  test(
    'Given a Duration primary key without a default, '
    'when generating SQLite DDL, '
    'then it cannot become an auto-incrementing rowid.',
    () {
      final table = _table(ColumnType.bigint);

      final sql = table.tableCreationToSql();

      expect(sql, contains('"id" INTEGER PRIMARY KEY'));
      expect(sql, contains('STRICT, WITHOUT ROWID'));
      expect(sql, isNot(contains('DEFAULT')));
    },
  );

  test(
    'Given a serial integer primary key, '
    'when generating SQLite DDL, '
    'then it retains SQLite rowid generation.',
    () {
      final table = _table(ColumnType.bigint, defaultValue: defaultIntSerial);

      final sql = table.tableCreationToSql();

      expect(sql, contains('"id" INTEGER PRIMARY KEY'));
      expect(sql, isNot(contains('WITHOUT ROWID')));
      expect(sql, isNot(contains('DEFAULT')));
    },
  );
}

TableDefinition _table(ColumnType type, {String? defaultValue}) {
  return TableDefinition(
    name: 'example',
    schema: 'public',
    columns: [
      ColumnDefinition(
        name: 'id',
        columnType: type,
        isNullable: false,
        columnDefault: defaultValue,
      ),
    ],
    foreignKeys: [],
    indexes: [],
  );
}
