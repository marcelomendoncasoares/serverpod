@Timeout(Duration(minutes: 5))
import 'package:serverpod_service_client/serverpod_service_client.dart';
import 'package:serverpod_test_server/test_util/migration_test_utils.dart';
import 'package:serverpod_test_server/test_util/service_client.dart';
import 'package:test/test.dart';

void main() {
  group(
    'Given a protocol model with custom class fields that serialize to scalar and map types, '
    'when applying the migration,',
    () {
      var tag = 'custom-class-roundtrip-schema';
      var targetStateProtocols = {
        'custom_class_roundtrip_table': '''
class: CustomClassRoundtripTable
table: custom_class_roundtrip_table
fields:
  intData: IntCustomClass
  doubleData: DoubleCustomClass
  stringData: CustomClass
  boolData: BoolCustomClass
  dateTimeData: DateTimeCustomClass
  mapData: CustomClass2, serializationDataType=json
  jsonbMapData: CustomClass2, serializationDataType=jsonb
  nullableIntData: IntCustomClass?
  nullableMapData: CustomClass2?, serializationDataType=json
''',
      };

      late TableDefinition table;

      setUpAll(() async {
        var createMigrationExitCode =
            await MigrationTestUtils.createMigrationFromProtocols(
              protocols: targetStateProtocols,
              tag: tag,
            );
        expect(createMigrationExitCode, 0);

        var applyMigrationExitCode =
            await MigrationTestUtils.runApplyMigrations();
        expect(applyMigrationExitCode, 0);

        var liveDefinition = await serviceClient.insights
            .getLiveDatabaseDefinition();
        table = liveDefinition.tables.firstWhere(
          (t) => t.name == 'custom_class_roundtrip_table',
        );
      });

      tearDownAll(() async {
        await MigrationTestUtils.migrationTestCleanup(
          resetSql: 'DROP TABLE IF EXISTS custom_class_roundtrip_table;',
          serviceClient: serviceClient,
        );
      });

      test('then the intData column type is bigint.', () {
        expect(
          table.columns.firstWhere((c) => c.name == 'intData').columnType.name,
          'bigint',
        );
      });

      test('then the doubleData column type is double precision.', () {
        expect(
          table.columns
              .firstWhere((c) => c.name == 'doubleData')
              .columnType
              .name,
          'double precision',
        );
      });

      test('then the stringData column type is text.', () {
        expect(
          table.columns
              .firstWhere((c) => c.name == 'stringData')
              .columnType
              .name,
          'text',
        );
      });

      test('then the boolData column type is boolean.', () {
        expect(
          table.columns.firstWhere((c) => c.name == 'boolData').columnType.name,
          'boolean',
        );
      });

      test(
        'then the dateTimeData column type is timestamp without time zone.',
        () {
          expect(
            table.columns
                .firstWhere((c) => c.name == 'dateTimeData')
                .columnType
                .name,
            'timestamp without time zone',
          );
        },
      );

      test('then the mapData column type is json.', () {
        expect(
          table.columns.firstWhere((c) => c.name == 'mapData').columnType.name,
          'json',
        );
      });

      test('then the jsonbMapData column type is jsonb.', () {
        expect(
          table.columns
              .firstWhere((c) => c.name == 'jsonbMapData')
              .columnType
              .name,
          'jsonb',
        );
      });

      test('then the nullableIntData column type is bigint.', () {
        expect(
          table.columns
              .firstWhere((c) => c.name == 'nullableIntData')
              .columnType
              .name,
          'bigint',
        );
      });

      test('then the nullableIntData column is nullable.', () {
        expect(
          table.columns
              .firstWhere((c) => c.name == 'nullableIntData')
              .isNullable,
          isTrue,
        );
      });

      test('then the nullableMapData column type is json.', () {
        expect(
          table.columns
              .firstWhere((c) => c.name == 'nullableMapData')
              .columnType
              .name,
          'json',
        );
      });

      test('then the nullableMapData column is nullable.', () {
        expect(
          table.columns
              .firstWhere((c) => c.name == 'nullableMapData')
              .isNullable,
          isTrue,
        );
      });
    },
  );
}
