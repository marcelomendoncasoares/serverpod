BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "decimal_default" (
    "id" INTEGER PRIMARY KEY,
    "decimalDefault" TEXT NOT NULL DEFAULT ('10.5'),
    "decimalDefaultNull" TEXT DEFAULT ('20.5')
) STRICT;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "decimal_default_mix" (
    "id" INTEGER PRIMARY KEY,
    "decimalDefaultAndDefaultModel" TEXT NOT NULL DEFAULT ('10.5'),
    "decimalDefaultAndDefaultPersist" TEXT NOT NULL DEFAULT ('20.5'),
    "decimalDefaultModelAndDefaultPersist" TEXT NOT NULL DEFAULT ('20.5')
) STRICT;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "decimal_default_model" (
    "id" INTEGER PRIMARY KEY,
    "decimalDefaultModelStr" TEXT NOT NULL,
    "decimalDefaultModelStrNull" TEXT
) STRICT;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "decimal_default_persist" (
    "id" INTEGER PRIMARY KEY,
    "decimalDefaultPersist" TEXT DEFAULT ('10.5')
) STRICT;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "object_with_decimal" (
    "id" INTEGER PRIMARY KEY,
    "decimalValue" TEXT NOT NULL,
    "decimalValueNull" TEXT
) STRICT;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "object_with_decimal_precision" (
    "id" INTEGER PRIMARY KEY,
    "price" INTEGER NOT NULL,
    "priceNullable" INTEGER,
    "quantity" TEXT NOT NULL,
    "unbounded" TEXT NOT NULL,
    "priceWithDefault" INTEGER NOT NULL DEFAULT (999),
    "priceWithDefaultNullable" INTEGER DEFAULT (123),
    "quantityWithDefault" TEXT NOT NULL DEFAULT ('100.0000')
) STRICT;

--
-- STORE COLUMN TYPES FOR MIGRATIONS
--
DROP TABLE IF EXISTS "serverpod_sqlite_schema";

CREATE TABLE "serverpod_sqlite_schema" (
    "table_name" TEXT NOT NULL,
    "column_name" TEXT NOT NULL,
    "column_type" TEXT NOT NULL,
    "column_vector_dimension" INTEGER,
    "column_decimal_precision" INTEGER,
    "column_decimal_scale" INTEGER,
    PRIMARY KEY ("table_name", "column_name")
);

