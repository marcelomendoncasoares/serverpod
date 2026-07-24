BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "custom_class_roundtrip_table" (
    "id" bigserial PRIMARY KEY,
    "intData" bigint NOT NULL,
    "doubleData" double precision NOT NULL,
    "stringData" text NOT NULL,
    "boolData" boolean NOT NULL,
    "dateTimeData" timestamp without time zone NOT NULL,
    "mapData" json NOT NULL,
    "jsonbMapData" jsonb NOT NULL,
    "nullableIntData" bigint,
    "nullableMapData" json
);


--
-- MIGRATION VERSION FOR serverpod_test
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_test', '20260724164841258', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260724164841258', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20260416151914983-insights-perf', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260416151914983-insights-perf', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth', '20260417182239578', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260417182239578', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_test_module
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_test_module', '20260417182416941', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260417182416941', "timestamp" = now();


COMMIT;
