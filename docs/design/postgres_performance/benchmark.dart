// Run from the repository root with its resolved package configuration.
// ignore_for_file: implementation_imports, invalid_use_of_internal_member

import 'dart:convert';
import 'dart:io';

import 'package:serverpod_database/serverpod_database.dart' hide Protocol;
import 'package:serverpod_database/src/adapters/postgres/postgres_pool_manager.dart';
import 'package:serverpod_database/src/adapters/postgres/sql_query_builder.dart';
import 'package:serverpod_shared/serverpod_shared.dart';
import 'package:serverpod_test_server/src/generated/protocol.dart';

class BenchmarkSession implements DatabaseSession {
  @override
  late Database db;

  @override
  Transaction? get transaction => null;

  @override
  LogQueryFunction? logQuery;

  @override
  LogWarningFunction? get logWarning => null;
}

Future<void> measure(
  String name,
  Future<void> Function() action, {
  Future<void> Function()? setup,
}) async {
  final samples = <double>[];

  for (var i = -5; i < 11; i++) {
    await setup?.call();
    final watch = Stopwatch()..start();
    await action();
    watch.stop();

    if (i >= 0) samples.add(watch.elapsedMicroseconds / 1000);
  }

  final sorted = samples.toList()..sort();
  print(
    jsonEncode({
      'case': name,
      'median_ms': sorted[sorted.length ~/ 2],
      'samples_ms': samples,
    }),
  );
}

Future<void> main(List<String> arguments) async {
  if (arguments.length != 1 ||
      !{'builder', 'rows', 'logging', 'catalog'}.contains(arguments.single)) {
    throw ArgumentError('Choose one workload: builder, rows, logging, catalog');
  }

  bool run(String name) => arguments.single == name;

  final directory = await Directory.systemTemp.createTemp('sp_pg_perf_');
  final pool = PostgresPoolManager(
    Protocol(),
    null,
    PostgresDatabaseConfig.embedded(
      dataPath: '${directory.path}/pgdata',
      name: 'performance',
    ),
  );
  final session = BenchmarkSession();
  session.db = DatabaseConstructor.create(session: session, poolManager: pool);

  try {
    await pool.started;
    print(
      jsonEncode({
        'dart': Platform.version,
        'postgres': (await session.db.unsafeQuery(
          'SELECT version()',
        )).first.first,
      }),
    );

    await session.db.unsafeSimpleExecute('''
CREATE TABLE simple_data (id bigint PRIMARY KEY, num bigint NOT NULL);
CREATE TABLE city (id bigint PRIMARY KEY, name text NOT NULL);
CREATE TABLE organization (
  id bigserial PRIMARY KEY,
  name text NOT NULL,
  "cityId" bigint REFERENCES city(id)
);
CREATE TABLE person (
  id bigint PRIMARY KEY,
  name text NOT NULL,
  "organizationId" bigint REFERENCES organization(id),
  "_cityCitizensCityId" bigint REFERENCES city(id)
);
INSERT INTO simple_data SELECT i, i FROM generate_series(1, 10000) AS i;
INSERT INTO city VALUES (1, 'city');
INSERT INTO organization SELECT i, 'organization ' || i, 1
FROM generate_series(1, 10000) AS i;
INSERT INTO person SELECT i, 'person ' || i, i, 1
FROM generate_series(1, 10000) AS i;
''');

    if (run('builder')) {
      await session.db.unsafeExecute('DELETE FROM person');

      final wideRows = List.generate(
        1000,
        (i) => Organization(id: i + 1, name: "value ' \\ ${'x' * 4096}"),
      );
      final mixedRows = [
        for (var i = 0; i < wideRows.length; i++)
          wideRows[i].copyWith(id: i.isEven ? i + 1 : null),
      ];

      for (final entry in {'uniform': wideRows, 'mixed': mixedRows}.entries) {
        await measure('build_${entry.key}_1000_wide', () async {
          final sql = InsertQueryBuilder(
            table: Organization.t,
            rows: entry.value,
            noReturn: true,
          ).build();

          if (!sql.contains('INSERT INTO') || sql.length < 4000000) {
            throw StateError('Incomplete insert SQL');
          }
        });
      }

      await measure(
        'insert_1000_wide_noReturn',
        () async {
          final result = await session.db.insert(wideRows, noReturn: true);
          if (result.isNotEmpty) throw StateError('Unexpected returning rows');
        },
        setup: () => session.db.unsafeExecute('DELETE FROM organization'),
      );

      final stored = await session.db.find<Organization>(
        orderBy: Organization.t.id,
      );
      if (stored.length != 1000 || stored.last.name != wideRows.last.name) {
        throw StateError('Insert values did not round trip');
      }
    }

    if (run('rows')) {
      await measure('find_10000', () async {
        final rows = await session.db.find<SimpleData>(
          orderBy: SimpleData.t.id,
        );
        if (rows.length != 10000 || rows.last.num != 10000) {
          throw StateError('Incorrect read');
        }
      });

      await measure('include_10000_parents_children', () async {
        final rows = await session.db.find<Organization>(
          orderBy: Organization.t.id,
          include: Organization.include(
            city: City.include(),
            people: Person.includeList(),
          ),
        );

        if (rows.length != 10000 ||
            rows.last.people!.single.id != 10000 ||
            rows.first.city!.name != 'city') {
          throw StateError('Incorrect include');
        }
      });

      final rows = List.generate(10000, (i) => SimpleData(id: i + 1, num: i));
      await measure('update_10000_returning', () async {
        final result = await session.db.update(rows);
        if (result.length != 10000) throw StateError('Incorrect update count');
      });
    }

    if (run('logging')) {
      for (final enabled in [false, true]) {
        var queries = 0;
        session.logQuery = enabled
            ? ({
                required query,
                required duration,
                required numRowsAffected,
                required error,
                required stackTrace,
              }) {
                queries++;
              }
            : null;

        await measure('select_1000_logging_$enabled', () async {
          for (var i = 0; i < 1000; i++) {
            final row = await session.db.findById<SimpleData>(i + 1);
            if (row == null) throw StateError('Missing row');
          }
        });

        if (enabled && queries != 16000) throw StateError('Missing query logs');
      }

      session.logQuery = null;
    }

    if (run('catalog')) {
      for (var i = 0; i < 100; i++) {
        await session.db.unsafeSimpleExecute('''
CREATE TABLE catalog_$i (
  id bigserial PRIMARY KEY,
  name text DEFAULT 'hello',
  parent bigint REFERENCES simple_data(id),
  amount double precision NOT NULL DEFAULT 1.5
);
CREATE INDEX catalog_${i}_name_idx ON catalog_$i (name);
''');
      }

      var queryCount = 0;
      session.logQuery =
          ({
            required query,
            required duration,
            required numRowsAffected,
            required error,
            required stackTrace,
          }) {
            queryCount++;
          };

      await measure('analyze_104_tables', () async {
        queryCount = 0;
        final tables = await session.db.analyzer.getTableDefinitions();
        final catalog = tables.where(
          (table) => table.name.startsWith('catalog_'),
        );
        if (tables.length != 104 ||
            catalog.length != 100 ||
            catalog.any(
              (table) =>
                  table.columns.length != 4 ||
                  table.foreignKeys.length != 1 ||
                  table.indexes.length != 1,
            )) {
          throw StateError('Incorrect catalog');
        }
      });

      print(jsonEncode({'catalog_queries': queryCount}));
    }
  } finally {
    await pool.stop();
    await directory.delete(recursive: true);
  }
}
