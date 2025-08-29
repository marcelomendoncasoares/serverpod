import 'package:serverpod/database.dart';
import 'package:test/test.dart';

void main() {
  group('Given a ColumnIterable', () {
    var columnName = 'sequence';
    var column =
        ColumnIterable<String>(columnName, Table<int?>(tableName: 'test'));

    test(
        'when toString is called then column name within double quotes is returned.',
        () {
      expect(column.toString(), '"test"."$columnName"');
    });

    test('when columnName getter is called then column name is returned.', () {
      expect(column.columnName, columnName);
    });

    test('when type is called then String is returned.', () {
      expect(column.type, String);
    });

    test('when created then it extends ColumnSerializable.', () {
      expect(column, isA<ColumnSerializable<Iterable<String>>>());
    });
  });

  group('Given a ColumnIterable with int elements', () {
    var columnName = 'values';
    var column =
        ColumnIterable<int>(columnName, Table<int?>(tableName: 'test'));

    test('when created then it has correct generic type.', () {
      expect(column, isA<ColumnIterable<int>>());
      expect(column, isA<ColumnSerializable<Iterable<int>>>());
    });

    test(
        'when toString is called then column name within double quotes is returned.',
        () {
      expect(column.toString(), '"test"."$columnName"');
    });
  });

  group('Given a ColumnIterable with hasDefault true', () {
    var columnName = 'defaultSequence';
    var column = ColumnIterable<String>(
      columnName,
      Table<int?>(tableName: 'test'),
      hasDefault: true,
    );

    test('when hasDefault is accessed then true is returned.', () {
      expect(column.hasDefault, isTrue);
    });
  });
}
