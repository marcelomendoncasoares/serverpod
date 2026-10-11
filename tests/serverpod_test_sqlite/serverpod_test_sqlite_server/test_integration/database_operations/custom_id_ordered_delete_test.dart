import 'package:serverpod/serverpod.dart';
import 'package:serverpod_test_sqlite_server/src/generated/protocol.dart';
import 'package:test/test.dart';

import '../test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Ordered custom-ID deletes', (sessionBuilder, endpoints) {
    late Session session;

    setUp(() {
      session = sessionBuilder.build();
    });

    group('Given persisted rows with DateTime IDs,', () {
      setUp(() async {
        await DateTimeIdModel.db.insert(session, [
          DateTimeIdModel(id: DateTime.utc(2026, 1), value: 'first'),
          DateTimeIdModel(id: DateTime.utc(2026, 2), value: 'second'),
          DateTimeIdModel(id: DateTime.utc(2026, 3), value: 'third'),
        ]);
      });

      test(
        'when deleting matching rows in descending ID order, '
        'then the returned rows follow that order.',
        () async {
          final deleted = await DateTimeIdModel.db.deleteWhere(
            session,
            where: (table) => table.id.notEquals(null),
            orderBy: (table) => table.id.desc(),
          );

          expect(deleted.map((row) => row.value), ['third', 'second', 'first']);
        },
      );
    });

    group('Given persisted rows with Duration IDs,', () {
      late List<DurationIdModel> rows;

      setUp(() async {
        rows = await DurationIdModel.db.insert(session, [
          DurationIdModel(id: const Duration(seconds: -1), value: 'first'),
          DurationIdModel(id: Duration.zero, value: 'second'),
          DurationIdModel(id: const Duration(seconds: 1), value: 'third'),
        ]);
      });

      test(
        'when deleting the rows in descending ID order, '
        'then the returned rows follow that order.',
        () async {
          final deleted = await DurationIdModel.db.delete(
            session,
            rows,
            orderBy: (table) => table.id.desc(),
          );

          expect(deleted.map((row) => row.value), ['third', 'second', 'first']);
        },
      );
    });

    group('Given persisted rows with UUID IDs,', () {
      setUp(() async {
        await UuidIdModel.db.insert(session, [
          UuidIdModel(
            id: UuidValue.fromString('00000000-0000-4000-8000-000000000001'),
            value: 'first',
          ),
          UuidIdModel(
            id: UuidValue.fromString('00000000-0000-4000-8000-000000000002'),
            value: 'second',
          ),
          UuidIdModel(
            id: UuidValue.fromString('00000000-0000-4000-8000-000000000003'),
            value: 'third',
          ),
        ]);
      });

      test(
        'when deleting matching rows in descending ID order, '
        'then the returned rows follow that order.',
        () async {
          final deleted = await UuidIdModel.db.deleteWhere(
            session,
            where: (table) => table.id.notEquals(null),
            orderBy: (table) => table.id.desc(),
          );

          expect(deleted.map((row) => row.value), ['third', 'second', 'first']);
        },
      );
    });
  });
}
