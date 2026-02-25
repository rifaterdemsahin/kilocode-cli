# ✅ Stage 7 — Testing Known

> **The "Proof"** — Validation against Stage 1 objectives, testing checklists, and outcome confirmation.

---

## 📺 Reference Video

> **Understanding the test setup:** Watch this for context on CLI tool testing
> 🎬 [Testing CLI Tools on Mac & Windows — YouTube](https://www.youtube.com/@RifatErdemSahin)

---

## 🧪 Master Testing Checklist

### Platform: macOS

- [ ] `kilocode --version` prints version without errors
- [ ] `kilocode doctor` shows all green
- [ ] Ollama API responds at `http://localhost:11434/api/tags`
- [ ] `nomic-embed-text` model listed in `ollama list`
- [ ] Qdrant health check passes at `http://localhost:6333/healthz`
- [ ] `kilocode_docs` collection exists with `size: 4096`
- [ ] `kilocode index .` completes on sample project (>0 vectors)
- [ ] `kilocode ask "what does main.ts do?"` returns relevant answer
- [ ] Response time < 3 seconds for typical query
- [ ] Config persists across terminal restarts

### Platform: Windows

- [ ] `kilocode --version` works in PowerShell 7
- [ ] `kilocode doctor` shows all green
- [ ] Ollama service running (Windows Services or systray)
- [ ] `nomic-embed-text` model available
- [ ] Qdrant container running in Docker Desktop
- [ ] `kilocode index .` works from PowerShell
- [ ] `kilocode ask "..."` returns answer
- [ ] PATH persists after system restart
- [ ] Works from both PowerShell 7 and Windows Terminal

---

## 🎯 Validation Against Stage 1 OKRs

### O1: macOS Setup
| OKR | Test | Result |
|-----|------|--------|
| Install without errors | `./install_mac.sh` exit 0 | ⏳ |
| Ollama running with nomic-embed-text | `ollama list` + API check | ⏳ |
| `kilocode ask` returns result | Manual test | ⏳ |
| Full docs in 4_Formula | Review 4_Formula/ | ⏳ |

### O2: Windows Setup
| OKR | Test | Result |
|-----|------|--------|
| winget install works | PowerShell install script | ⏳ |
| PowerShell 7 working | `kilocode doctor` green | ⏳ |
| Config parity with Mac | `diff mac.yaml windows.yaml` | ⏳ |
| Gotchas logged in 6_Semblance | Review 6_Semblance/ | ⏳ |

### O3: AI Search Working
| OKR | Test | Result |
|-----|------|--------|
| Qdrant running | Health check endpoint | ⏳ |
| Sample project indexed | > 0 vectors in collection | ⏳ |
| Semantic search top-3 accuracy | Manual relevance test | ⏳ |

---

## 🔁 Regression Tests

Run after any configuration change:

```bash
# Mac
./5_Symbols/verify.sh

# Windows
# (run verify.sh via WSL2 or equivalent PS script)
```

---

## 📁 Files in This Folder

| File | Purpose |
|------|---------|
| `README.md` | This file — testing checklist |
| `test_results.md` | Recorded test run results |

---

*[← Stage 6](../markdown_renderer.html?file=6_Semblance/README.md) · [Back to Home →](../index.html)*
