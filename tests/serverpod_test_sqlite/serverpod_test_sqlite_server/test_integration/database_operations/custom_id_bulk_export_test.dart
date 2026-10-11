import 'dart:convert';

import 'package:serverpod/serverpod.dart';
import 'package:serverpod/src/endpoints/insights.dart';
import 'package:serverpod_database/serverpod_database.dart'
    show
        BulkData,
        BulkDataException,
        Filter,
        FilterConstraint,
        FilterConstraintType;
import 'package:serverpod_test_sqlite_server/src/generated/protocol.dart';
import 'package:test/test.dart';

import '../test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod(
    'Custom-ID Insights export',
    configOverride: (config) =>
        config.copyWith(insightsDatabaseAccessEnabled: true),
    (sessionBuilder, endpoints) {
      late Session session;
      final endpoint = InsightsEndpoint();

      setUp(() {
        session = sessionBuilder.build();
      });

      test(
        'Given String IDs including an empty and a quoted key, '
        'when exporting successive pages through Insights, '
        'then every row is returned exactly once.',
        () async {
          await StringIdModel.db.insert(session, [
            StringIdModel(id: '', value: 'first'),
            StringIdModel(id: "a'b", value: 'second'),
            StringIdModel(id: 'z', value: 'third'),
          ]);

          final first = await endpoint.fetchDatabaseBulkData(
            session,
            table: 'string_id_model',
            limit: 2,
          );
          final second = await endpoint.fetchDatabaseBulkData(
            session,
            table: 'string_id_model',
            startingIdText: "a'b",
            limit: 2,
          );

          expect(_values(first), ['first', 'second']);
          expect(_values(second), ['third']);
        },
      );

      test(
        'Given DateTime IDs before and after the Unix epoch, '
        'when exporting successive pages through Insights, '
        'then the ISO timestamp cursor preserves the ordering.',
        () async {
          await DateTimeIdModel.db.insert(session, [
            DateTimeIdModel(id: DateTime.utc(1969), value: 'first'),
            DateTimeIdModel(id: DateTime.utc(1970), value: 'second'),
            DateTimeIdModel(id: DateTime.utc(2026), value: 'third'),
          ]);

          final first = await endpoint.fetchDatabaseBulkData(
            session,
            table: 'date_time_id_model',
            limit: 2,
          );
          final second = await endpoint.fetchDatabaseBulkData(
            session,
            table: 'date_time_id_model',
            startingIdText: DateTime.utc(1970).toIso8601String(),
            limit: 2,
          );

          expect(_values(first), ['first', 'second']);
          expect(_values(second), ['third']);
        },
      );

      test(
        'Given negative and zero Duration IDs, '
        'when exporting successive pages through Insights, '
        'then the millisecond cursor includes all rows.',
        () async {
          await DurationIdModel.db.insert(session, [
            DurationIdModel(id: const Duration(seconds: -1), value: 'first'),
            DurationIdModel(id: Duration.zero, value: 'second'),
            DurationIdModel(id: const Duration(seconds: 1), value: 'third'),
          ]);

          final first = await endpoint.fetchDatabaseBulkData(
            session,
            table: 'duration_id_model',
            limit: 2,
          );
          final second = await endpoint.fetchDatabaseBulkData(
            session,
            table: 'duration_id_model',
            startingIdText: '0',
            limit: 2,
          );

          expect(_values(first), ['first', 'second']);
          expect(_values(second), ['third']);
        },
      );

      test(
        'Given caller-supplied integer IDs including negative and zero values, '
        'when exporting the first page and using the legacy integer cursor, '
        'then every row is returned exactly once.',
        () async {
          await IntIdModel.db.insert(session, [
            IntIdModel(id: -1, value: 'first'),
            IntIdModel(id: 0, value: 'second'),
            IntIdModel(id: 1, value: 'third'),
          ]);

          final first = await endpoint.fetchDatabaseBulkData(
            session,
            table: 'int_id_model',
            limit: 2,
          );
          final second = await endpoint.fetchDatabaseBulkData(
            session,
            table: 'int_id_model',
            startingId: 0,
            limit: 2,
          );

          expect(_values(first), ['first', 'second']);
          expect(_values(second), ['third']);
        },
      );

      test(
        'Given UUID primary keys, '
        'when exporting successive pages through Insights, '
        'then the textual UUID cursor selects the remaining row.',
        () async {
          const middle = '00000000-0000-4000-8000-000000000002';
          await UuidIdModel.db.insert(session, [
            UuidIdModel(
              id: UuidValue.fromString('00000000-0000-4000-8000-000000000001'),
              value: 'first',
            ),
            UuidIdModel(id: UuidValue.fromString(middle), value: 'second'),
            UuidIdModel(
              id: UuidValue.fromString('00000000-0000-4000-8000-000000000003'),
              value: 'third',
            ),
          ]);

          final first = await endpoint.fetchDatabaseBulkData(
            session,
            table: 'uuid_id_model',
            limit: 2,
          );
          final second = await endpoint.fetchDatabaseBulkData(
            session,
            table: 'uuid_id_model',
            startingIdText: middle,
            limit: 2,
          );

          expect(_values(first), ['first', 'second']);
          expect(_values(second), ['third']);
        },
      );
      test(
        'Given a filtered export with String IDs, '
        'when reading the first page without a cursor, '
        'then the filter still restricts the returned rows.',
        () async {
          await StringIdModel.db.insert(session, [
            StringIdModel(id: 'a', value: 'keep'),
            StringIdModel(id: 'b', value: 'omit'),
          ]);
          final filter = Filter(
            name: 'kept values',
            table: 'string_id_model',
            constraints: [
              FilterConstraint(
                type: FilterConstraintType.equals,
                column: 'value',
                value: 'keep',
              ),
            ],
          );

          final page = await endpoint.fetchDatabaseBulkData(
            session,
            table: 'string_id_model',
            limit: 2,
            filter: filter,
          );

          expect(_values(page), ['keep']);
        },
      );

      test(
        'Given both integer and textual export cursors, '
        'when requesting a page through Insights, '
        'then the ambiguous cursor is rejected.',
        () async {
          final page = endpoint.fetchDatabaseBulkData(
            session,
            table: 'int_id_model',
            startingId: 0,
            startingIdText: '1',
            limit: 2,
          );

          await expectLater(page, throwsA(isA<BulkDataException>()));
        },
      );
    },
  );
}

List<String> _values(BulkData data) {
  final valueIndex = data.tableDefinition.columns.indexWhere(
    (column) => column.name == 'value',
  );
  return (jsonDecode(data.data) as List)
      .map((row) => (row as List)[valueIndex] as String)
      .toList();
}
