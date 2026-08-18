import 'package:serverpod_test_server/src/generated/protocol.dart';
import 'package:serverpod_test_shared/serverpod_test_shared.dart';
import 'package:test/test.dart';

import '../test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod(
    'Given a table with custom class fields, '
    'when inserting a row with scalar and map custom class values,',
    (sessionBuilder, endpoints) {
      var session = sessionBuilder.build();
      final dateTime = DateTime.utc(2024, 6, 15, 12, 30, 45);
      late CustomClassRoundtripTable inserted;

      setUp(() async {
        inserted = await CustomClassRoundtripTable.db.insertRow(
          session,
          CustomClassRoundtripTable(
            intData: IntCustomClass(42),
            doubleData: DoubleCustomClass(3.14),
            stringData: CustomClass('hello'),
            boolData: BoolCustomClass(true),
            dateTimeData: DateTimeCustomClass(dateTime),
            mapData: const CustomClass2('map-value'),
            jsonbMapData: const CustomClass2('jsonb-value'),
          ),
        );
      });

      test('then the inserted row contains those values.', () {
        expect(inserted.id, isNotNull);
        expect(inserted.intData.value, 42);
        expect(inserted.doubleData.value, 3.14);
        expect(inserted.stringData.value, 'hello');
        expect(inserted.boolData.value, isTrue);
        expect(inserted.dateTimeData.value, dateTime);
        expect(inserted.mapData.value, 'map-value');
        expect(inserted.jsonbMapData.value, 'jsonb-value');
      });
    },
  );

  withServerpod(
    'Given a stored row with custom class values,',
    (sessionBuilder, endpoints) {
      var session = sessionBuilder.build();
      final dateTime = DateTime.utc(2024, 6, 15, 12, 30, 45);
      late CustomClassRoundtripTable inserted;

      setUp(() async {
        inserted = await CustomClassRoundtripTable.db.insertRow(
          session,
          CustomClassRoundtripTable(
            intData: IntCustomClass(42),
            doubleData: DoubleCustomClass(3.14),
            stringData: CustomClass('hello'),
            boolData: BoolCustomClass(true),
            dateTimeData: DateTimeCustomClass(dateTime),
            mapData: const CustomClass2('map-value'),
            jsonbMapData: const CustomClass2('jsonb-value'),
          ),
        );
      });

      test(
        'when reading the row by id, '
        'then those values are returned.',
        () async {
          var fetched = await CustomClassRoundtripTable.db.findById(
            session,
            inserted.id!,
          );

          expect(fetched, isNotNull);
          expect(fetched!.intData.value, inserted.intData.value);
          expect(fetched.doubleData.value, inserted.doubleData.value);
          expect(fetched.stringData.value, inserted.stringData.value);
          expect(fetched.boolData.value, inserted.boolData.value);
          expect(fetched.dateTimeData.value, inserted.dateTimeData.value);
          expect(fetched.mapData.value, inserted.mapData.value);
          expect(fetched.jsonbMapData.value, inserted.jsonbMapData.value);
        },
      );

      group('when updating the custom class values,', () {
        final updatedDateTime = DateTime.utc(2025, 1, 2, 8, 0);
        late CustomClassRoundtripTable afterUpdate;

        setUp(() async {
          afterUpdate = await CustomClassRoundtripTable.db.updateRow(
            session,
            inserted.copyWith(
              intData: IntCustomClass(99),
              doubleData: DoubleCustomClass(2.71),
              stringData: CustomClass('updated'),
              boolData: BoolCustomClass(false),
              dateTimeData: DateTimeCustomClass(updatedDateTime),
              mapData: const CustomClass2('updated-map'),
              jsonbMapData: const CustomClass2('updated-jsonb'),
            ),
          );
        });

        test('then the updated row is returned with the new values.', () {
          expect(afterUpdate.intData.value, 99);
          expect(afterUpdate.doubleData.value, 2.71);
          expect(afterUpdate.stringData.value, 'updated');
          expect(afterUpdate.boolData.value, isFalse);
          expect(afterUpdate.dateTimeData.value, updatedDateTime);
          expect(afterUpdate.mapData.value, 'updated-map');
          expect(afterUpdate.jsonbMapData.value, 'updated-jsonb');
        });

        test('then the stored row has the new values.', () async {
          var refetched = await CustomClassRoundtripTable.db.findById(
            session,
            inserted.id!,
          );

          expect(refetched!.intData.value, afterUpdate.intData.value);
          expect(refetched.doubleData.value, afterUpdate.doubleData.value);
          expect(refetched.stringData.value, afterUpdate.stringData.value);
          expect(refetched.boolData.value, afterUpdate.boolData.value);
          expect(refetched.dateTimeData.value, afterUpdate.dateTimeData.value);
          expect(refetched.mapData.value, afterUpdate.mapData.value);
          expect(refetched.jsonbMapData.value, afterUpdate.jsonbMapData.value);
        });
      });
    },
  );

  withServerpod(
    'Given a stored row with null nullable custom class fields,',
    (sessionBuilder, endpoints) {
      var session = sessionBuilder.build();
      final dateTime = DateTime.utc(2024, 6, 15, 12, 30, 45);
      late CustomClassRoundtripTable inserted;

      setUp(() async {
        inserted = await CustomClassRoundtripTable.db.insertRow(
          session,
          CustomClassRoundtripTable(
            intData: IntCustomClass(42),
            doubleData: DoubleCustomClass(3.14),
            stringData: CustomClass('hello'),
            boolData: BoolCustomClass(true),
            dateTimeData: DateTimeCustomClass(dateTime),
            mapData: const CustomClass2('map-value'),
            jsonbMapData: const CustomClass2('jsonb-value'),
            nullableIntData: null,
            nullableMapData: null,
          ),
        );
      });

      test(
        'when reading the row by id, '
        'then the nullable fields are null.',
        () async {
          var fetched = await CustomClassRoundtripTable.db.findById(
            session,
            inserted.id!,
          );

          expect(fetched, isNotNull);
          expect(fetched!.nullableIntData, isNull);
          expect(fetched.nullableMapData, isNull);
        },
      );

      group('when updating those fields,', () {
        late CustomClassRoundtripTable afterUpdate;

        setUp(() async {
          afterUpdate = await CustomClassRoundtripTable.db.updateRow(
            session,
            inserted.copyWith(
              nullableIntData: IntCustomClass(7),
              nullableMapData: const CustomClass2('nullable-map'),
            ),
          );
        });

        test('then the updated row contains those values.', () {
          expect(afterUpdate.nullableIntData?.value, 7);
          expect(afterUpdate.nullableMapData?.value, 'nullable-map');
        });

        test('then the stored row has those values.', () async {
          var refetched = await CustomClassRoundtripTable.db.findById(
            session,
            inserted.id!,
          );

          expect(refetched!.nullableIntData?.value, 7);
          expect(refetched.nullableMapData?.value, 'nullable-map');
        });
      });
    },
  );

  withServerpod(
    'Given a stored row with nullable custom class values, '
    'when clearing those fields,',
    (sessionBuilder, endpoints) {
      var session = sessionBuilder.build();
      final dateTime = DateTime.utc(2024, 6, 15, 12, 30, 45);
      late CustomClassRoundtripTable afterClear;

      setUp(() async {
        var inserted = await CustomClassRoundtripTable.db.insertRow(
          session,
          CustomClassRoundtripTable(
            intData: IntCustomClass(42),
            doubleData: DoubleCustomClass(3.14),
            stringData: CustomClass('hello'),
            boolData: BoolCustomClass(true),
            dateTimeData: DateTimeCustomClass(dateTime),
            mapData: const CustomClass2('map-value'),
            jsonbMapData: const CustomClass2('jsonb-value'),
            nullableIntData: IntCustomClass(7),
            nullableMapData: const CustomClass2('nullable-map'),
          ),
        );

        afterClear = await CustomClassRoundtripTable.db.updateRow(
          session,
          inserted.copyWith(
            nullableIntData: null,
            nullableMapData: null,
          ),
        );
      });

      test('then the updated row has null nullable fields.', () {
        expect(afterClear.nullableIntData, isNull);
        expect(afterClear.nullableMapData, isNull);
      });

      test(
        'then the stored row has null nullable fields.',
        () async {
          var fetched = await CustomClassRoundtripTable.db.findById(
            session,
            afterClear.id!,
          );

          expect(fetched!.nullableIntData, isNull);
          expect(fetched.nullableMapData, isNull);
        },
      );
    },
  );

  withServerpod(
    'Given two stored rows with different int custom class values, '
    'when filtering where intData equals 42,',
    (sessionBuilder, endpoints) {
      var session = sessionBuilder.build();
      late List<CustomClassRoundtripTable> matches;

      setUp(() async {
        await CustomClassRoundtripTable.db.insertRow(
          session,
          CustomClassRoundtripTable(
            intData: IntCustomClass(42),
            doubleData: DoubleCustomClass(1.0),
            stringData: CustomClass('match'),
            boolData: BoolCustomClass(true),
            dateTimeData: DateTimeCustomClass(DateTime.utc(2024)),
            mapData: const CustomClass2('map'),
            jsonbMapData: const CustomClass2('jsonb'),
          ),
        );
        await CustomClassRoundtripTable.db.insertRow(
          session,
          CustomClassRoundtripTable(
            intData: IntCustomClass(7),
            doubleData: DoubleCustomClass(9.9),
            stringData: CustomClass('other'),
            boolData: BoolCustomClass(false),
            dateTimeData: DateTimeCustomClass(DateTime.utc(2025)),
            mapData: const CustomClass2('other-map'),
            jsonbMapData: const CustomClass2('other-jsonb'),
          ),
        );

        matches = await CustomClassRoundtripTable.db.find(
          session,
          where: (t) => t.intData.equals(42),
        );
      });

      test('then only the matching row is returned.', () {
        expect(matches, hasLength(1));
        expect(matches.single.intData.value, 42);
        expect(matches.single.stringData.value, 'match');
      });
    },
  );
}
