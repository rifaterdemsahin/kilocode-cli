# 💻 Stage 5 — Symbols

> **The "Reality"** — Core source code and implementation.

---

## Scripts Overview

| Script | Platform | Purpose |
|--------|----------|---------|
| `install_mac.sh` | macOS | One-shot install for Mac |
| `install_windows.ps1` | Windows | One-shot install for Windows |
| `setup_qdrant.sh` | Mac/Linux | Qdrant Docker setup |
| `docker-compose.yml` | Both | Full AI stack compose file |
| `verify.sh` | Mac/Linux | Health check all services |

---

## Quick Start

### macOS
```bash
chmod +x 5_Symbols/install_mac.sh
./5_Symbols/install_mac.sh
```

### Windows (PowerShell 7 as Admin)
```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
.\5_Symbols\install_windows.ps1
```

---

## Configuration Schema

```yaml
# ~/.kilocode/config.yaml
embeddings:
  provider: ollama
  model: nomic-embed-text
  dimensions: 4096
  host: http://localhost:11434

vectordb:
  provider: qdrant
  host: http://localhost:6333
  collection: kilocode_docs

search:
  max_results: 5
  min_score: 0.7

ui:
  color: true
  verbose: false
```

---

*[← Stage 4](../markdown_renderer.html?file=4_Formula/README.md) · [Stage 6 →](../markdown_renderer.html?file=6_Semblance/README.md)*
