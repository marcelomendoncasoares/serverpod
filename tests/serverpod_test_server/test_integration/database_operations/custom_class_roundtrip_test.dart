import 'package:serverpod_test_shared/serverpod_test_shared.dart';
import 'package:serverpod_test_server/src/generated/protocol.dart';
import 'package:test/test.dart';

import '../test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod(
    'Given custom class roundtrip table,',
    (sessionBuilder, endpoints) {
      var session = sessionBuilder.build();

      test(
        'when inserting, reading, and updating rows, '
        'then scalar and map custom classes round-trip with correct storage types',
        () async {
          final dateTime = DateTime.utc(2024, 6, 15, 12, 30, 45);

          var record = CustomClassRoundtripTable(
            intData: IntCustomClass(42),
            doubleData: DoubleCustomClass(3.14),
            stringData: CustomClass('hello'),
            boolData: BoolCustomClass(true),
            dateTimeData: DateTimeCustomClass(dateTime),
            mapData: const CustomClass2('map-value'),
            jsonbMapData: const CustomClass2('jsonb-value'),
          );

          var inserted = await CustomClassRoundtripTable.db.insertRow(
            session,
            record,
          );

          expect(inserted.id, isNotNull);
          expect(inserted.intData.value, 42);
          expect(inserted.doubleData.value, 3.14);
          expect(inserted.stringData.value, 'hello');
          expect(inserted.boolData.value, isTrue);
          expect(inserted.dateTimeData.value, dateTime);
          expect(inserted.mapData.value, 'map-value');
          expect(inserted.jsonbMapData.value, 'jsonb-value');

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

          final updatedDateTime = DateTime.utc(2025, 1, 2, 8, 0);
          var updated = inserted.copyWith(
            intData: IntCustomClass(99),
            doubleData: DoubleCustomClass(2.71),
            stringData: CustomClass('updated'),
            boolData: BoolCustomClass(false),
            dateTimeData: DateTimeCustomClass(updatedDateTime),
            mapData: const CustomClass2('updated-map'),
            jsonbMapData: const CustomClass2('updated-jsonb'),
          );
          var afterUpdate = await CustomClassRoundtripTable.db.updateRow(
            session,
            updated,
          );

          expect(afterUpdate.intData.value, 99);
          expect(afterUpdate.doubleData.value, 2.71);
          expect(afterUpdate.stringData.value, 'updated');
          expect(afterUpdate.boolData.value, isFalse);
          expect(afterUpdate.dateTimeData.value, updatedDateTime);
          expect(afterUpdate.mapData.value, 'updated-map');
          expect(afterUpdate.jsonbMapData.value, 'updated-jsonb');

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
          expect(
            refetched.jsonbMapData.value,
            afterUpdate.jsonbMapData.value,
          );
        },
      );

      test(
        'when filtering on scalar custom class columns, '
        'then rows can be queried by their serialized values',
        () async {
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

          final matches = await CustomClassRoundtripTable.db.find(
            session,
            where: (t) => t.intData.equals(42),
          );

          expect(matches, hasLength(1));
          expect(matches.single.intData.value, 42);
          expect(matches.single.stringData.value, 'match');
        },
      );
    },
  );
}
