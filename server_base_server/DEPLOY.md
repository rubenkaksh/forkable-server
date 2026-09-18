# Production Deploy

## Docker image
Build from the **repo root** (not `server_base_server/`), since the build stage needs `pubspec.lock`:
```bash
docker build -f server_base_server/Dockerfile -t server_base .
```
Two-stage build: `dart:3.12.2` compiles a self-contained bundle via `dart build cli` (a minimal single-member workspace pinned to the committed `pubspec.lock`, so the image gets the exact locked dependency versions — not the client/Flutter packages, which the server doesn't need), then an `alpine:latest` runtime stage copies only the bundle, `config/`, `web/`, `migrations/`, and `lib/src/generated/protocol.yaml` (required for the Insights endpoint log filter). Final image is ~29MB. Adapted from a fresh Serverpod 4.0.0 stable scaffold's own Dockerfile per plan §32/§43 — not the ad-hoc pattern this file used to describe.

Verified locally: image builds successfully; a container started with production config (`ENTRYPOINT` reads `config/production.yaml`, passwords via `SERVERPOD_PASSWORD_*` env vars) connected to a throwaway Postgres over a Docker network, applied migrations on startup (`--apply-migrations`), and all three of Serverpod's built-in health probes returned `200`:
```bash
curl http://localhost:8080/livez     # process is up
curl http://localhost:8080/readyz    # process + dependencies (DB) are healthy
curl http://localhost:8080/startupz  # startup sequence completed
```
These are Kubernetes-style probes on the **API server** port (8080), not the web server — wire your orchestrator's liveness/readiness checks to them.

## Migration procedure
Fresh deploy: apply committed migrations using maintenance role, fail fast if migration fails, never continue rollout on failure:
```bash
serverpod apply-migrations  # or `--role maintenance --apply-migrations` on CI/startup
```
Before production migration:
1. Confirm backup/PITR posture (below).
2. Rehearse migration against staging restored from production-like backup.
3. Review generated SQL and destructive warnings (manual intervention allowed in `migration.sql` only for data transforms — keep final schema equal to `definition.sql`).

## Rate limiting
In-app, database-backed limits on auth-sensitive endpoints (plan §17a), configured in `lib/src/core/auth/auth_setup.dart` (`AuthRateLimits`) and wired in `server.dart`:

- **Failed sign-in** (per email): 5 attempts / 5 min in staging/production, 20 / 5 min in development/test. Built into `serverpod_auth_idp`'s `EmailIdpConfig.failedLoginRateLimit`.
- **Password reset requests** (per email): 3 / hour in staging/production, 10 / hour in development/test. Built into `EmailIdpConfig.maxPasswordResetAttempts`.
- **Verification code guesses** (registration + password reset): 3 attempts per code, Serverpod's own default — not overridden.
- **Sign-up start requests** (per email): 5 / 10 min in staging/production, 20 / 10 min in development/test. Not covered by Serverpod's built-ins; added via `RegistrationRateLimiter` (`lib/src/core/auth/registration_rate_limiter.dart`), using the same `DatabaseRateLimiter` primitive the framework uses internally.

All of the above are single-instance, database-table-backed limits (`serverpod_auth_idp_rate_limited_request_attempt` for the built-ins, same table/mechanism for the custom one) — no Redis required for this MVP. Exceeding a limit is logged (`session.log`, warning level, or via the thrown exception which Serverpod logs) for observability. If this deploys behind a gateway/reverse proxy (e.g. Cloudflare/nginx `limit_req`), that can add a coarser IP-based layer in front of these — not required, since the endpoint-level limits above already cover the auth surface. For multi-instance deployments, revisit whether these in-memory-table checks (currently per-database, so already shared across instances via Postgres) need a faster/distributed mechanism once measured load requires it.

Public search / expensive endpoints and webhook endpoints: none exist in this template yet: rate-limit them the same way (`DatabaseRateLimiter` + `RateLimiterConfig`) if/when added.
