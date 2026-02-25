# 🍎 macOS Setup Guide — KiloCode CLI

> Step-by-step guide for Mac (Apple Silicon + Intel)

---

## Step 1: Install Homebrew

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

For Apple Silicon, add Homebrew to your PATH:
```bash
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"
```

Verify:
```bash
brew --version
```

---

## Step 2: Install Node.js 20+

```bash
brew install node@20
```

Or via nvm (recommended for version management):
```bash
brew install nvm
nvm install 20
nvm use 20
```

---

## Step 3: Install KiloCode CLI

```bash
# Option A: via npm
npm install -g kilocode

# Option B: via Homebrew (if tap available)
brew tap rifaterdemsahin/kilocode
brew install kilocode

# Verify
kilocode --version
```

---

## Step 4: Install Ollama

```bash
# Download from ollama.ai or via brew
brew install ollama

# Start the Ollama service
brew services start ollama

# Pull the embedding model
ollama pull nomic-embed-text

# Verify
curl http://localhost:11434/api/tags
```

---

## Step 5: Install Docker + Qdrant

```bash
# Install Docker Desktop
brew install --cask docker

# Start Docker Desktop (GUI), then run Qdrant:
docker run -d --name qdrant \
  -p 6333:6333 \
  -v $(pwd)/qdrant_storage:/qdrant/storage \
  qdrant/qdrant:latest

# Verify
curl http://localhost:6333/healthz
```

---

## Step 6: Configure KiloCode

```bash
# Set Ollama as the provider
kilocode config set embeddings.provider ollama
kilocode config set embeddings.model nomic-embed-text
kilocode config set embeddings.dimensions 4096

# Set Qdrant as vector store
kilocode config set vectordb.provider qdrant
kilocode config set vectordb.host http://localhost:6333

# Verify config
kilocode config show
```

---

## Step 7: Test

```bash
# Index a sample project
cd ~/projects/some-project
kilocode index .

# Ask a question
kilocode ask "what does this codebase do?"
```

---

## 🩹 Common Issues

| Issue | Fix |
|-------|-----|
| `command not found: kilocode` | Add npm global bin to PATH |
| Ollama not starting | `brew services restart ollama` |
| Docker permission denied | Open Docker Desktop first |
| Port 6333 already in use | `lsof -i :6333` to find conflict |

---

*[← Back to Environment](../markdown_renderer.html?file=2_Environment/README.md)*
