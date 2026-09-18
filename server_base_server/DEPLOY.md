# Production Deploy

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
