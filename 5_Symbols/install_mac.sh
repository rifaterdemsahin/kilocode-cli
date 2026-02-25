#!/usr/bin/env bash
# ⚡ KiloCode CLI — macOS One-Shot Installer
# Run: chmod +x install_mac.sh && ./install_mac.sh

set -euo pipefail

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log()  { echo -e "${BLUE}[INFO]${NC} $*"; }
ok()   { echo -e "${GREEN}[ OK ]${NC} $*"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
err()  { echo -e "${RED}[ERR ]${NC} $*" >&2; exit 1; }

echo ""
echo "⚡ KiloCode CLI — macOS Installer"
echo "=================================="
echo ""

# ── 1. Homebrew ──────────────────────────────────────────────
log "Checking Homebrew..."
if ! command -v brew &>/dev/null; then
  log "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # Apple Silicon path
  if [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
  fi
fi
ok "Homebrew $(brew --version | head -1)"

# ── 2. Node.js ───────────────────────────────────────────────
log "Checking Node.js..."
if ! command -v node &>/dev/null || [[ $(node -e "process.exit(parseInt(process.version.slice(1)) < 20 ? 1 : 0)" 2>&1; echo $?) == "1" ]]; then
  log "Installing Node.js 20..."
  brew install node@20
  brew link node@20 --force --overwrite
fi
ok "Node.js $(node --version)"

# ── 3. Docker ────────────────────────────────────────────────
log "Checking Docker..."
if ! command -v docker &>/dev/null; then
  log "Installing Docker Desktop (requires manual open & setup)..."
  brew install --cask docker
  warn "Please open Docker Desktop from Applications before continuing."
  read -p "Press ENTER after Docker Desktop is running... "
fi
ok "Docker $(docker --version)"

# ── 4. Ollama ────────────────────────────────────────────────
log "Checking Ollama..."
if ! command -v ollama &>/dev/null; then
  log "Installing Ollama..."
  brew install ollama
fi

log "Starting Ollama service..."
brew services start ollama 2>/dev/null || true
sleep 2

log "Pulling nomic-embed-text (274 MB — may take a few minutes)..."
if ! ollama list 2>/dev/null | grep -q "nomic-embed-text"; then
  ollama pull nomic-embed-text
fi
ok "Ollama + nomic-embed-text ready"

# ── 5. Qdrant ────────────────────────────────────────────────
log "Starting Qdrant..."
if ! docker ps | grep -q qdrant; then
  docker run -d --name qdrant --restart unless-stopped \
    -p 6333:6333 \
    -v qdrant_storage:/qdrant/storage \
    qdrant/qdrant:latest
  sleep 3
fi

log "Creating kilocode_docs collection..."
curl -sf -X PUT http://localhost:6333/collections/kilocode_docs \
  -H 'Content-Type: application/json' \
  -d '{"vectors":{"size":4096,"distance":"Cosine"}}' > /dev/null || \
  warn "Collection may already exist — continuing"
ok "Qdrant running on :6333"

# ── 6. KiloCode CLI ──────────────────────────────────────────
log "Installing KiloCode CLI..."
npm install -g kilocode

log "Configuring KiloCode..."
kilocode config set embeddings.provider ollama
kilocode config set embeddings.model nomic-embed-text
kilocode config set embeddings.dimensions 4096
kilocode config set vectordb.provider qdrant
kilocode config set vectordb.host http://localhost:6333
ok "KiloCode configured"

# ── 7. Verify ────────────────────────────────────────────────
echo ""
echo "🔍 Running health check..."
kilocode doctor || warn "Some checks may have warnings — see output above"

echo ""
echo "✅ Installation complete!"
echo ""
echo "   Try it:"
echo "   cd ~/your-project"
echo "   kilocode index ."
echo "   kilocode ask 'what does this code do?'"
echo ""
