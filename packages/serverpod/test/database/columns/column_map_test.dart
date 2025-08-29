import 'package:serverpod/database.dart';
import 'package:test/test.dart';

void main() {
  group('Given a ColumnMap', () {
    var columnName = 'metadata';
    var column =
        ColumnMap<String, int>(columnName, Table<int?>(tableName: 'test'));

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
      expect(column, isA<ColumnSerializable<Map<String, int>>>());
    });
  });

  group('Given a ColumnMap with different key-value types', () {
    var columnName = 'settings';
    var column =
        ColumnMap<int, String>(columnName, Table<int?>(tableName: 'test'));

    test('when created then it has correct generic type.', () {
      expect(column, isA<ColumnMap<int, String>>());
      expect(column, isA<ColumnSerializable<Map<int, String>>>());
    });

    test(
        'when toString is called then column name within double quotes is returned.',
        () {
      expect(column.toString(), '"test"."$columnName"');
    });
  });

  group('Given a ColumnMap with hasDefault true', () {
    var columnName = 'defaultMetadata';
    var column = ColumnMap<String, int>(
      columnName,
      Table<int?>(tableName: 'test'),
      hasDefault: true,
    );

    test('when hasDefault is accessed then true is returned.', () {
      expect(column.hasDefault, isTrue);
    });
  });
}
