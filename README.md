# server_base — Serverpod 4 MVP Backend Template

Reusable backend template for rapid Flutter MVP development (plan: serverpod_4_mvp_backend_template.md).
Serverpod **4.0.0** (stable).

## Start (development)

```bash
export PATH="$HOME/fvm/versions/3.32.0/bin:$PATH"  # system dart broken on this machine
cd server_base_server
serverpod start     # embedded Postgres + migrations + server + Flutter app + hot reload
```

Workspace: `server_base_server` (API), `server_base_client` (generated, never edit), `server_base_flutter`.

## Workflow

```bash
serverpod start                # dev (watch mode)
serverpod generate             # after .spy.yaml changes (also incremental via start)
serverpod create-migration --tag "feature"   # after DB model changes
dart test                      # from server_base_server (embedded PG, no Docker)
dart analyze && dart format .
```

## Conventions

- **Feature-first**: `lib/src/features/<feature>/` — endpoint (thin: identity + delegation), service (business rules), `<model>.spy.yaml`, optional policy/repository only when complexity proves it.
- **Core**: `lib/src/core/auth/auth.dart` (`requireAuthenticatedUser(session)` → String UUID), `lib/src/core/errors/app_exceptions.dart` (typed: Unauthorized/Forbidden/NotFound/Validation/Conflict — serializable to client).
- **Models are source of truth**; DB-level uniqueness over service checks; transactions for atomic multi-writes (see `TodoService.createMany`).
- Never edit `generated/` or `server_base_client/`.
- Agent rules: see `AGENTS.md`.

## Deploy

See `server_base_server/DEPLOY.md` (migrations, backup/PITR posture, rate limiting = gateway-level). Dockerfile in `server_base_server/`.
