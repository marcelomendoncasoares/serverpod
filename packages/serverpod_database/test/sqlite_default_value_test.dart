import 'package:serverpod_database/serverpod_database.dart';
import 'package:serverpod_database/src/adapters/sqlite/sqlite_default_value.dart';
import 'package:serverpod_serialization/serverpod_serialization.dart';
import 'package:test/test.dart';

void main() {
  group(
    'Given a decimal column with precision and scale and an abstract default value,',
    () {
      final column = ColumnDefinition(
        name: 'numberOfAtoms',
        columnType: ColumnType.decimal,
        isNullable: false,
      );

      test(
        'when getting the SQLite column default from the abstract default value, '
        'then the value is quoted as a TEXT literal.',
        () {
          expect(
            column.getSqliteColumnDefault('10.5'),
            equals("'10.5'"),
          );
          final t = Decimal.parse('10.5');
          print(t.toString());
        },
      );

      test(
        'when reverting the SQLite column default to the abstract default value, '
        'then the value is the original value.',
        () {
          const abstractDefault = '10.5';
          final converted = column.getSqliteColumnDefault(abstractDefault);

          expect(
            sqliteSqlToAbstractDefault(
              converted,
              column.columnType,
              decimalPrecision: column.decimalPrecision,
              decimalScale: column.decimalScale,
            ),
            equals(abstractDefault),
          );
        },
      );
    },
  );

  group(
    'Given a decimal column with max precision supported by Postgres and no scale,',
    () {
      final column = ColumnDefinition(
        name: 'numberOfAtoms',
        columnType: ColumnType.decimal,
        isNullable: false,
        decimalPrecision: 1000,
      );

      test(
        'when getting the SQLite column default from the abstract default value, '
        'then the value is quoted as a TEXT literal.',
        () {
          expect(
            column.getSqliteColumnDefault('10.5'),
            equals("'10.5'"),
          );
        },
      );

      test(
        'when reverting the SQLite column default to the abstract default value, '
        'then the value is the original value.',
        () {
          const abstractDefault = '10.5';
          final converted = column.getSqliteColumnDefault(abstractDefault);

          expect(
            sqliteSqlToAbstractDefault(converted, column.columnType),
            equals(abstractDefault),
          );
        },
      );
    },
  );

  group('Given a decimal column with precision inferior to 19 and no scale,', () {
    final column = ColumnDefinition(
      name: 'population',
      columnType: ColumnType.decimal,
      isNullable: false,
      decimalPrecision: 18,
    );

    test(
      'when getting the SQLite column default from the abstract default value, '
      'then the value is a scaled INTEGER with scale 0.',
      () {
        expect(
          column.getSqliteColumnDefault('10.5'),
          equals('10'),
        );
      },
    );

    test(
      'when reverting the SQLite column default to the abstract default value, '
      'then the value is the original value with scale 0.',
      () {
        const abstractDefault = '10.5';
        final converted = column.getSqliteColumnDefault(abstractDefault);

        expect(
          sqliteSqlToAbstractDefault(
            converted,
            column.columnType,
            decimalPrecision: column.decimalPrecision,
            decimalScale: column.decimalScale,
          ),
          equals('10'),
        );
      },
    );
  });

  group('Given a decimal column with precision inferior to 19 and scale,', () {
    final column = ColumnDefinition(
      name: 'price',
      columnType: ColumnType.decimal,
      isNullable: false,
      decimalPrecision: 10,
      decimalScale: 2,
    );

    test(
      'when getting the SQLite column default from the abstract default value, '
      'then the value is a scaled INTEGER with the correct scale.',
      () {
        expect(
          column.getSqliteColumnDefault('10.5'),
          equals('1050'),
        );
      },
    );

    test(
      'when reverting the SQLite column default to the abstract default value, '
      'then the value is the original value with scale 2.',
      () {
        const abstractDefault = '10.5';
        final converted = column.getSqliteColumnDefault(abstractDefault);

        expect(
          sqliteSqlToAbstractDefault(
            converted,
            column.columnType,
            decimalPrecision: column.decimalPrecision,
            decimalScale: column.decimalScale,
          ),
          equals('10.50'),
        );
      },
    );
  });
}
