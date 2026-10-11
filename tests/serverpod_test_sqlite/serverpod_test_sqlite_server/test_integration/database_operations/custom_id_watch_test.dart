import 'dart:async';

import 'package:serverpod/serverpod.dart';
import 'package:serverpod_test_sqlite_server/src/generated/protocol.dart';
import 'package:test/test.dart';

import '../test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod(
    'Custom primary key watches',
    rollbackDatabase: RollbackDatabase.disabled,
    (sessionBuilder, endpoints) {
      late Session session;

      setUp(() {
        session = sessionBuilder.build();
      });

      test(
        'Given an empty table with caller-supplied String IDs, '
        'when watching while inserting, updating and deleting a row, '
        'then each committed change emits the current rows.',
        () async {
          final row = StringIdModel(id: 'watched', value: 'inserted');
          final iterator = StreamIterator(StringIdModel.db.watch(session));
          addTearDown(iterator.cancel);
          final snapshots = <List<String>>[];

          await iterator.moveNext().timeout(const Duration(seconds: 5));
          snapshots.add(iterator.current.map((row) => row.value).toList());
          final inserted = await StringIdModel.db.insertRow(session, row);
          await iterator.moveNext().timeout(const Duration(seconds: 5));
          snapshots.add(iterator.current.map((row) => row.value).toList());
          await StringIdModel.db.updateRow(
            session,
            inserted.copyWith(value: 'updated'),
          );
          await iterator.moveNext().timeout(const Duration(seconds: 5));
          snapshots.add(iterator.current.map((row) => row.value).toList());
          await StringIdModel.db.deleteRow(session, inserted);
          await iterator.moveNext().timeout(const Duration(seconds: 5));
          snapshots.add(iterator.current.map((row) => row.value).toList());

          expect(snapshots, [
            <String>[],
            ['inserted'],
            ['updated'],
            <String>[],
          ]);
        },
      );

      test(
        'Given an empty table with caller-supplied DateTime IDs, '
        'when watching while inserting, updating and deleting a row, '
        'then each committed change emits the current rows.',
        () async {
          final row = DateTimeIdModel(
            id: DateTime.utc(2026, 1, 2),
            value: 'inserted',
          );
          final iterator = StreamIterator(DateTimeIdModel.db.watch(session));
          addTearDown(iterator.cancel);
          final snapshots = <List<String>>[];

          await iterator.moveNext().timeout(const Duration(seconds: 5));
          snapshots.add(iterator.current.map((row) => row.value).toList());
          final inserted = await DateTimeIdModel.db.insertRow(session, row);
          await iterator.moveNext().timeout(const Duration(seconds: 5));
          snapshots.add(iterator.current.map((row) => row.value).toList());
          await DateTimeIdModel.db.updateRow(
            session,
            inserted.copyWith(value: 'updated'),
          );
          await iterator.moveNext().timeout(const Duration(seconds: 5));
          snapshots.add(iterator.current.map((row) => row.value).toList());
          await DateTimeIdModel.db.deleteRow(session, inserted);
          await iterator.moveNext().timeout(const Duration(seconds: 5));
          snapshots.add(iterator.current.map((row) => row.value).toList());

          expect(snapshots, [
            <String>[],
            ['inserted'],
            ['updated'],
            <String>[],
          ]);
        },
      );

      test(
        'Given an empty table with caller-supplied Duration IDs, '
        'when watching while inserting, updating and deleting a row, '
        'then each committed change emits the current rows.',
        () async {
          final row = DurationIdModel(
            id: const Duration(milliseconds: -1234),
            value: 'inserted',
          );
          final iterator = StreamIterator(DurationIdModel.db.watch(session));
          addTearDown(iterator.cancel);
          final snapshots = <List<String>>[];

          await iterator.moveNext().timeout(const Duration(seconds: 5));
          snapshots.add(iterator.current.map((row) => row.value).toList());
          final inserted = await DurationIdModel.db.insertRow(session, row);
          await iterator.moveNext().timeout(const Duration(seconds: 5));
          snapshots.add(iterator.current.map((row) => row.value).toList());
          await DurationIdModel.db.updateRow(
            session,
            inserted.copyWith(value: 'updated'),
          );
          await iterator.moveNext().timeout(const Duration(seconds: 5));
          snapshots.add(iterator.current.map((row) => row.value).toList());
          await DurationIdModel.db.deleteRow(session, inserted);
          await iterator.moveNext().timeout(const Duration(seconds: 5));
          snapshots.add(iterator.current.map((row) => row.value).toList());

          expect(snapshots, [
            <String>[],
            ['inserted'],
            ['updated'],
            <String>[],
          ]);
        },
      );

      test(
        'Given an empty table with caller-supplied integer IDs, '
        'when watching while inserting, updating and deleting a row, '
        'then each committed change emits the current rows.',
        () async {
          final row = IntIdModel(id: 42, value: 'inserted');
          final iterator = StreamIterator(IntIdModel.db.watch(session));
          addTearDown(iterator.cancel);
          final snapshots = <List<String>>[];

          await iterator.moveNext().timeout(const Duration(seconds: 5));
          snapshots.add(iterator.current.map((row) => row.value).toList());
          final inserted = await IntIdModel.db.insertRow(session, row);
          await iterator.moveNext().timeout(const Duration(seconds: 5));
          snapshots.add(iterator.current.map((row) => row.value).toList());
          await IntIdModel.db.updateRow(
            session,
            inserted.copyWith(value: 'updated'),
          );
          await iterator.moveNext().timeout(const Duration(seconds: 5));
          snapshots.add(iterator.current.map((row) => row.value).toList());
          await IntIdModel.db.deleteRow(session, inserted);
          await iterator.moveNext().timeout(const Duration(seconds: 5));
          snapshots.add(iterator.current.map((row) => row.value).toList());

          expect(snapshots, [
            <String>[],
            ['inserted'],
            ['updated'],
            <String>[],
          ]);
        },
      );
    },
  );
}
