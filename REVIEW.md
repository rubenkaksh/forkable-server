# server_base — Implementation Review vs. Serverpod 4 MVP Backend Template

**Review date:** 2026-09-12
**Scope:** All phases of `serverpod_4_mvp_backend_template.md` (Phases 0–8) implemented in `workspaces/server_base`.
**Serverpod version:** `4.0.0-rc.2` (latest published RC; plan §43 source-of-truth says follow stable — but stable 4.0 does not yet exist, so RC scaffold docs govern).
**Repo:** `workspaces/server_base` is its OWN git repo (sandbox `.gitignore` excludes `workspaces/*/`). 10 commits: `bfef435` → `d02a298`.

---

## Implemented

- **Phase 1 — Scaffold:** `serverpod create server_base --template fullstack --ide none`; server + generated client + Flutter app + `AGENTS.md` (Serverpod's own MCP-first agent rules).
- **Phase 2 — Architecture:** feature-first layout: `lib/src/features/{greetings,todos}`, `lib/src/core/{auth,errors}`; generator detects endpoints anywhere under `lib/`.
- **Phase 3 — Auth foundation:** `core/auth/auth.dart` exposes `requireAuthenticatedUser(Session) → String` (UUID). Modular auth wired by scaffold (`serverpod_auth_idp_server`, JWT token manager, `EmailIdpEndpoint` + `JwtRefreshEndpoint`).
- **Phase 4 — Example feature:** complete `todos` feature — `Todo`+`CreateTodoRequest` models (`.spy.yaml`), thin `TodoEndpoint`, `TodoService` (validation, ownership authz, transactional `createMany`), 7 passing server tests, migration `20260912021743873-todos`, and a Flutter `TodosRepository` calling the generated client.
- **Phase 5 — Errors/config:** `core/errors/app_exceptions.dart` — serializable `Unauthorized/Forbidden/NotFound/Validation/Conflict` exceptions typed to the client. Secrets stay in `passwords.yaml` (git-ignored by scaffold).
- **Phase 6 — Tests:** service rules + endpoint contract + authenticated/unauthenticated + DB transaction (rollback) covered by the todos suite; `withServerpod` harness uses embedded Postgres, no Docker.
- **Phase 7 — CI:** `.github/workflows/ci.yml` — setup-dart 3.13.2 → `pub get` → `serverpod generate` → **fail on stale generated code** (`git diff --exit-code`) → `dart format --set-exit-if-changed` → `dart analyze --fatal-infos` → `dart test`; separate flutter job (format + analyze).
- **Phase 8 — Production baseline:** `server_base_server/Dockerfile` (`dart build cli` bundle, entrypoint `build/bin/main.dart`), `server_base_server/DEPLOY.md` (migration procedure, backup/PITR posture note, rate limiting = gateway-level deferral).
- **Template docs:** `README.md` teaching `serverpod start`, commands, conventions.
- **Live verification:** `serverpod start` boots embedded Postgres, auto-applies both migrations, server + web (:8082) + MCP socket up, HTTP 200.

## Architecture

```
Flutter (features/todos) ─generated client─▶ Endpoint (thin)
                                          └▶ requireAuthenticatedUser → Service (rules)
                                               └▶ ORM (Todo.db) in transaction
```
Principle honored: **thin endpoint, small service, typed model, direct ORM; abstraction only when justified** (policy/repository NOT added — confirmed per plan §8/§17).

## Serverpod version
`4.0.0-rc.2`. API deltas discovered vs. plan's 4.0-beta assumptions (verified against installed sources):
- Auth identity is `session.authenticated?.userIdentifier` (String UUID) — NOT `session.auth` (removed) and NOT `int userId`.
- ORM sorting: `orderBy: (t) => t.createdAt.desc()` — `orderDescending` removed in 4.0.
- Test auth: `sessionBuilder.copyWith(authentication: AuthenticationOverride.authenticationInfo(id, {}))`.
- Unauthenticated test calls surface our own `UnauthorizedException` (not the harness type) once thrown in the endpoint.
- Transaction tests need `rollbackDatabase: RollbackDatabase.disabled` on their `withServerpod` block (harness forbids nested implicit transactions).
- Generated client getter is `client.todo` (singular), not `client.todos`.

## Database
PostgreSQL via Serverpod ORM. Embedded Postgres for dev/test (`config/*.yaml` `dataPath`). `todos` table + `todos_userId_idx` from migration. Production = managed Postgres (plan §9, §31a) — config only, no instance provisioned here.

## Auth
Modular `serverpod_auth_idp` (email) + JWT. `requireAuthenticatedUser` enforces identity server-side. Authorization inline (ownership check in `TodoService.complete`) — no permission framework (per plan §17). Client certs/secrets never logged.

## Tests
`dart test` → **7/7 pass** (greeting + 6 todos incl. transaction rollback). `dart analyze` clean (server + client). `flutter analyze` clean. CI is green-by-construction (stale-check validated: `generate` → zero diff on committed tree).

## Commands verified
- `serverpod start` ✅ (live: migration applied, HTTP 200, MCP socket)
- `serverpod generate` ✅ (zero diff on clean tree)
- `serverpod create-migration --tag todos` ✅
- `dart analyze` ✅ (both packages)
- `dart test` ✅ (7/7)
- `flutter analyze` ✅

## Known limitations
1. **CI not dry-run on a real PR** — repo is local-only (no `remote origin`); pushing needs user setup/permission.
2. **`docker build` never actually executed** — Dockerfile path (`build/bin/main.dart`) follows the documented `dart build cli` layout but is unverified at runtime.
3. **Live Flutter sign-in acceptance (plan §37a/Phase 3) untested** — needs a running `serverpod start` + Flutter driver session, which this tool set can't drive headlessly.
4. **Rate limiting** deferred to gateway/reverse proxy (documented in DEPLOY.md); no in-app limiter (acceptable for MVP per plan §17a until no gateway exists).
5. **Flutter todos is a repository only** — no UI screen wired (feature is demonstrable but not visually clickable yet).
6. **Serverpod 4 = RC, not stable** — pin to stable when released and re-verify APIs (plan §43).

## Follow-up opportunities
- Build + smoke-test the Docker image on a CI matrix; add `--role maintenance --apply-migrations` startup job.
- Add a Flutter `todos` page/screen using `TodosRepository`; run `flutter test` critical-journey.
- Implement gateway or in-app rate limiting if deploy target lacks a reverse proxy.
- Add Sentry/error-tracking integration boundary (plan §37a deferred).
- After Serverpod 4.0 stable ships: re-run Phase 0 verification, bump versions, re-test.
