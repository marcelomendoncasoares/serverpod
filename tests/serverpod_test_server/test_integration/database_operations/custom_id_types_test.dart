import 'package:serverpod/serverpod.dart';
import 'package:serverpod_test_server/src/generated/protocol.dart';
import 'package:test/test.dart';

import '../test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Custom primary keys', (sessionBuilder, endpoints) {
    late Session session;

    setUp(() {
      session = sessionBuilder.build();
    });

    group('Given rows with caller-supplied String IDs,', () {
      late List<StringIdModel> rows;

      setUp(() {
        final ids = ["customer's/雪", "other"];
        rows = [
          StringIdModel(id: ids[0], value: 'first'),
          StringIdModel(id: ids[1], value: 'second'),
        ];
      });

      test(
        'when inserting and finding by ID, '
        'then the IDs and values round-trip unchanged.',
        () async {
          final inserted = await StringIdModel.db.insert(session, rows);
          final found = await StringIdModel.db.findById(session, rows.first.id);

          expect(inserted.map((row) => row.id), rows.map((row) => row.id));
          expect(found?.id, rows.first.id);
          expect(found?.value, 'first');
        },
      );

      group('when inserting and updating a row by ID,', () {
        late StringIdModel? updated;
        late StringIdModel? found;

        setUp(() async {
          await StringIdModel.db.insert(session, rows);
          updated = await StringIdModel.db.updateById(
            session,
            rows.first.id,
            columnValues: (table) => [table.value('updated')],
          );
          found = await StringIdModel.db.findById(session, rows.first.id);
        });

        test('then the returned and persisted row keep the supplied ID.', () {
          expect(updated?.id, rows.first.id);
          expect(updated?.value, 'updated');
          expect(found?.id, rows.first.id);
          expect(found?.value, 'updated');
        });
      });

      group('when inserting the first row and upserting both rows,', () {
        late List<StringIdModel> upserted;
        late List<StringIdModel> found;

        setUp(() async {
          await StringIdModel.db.insertRow(session, rows.first);
          upserted = await StringIdModel.db.upsert(session, [
            rows.first.copyWith(value: 'updated'),
            rows.last,
          ], conflictColumns: (table) => [table.id]);
          found = await StringIdModel.db.find(
            session,
            where: (table) => table.id.inSet(rows.map((row) => row.id).toSet()),
          );
        });

        test('then both IDs address the expected persisted values.', () {
          expect(upserted.map((row) => row.id), rows.map((row) => row.id));
          expect(
            {for (final row in found) row.id: row.value},
            {rows.first.id: 'updated', rows.last.id: 'second'},
          );
        });
      });

      group('when inserting and updating both rows in a batch,', () {
        late List<StringIdModel> updated;
        late List<StringIdModel> found;

        setUp(() async {
          await StringIdModel.db.insert(session, rows);
          updated = await StringIdModel.db.update(session, [
            rows.first.copyWith(value: 'updated first'),
            rows.last.copyWith(value: 'updated second'),
          ]);
          found = await StringIdModel.db.find(session);
        });

        test('then each ID retains its corresponding updated value.', () {
          final expected = {
            rows.first.id: 'updated first',
            rows.last.id: 'updated second',
          };

          expect({for (final row in updated) row.id: row.value}, expected);
          expect({for (final row in found) row.id: row.value}, expected);
        });
      });

      group('when inserting and deleting the rows,', () {
        late List<StringIdModel> deleted;
        late List<StringIdModel> remaining;

        setUp(() async {
          await StringIdModel.db.insert(session, rows);
          deleted = await StringIdModel.db.delete(session, rows);
          remaining = await StringIdModel.db.find(session);
        });

        test('then the supplied IDs are returned and no rows remain.', () {
          expect(
            deleted.map((row) => row.id),
            unorderedEquals(rows.map((row) => row.id)),
          );
          expect(remaining, isEmpty);
        });
      });

      test(
        'when inserting the same primary key twice, '
        'then the database rejects it.',
        () async {
          await StringIdModel.db.insertRow(session, rows.first);

          final insert = StringIdModel.db.insertRow(session, rows.first);

          await expectLater(insert, throwsA(isA<DatabaseQueryException>()));
        },
      );
    });

    group('Given rows with caller-supplied DateTime IDs,', () {
      late List<DateTimeIdModel> rows;

      setUp(() {
        final ids = [
          DateTime.utc(2026, 1, 2, 3, 4, 5, 123),
          DateTime.utc(2026, 2),
        ];
        rows = [
          DateTimeIdModel(id: ids[0], value: 'first'),
          DateTimeIdModel(id: ids[1], value: 'second'),
        ];
      });

      test(
        'when inserting and finding by ID, '
        'then the IDs and values round-trip unchanged.',
        () async {
          final inserted = await DateTimeIdModel.db.insert(session, rows);
          final found = await DateTimeIdModel.db.findById(
            session,
            rows.first.id,
          );

          expect(inserted.map((row) => row.id), rows.map((row) => row.id));
          expect(found?.id, rows.first.id);
          expect(found?.value, 'first');
        },
      );

      group('when inserting and updating a row by ID,', () {
        late DateTimeIdModel? updated;
        late DateTimeIdModel? found;

        setUp(() async {
          await DateTimeIdModel.db.insert(session, rows);
          updated = await DateTimeIdModel.db.updateById(
            session,
            rows.first.id,
            columnValues: (table) => [table.value('updated')],
          );
          found = await DateTimeIdModel.db.findById(session, rows.first.id);
        });

        test('then the returned and persisted row keep the supplied ID.', () {
          expect(updated?.id, rows.first.id);
          expect(updated?.value, 'updated');
          expect(found?.id, rows.first.id);
          expect(found?.value, 'updated');
        });
      });

      group('when inserting the first row and upserting both rows,', () {
        late List<DateTimeIdModel> upserted;
        late List<DateTimeIdModel> found;

        setUp(() async {
          await DateTimeIdModel.db.insertRow(session, rows.first);
          upserted = await DateTimeIdModel.db.upsert(session, [
            rows.first.copyWith(value: 'updated'),
            rows.last,
          ], conflictColumns: (table) => [table.id]);
          found = await DateTimeIdModel.db.find(
            session,
            where: (table) => table.id.inSet(rows.map((row) => row.id).toSet()),
          );
        });

        test('then both IDs address the expected persisted values.', () {
          expect(upserted.map((row) => row.id), rows.map((row) => row.id));
          expect(
            {for (final row in found) row.id: row.value},
            {rows.first.id: 'updated', rows.last.id: 'second'},
          );
        });
      });

      group('when inserting and updating both rows in a batch,', () {
        late List<DateTimeIdModel> updated;
        late List<DateTimeIdModel> found;

        setUp(() async {
          await DateTimeIdModel.db.insert(session, rows);
          updated = await DateTimeIdModel.db.update(session, [
            rows.first.copyWith(value: 'updated first'),
            rows.last.copyWith(value: 'updated second'),
          ]);
          found = await DateTimeIdModel.db.find(session);
        });

        test('then each ID retains its corresponding updated value.', () {
          final expected = {
            rows.first.id: 'updated first',
            rows.last.id: 'updated second',
          };

          expect({for (final row in updated) row.id: row.value}, expected);
          expect({for (final row in found) row.id: row.value}, expected);
        });
      });

      group('when inserting and deleting the rows,', () {
        late List<DateTimeIdModel> deleted;
        late List<DateTimeIdModel> remaining;

        setUp(() async {
          await DateTimeIdModel.db.insert(session, rows);
          deleted = await DateTimeIdModel.db.delete(session, rows);
          remaining = await DateTimeIdModel.db.find(session);
        });

        test('then the supplied IDs are returned and no rows remain.', () {
          expect(
            deleted.map((row) => row.id),
            unorderedEquals(rows.map((row) => row.id)),
          );
          expect(remaining, isEmpty);
        });
      });

      test(
        'when inserting the same primary key twice, '
        'then the database rejects it.',
        () async {
          await DateTimeIdModel.db.insertRow(session, rows.first);

          final insert = DateTimeIdModel.db.insertRow(session, rows.first);

          await expectLater(insert, throwsA(isA<DatabaseQueryException>()));
        },
      );
    });

    group('Given rows with caller-supplied Duration IDs,', () {
      late List<DurationIdModel> rows;

      setUp(() {
        final ids = [
          const Duration(milliseconds: -1234),
          const Duration(days: 2),
        ];
        rows = [
          DurationIdModel(id: ids[0], value: 'first'),
          DurationIdModel(id: ids[1], value: 'second'),
        ];
      });

      test(
        'when inserting and finding by ID, '
        'then the IDs and values round-trip unchanged.',
        () async {
          final inserted = await DurationIdModel.db.insert(session, rows);
          final found = await DurationIdModel.db.findById(
            session,
            rows.first.id,
          );

          expect(inserted.map((row) => row.id), rows.map((row) => row.id));
          expect(found?.id, rows.first.id);
          expect(found?.value, 'first');
        },
      );

      group('when inserting and updating a row by ID,', () {
        late DurationIdModel? updated;
        late DurationIdModel? found;

        setUp(() async {
          await DurationIdModel.db.insert(session, rows);
          updated = await DurationIdModel.db.updateById(
            session,
            rows.first.id,
            columnValues: (table) => [table.value('updated')],
          );
          found = await DurationIdModel.db.findById(session, rows.first.id);
        });

        test('then the returned and persisted row keep the supplied ID.', () {
          expect(updated?.id, rows.first.id);
          expect(updated?.value, 'updated');
          expect(found?.id, rows.first.id);
          expect(found?.value, 'updated');
        });
      });

      group('when inserting the first row and upserting both rows,', () {
        late List<DurationIdModel> upserted;
        late List<DurationIdModel> found;

        setUp(() async {
          await DurationIdModel.db.insertRow(session, rows.first);
          upserted = await DurationIdModel.db.upsert(session, [
            rows.first.copyWith(value: 'updated'),
            rows.last,
          ], conflictColumns: (table) => [table.id]);
          found = await DurationIdModel.db.find(
            session,
            where: (table) => table.id.inSet(rows.map((row) => row.id).toSet()),
          );
        });

        test('then both IDs address the expected persisted values.', () {
          expect(upserted.map((row) => row.id), rows.map((row) => row.id));
          expect(
            {for (final row in found) row.id: row.value},
            {rows.first.id: 'updated', rows.last.id: 'second'},
          );
        });
      });

      group('when inserting and updating both rows in a batch,', () {
        late List<DurationIdModel> updated;
        late List<DurationIdModel> found;

        setUp(() async {
          await DurationIdModel.db.insert(session, rows);
          updated = await DurationIdModel.db.update(session, [
            rows.first.copyWith(value: 'updated first'),
            rows.last.copyWith(value: 'updated second'),
          ]);
          found = await DurationIdModel.db.find(session);
        });

        test('then each ID retains its corresponding updated value.', () {
          final expected = {
            rows.first.id: 'updated first',
            rows.last.id: 'updated second',
          };

          expect({for (final row in updated) row.id: row.value}, expected);
          expect({for (final row in found) row.id: row.value}, expected);
        });
      });

      group('when inserting and deleting the rows,', () {
        late List<DurationIdModel> deleted;
        late List<DurationIdModel> remaining;

        setUp(() async {
          await DurationIdModel.db.insert(session, rows);
          deleted = await DurationIdModel.db.delete(session, rows);
          remaining = await DurationIdModel.db.find(session);
        });

        test('then the supplied IDs are returned and no rows remain.', () {
          expect(
            deleted.map((row) => row.id),
            unorderedEquals(rows.map((row) => row.id)),
          );
          expect(remaining, isEmpty);
        });
      });

      test(
        'when inserting the same primary key twice, '
        'then the database rejects it.',
        () async {
          await DurationIdModel.db.insertRow(session, rows.first);

          final insert = DurationIdModel.db.insertRow(session, rows.first);

          await expectLater(insert, throwsA(isA<DatabaseQueryException>()));
        },
      );
    });

    test(
      'Given a required integer ID without a default, '
      'when inserting and reading a row, '
      'then the supplied ID is preserved.',
      () async {
        final row = IntIdModel(id: 42, value: 'supplied');

        final inserted = await IntIdModel.db.insertRow(session, row);
        final found = await IntIdModel.db.findById(session, row.id);

        expect(inserted.id, row.id);
        expect(found?.id, row.id);
        expect(found?.value, 'supplied');
        expect(IntIdModel.t.id.hasDefault, isFalse);
      },
    );

    test(
      'Given a required UUID ID without a default, '
      'when inserting and reading a row, '
      'then the supplied ID is preserved.',
      () async {
        final row = UuidIdModel(
          id: UuidValue.fromString('550e8400-e29b-41d4-a716-446655440000'),
          value: 'supplied',
        );

        final inserted = await UuidIdModel.db.insertRow(session, row);
        final found = await UuidIdModel.db.findById(session, row.id);

        expect(inserted.id, row.id);
        expect(found?.id, row.id);
        expect(found?.value, 'supplied');
        expect(UuidIdModel.t.id.hasDefault, isFalse);
      },
    );

    test(
      'Given a DateTime ID with a model now generator, '
      'when constructing and inserting a row without an ID, '
      'then its generated timestamp is persisted.',
      () async {
        final before = DateTime.now().toUtc().subtract(
          const Duration(seconds: 1),
        );

        final row = DateTimeIdDefaultModel(value: 'model default');
        final inserted = await DateTimeIdDefaultModel.db.insertRow(
          session,
          row,
        );
        final found = await DateTimeIdDefaultModel.db.findById(
          session,
          inserted.id,
        );
        final after = DateTime.now().toUtc().add(const Duration(seconds: 1));

        expect(row.id.isAfter(before), isTrue);
        expect(row.id.isBefore(after), isTrue);
        expect(
          inserted.id.millisecondsSinceEpoch,
          row.id.millisecondsSinceEpoch,
        );
        expect(found?.id, inserted.id);
      },
    );

    test(
      'Given a DateTime ID with a database now generator, '
      'when inserting a row without an ID, '
      'then the database returns a current timestamp that identifies the row.',
      () async {
        final row = DateTimeIdDefaultPersist(value: 'database default');
        final before = DateTime.now().toUtc().subtract(
          const Duration(seconds: 5),
        );

        final inserted = await DateTimeIdDefaultPersist.db.insertRow(
          session,
          row,
        );
        final found = await DateTimeIdDefaultPersist.db.findById(
          session,
          inserted.id!,
        );
        final after = DateTime.now().toUtc().add(const Duration(seconds: 5));

        expect(row.id, isNull);
        expect(inserted.id!.isAfter(before), isTrue);
        expect(inserted.id!.isBefore(after), isTrue);
        expect(found?.id, inserted.id);
        expect(found?.value, 'database default');
      },
    );

    test(
      'Given a DateTime ID with a database now generator and an explicit ID, '
      'when inserting the row, '
      'then the explicit timestamp takes precedence.',
      () async {
        final id = DateTime.utc(2020, 1, 2);
        final row = DateTimeIdDefaultPersist(id: id, value: 'explicit');

        final inserted = await DateTimeIdDefaultPersist.db.insertRow(
          session,
          row,
        );

        expect(inserted.id, id);
      },
    );

    group(
      'Given a child linked to String, DateTime and Duration primary keys,',
      () {
        late StringIdModel string;
        late DateTimeIdModel dateTime;
        late DurationIdModel duration;
        late CustomIdRelated child;

        setUp(() async {
          string = await StringIdModel.db.insertRow(
            session,
            StringIdModel(id: "parent's/雪", value: 'string'),
          );
          dateTime = await DateTimeIdModel.db.insertRow(
            session,
            DateTimeIdModel(id: DateTime.utc(2026, 1, 2), value: 'dateTime'),
          );
          duration = await DurationIdModel.db.insertRow(
            session,
            DurationIdModel(
              id: const Duration(milliseconds: -1234),
              value: 'duration',
            ),
          );
          child = await CustomIdRelated.db.insertRow(
            session,
            CustomIdRelated(
              id: 'child',
              stringId: string.id,
              dateTimeId: dateTime.id,
              durationId: duration.id,
            ),
          );
        });

        test(
          'when including the parent objects, '
          'then all three relations resolve by their supplied IDs.',
          () async {
            final found = await CustomIdRelated.db.findById(
              session,
              child.id,
              include: CustomIdRelated.include(
                string: StringIdModel.include(),
                dateTime: DateTimeIdModel.include(),
                duration: DurationIdModel.include(),
              ),
            );

            expect(found?.string?.id, string.id);
            expect(found?.dateTime?.id, dateTime.id);
            expect(found?.duration?.id, duration.id);
          },
        );

        test(
          'when including the child lists from each parent, '
          'then all three lists contain the related child.',
          () async {
            final foundString = await StringIdModel.db.findById(
              session,
              string.id,
              include: StringIdModel.include(
                related: CustomIdRelated.includeList(),
              ),
            );
            final foundDateTime = await DateTimeIdModel.db.findById(
              session,
              dateTime.id,
              include: DateTimeIdModel.include(
                related: CustomIdRelated.includeList(),
              ),
            );
            final foundDuration = await DurationIdModel.db.findById(
              session,
              duration.id,
              include: DurationIdModel.include(
                related: CustomIdRelated.includeList(),
              ),
            );

            expect(foundString?.related?.single.id, child.id);
            expect(foundDateTime?.related?.single.id, child.id);
            expect(foundDuration?.related?.single.id, child.id);
          },
        );
      },
    );

    test(
      'Given migrated tables with caller-supplied and generated IDs, '
      'when inspecting their database definitions, '
      'then only generated IDs have database defaults.',
      () async {
        final tables = await session.db.analyzer.getTableDefinitions();
        final ids = {
          for (final table in tables)
            table.name: table.columns.singleWhere(
              (column) => column.name == 'id',
            ),
        };

        expect(
          ids.keys,
          containsAll([
            'string_id_model',
            'date_time_id_model',
            'duration_id_model',
            'int_id_model',
            'uuid_id_model',
            'date_time_id_default_model',
            'date_time_id_default_persist',
          ]),
        );
        expect(ids['string_id_model']?.columnDefault, isNull);
        expect(ids['date_time_id_model']?.columnDefault, isNull);
        expect(ids['duration_id_model']?.columnDefault, isNull);
        expect(ids['int_id_model']?.columnDefault, isNull);
        expect(ids['uuid_id_model']?.columnDefault, isNull);
        expect(ids['date_time_id_default_model']?.columnDefault, 'now');
        expect(ids['date_time_id_default_persist']?.columnDefault, 'now');
        expect(ids['date_time_id_default_persist']?.isNullable, isFalse);
      },
    );
  });
}
