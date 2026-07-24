@Timeout(Duration(minutes: 5))
import 'package:serverpod_test_server/test_util/migration_test_utils.dart';
import 'package:serverpod_test_server/test_util/service_client.dart';
import 'package:test/test.dart';

void main() {
  group(
    'Given a custom class roundtrip table migration',
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

      tearDown(() async {
        await MigrationTestUtils.migrationTestCleanup(
          resetSql: 'DROP TABLE IF EXISTS custom_class_roundtrip_table;',
          serviceClient: serviceClient,
        );
      });

      test(
        'when applying the migration, '
        'then column types match custom class serialization types',
        () async {
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
          var table = liveDefinition.tables.firstWhere(
            (t) => t.name == 'custom_class_roundtrip_table',
          );

          expect(
            table.columns.firstWhere((c) => c.name == 'intData').columnType.name,
            'bigint',
          );
          expect(
            table.columns
                .firstWhere((c) => c.name == 'doubleData')
                .columnType
                .name,
            'double precision',
          );
          expect(
            table.columns
                .firstWhere((c) => c.name == 'stringData')
                .columnType
                .name,
            'text',
          );
          expect(
            table.columns.firstWhere((c) => c.name == 'boolData').columnType.name,
            'boolean',
          );
          expect(
            table.columns
                .firstWhere((c) => c.name == 'dateTimeData')
                .columnType
                .name,
            'timestamp without time zone',
          );
          expect(
            table.columns.firstWhere((c) => c.name == 'mapData').columnType.name,
            'json',
          );
          expect(
            table.columns
                .firstWhere((c) => c.name == 'jsonbMapData')
                .columnType
                .name,
            'jsonb',
          );
          expect(
            table.columns
                .firstWhere((c) => c.name == 'nullableIntData')
                .columnType
                .name,
            'bigint',
          );
          expect(
            table.columns
                .firstWhere((c) => c.name == 'nullableIntData')
                .isNullable,
            isTrue,
          );
          expect(
            table.columns
                .firstWhere((c) => c.name == 'nullableMapData')
                .columnType
                .name,
            'json',
          );
          expect(
            table.columns
                .firstWhere((c) => c.name == 'nullableMapData')
                .isNullable,
            isTrue,
          );
        },
      );
    },
  );
}
