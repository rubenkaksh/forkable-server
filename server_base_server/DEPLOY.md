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
Defer to gateway/reverse proxy (e.g. Cloudflare/nginx `limit_req`) for MVP. No in-app rate limiter implemented — follow-up needed if no gateway present. Applies to: auth endpoints, recovery, public search (plan §17a).
