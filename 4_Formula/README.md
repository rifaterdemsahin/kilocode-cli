# 📐 Stage 4 — Formula

> **The "Recipe"** — Step-by-step guides, research notes, and the logic behind the build.

---

## 📋 Master Installation Checklist

### Phase 1: Prerequisites
- [ ] macOS 12+ or Windows 10 21H2+
- [ ] 16 GB RAM (8 GB minimum)
- [ ] 15 GB free disk space
- [ ] Internet connection for initial downloads
- [ ] Admin/sudo access

### Phase 2: Core Tools
- [ ] Package manager installed (Homebrew / winget)
- [ ] Node.js 20+ installed and verified
- [ ] Git 2.40+ installed and configured
- [ ] Docker Desktop installed and running

### Phase 3: AI Stack
- [ ] Ollama installed and service running
- [ ] `nomic-embed-text` model pulled (274 MB)
- [ ] Qdrant container running on port 6333
- [ ] `kilocode_docs` collection created (4096 dims, Cosine)

### Phase 4: KiloCode CLI
- [ ] KiloCode CLI installed globally (`npm i -g @kilocode/cli`)
- [ ] Configuration set (provider + API key)
- [ ] `kilo --version` prints a version number
- [ ] `kilo` opens the TUI successfully
- [ ] First project session working

---

## 🧠 Logic Behind the Build

### Why Ollama?
- Runs 100% locally — no API keys, no rate limits
- `nomic-embed-text` produces high-quality 4096-dim embeddings
- Cross-platform (Mac, Windows, Linux)
- Easy model management

### Why Qdrant?
- Purpose-built for vector similarity search
- Cosine similarity ideal for semantic code search
- Free local tier via Docker
- Fast: sub-millisecond search on 10k vectors

### Why nomic-embed-text?
- 4096 dimensions → richer semantic representation
- Trained on code + documentation data
- Small footprint (274 MB)
- MIT license

### Platform Strategy
- **Mac**: Homebrew for everything — clean, reproducible
- **Windows**: winget + PowerShell 7 — avoid Cygwin/MinGW friction
- **Both**: Docker for Qdrant → same container everywhere
- **Config**: Single YAML format, same keys on both platforms

---

## 📚 Research Notes

### Embedding Model Comparison

| Model | Dims | Size | Speed | Quality |
|-------|------|------|-------|---------|
| nomic-embed-text | 4096 | 274 MB | ~120ms | ⭐⭐⭐⭐⭐ |
| all-minilm | 384 | 45 MB | ~20ms | ⭐⭐⭐ |
| mxbai-embed-large | 1024 | 670 MB | ~200ms | ⭐⭐⭐⭐ |

**Decision:** nomic-embed-text for best quality in code understanding.

### Vector DB Comparison

| DB | Local | Speed | Filtering | License |
|----|-------|-------|-----------|---------|
| Qdrant | ✅ | Fast | Rich | Apache 2 |
| Chroma | ✅ | Medium | Basic | Apache 2 |
| Pinecone | ❌ | Fast | Rich | Proprietary |

**Decision:** Qdrant for local-first, feature-rich setup.

---

## 📁 Files in This Folder

| File | Purpose |
|------|---------|
| `README.md` | Master checklist + logic |
| `installation_steps.md` | Detailed step-by-step |
| `alternatives.md` | Terminal AI alternatives + xAI setup |
| `run_kilocode_mac.md` | Mac-specific KiloCode guide |
| `flyio_deployment.md` | Authoritative formula for Fly.io remote VM |
| `flyio_cost_estimation.md` | Cost analysis and optimization for Fly.io VM |
| `flyio_tty_fix.md` | Fix log for kilo CLI hanging in ttyd browser terminal |

---

*[← Stage 3](../3_Simulation/index.html) · [Stage 5 →](../markdown_renderer.html?file=5_Symbols/README.md)*
