import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:serverpod_test_sqlite_client/serverpod_test_sqlite_client.dart';

// Run from the workspace root with its resolved package configuration:
// dart --packages=.dart_tool/package_config.json -Ddart.vm.product=true \
//   docs/design/sqlite_performance/returning_writes/orm_benchmark.dart <label>
Future<void> main(List<String> arguments) async {
  final directory = await Directory.systemTemp.createTemp('sqlite_orm_batch_');
  final session = await Client('http://localhost:8080/').createSession(
    '${directory.path}/database',
  );
  final results = <String, Object?>{};
  final rows = [
    for (var index = 0; index < 1000; index++)
      SimpleData(id: index + 1, num: index),
  ];

  Future<void> measure(
    String name,
    Future<List<SimpleData>> Function() operation, {
    Future<void> Function()? setup,
    required bool returnsRows,
  }) async {
    final samples = <double>[];
    for (var index = -5; index < 7; index++) {
      await setup?.call();
      final stopwatch = Stopwatch()..start();
      final returned = await operation();
      stopwatch.stop();

      if (returnsRows) {
        if (returned.length != rows.length) throw StateError('Wrong row count');
        for (var row = 0; row < rows.length; row++) {
          if (returned[row].id != rows[row].id ||
              returned[row].num != rows[row].num) {
            throw StateError('Wrong returned row at $row');
          }
        }
      } else if (returned.isNotEmpty) {
        throw StateError('noReturn returned rows');
      }
      if (index >= 0) samples.add(stopwatch.elapsedMicroseconds / 1000);
    }
    final stored = await SimpleData.db.find(
      session,
      orderBy: (table) => table.id,
    );
    if (stored.length != rows.length || stored.last.num != rows.last.num) {
      throw StateError('Wrong stored values');
    }
    final sorted = [...samples]..sort();
    results[name] = {'median_ms': sorted[3], 'samples_ms': samples};
  }

  try {
    Future<void> clear() => session.db.unsafeExecute('DELETE FROM simple_data');

    await measure(
      'insert_1000_returning',
      () => SimpleData.db.insert(session, rows),
      setup: clear,
      returnsRows: true,
    );
    await measure(
      'update_1000_returning',
      () => SimpleData.db.update(session, rows),
      returnsRows: true,
    );
    await measure(
      'upsert_1000_returning',
      () => SimpleData.db.upsert(
        session,
        rows,
        conflictColumns: (table) => [table.id],
      ),
      returnsRows: true,
    );
    await measure(
      'insert_1000_no_return',
      () => SimpleData.db.insert(session, rows, noReturn: true),
      setup: clear,
      returnsRows: false,
    );
    await measure(
      'update_1000_no_return',
      () => SimpleData.db.update(session, rows, noReturn: true),
      returnsRows: false,
    );

    final wide = [
      for (var index = 0; index < 1000; index++)
        Types(
          id: index + 1,
          aString: List.filled(4096, 'x').join(),
          aList: [for (var value = 0; value < 100; value++) value],
        ),
    ];
    final samples = <double>[];
    for (var index = -5; index < 7; index++) {
      final stopwatch = Stopwatch()..start();
      final returned = await Types.db.upsert(
        session,
        wide,
        conflictColumns: (table) => [table.id],
        noReturn: true,
      );
      stopwatch.stop();
      if (returned.isNotEmpty) throw StateError('noReturn returned rows');
      if (index >= 0) samples.add(stopwatch.elapsedMicroseconds / 1000);
    }
    if (await Types.db.count(session) != 1000) throw StateError('Wrong count');
    final sorted = [...samples]..sort();
    results['upsert_wide_1000_no_return'] = {
      'median_ms': sorted[3],
      'samples_ms': samples,
    };
    final version = await session.db.unsafeQuery('SELECT sqlite_version()');
    final adapterSource = await Isolate.resolvePackageUri(
      Uri.parse(
        'package:serverpod_database/src/adapters/sqlite/database_connection.dart',
      ),
    );
    stdout.writeln(
      const JsonEncoder.withIndent('  ').convert({
        'label': arguments.singleOrNull ?? 'current',
        'adapter_source': adapterSource.toString(),
        'dart': Platform.version,
        'sqlite': version.single.single,
        'rows': rows.length,
        'warmup': 5,
        'samples': 7,
        'results': results,
      }),
    );
  } finally {
    await session.close();
    await directory.delete(recursive: true);
  }
}
