#!/usr/bin/env bash
# ⚡ KiloCode CLI — Health Check Script
# Run: ./verify.sh

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

pass() { echo -e "  ${GREEN}✓${NC} $*"; }
fail() { echo -e "  ${RED}✗${NC} $*"; FAILED=1; }
warn() { echo -e "  ${YELLOW}~${NC} $*"; }

FAILED=0

echo ""
echo "🔍 KiloCode CLI Health Check"
echo "=============================="

echo ""
echo "📦 Tools:"
command -v node   &>/dev/null && pass "Node.js $(node --version)"     || fail "Node.js not found"
command -v npm    &>/dev/null && pass "npm $(npm --version)"          || fail "npm not found"
command -v docker &>/dev/null && pass "Docker $(docker --version | cut -d' ' -f3 | tr -d ',')" || fail "Docker not found"
command -v ollama &>/dev/null && pass "Ollama installed"              || fail "Ollama not found"
command -v kilocode &>/dev/null && pass "KiloCode CLI $(kilocode --version 2>/dev/null)" || fail "KiloCode CLI not found"

echo ""
echo "🤖 Services:"
curl -sf http://localhost:11434/api/tags > /dev/null 2>&1 && pass "Ollama API :11434" || fail "Ollama API not responding"
ollama list 2>/dev/null | grep -q "nomic-embed-text"   && pass "nomic-embed-text model available" || fail "nomic-embed-text not pulled"
curl -sf http://localhost:6333/healthz   > /dev/null 2>&1 && pass "Qdrant :6333"     || fail "Qdrant not responding"

echo ""
echo "🗄 Qdrant Collections:"
COLS=$(curl -sf http://localhost:6333/collections 2>/dev/null | python3 -c "import sys,json; d=json.load(sys.stdin); [print('  •',c['name']) for c in d['result']['collections']]" 2>/dev/null)
if [[ -n "$COLS" ]]; then
  echo "$COLS" | while read -r line; do pass "${line#  • }"; done
  echo "$COLS" | grep -q "kilocode_docs" && pass "kilocode_docs collection exists" || warn "kilocode_docs not found — run setup"
else
  warn "Could not list collections"
fi

echo ""
if [[ $FAILED -eq 0 ]]; then
  echo -e "${GREEN}✅ All checks passed!${NC}"
else
  echo -e "${RED}❌ Some checks failed — see above${NC}"
  exit 1
fi
echo ""
