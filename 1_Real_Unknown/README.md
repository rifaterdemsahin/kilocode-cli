# ❓ Stage 1 — Real Unknown

> **The "Why"** — Problem definitions, OKRs, and the core questions driving this project.

---

## 🎯 Problem Statement

Setting up KiloCode CLI consistently across **macOS** and **Windows** environments
is non-trivial. Configuration drift, PATH issues, dependency mismatches, and
platform-specific quirks create friction for developers who work across machines.

This project documents the complete, reproducible setup journey — capturing every
obstacle, workaround, and validation step so the process can be repeated reliably.

---

## 📊 OKRs (Objectives & Key Results)

### Objective 1: Achieve a working KiloCode CLI on macOS
| Key Result | Target | Status |
|-----------|--------|--------|
| Install KiloCode CLI without errors | 100% success rate | 🔄 In Progress |
| Configure Ollama local model integration | nomic-embed-text working | 🔄 In Progress |
| Verify `kilocode ask` returns relevant results | < 2s response time | ⏳ Pending |
| Document every step in `4_Formula/` | Complete guide | ⏳ Pending |

### Objective 2: Achieve a working KiloCode CLI on Windows
| Key Result | Target | Status |
|-----------|--------|--------|
| Install via winget or manual method | Zero manual PATH hacks | 🔄 In Progress |
| PowerShell + WSL2 both working | Both verified | ⏳ Pending |
| Configuration parity with Mac setup | Same config works | ⏳ Pending |
| Document Windows-specific gotchas in `6_Semblance/` | All errors logged | ⏳ Pending |

### Objective 3: AI-assisted code search working
| Key Result | Target | Status |
|-----------|--------|--------|
| Qdrant running locally via Docker | Health check passing | ⏳ Pending |
| nomic-embed-text indexed a sample project | > 100 vectors stored | ⏳ Pending |
| Semantic search returns correct files | Top-3 accuracy > 80% | ⏳ Pending |

---

## ❓ Core Questions

1. **What is the minimum viable KiloCode CLI setup on each platform?**
2. **What dependencies does KiloCode CLI actually need at runtime?**
3. **How do Mac (Homebrew) and Windows (winget/choco) installation paths differ?**
4. **Does WSL2 work better than native Windows PowerShell for KiloCode?**
5. **What happens when Ollama is not running — does KiloCode degrade gracefully?**
6. **How do we keep Mac and Windows configs in sync (dotfiles strategy)?**
7. **Which Ollama model gives the best code embedding quality vs. speed?**

---

## 🗺 Journey Map

```
❓ Real Unknown
    ↓
🌍 Environment setup (Mac + Windows + AI)
    ↓
🎨 Simulate the ideal flow
    ↓
📐 Follow the formula (step-by-step)
    ↓
💻 Write the actual code/scripts
    ↓
🩹 Log every error and scar
    ↓
✅ Prove it works (testing)
```

---

## 📁 Files in This Folder

| File | Purpose |
|------|---------|
| `README.md` | This file — problem + OKRs |
| `okrs.md` | Detailed OKR tracking |
| `questions.md` | Expanded question backlog |

---

*[← Back to Home](../index.html) · [Next: Environment →](../markdown_renderer.html?file=2_Environment/README.md)*
