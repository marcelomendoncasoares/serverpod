BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "secured_record" (
    "id" bigserial PRIMARY KEY,
    "ownerId" uuid NOT NULL,
    "name" text NOT NULL
);

-- Row-level security
ALTER TABLE "secured_record" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "secured_record" FORCE ROW LEVEL SECURITY;
CREATE POLICY "secured_record_ownerId_rls" ON "secured_record"
    USING ("ownerId" = NULLIF(current_setting('serverpod.user_id', true), '')::uuid);


--
-- MIGRATION VERSION FOR serverpod_test
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_test', '20260630113436580', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260630113436580', "timestamp" = now();

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
