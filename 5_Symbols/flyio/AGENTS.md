# 🤖 AGENTS.md — Fly.io Deployment

> **Agent guidance for working on the Kilo CLI Fly.io remote VM.**

---

## Security Rule #1: No Credentials in Git

**Never** commit API keys, tokens, passwords, or private keys to this repository.

| What | Where It Lives | Never In |
|------|---------------|----------|
| Kilo API key | Azure Key Vault → Fly secrets | Git, Dockerfile, fly.toml, scripts |
| SSH private key | Your local `~/.ssh/` | This repo |
| Azure SP creds (if any) | Fly secrets or local env | This repo |

**Only `authorized_keys` (public SSH keys) may be added to this directory.**

---

## Architecture

The deployment follows a **host-side secret injection** model:

```
macOS (your laptop)
  ├─ az keyvault secret show  → fetches Kilo API key from Azure
  └─ flyctl secrets set       → pushes key into Fly.io encrypted store

Fly Machine (container)
  └─ KILO_API_KEY env var     → read by Kilo CLI at runtime
```

The **container does not contain Azure CLI**. It receives the secret directly from Fly.io's encrypted secret store via the `KILO_API_KEY` environment variable.

---

## Modification Rules

### If editing `deploy.sh`
- **Never** `echo`, `printf`, or log the secret value or its length after fetching.
- The script already pipes the key directly: `printf '%s' "$API_KEY" | flyctl secrets set KILO_API_KEY=-`
- Keep the `--app "$FLY_APP_NAME"` flag explicit to avoid targeting the wrong app.

### If editing `entrypoint.sh`
- **Never** print the value of `KILO_API_KEY`.
- Logging the presence of the key (boolean) and its length are acceptable for debugging.
- If you need to validate the key, check existence only: `[ -n "${KILO_API_KEY:-}" ]`.

### If editing `Dockerfile`
- Do **not** add `ARG` or `ENV` lines that accept secrets at build time.
- Do **not** `COPY` any file that might contain a secret into the image.
- The only file copied at build time is `authorized_keys` (public keys only).

### If editing `fly.toml`
- Do **not** add `env` entries with hardcoded secret values.
- `KILO_API_KEY` must be injected via `flyctl secrets set`, not `fly.toml`.

---

## Adding New Files

Before committing any new file in `5_Symbols/flyio/`, run this self-check:

```bash
grep -riE "(eyJ[a-zA-Z0-9_-]*\.eyJ|api[_-]?key|apikey|secret|token|password|private.?key)" 5_Symbols/flyio/
```

If the command returns any match, **stop** and remove the credential before committing.

---

## Testing Safely

- Use `flyctl secrets list --app kilo-remote` to confirm a secret is set (values are masked).
- Use `flyctl ssh console --app kilo-remote` to verify the runtime environment.
- Inside the VM, `env | grep KILO` should show `KILO_API_KEY=<REDACTED>` — Fly masks it in process listings.

---

## Commit Message Convention

Follow the repo standard: descriptive with emojis for visual distinction.

Examples:
- `🚀 Add Fly.io deployment formula`
- `🔒 Harden secret handling in deploy.sh`
- `📖 Update fly.io operator README`

---

*[← Root AGENTS.md](../../AGENTS.md)*
