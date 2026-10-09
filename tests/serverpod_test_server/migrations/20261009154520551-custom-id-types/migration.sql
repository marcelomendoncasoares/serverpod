BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "custom_id_related" (
    "id" text PRIMARY KEY,
    "stringId" text NOT NULL,
    "dateTimeId" timestamp without time zone NOT NULL,
    "durationId" bigint NOT NULL
);

--
-- ACTION CREATE TABLE
--
CREATE TABLE "date_time_id_default_model" (
    "id" timestamp without time zone PRIMARY KEY DEFAULT CURRENT_TIMESTAMP,
    "value" text NOT NULL
);

--
-- ACTION CREATE TABLE
--
CREATE TABLE "date_time_id_default_persist" (
    "id" timestamp without time zone PRIMARY KEY DEFAULT CURRENT_TIMESTAMP,
    "value" text NOT NULL
);

--
-- ACTION CREATE TABLE
--
CREATE TABLE "date_time_id_model" (
    "id" timestamp without time zone PRIMARY KEY,
    "value" text NOT NULL
);

--
-- ACTION CREATE TABLE
--
CREATE TABLE "duration_id_model" (
    "id" bigint PRIMARY KEY,
    "value" text NOT NULL
);

--
-- ACTION CREATE TABLE
--
CREATE TABLE "int_id_model" (
    "id" bigint PRIMARY KEY,
    "value" text NOT NULL
);

--
-- ACTION CREATE TABLE
--
CREATE TABLE "string_id_model" (
    "id" text PRIMARY KEY,
    "value" text NOT NULL
);

--
-- ACTION CREATE TABLE
--
CREATE TABLE "uuid_id_model" (
    "id" uuid PRIMARY KEY,
    "value" text NOT NULL
);

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "custom_id_related"
    ADD CONSTRAINT "custom_id_related_fk_0"
    FOREIGN KEY("stringId")
    REFERENCES "string_id_model"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "custom_id_related"
    ADD CONSTRAINT "custom_id_related_fk_1"
    FOREIGN KEY("dateTimeId")
    REFERENCES "date_time_id_model"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "custom_id_related"
    ADD CONSTRAINT "custom_id_related_fk_2"
    FOREIGN KEY("durationId")
    REFERENCES "duration_id_model"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR serverpod_test
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_test', '20261009154520551-custom-id-types', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261009154520551-custom-id-types', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20260824182259319', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260824182259319', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth', '20260824182343939', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260824182343939', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_test_module
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_test_module', '20260824182503455', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260824182503455', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_test_shared_module
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_test_shared_module', '20260824182514685', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260824182514685', "timestamp" = now();


COMMIT;
