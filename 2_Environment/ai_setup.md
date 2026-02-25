# 🤖 AI Stack Setup — Ollama + Qdrant

> Configure the AI backend for KiloCode CLI

---

## Architecture

```
┌─────────────────┐     ┌──────────────────┐     ┌───────────────────┐
│  KiloCode CLI   │────▶│  Ollama Server   │────▶│  nomic-embed-text │
│  (your terminal)│     │  :11434          │     │  (4096 dims)      │
└────────┬────────┘     └──────────────────┘     └───────────────────┘
         │
         │ vectors
         ▼
┌─────────────────┐
│   Qdrant DB     │
│   :6333         │
│  (local Docker) │
└─────────────────┘
```

---

## Ollama Setup

### Install + Start
```bash
# Mac
brew install ollama && brew services start ollama

# Windows — download from ollama.ai

# Linux
curl -fsSL https://ollama.ai/install.sh | sh
```

### Pull Models
```bash
# Embedding model (required)
ollama pull nomic-embed-text

# Code generation (optional but useful)
ollama pull codellama
ollama pull llama3.2
```

### Test Ollama
```bash
# List models
ollama list

# Test embedding
curl http://localhost:11434/api/embeddings \
  -d '{"model":"nomic-embed-text","prompt":"hello world"}'
```

---

## Qdrant Setup (Docker Compose)

Create `docker-compose.yml` in your workspace:

```yaml
version: '3.8'
services:
  qdrant:
    image: qdrant/qdrant:latest
    restart: unless-stopped
    ports:
      - "6333:6333"
      - "6334:6334"
    volumes:
      - qdrant_storage:/qdrant/storage
    environment:
      QDRANT__SERVICE__HTTP_PORT: 6333
      QDRANT__SERVICE__GRPC_PORT: 6334

volumes:
  qdrant_storage:
```

```bash
# Start Qdrant
docker compose up -d

# Check health
curl http://localhost:6333/healthz

# View dashboard
open http://localhost:6333/dashboard
```

---

## Create Qdrant Collection

```bash
curl -X PUT http://localhost:6333/collections/kilocode_docs \
  -H 'Content-Type: application/json' \
  -d '{
    "vectors": {
      "size": 4096,
      "distance": "Cosine"
    }
  }'
```

---

## Verify Full Stack

```bash
# Check Ollama
curl http://localhost:11434/api/tags | jq '.models[].name'

# Check Qdrant
curl http://localhost:6333/collections | jq '.result.collections'

# Check KiloCode integration
kilocode doctor
```

---

*[← Back to Environment](../markdown_renderer.html?file=2_Environment/README.md)*
