# 📋 Detailed Installation Steps

> Complete step-by-step for both Mac and Windows

---

## macOS — Complete Walkthrough

```bash
# 1. Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 2. Install core tools
brew install node git

# 3. Install Docker Desktop
brew install --cask docker
# → Open Docker Desktop from Applications and complete setup

# 4. Install Ollama
brew install ollama
brew services start ollama

# 5. Pull nomic-embed-text
ollama pull nomic-embed-text
# Wait ~2 min for 274 MB download

# 6. Start Qdrant
docker run -d --name qdrant --restart unless-stopped \
  -p 6333:6333 \
  -v qdrant_storage:/qdrant/storage \
  qdrant/qdrant:latest

# 7. Create collection
curl -X PUT http://localhost:6333/collections/kilocode_docs \
  -H 'Content-Type: application/json' \
  -d '{"vectors":{"size":4096,"distance":"Cosine"}}'

# 8. Install KiloCode CLI
npm install -g kilocode

# 9. Configure
kilocode config set embeddings.provider ollama
kilocode config set embeddings.model nomic-embed-text
kilocode config set embeddings.dimensions 4096
kilocode config set vectordb.provider qdrant
kilocode config set vectordb.host http://localhost:6333

# 10. Verify
kilocode doctor
```

---

## Windows — Complete Walkthrough (PowerShell 7)

```powershell
# 1. Open PowerShell 7 as Administrator

# 2. Install tools via winget
winget install Microsoft.PowerShell     # PS7 (restart after)
winget install OpenJS.NodeJS.LTS        # Node.js 20
winget install Git.Git                  # Git
winget install Docker.DockerDesktop     # Docker

# 3. Restart PowerShell 7 as Admin

# 4. Install Ollama
# Download and run installer from https://ollama.ai/download/windows
# Or:
winget install Ollama.Ollama

# 5. Pull nomic-embed-text
ollama pull nomic-embed-text

# 6. Start Qdrant (Docker Desktop must be running)
docker run -d --name qdrant --restart unless-stopped `
  -p 6333:6333 `
  -v qdrant_storage:/qdrant/storage `
  qdrant/qdrant:latest

# 7. Create collection
Invoke-RestMethod -Method PUT `
  -Uri http://localhost:6333/collections/kilocode_docs `
  -ContentType application/json `
  -Body '{"vectors":{"size":4096,"distance":"Cosine"}}'

# 8. Install KiloCode CLI
npm install -g kilocode

# 9. Configure (same as Mac!)
kilocode config set embeddings.provider ollama
kilocode config set embeddings.model nomic-embed-text
kilocode config set embeddings.dimensions 4096
kilocode config set vectordb.provider qdrant
kilocode config set vectordb.host http://localhost:6333

# 10. Verify
kilocode doctor
```

---

*[← Back to Formula](../markdown_renderer.html?file=4_Formula/README.md)*
