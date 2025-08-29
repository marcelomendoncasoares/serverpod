import 'package:serverpod/database.dart';
import 'package:test/test.dart';

void main() {
  group('Given a ColumnRecord', () {
    var columnName = 'recordData';
    var column = ColumnRecord(columnName, Table<int?>(tableName: 'test'));

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
      expect(column, isA<ColumnSerializable<Record>>());
    });
  });

  group('Given a ColumnRecord with hasDefault true', () {
    var columnName = 'defaultRecord';
    var column = ColumnRecord(
      columnName,
      Table<int?>(tableName: 'test'),
      hasDefault: true,
    );

    test('when hasDefault is accessed then true is returned.', () {
      expect(column.hasDefault, isTrue);
    });

    test(
        'when toString is called then column name within double quotes is returned.',
        () {
      expect(column.toString(), '"test"."$columnName"');
    });
  });

  group('Given a ColumnRecord with different table', () {
    var columnName = 'userRecord';
    var column = ColumnRecord(columnName, Table<int?>(tableName: 'users'));

    test(
        'when toString is called then correct table and column name is returned.',
        () {
      expect(column.toString(), '"users"."$columnName"');
    });

    test('when created then it has correct type.', () {
      expect(column, isA<ColumnRecord>());
      expect(column, isA<ColumnSerializable<Record>>());
    });
  });
}
