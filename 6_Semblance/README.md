# 🩹 Stage 6 — Semblance

> **The "Scars"** — Error logs, near-misses, workarounds, and the gap between plan and reality.

---

## 🐛 Error Log

### Mac Errors

| # | Date | Error | Fix | Status |
|---|------|-------|-----|--------|
| M01 | 2026-02-25 | Homebrew not in PATH after Apple Silicon install | Added `eval "$(/opt/homebrew/bin/brew shellenv)"` to `.zprofile` | ✅ Fixed |
| M02 | — | `ollama pull` times out on corporate network | Set `HTTPS_PROXY` env var | ⏳ Pending |
| M03 | — | Docker Desktop requires manual first-launch | Added interactive prompt in install script | ✅ Fixed |

### Windows Errors

| # | Date | Error | Fix | Status |
|---|------|-------|-----|--------|
| W01 | 2026-02-25 | `kilocode` not found after npm install | Manually added npm global bin to PATH | ✅ Fixed |
| W02 | — | PowerShell execution policy blocks script | Added `Set-ExecutionPolicy RemoteSigned` step | ✅ Fixed |
| W03 | — | Windows Defender quarantines `kilocode.exe` | Add exclusion for `%AppData%\npm` | ⏳ Pending |
| W04 | — | WSL2 can't reach Windows Docker Qdrant | Use `host.docker.internal` instead of `localhost` | ✅ Fixed |

### AI Stack Errors

| # | Date | Error | Fix | Status |
|---|------|-------|-----|--------|
| A01 | — | Qdrant collection size mismatch (384 vs 4096) | Delete + recreate collection with correct dims | ✅ Fixed |
| A02 | — | Ollama returns 500 when model loading | Wait 10s after first pull, retry | ⏳ Pending |
| A03 | — | `nomic-embed-text` returns truncated embeddings | Set `num_ctx` parameter to 8192 | ⏳ Pending |

---

## ⚠️ Near-Misses

### "The Silent PATH Problem" (macOS)
After installing Node.js via Homebrew on Apple Silicon, `npm` was available but
`npm install -g` put binaries in `/opt/homebrew/bin/` which wasn't always in PATH
for new terminal sessions. The fix was to ensure `.zprofile` sources Homebrew env.

### "The Wrong Architecture" (macOS)
On Apple Silicon running Rosetta, some npm packages compiled for x64.
KiloCode CLI was installed under x64 Node but run with arm64 shell.
Fix: ensure `node` and `kilocode` both resolve to the same architecture.

### "The Port 6333 Ghost" (Windows)
After uninstalling an old Qdrant instance, port 6333 remained occupied by a
zombie Docker container. Fix: `docker rm -f qdrant` before reinstalling.

---

## 📁 Files in This Folder

| File | Purpose |
|------|---------|
| `README.md` | This file — error log + near-misses |
| `error_log.md` | Extended error log with full stack traces |

---

*[← Stage 5](../markdown_renderer.html?file=5_Symbols/README.md) · [Stage 7 →](../markdown_renderer.html?file=7_Testing_Known/README.md)*
