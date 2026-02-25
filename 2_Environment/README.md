# 🌍 Stage 2 — Environment

> **The "Context"** — Roadmaps, constraints, and setup guides for Mac, Windows, and AI clients.

---

## 🗺 Roadmap

```
Week 1: macOS baseline setup
  → Install Homebrew, Node.js, KiloCode CLI
  → Configure Ollama with nomic-embed-text
  → Verify Qdrant integration

Week 2: Windows setup
  → PowerShell 7 + winget baseline
  → Install KiloCode CLI (winget or manual)
  → Match Mac configuration

Week 3: AI client integration
  → Ollama model optimization
  → Qdrant indexing and semantic search
  → End-to-end testing on both platforms

Week 4: Documentation and publication
  → Complete 7-stage documentation
  → GitHub Pages live
  → Testing validation
```

---

## 🍎 macOS Environment

### Requirements
| Component | Minimum | Recommended |
|-----------|---------|-------------|
| macOS | 12 (Monterey) | 14 (Sonoma) |
| RAM | 8 GB | 16 GB |
| Disk | 10 GB free | 20 GB free |
| CPU | Intel Core i5 | Apple M1/M2 |

### Key Tools
- **Homebrew** — Package manager
- **Node.js 20+** — Runtime
- **Git** — Version control
- **Docker Desktop** — For Qdrant
- **Ollama** — Local AI models

➡ See [`mac_setup.md`](../markdown_renderer.html?file=2_Environment/mac_setup.md) for step-by-step guide.

---

## 🪟 Windows Environment

### Requirements
| Component | Minimum | Recommended |
|-----------|---------|-------------|
| Windows | 10 21H2 | 11 23H2 |
| RAM | 8 GB | 16 GB |
| Disk | 15 GB free | 30 GB free |
| WSL2 | Optional | Recommended |

### Key Tools
- **winget** or **Chocolatey** — Package manager
- **PowerShell 7** — Modern shell
- **Node.js 20+** — Runtime
- **Docker Desktop** (Windows) — For Qdrant
- **Ollama for Windows** — Local AI models

➡ See [`windows_setup.md`](../markdown_renderer.html?file=2_Environment/windows_setup.md) for step-by-step guide.

---

## 🤖 AI Client Setup

### Ollama
- Model: `nomic-embed-text` (4096 dimensions)
- Endpoint: `http://localhost:11434`
- Pull: `ollama pull nomic-embed-text`

### Qdrant (Docker)
```yaml
# docker-compose.yml
services:
  qdrant:
    image: qdrant/qdrant:latest
    ports:
      - "6333:6333"
    volumes:
      - qdrant_storage:/qdrant/storage
volumes:
  qdrant_storage:
```

➡ See [`ai_setup.md`](../markdown_renderer.html?file=2_Environment/ai_setup.md) for full AI stack guide.

---

## ⚠️ Known Constraints

1. **Apple Silicon vs Intel** — Some Ollama models require Rosetta on older Macs
2. **Windows Defender** — May flag downloaded binaries; exclusions needed
3. **Corporate proxies** — May block Ollama model downloads; configure `HTTPS_PROXY`
4. **WSL2 memory** — Default 50% RAM cap; configure `.wslconfig`
5. **Docker resources** — Qdrant needs at least 1 GB RAM allocated

---

## 📁 Files in This Folder

| File | Purpose |
|------|---------|
| `README.md` | This file — overview and roadmap |
| `mac_setup.md` | macOS step-by-step setup guide |
| `windows_setup.md` | Windows step-by-step setup guide |
| `ai_setup.md` | Ollama + Qdrant setup guide |

---

*[← Stage 1](../markdown_renderer.html?file=1_Real_Unknown/README.md) · [Stage 3 →](../3_Simulation/index.html)*
