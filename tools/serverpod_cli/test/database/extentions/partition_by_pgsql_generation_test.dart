import 'package:serverpod_cli/src/database/extensions.dart';
import 'package:serverpod_service_client/serverpod_service_client.dart';
import 'package:test/test.dart';

import '../../test_util/builders/database/table_definition_builder.dart';

void main() {
  group(
    'Given a table definition with single partitionBy column',
    () {
      test(
        'when generating SQL then CREATE TABLE includes PARTITION BY LIST clause.',
        () {
          var table = TableDefinitionBuilder()
              .withName('example')
              .withPartitionBy(['source'])
              .build();

          var sql = table.tableCreationToPgsql();

          expect(sql, contains('PARTITION BY LIST ("source")'));
        },
      );
    },
  );

  group(
    'Given a table definition with multiple partitionBy columns',
    () {
      test(
        'when generating SQL then all columns are in PARTITION BY clause.',
        () {
          var table = TableDefinitionBuilder()
              .withName('example')
              .withPartitionBy(['source', 'category'])
              .build();

          var sql = table.tableCreationToPgsql();

          expect(sql, contains('PARTITION BY LIST ("source", "category")'));
        },
      );
    },
  );

  group(
    'Given a table definition without partitionBy',
    () {
      test(
        'when generating SQL then CREATE TABLE does not include PARTITION BY clause.',
        () {
          var table = TableDefinitionBuilder().withName('example').build();

          var sql = table.tableCreationToPgsql();

          expect(sql, isNot(contains('PARTITION BY')));
        },
      );
    },
  );

  group(
    'Given a table definition with partitionBy and method list',
    () {
      test(
        'when generating SQL then PARTITION BY LIST is generated.',
        () {
          var table = TableDefinitionBuilder()
              .withName('example')
              .withPartitionBy(['source'])
              .withPartitionMethod(PartitionMethod.list)
              .build();

          var sql = table.tableCreationToPgsql();

          expect(sql, contains('PARTITION BY LIST ("source")'));
        },
      );
    },
  );

  group(
    'Given a table definition with partitionBy and method range',
    () {
      test(
        'when generating SQL then PARTITION BY RANGE is generated.',
        () {
          var table = TableDefinitionBuilder()
              .withName('example')
              .withPartitionBy(['created'])
              .withPartitionMethod(PartitionMethod.range)
              .build();

          var sql = table.tableCreationToPgsql();

          expect(sql, contains('PARTITION BY RANGE ("created")'));
        },
      );
    },
  );

  group(
    'Given a table definition with partitionBy and method hash',
    () {
      test(
        'when generating SQL then PARTITION BY HASH is generated.',
        () {
          var table = TableDefinitionBuilder()
              .withName('example')
              .withPartitionBy(['userId'])
              .withPartitionMethod(PartitionMethod.hash)
              .withNumPartitions(4)
              .build();

          var sql = table.tableCreationToPgsql();

          expect(sql, contains('PARTITION BY HASH ("userId")'));
        },
      );

      test(
        'when generating SQL with numPartitions then partition tables are created.',
        () {
          var table = TableDefinitionBuilder()
              .withName('users')
              .withPartitionBy(['userId'])
              .withPartitionMethod(PartitionMethod.hash)
              .withNumPartitions(4)
              .build();

          var sql = table.tableCreationToPgsql();

          expect(sql, contains('PARTITION BY HASH ("userId")'));
          expect(sql, contains('CREATE TABLE "users_p0" PARTITION OF "users"'));
          expect(sql, contains('FOR VALUES WITH (MODULUS 4, REMAINDER 0)'));
          expect(sql, contains('CREATE TABLE "users_p1" PARTITION OF "users"'));
          expect(sql, contains('FOR VALUES WITH (MODULUS 4, REMAINDER 1)'));
          expect(sql, contains('CREATE TABLE "users_p2" PARTITION OF "users"'));
          expect(sql, contains('FOR VALUES WITH (MODULUS 4, REMAINDER 2)'));
          expect(sql, contains('CREATE TABLE "users_p3" PARTITION OF "users"'));
          expect(sql, contains('FOR VALUES WITH (MODULUS 4, REMAINDER 3)'));
        },
      );
    },
  );

  group(
    'Given a table definition with partitionBy',
    () {
      test(
        'when generating SQL then PRIMARY KEY includes partitioning columns.',
        () {
          var table = TableDefinitionBuilder()
              .withName('example')
              .withPartitionBy(['source'])
              .build();

          var sql = table.tableCreationToPgsql();

          expect(sql, contains('PRIMARY KEY ("id", "source")'));
          expect(sql, isNot(contains('"id" bigserial PRIMARY KEY')));
        },
      );

      test(
        'when generating SQL with multiple partition columns then PRIMARY KEY includes all partitioning columns.',
        () {
          var table = TableDefinitionBuilder()
              .withName('example')
              .withPartitionBy(['source', 'category'])
              .build();

          var sql = table.tableCreationToPgsql();

          expect(sql, contains('PRIMARY KEY ("id", "source", "category")'));
          expect(sql, isNot(contains('"id" bigserial PRIMARY KEY')));
        },
      );
    },
  );
}
