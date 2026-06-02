import 'package:serverpod_database/src/adapters/postgres/value_encoder.dart';
import 'package:serverpod_database/src/concepts/columns.dart';
import 'package:serverpod_database/src/concepts/expressions.dart';
import 'package:serverpod_database/src/concepts/table.dart';
import 'package:serverpod_database/src/interface/value_encoder.dart';
import 'package:test/test.dart';

void main() {
  ValueEncoder.set(const PostgresValueEncoder());

  final testTable = Table<int?>(tableName: 'test');

  test(
    'Given a searched CASE expression with multiple branches, '
    'when the expression is converted to SQL, '
    'then the CASE expression contains each condition and encoded result.',
    () {
      final age = ColumnInt('age', testTable);

      final expression = Case()
          .when(age > 18, then: Constant.string('adult'))
          .when(age > 12, then: Constant.string('teenager'))
          .orElse(Constant.string('child'));

      expect(
        expression.toString(),
        'CASE WHEN "test"."age" > 18 THEN \'adult\' '
        'WHEN "test"."age" > 12 THEN \'teenager\' ELSE \'child\' END',
      );
    },
  );

  test(
    'Given a simple CASE expression with a column and a null fallback, '
    'when the expression is converted to SQL, '
    'then the CASE expression contains the column and encoded values.',
    () {
      final status = ColumnString('status', testTable);

      final expression = Case(status)
          .when(Constant.string('active'), then: Constant.bool(true))
          .when(Constant.string('inactive'), then: Constant.bool(false))
          .orElse(Constant.nullValue);

      expect(
        expression.toString(),
        'CASE "test"."status" WHEN \'active\' THEN TRUE '
        'WHEN \'inactive\' THEN FALSE ELSE NULL END',
      );
    },
  );

  test(
    'Given a searched CASE expression with condition columns, '
    'when referenced columns are retrieved, '
    'then only the condition columns are returned in SQL order.',
    () {
      final isActive = ColumnBool('isActive', testTable);
      final age = ColumnInt('age', testTable);

      final expression = Case()
          .when(isActive.equals(true), then: Constant.string('active'))
          .when(age > 18, then: Constant.string('adult'))
          .orElse(Constant.string('other'));

      expect(
        expression.columns,
        [isActive, age],
      );
    },
  );

  test(
    'Given a searched CASE expression with multiple nested branches, '
    'when expressions are traversed depth first, '
    'then each condition and result is returned in SQL order.',
    () {
      const firstWhen = Expression('first condition');
      const firstThen = Expression('first result');
      const secondWhen = Expression('second condition');
      const secondThen = Expression('second result');
      const orElse = Expression('fallback');

      final expression = Case()
          .when(firstWhen, then: firstThen)
          .when(secondWhen, then: secondThen)
          .orElse(orElse);

      expect(
        expression.depthFirst,
        [
          expression,
          firstWhen,
          firstThen,
          secondWhen,
          secondThen,
          orElse,
        ],
      );
    },
  );

  test(
    'Given a CASE expression with a selector and condition column, '
    'when referenced columns are retrieved, '
    'then the columns are returned in SQL order.',
    () {
      final selector = ColumnString('selector', testTable);
      final condition = ColumnBool('condition', testTable);

      final expression = Case(selector)
          .when(condition.equals(true), then: Constant.string('yes'))
          .orElse(Constant.string('no'));

      expect(
        expression.columns,
        [selector, condition],
      );
    },
  );

  test(
    'Given a CASE expression with nested expressions, '
    'when expressions are traversed depth first, '
    'then the CASE expression and nested expressions are returned in SQL order.',
    () {
      const when = Expression('condition');
      const then = Expression('result');
      const orElse = Expression('fallback');

      final expression = Case().when(when, then: then).orElse(orElse);

      expect(expression.depthFirst, [expression, when, then, orElse]);
    },
  );
}
