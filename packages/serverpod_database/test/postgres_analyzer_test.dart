@Tags(['integration'])
library;

import 'dart:io';

import 'package:serverpod_database/serverpod_database.dart';
import 'package:serverpod_shared/serverpod_shared.dart';
import 'package:test/test.dart';

void main() {
  late Directory directory;
  late DatabasePoolManager pool;
  late _AnalyzerSession session;

  setUpAll(() async {
    directory = await Directory.systemTemp.createTemp('pg_analyzer_test_');
    pool = DatabaseProvider.forDialect(DatabaseDialect.postgres)
        .createPoolManager(
          _SerializationManager(),
          null,
          PostgresDatabaseConfig.embedded(
            dataPath: '${directory.path}/pgdata',
            name: 'analyzer_test',
          ),
        );
    await pool.started;
    session = _AnalyzerSession(pool);
  });

  tearDownAll(() async {
    await pool.stop();
    await directory.delete(recursive: true);
  });

  group('Given same-named tables in separate schemas,', () {
    setUpAll(() async {
      await session.db.unsafeSimpleExecute('''
CREATE SCHEMA first_schema;
CREATE SCHEMA second_schema;
CREATE TABLE second_schema.shared (id bigint PRIMARY KEY, external uuid);
CREATE TABLE first_schema.shared (
  id bigserial PRIMARY KEY,
  removed text,
  label text DEFAULT 'hello',
  parent bigint,
  CONSTRAINT parent_key FOREIGN KEY (parent) REFERENCES second_schema.shared(id)
    ON UPDATE CASCADE ON DELETE SET NULL DEFERRABLE INITIALLY DEFERRED
);
ALTER TABLE first_schema.shared DROP COLUMN removed;
CREATE UNIQUE INDEX label_unique ON first_schema.shared (label) NULLS NOT DISTINCT;
CREATE INDEX label_expression ON first_schema.shared (lower(label)) WHERE parent IS NOT NULL;
''');
    });

    group('when the database catalog is analyzed,', () {
      late TableDefinition first;
      late TableDefinition second;

      setUpAll(() async {
        final tables = await session.db.analyzer.getTableDefinitions();
        first = tables.singleWhere((table) => table.schema == 'first_schema');
        second = tables.singleWhere((table) => table.schema == 'second_schema');
      });

      test('then each table retains its own columns in physical order.', () {
        expect(first.columns.map((column) => column.name), [
          'id',
          'label',
          'parent',
        ]);
        expect(second.columns.map((column) => column.name), ['id', 'external']);
        expect(first.columns[1].columnType, ColumnType.text);
        expect(first.columns[1].columnDefault, "'hello'");
        expect(second.columns[1].columnType, ColumnType.uuid);
      });

      test(
        'then the cross-schema foreign key retains its actions and deferral.',
        () {
          final foreignKey = first.foreignKeys.single;

          expect(foreignKey.constraintName, 'parent_key');
          expect(foreignKey.columns, ['parent']);
          expect(foreignKey.referenceTableSchema, 'second_schema');
          expect(foreignKey.referenceTable, 'shared');
          expect(foreignKey.referenceColumns, ['id']);
          expect(foreignKey.onUpdate, ForeignKeyAction.cascade);
          expect(foreignKey.onDelete, ForeignKeyAction.setNull);
          expect(foreignKey.deferrable, DeferrableConstraint.initiallyDeferred);
          expect(second.foreignKeys, isEmpty);
        },
      );

      test('then unique and expression indexes retain their definitions.', () {
        final unique = first.indexes.singleWhere(
          (index) => index.indexName == 'label_unique',
        );
        final expression = first.indexes.singleWhere(
          (index) => index.indexName == 'label_expression',
        );

        expect(first.indexes, hasLength(2));
        expect(unique.isUnique, isTrue);
        expect(unique.nullsDistinct, isFalse);
        expect(unique.elements.single.definition, 'label');
        expect(
          expression.elements.single.type,
          IndexElementDefinitionType.expression,
        );
        expect(expression.elements.single.definition, 'lower(label)');
        expect(expression.predicate, '(parent IS NOT NULL)');
        expect(second.indexes, isEmpty);
      });
    });

    test(
      'when one table is inspected directly, '
      'then its metadata matches the complete analysis.',
      () async {
        final table = (await session.db.analyzer.getTableDefinitions())
            .singleWhere((table) => table.schema == 'first_schema');

        final columns = await session.db.analyzer.getColumnDefinitions(
          schemaName: 'first_schema',
          tableName: 'shared',
        );
        final keys = await session.db.analyzer.getForeignKeyDefinitions(
          schemaName: 'first_schema',
          tableName: 'shared',
        );
        final indexes = await session.db.analyzer.getIndexDefinitions(
          schemaName: 'first_schema',
          tableName: 'shared',
        );

        expect(
          columns.map((column) => column.toJson()),
          table.columns.map((column) => column.toJson()),
        );
        expect(
          keys.map((key) => key.toJson()),
          table.foreignKeys.map((key) => key.toJson()),
        );
        expect(
          indexes.map((index) => index.toJson()),
          unorderedEquals(table.indexes.map((index) => index.toJson())),
        );
      },
    );
  });

  group('Given schema and table names containing SQL punctuation,', () {
    const schemaName = "schema'quoted";
    const tableName = "table'; SELECT 1; --";

    setUpAll(() async {
      await session.db.unsafeSimpleExecute('''
CREATE SCHEMA "schema'quoted";
CREATE TABLE "schema'quoted"."table'; SELECT 1; --" (
  id bigint PRIMARY KEY,
  parent bigint REFERENCES "schema'quoted"."table'; SELECT 1; --"(id)
);
CREATE INDEX quoted_parent ON "schema'quoted"."table'; SELECT 1; --" (parent);
''');
    });

    test(
      'when the table is inspected directly, '
      'then names are treated as catalog values.',
      () async {
        final columns = await session.db.analyzer.getColumnDefinitions(
          schemaName: schemaName,
          tableName: tableName,
        );
        final keys = await session.db.analyzer.getForeignKeyDefinitions(
          schemaName: schemaName,
          tableName: tableName,
        );
        final indexes = await session.db.analyzer.getIndexDefinitions(
          schemaName: schemaName,
          tableName: tableName,
        );

        expect(columns.map((column) => column.name), ['id', 'parent']);
        expect(keys.single.referenceTable, tableName);
        expect(keys.single.referenceTableSchema, schemaName);
        expect(indexes.single.indexName, 'quoted_parent');
      },
    );

    test(
      'when all tables are analyzed, '
      'then the quoted table is included with its metadata.',
      () async {
        final tables = await session.db.analyzer.getTableDefinitions();
        final table = tables.singleWhere((table) => table.schema == schemaName);

        expect(table.name, tableName);
        expect(table.columns.map((column) => column.name), ['id', 'parent']);
        expect(table.foreignKeys.single.referenceTable, tableName);
        expect(table.indexes.single.indexName, 'quoted_parent');
      },
    );
  });

  group('Given a role with access to only one column,', () {
    setUpAll(() async {
      await session.db.unsafeSimpleExecute('''
CREATE SCHEMA restricted_schema;
CREATE TABLE restricted_schema.visible (id bigint, secret text);
CREATE ROLE analyzer_reader;
GRANT USAGE ON SCHEMA restricted_schema TO analyzer_reader;
GRANT SELECT (id) ON restricted_schema.visible TO analyzer_reader;
''');
    });

    test(
      'when that role analyzes tables, '
      'then inaccessible columns remain hidden.',
      () async {
        final table = await session.db.transaction((transaction) async {
          final restricted = _AnalyzerSession(pool, transaction: transaction);
          await restricted.db.unsafeExecute('SET LOCAL ROLE analyzer_reader');
          final tables = await restricted.db.analyzer.getTableDefinitions();
          return tables.singleWhere(
            (table) => table.schema == 'restricted_schema',
          );
        });

        expect(table.columns.map((column) => column.name), ['id']);
      },
    );
  });

  group('Given a PostGIS extension and an ordinary table,', () {
    setUpAll(() async {
      await session.db.unsafeSimpleExecute('''
CREATE EXTENSION postgis;
CREATE TABLE geographic_data (id bigint, point geography(Point,4326));
''');
    });

    test(
      'when the database is analyzed, '
      'then extension-owned tables are excluded and geography types are retained.',
      () async {
        final tables = await session.db.analyzer.getTableDefinitions();
        final geographic = tables.singleWhere(
          (table) => table.name == 'geographic_data',
        );

        expect(tables.any((table) => table.name == 'spatial_ref_sys'), isFalse);
        expect(geographic.columns.last.columnType, ColumnType.geography);
      },
    );
  });
}

class _AnalyzerSession implements DatabaseSession {
  @override
  late final Database db;

  @override
  final Transaction? transaction;

  _AnalyzerSession(DatabasePoolManager pool, {this.transaction}) {
    db = DatabaseConstructor.create(session: this, poolManager: pool);
  }

  @override
  LogQueryFunction? get logQuery => null;

  @override
  LogWarningFunction? get logWarning => null;
}

class _SerializationManager extends DatabaseSerializationManager {
  @override
  String getModuleName() => 'analyzer_test';

  @override
  Table? getTableForType(Type type) => null;

  @override
  List<TableDefinition> getTargetTableDefinitions() => [];
}
