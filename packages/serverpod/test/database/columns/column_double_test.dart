import 'package:serverpod/database.dart';
import 'package:test/test.dart';

void main() {
  group('Given a ColumnDouble', () {
    var columnName = 'age';
    var column = ColumnDouble(columnName, Table<int?>(tableName: 'test'));

    test(
        'when toString is called then column name withing double quotes is returned.',
        () {
      expect(column.toString(), '"test"."$columnName"');
    });

    test('when columnName getter is called then column name is returned.', () {
      expect(column.columnName, columnName);
    });

    test('when type is called then double is returned.', () {
      expect(column.type, double);
    });

    group('with _ColumnDefaultOperations mixin', () {
      test(
          'when equals compared to NULL value then output is IS NULL expression.',
          () {
        var comparisonExpression = column.equals(null);

        expect(comparisonExpression.toString(), '$column IS NULL');
      });

      test(
          'when equals compared to double value then output is equals expression.',
          () {
        var comparisonExpression = column.equals(10.0);

        expect(comparisonExpression.toString(), '$column = 10.0');
      });

      test(
          'when NOT equals compared to NULL value then output is IS NOT NULL expression.',
          () {
        var comparisonExpression = column.notEquals(null);

        expect(comparisonExpression.toString(), '$column IS NOT NULL');
      });

      test(
          'when NOT equals compared to double value then output is NOT equals expression.',
          () {
        var comparisonExpression = column.notEquals(10.0);

        expect(
            comparisonExpression.toString(), '$column IS DISTINCT FROM 10.0');
      });

      test(
          'when checking if expression is between double values then output is between expression.',
          () {
        var comparisonExpression = column.between(10.0, 20.0);

        expect(
            comparisonExpression.toString(), '$column BETWEEN 10.0 AND 20.0');
      });

      test(
          'when checking if expression is NOT between double value then output is NOT between expression.',
          () {
        var comparisonExpression = column.notBetween(10.0, 20.0);

        expect(comparisonExpression.toString(),
            '$column NOT BETWEEN 10.0 AND 20.0');
      });

      test(
          'when checking if expression is in value set then output is IN expression.',
          () {
        var comparisonExpression = column.inSet(<double>{10.0, 11.0, 12.0});

        expect(
            comparisonExpression.toString(), '$column IN (10.0, 11.0, 12.0)');
      });

      test(
          'when checking if expression is in empty value set then output is FALSE expression.',
          () {
        var comparisonExpression = column.inSet(<double>{});

        expect(comparisonExpression.toString(), 'FALSE');
      });

      test(
          'when checking if expression is NOT in value set then output is NOT IN expression.',
          () {
        var comparisonExpression = column.notInSet(<double>{10.0, 11.0, 12.0});

        expect(comparisonExpression.toString(),
            '($column NOT IN (10.0, 11.0, 12.0) OR $column IS NULL)');
      });

      test(
          'when checking if expression is NOT in empty value set then output is TRUE expression.',
          () {
        var comparisonExpression = column.notInSet(<double>{});

        expect(comparisonExpression.toString(), 'TRUE');
      });
    });

    group('with _ColumnNumberOperations mixin', () {
      test(
          'when checking if expression is between double values then output is between expression.',
          () {
        var comparisonExpression = column.between(10.0, 20.0);

        expect(
            comparisonExpression.toString(), '$column BETWEEN 10.0 AND 20.0');
      });

      test(
          'when checking if expression is NOT between int values then output is NOT between expression.',
          () {
        var comparisonExpression = column.notBetween(10.0, 20.0);

        expect(comparisonExpression.toString(),
            '$column NOT BETWEEN 10.0 AND 20.0');
      });
      test(
          'when greater than compared to expression then output is operator expression.',
          () {
        var comparisonExpression = column > const Expression('10');

        expect(comparisonExpression.toString(), '$column > 10');
      });

      test(
          'when greater than compared to column type then output is operator expression.',
          () {
        var comparisonExpression = column > 10.0;

        expect(comparisonExpression.toString(), '$column > 10.0');
      });

      test(
          'when greater than compared to column then output is operator expression.',
          () {
        var comparisonExpression = column > column;

        expect(comparisonExpression.toString(), '$column > $column');
      });

      test(
          'when greater than compared to unhandled type then argument error is thrown.',
          () {
        expect(
          () => column > 'string is unhandled',
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              'Invalid type for comparison: String, allowed types are Expression, double or Column',
            ),
          ),
        );
      });

      test(
          'when greater or equal than compared to expression then output is operator expression.',
          () {
        var comparisonExpression = column >= const Expression('10');

        expect(comparisonExpression.toString(), '$column >= 10');
      });

      test(
          'when greater or equal than compared to column type then output is operator expression.',
          () {
        var comparisonExpression = column >= 10.0;

        expect(comparisonExpression.toString(), '$column >= 10.0');
      });

      test(
          'when greater or equal than compared to column then output is operator expression.',
          () {
        var comparisonExpression = column >= column;

        expect(comparisonExpression.toString(), '$column >= $column');
      });

      test(
          'when greater or equal than compared to unhandled type then argument error is thrown.',
          () {
        expect(
          () => column >= 'string is unhandled',
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              'Invalid type for comparison: String, allowed types are Expression, double or Column',
            ),
          ),
        );
      });

      test(
          'when less than compared to expression then output is operator expression.',
          () {
        var comparisonExpression = column < const Expression('10');

        expect(comparisonExpression.toString(), '$column < 10');
      });

      test(
          'when less than compared to column type then output is operator expression.',
          () {
        var comparisonExpression = column < 10.0;

        expect(comparisonExpression.toString(), '$column < 10.0');
      });

      test(
          'when less than compared to column then output is operator expression.',
          () {
        var comparisonExpression = column < column;

        expect(comparisonExpression.toString(), '$column < $column');
      });

      test(
          'when less than compared to unhandled type then argument error is thrown.',
          () {
        expect(
          () => column < 'string is unhandled',
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              'Invalid type for comparison: String, allowed types are Expression, double or Column',
            ),
          ),
        );
      });

      test(
          'when less or equal than compared to expression then output is operator expression.',
          () {
        var comparisonExpression = column <= const Expression('10');

        expect(comparisonExpression.toString(), '$column <= 10');
      });

      test(
          'when less or equal than compared to column type then output is operator expression.',
          () {
        var comparisonExpression = column <= 10.0;

        expect(comparisonExpression.toString(), '$column <= 10.0');
      });

      test(
          'when less or equal than compared to column then output is operator expression.',
          () {
        var comparisonExpression = column <= column;

        expect(comparisonExpression.toString(), '$column <= $column');
      });

      test(
          'when less or equal than compared to unhandled type then argument error is thrown.',
          () {
        expect(
          () => column <= 'string is unhandled',
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              'Invalid type for comparison: String, allowed types are Expression, double or Column',
            ),
          ),
        );
      });
    });
  });
}