INSERT INTO "serverpod_sqlite_schema" VALUES
    ('address_uuid', 'id', 'uuid', NULL, NULL, NULL),
    ('arena_uuid', 'id', 'uuid', NULL, NULL, NULL),
    ('bool_default', 'boolDefaultTrue', 'boolean', NULL, NULL, NULL),
    ('bool_default', 'boolDefaultFalse', 'boolean', NULL, NULL, NULL),
    ('bool_default', 'boolDefaultNullFalse', 'boolean', NULL, NULL, NULL),
    ('bool_default_mix', 'boolDefaultAndDefaultModel', 'boolean', NULL, NULL, NULL),
    ('bool_default_mix', 'boolDefaultAndDefaultPersist', 'boolean', NULL, NULL, NULL),
    ('bool_default_mix', 'boolDefaultModelAndDefaultPersist', 'boolean', NULL, NULL, NULL),
    ('bool_default_model', 'boolDefaultModelTrue', 'boolean', NULL, NULL, NULL),
    ('bool_default_model', 'boolDefaultModelFalse', 'boolean', NULL, NULL, NULL),
    ('bool_default_model', 'boolDefaultModelNullFalse', 'boolean', NULL, NULL, NULL),
    ('bool_default_persist', 'boolDefaultPersistTrue', 'boolean', NULL, NULL, NULL),
    ('bool_default_persist', 'boolDefaultPersistFalse', 'boolean', NULL, NULL, NULL),
    ('changed_id_type_self', 'id', 'uuid', NULL, NULL, NULL),
    ('changed_id_type_self', 'nextId', 'uuid', NULL, NULL, NULL),
    ('changed_id_type_self', 'parentId', 'uuid', NULL, NULL, NULL),
    ('citizen_int', 'companyId', 'uuid', NULL, NULL, NULL),
    ('citizen_int', 'oldCompanyId', 'uuid', NULL, NULL, NULL),
    ('comment_int', 'orderId', 'uuid', NULL, NULL, NULL),
    ('company_uuid', 'id', 'uuid', NULL, NULL, NULL),
    ('course_uuid', 'id', 'uuid', NULL, NULL, NULL),
    ('datetime_default', 'dateTimeDefaultNow', 'timestampWithoutTimeZone', NULL, NULL, NULL),
    ('datetime_default', 'dateTimeDefaultStr', 'timestampWithoutTimeZone', NULL, NULL, NULL),
    ('datetime_default', 'dateTimeDefaultStrNull', 'timestampWithoutTimeZone', NULL, NULL, NULL),
    ('datetime_default_mix', 'dateTimeDefaultAndDefaultModel', 'timestampWithoutTimeZone', NULL, NULL, NULL),
    ('datetime_default_mix', 'dateTimeDefaultAndDefaultPersist', 'timestampWithoutTimeZone', NULL, NULL, NULL),
    ('datetime_default_mix', 'dateTimeDefaultModelAndDefaultPersist', 'timestampWithoutTimeZone', NULL, NULL, NULL),
    ('datetime_default_model', 'dateTimeDefaultModelNow', 'timestampWithoutTimeZone', NULL, NULL, NULL),
    ('datetime_default_model', 'dateTimeDefaultModelStr', 'timestampWithoutTimeZone', NULL, NULL, NULL),
    ('datetime_default_model', 'dateTimeDefaultModelStrNull', 'timestampWithoutTimeZone', NULL, NULL, NULL),
    ('datetime_default_persist', 'dateTimeDefaultPersistNow', 'timestampWithoutTimeZone', NULL, NULL, NULL),
    ('datetime_default_persist', 'dateTimeDefaultPersistStr', 'timestampWithoutTimeZone', NULL, NULL, NULL),
    ('decimal_default', 'decimalDefault', 'decimal', NULL, NULL, NULL),
    ('decimal_default', 'decimalDefaultNull', 'decimal', NULL, NULL, NULL),
    ('decimal_default_mix', 'decimalDefaultAndDefaultModel', 'decimal', NULL, NULL, NULL),
    ('decimal_default_mix', 'decimalDefaultAndDefaultPersist', 'decimal', NULL, NULL, NULL),
    ('decimal_default_mix', 'decimalDefaultModelAndDefaultPersist', 'decimal', NULL, NULL, NULL),
    ('decimal_default_model', 'decimalDefaultModelStr', 'decimal', NULL, NULL, NULL),
    ('decimal_default_model', 'decimalDefaultModelStrNull', 'decimal', NULL, NULL, NULL),
    ('decimal_default_persist', 'decimalDefaultPersist', 'decimal', NULL, NULL, NULL),
    ('enrollment_int', 'studentId', 'uuid', NULL, NULL, NULL),
    ('enrollment_int', 'courseId', 'uuid', NULL, NULL, NULL),
    ('object_with_bit', 'bit', 'bit', 512, NULL, NULL),
    ('object_with_bit', 'bitNullable', 'bit', 512, NULL, NULL),
    ('object_with_bit', 'bitIndexedHnsw', 'bit', 512, NULL, NULL),
    ('object_with_bit', 'bitIndexedHnswWithParams', 'bit', 512, NULL, NULL),
    ('object_with_bit', 'bitIndexedIvfflat', 'bit', 512, NULL, NULL),
    ('object_with_bit', 'bitIndexedIvfflatWithParams', 'bit', 512, NULL, NULL),
    ('object_with_decimal', 'decimalValue', 'decimal', NULL, NULL, NULL),
    ('object_with_decimal', 'decimalValueNull', 'decimal', NULL, NULL, NULL),
    ('object_with_decimal_precision', 'price', 'decimal', NULL, 10, 2),
    ('object_with_decimal_precision', 'priceNullable', 'decimal', NULL, 10, 2),
    ('object_with_decimal_precision', 'quantity', 'decimal', NULL, 19, 4),
    ('object_with_decimal_precision', 'unbounded', 'decimal', NULL, NULL, NULL),
    ('object_with_decimal_precision', 'priceWithDefault', 'decimal', NULL, 10, 2),
    ('object_with_decimal_precision', 'priceWithDefaultNullable', 'decimal', NULL, 10, 2),
    ('object_with_decimal_precision', 'quantityWithDefault', 'decimal', NULL, 19, 4),
    ('object_with_dynamic', 'payload', 'json', NULL, NULL, NULL),
    ('object_with_dynamic', 'jsonbPayload', 'jsonb', NULL, NULL, NULL),
    ('object_with_dynamic', 'payloadList', 'json', NULL, NULL, NULL),
    ('object_with_dynamic', 'payloadMap', 'json', NULL, NULL, NULL),
    ('object_with_dynamic', 'payloadSet', 'json', NULL, NULL, NULL),
    ('object_with_dynamic', 'payloadMapWithDynamicKeys', 'jsonb', NULL, NULL, NULL),
    ('object_with_enum', 'enumList', 'json', NULL, NULL, NULL),
    ('object_with_enum', 'nullableEnumList', 'json', NULL, NULL, NULL),
    ('object_with_enum', 'enumListList', 'json', NULL, NULL, NULL),
    ('object_with_enum_enhanced', 'byIndexList', 'json', NULL, NULL, NULL),
    ('object_with_enum_enhanced', 'byNameList', 'json', NULL, NULL, NULL),
    ('object_with_half_vector', 'halfVector', 'halfvec', 512, NULL, NULL),
    ('object_with_half_vector', 'halfVectorNullable', 'halfvec', 512, NULL, NULL),
    ('object_with_half_vector', 'halfVectorIndexedHnsw', 'halfvec', 512, NULL, NULL),
    ('object_with_half_vector', 'halfVectorIndexedHnswWithParams', 'halfvec', 512, NULL, NULL),
    ('object_with_half_vector', 'halfVectorIndexedIvfflat', 'halfvec', 512, NULL, NULL),
    ('object_with_half_vector', 'halfVectorIndexedIvfflatWithParams', 'halfvec', 512, NULL, NULL),
    ('object_with_jsonb', 'notJsonb', 'json', NULL, NULL, NULL),
    ('object_with_jsonb', 'jsonb', 'jsonb', NULL, NULL, NULL),
    ('object_with_jsonb', 'jsonbMap', 'jsonb', NULL, NULL, NULL),
    ('object_with_jsonb', 'jsonbObject', 'jsonb', NULL, NULL, NULL),
    ('object_with_jsonb', 'jsonbIndexed', 'jsonb', NULL, NULL, NULL),
    ('object_with_jsonb', 'jsonbIndexedGin', 'jsonb', NULL, NULL, NULL),
    ('object_with_jsonb', 'jsonbIndexedGinJsonbPath', 'jsonb', NULL, NULL, NULL),
    ('object_with_jsonb', 'jsonbIndexedImplicitGin', 'jsonb', NULL, NULL, NULL),
    ('object_with_jsonb', 'nullableJsonb', 'jsonb', NULL, NULL, NULL),
    ('object_with_jsonb_class_level', 'implicitJsonb', 'jsonb', NULL, NULL, NULL),
    ('object_with_jsonb_class_level', 'explicitJsonb', 'jsonb', NULL, NULL, NULL),
    ('object_with_jsonb_class_level', 'json', 'json', NULL, NULL, NULL),
    ('object_with_object', 'data', 'json', NULL, NULL, NULL),
    ('object_with_object', 'nullableData', 'json', NULL, NULL, NULL),
    ('object_with_object', 'dataList', 'json', NULL, NULL, NULL),
    ('object_with_object', 'nullableDataList', 'json', NULL, NULL, NULL),
    ('object_with_object', 'listWithNullableData', 'json', NULL, NULL, NULL),
    ('object_with_object', 'nullableListWithNullableData', 'json', NULL, NULL, NULL),
    ('object_with_object', 'nestedDataList', 'json', NULL, NULL, NULL),
    ('object_with_object', 'nestedDataListInMap', 'json', NULL, NULL, NULL),
    ('object_with_object', 'nestedDataMap', 'json', NULL, NULL, NULL),
    ('object_with_sparse_vector', 'sparseVector', 'sparsevec', 512, NULL, NULL),
    ('object_with_sparse_vector', 'sparseVectorNullable', 'sparsevec', 512, NULL, NULL),
    ('object_with_sparse_vector', 'sparseVectorIndexedHnsw', 'sparsevec', 512, NULL, NULL),
    ('object_with_sparse_vector', 'sparseVectorIndexedHnswWithParams', 'sparsevec', 512, NULL, NULL),
    ('object_with_uuid', 'uuid', 'uuid', NULL, NULL, NULL),
    ('object_with_uuid', 'uuidNullable', 'uuid', NULL, NULL, NULL),
    ('object_with_vector', 'vector', 'vector', 512, NULL, NULL),
    ('object_with_vector', 'vectorNullable', 'vector', 512, NULL, NULL),
    ('object_with_vector', 'vectorIndexedHnsw', 'vector', 512, NULL, NULL),
    ('object_with_vector', 'vectorIndexedHnswWithParams', 'vector', 512, NULL, NULL),
    ('object_with_vector', 'vectorIndexedIvfflat', 'vector', 512, NULL, NULL),
    ('object_with_vector', 'vectorIndexedIvfflatWithParams', 'vector', 512, NULL, NULL),
    ('order_uuid', 'id', 'uuid', NULL, NULL, NULL),
    ('player_uuid', 'id', 'uuid', NULL, NULL, NULL),
    ('server_only_changed_id_field_class', 'id', 'uuid', NULL, NULL, NULL),
    ('simple_date_time', 'dateTime', 'timestampWithoutTimeZone', NULL, NULL, NULL),
    ('student_uuid', 'id', 'uuid', NULL, NULL, NULL),
    ('team_int', 'arenaId', 'uuid', NULL, NULL, NULL),
    ('types', 'aBool', 'boolean', NULL, NULL, NULL),
    ('types', 'aDateTime', 'timestampWithoutTimeZone', NULL, NULL, NULL),
    ('types', 'aUuid', 'uuid', NULL, NULL, NULL),
    ('types', 'aVector', 'vector', 3, NULL, NULL),
    ('types', 'aHalfVector', 'halfvec', 3, NULL, NULL),
    ('types', 'aSparseVector', 'sparsevec', 3, NULL, NULL),
    ('types', 'aBit', 'bit', 3, NULL, NULL),
    ('types', 'aList', 'json', NULL, NULL, NULL),
    ('types', 'aMap', 'json', NULL, NULL, NULL),
    ('types', 'aSet', 'json', NULL, NULL, NULL),
    ('types', 'aRecord', 'json', NULL, NULL, NULL),
    ('uuid_default', 'uuidDefaultRandom', 'uuid', NULL, NULL, NULL),
    ('uuid_default', 'uuidDefaultRandomV7', 'uuid', NULL, NULL, NULL),
    ('uuid_default', 'uuidDefaultRandomNull', 'uuid', NULL, NULL, NULL),
    ('uuid_default', 'uuidDefaultStr', 'uuid', NULL, NULL, NULL),
    ('uuid_default', 'uuidDefaultStrNull', 'uuid', NULL, NULL, NULL),
    ('uuid_default_mix', 'uuidDefaultAndDefaultModel', 'uuid', NULL, NULL, NULL),
    ('uuid_default_mix', 'uuidDefaultAndDefaultPersist', 'uuid', NULL, NULL, NULL),
    ('uuid_default_mix', 'uuidDefaultModelAndDefaultPersist', 'uuid', NULL, NULL, NULL),
    ('uuid_default_model', 'uuidDefaultModelRandom', 'uuid', NULL, NULL, NULL),
    ('uuid_default_model', 'uuidDefaultModelRandomV7', 'uuid', NULL, NULL, NULL),
    ('uuid_default_model', 'uuidDefaultModelRandomNull', 'uuid', NULL, NULL, NULL),
    ('uuid_default_model', 'uuidDefaultModelStr', 'uuid', NULL, NULL, NULL),
    ('uuid_default_model', 'uuidDefaultModelStrNull', 'uuid', NULL, NULL, NULL),
    ('uuid_default_persist', 'uuidDefaultPersistRandom', 'uuid', NULL, NULL, NULL),
    ('uuid_default_persist', 'uuidDefaultPersistRandomV7', 'uuid', NULL, NULL, NULL),
    ('uuid_default_persist', 'uuidDefaultPersistStr', 'uuid', NULL, NULL, NULL),
    ('serverpod_cloud_storage', 'addedTime', 'timestampWithoutTimeZone', NULL, NULL, NULL),
    ('serverpod_cloud_storage', 'expiration', 'timestampWithoutTimeZone', NULL, NULL, NULL),
    ('serverpod_cloud_storage', 'verified', 'boolean', NULL, NULL, NULL),
    ('serverpod_cloud_storage_direct_upload', 'expiration', 'timestampWithoutTimeZone', NULL, NULL, NULL),
    ('serverpod_future_call', 'time', 'timestampWithoutTimeZone', NULL, NULL, NULL),
    ('serverpod_future_call', 'scheduling', 'json', NULL, NULL, NULL),
    ('serverpod_future_call_claim', 'lastHeartbeatTime', 'timestampWithoutTimeZone', NULL, NULL, NULL),
    ('serverpod_health_connection_info', 'timestamp', 'timestampWithoutTimeZone', NULL, NULL, NULL),
    ('serverpod_health_metric', 'timestamp', 'timestampWithoutTimeZone', NULL, NULL, NULL),
    ('serverpod_health_metric', 'isHealthy', 'boolean', NULL, NULL, NULL),
    ('serverpod_log', 'time', 'timestampWithoutTimeZone', NULL, NULL, NULL),
    ('serverpod_message_log', 'slow', 'boolean', NULL, NULL, NULL),
    ('serverpod_migrations', 'timestamp', 'timestampWithoutTimeZone', NULL, NULL, NULL),
    ('serverpod_query_log', 'slow', 'boolean', NULL, NULL, NULL),
    ('serverpod_runtime_settings', 'logSettings', 'json', NULL, NULL, NULL),
    ('serverpod_runtime_settings', 'logSettingsOverrides', 'json', NULL, NULL, NULL),
    ('serverpod_runtime_settings', 'logServiceCalls', 'boolean', NULL, NULL, NULL),
    ('serverpod_runtime_settings', 'logMalformedCalls', 'boolean', NULL, NULL, NULL),
    ('serverpod_session_log', 'time', 'timestampWithoutTimeZone', NULL, NULL, NULL),
    ('serverpod_session_log', 'slow', 'boolean', NULL, NULL, NULL),
    ('serverpod_session_log', 'isOpen', 'boolean', NULL, NULL, NULL),
    ('serverpod_session_log', 'touched', 'timestampWithoutTimeZone', NULL, NULL, NULL);

--
-- MIGRATION VERSION FOR serverpod_test_sqlite
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_test_sqlite', '20260512183028996', (unixepoch('now', 'subsecond') * 1000))
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260512183028996', "timestamp" = (unixepoch('now', 'subsecond') * 1000);

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20260416151914983-insights-perf', (unixepoch('now', 'subsecond') * 1000))
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260416151914983-insights-perf', "timestamp" = (unixepoch('now', 'subsecond') * 1000);


COMMIT;
