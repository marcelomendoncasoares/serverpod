import 'package:serverpod_cli/src/generator/types.dart';
import 'package:test/test.dart';

void main() {
  group('Given TypeDefinition columnType method', () {
    test('when className is List then ColumnList is returned.', () {
      var type = TypeDefinition(
        className: 'List',
        nullable: false,
        generics: [
          TypeDefinition(className: 'String', nullable: false),
        ],
      );

      expect(type.columnType, 'ColumnList');
    });

    test('when className is Set then ColumnSet is returned.', () {
      var type = TypeDefinition(
        className: 'Set',
        nullable: false,
        generics: [
          TypeDefinition(className: 'int', nullable: false),
        ],
      );

      expect(type.columnType, 'ColumnSet');
    });

    test('when className is Map then ColumnMap is returned.', () {
      var type = TypeDefinition(
        className: 'Map',
        nullable: false,
        generics: [
          TypeDefinition(className: 'String', nullable: false),
          TypeDefinition(className: 'int', nullable: false),
        ],
      );

      expect(type.columnType, 'ColumnMap');
    });

    test('when className is Iterable then ColumnIterable is returned.', () {
      var type = TypeDefinition(
        className: 'Iterable',
        nullable: false,
        generics: [
          TypeDefinition(className: 'String', nullable: false),
        ],
      );

      expect(type.columnType, 'ColumnIterable');
    });

    test('when isRecordType is true then ColumnRecord is returned.', () {
      var type = TypeDefinition(
        className: '_Record',
        nullable: false,
      );

      expect(type.columnType, 'ColumnRecord');
    });

    test(
        'when className is a custom class then ColumnSerializable is returned.',
        () {
      var type = TypeDefinition(
        className: 'CustomClass',
        nullable: false,
      );

      expect(type.columnType, 'ColumnSerializable');
    });

    test('when className is int then ColumnInt is returned.', () {
      var type = TypeDefinition(
        className: 'int',
        nullable: false,
      );

      expect(type.columnType, 'ColumnInt');
    });

    test('when className is String then ColumnString is returned.', () {
      var type = TypeDefinition(
        className: 'String',
        nullable: false,
      );

      expect(type.columnType, 'ColumnString');
    });

    test('when className is Vector then ColumnVector is returned.', () {
      var type = TypeDefinition(
        className: 'Vector',
        nullable: false,
        vectorDimension: 512,
      );

      expect(type.columnType, 'ColumnVector');
    });
  });
}
