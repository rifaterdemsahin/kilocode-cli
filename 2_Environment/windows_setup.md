# 🪟 Windows Setup Guide — KiloCode CLI

> Step-by-step guide for Windows 10/11 (PowerShell 7 + WSL2)

---

## Prerequisites

Open PowerShell 7 as Administrator:
```powershell
# Check PS version
$PSVersionTable.PSVersion
```

If not PowerShell 7, install it:
```powershell
winget install Microsoft.PowerShell
```

---

## Step 1: Install Node.js 20+

```powershell
# via winget
winget install OpenJS.NodeJS.LTS

# Or via nvm-windows
winget install CoreyButler.NVMforWindows
nvm install 20
nvm use 20

# Verify
node --version
npm --version
```

---

## Step 2: Install KiloCode CLI

```powershell
# via npm (recommended)
npm install -g kilocode

# Or via winget (if available)
winget install kilocode

# Verify
kilocode --version
```

If PATH is missing:
```powershell
$npmGlobal = (npm config get prefix)
[Environment]::SetEnvironmentVariable("PATH", "$env:PATH;$npmGlobal", "User")
```

---

## Step 3: Install Ollama for Windows

1. Download from [https://ollama.ai/download/windows](https://ollama.ai/download/windows)
2. Run the installer
3. Ollama starts automatically as a system service

```powershell
# Pull embedding model
ollama pull nomic-embed-text

# Verify
Invoke-RestMethod http://localhost:11434/api/tags
```

---

## Step 4: Install Docker Desktop + Qdrant

```powershell
# Install Docker Desktop
winget install Docker.DockerDesktop

# Start Docker Desktop, then run Qdrant
docker run -d --name qdrant `
  -p 6333:6333 `
  -v qdrant_storage:/qdrant/storage `
  qdrant/qdrant:latest

# Verify
Invoke-RestMethod http://localhost:6333/healthz
```

---

## Step 5: Configure KiloCode

```powershell
kilocode config set embeddings.provider ollama
kilocode config set embeddings.model nomic-embed-text
kilocode config set embeddings.dimensions 4096
kilocode config set vectordb.provider qdrant
kilocode config set vectordb.host http://localhost:6333

# Verify
kilocode config show
```

---

## Option B: WSL2 Setup

WSL2 gives a near-identical Linux experience:

```powershell
# Install WSL2 with Ubuntu
wsl --install -d Ubuntu

# Inside WSL2:
sudo apt update && sudo apt install -y nodejs npm
npm install -g kilocode
# Then follow Mac/Linux steps for Ollama + Qdrant
```

> ⚠️ WSL2 and Windows Docker Desktop may conflict on port bindings.
> Use `QDRANT_HOST=http://host.docker.internal:6333` inside WSL2.

---

## 🩹 Common Issues

| Issue | Fix |
|-------|-----|
| `kilocode` not found | Restart PowerShell after npm install |
| Ollama service not starting | Run as Administrator first time |
| Docker requires Hyper-V | Enable in BIOS + Windows Features |
| Port conflicts | Check with `netstat -ano \| findstr :6333` |
| Windows Defender blocking | Add exclusion for `~\AppData\Roaming\npm` |

---

*[← Back to Environment](../markdown_renderer.html?file=2_Environment/README.md)*
