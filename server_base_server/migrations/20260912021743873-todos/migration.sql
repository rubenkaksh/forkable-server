BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "todos" (
    "id" bigserial PRIMARY KEY,
    "userId" text NOT NULL,
    "title" text NOT NULL,
    "isDone" boolean NOT NULL,
    "createdAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE INDEX "todos_userId_idx" ON "todos" USING btree ("userId");


--
-- MIGRATION VERSION FOR server_base
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('server_base', '20260912021743873-todos', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260912021743873-todos', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20260824182259319', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260824182259319', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_idp
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_idp', '20260824182405944', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260824182405944', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_core
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_core', '20260824182354731', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260824182354731', "timestamp" = now();


COMMIT;
