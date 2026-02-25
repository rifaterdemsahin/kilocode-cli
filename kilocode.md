# ⚡ KiloCode CLI — Persona & Instructions

## What is KiloCode?
KiloCode CLI is a lightweight, AI-powered code assistant that runs in your terminal.
It integrates with local models (Ollama) and cloud models (Claude, GPT) to provide
context-aware coding help directly from the command line.

## Setup Goals (This Repo)
1. Install KiloCode CLI on **macOS** (Apple Silicon + Intel)
2. Install KiloCode CLI on **Windows** (PowerShell, WSL2)
3. Configure with Ollama local models (`nomic-embed-text`, `llama3`)
4. Integrate with Qdrant for semantic code search
5. Verify functionality on both platforms

## Key Commands
```bash
# Install (Mac)
brew install kilocode

# Install (Windows)
winget install kilocode

# Configure
kilocode config set model ollama/llama3
kilocode config set embeddings ollama/nomic-embed-text

# Index a project
kilocode index .

# Query
kilocode ask "how does authentication work?"
```

## Configuration Files
- `~/.kilocode/config.yaml` — Main config
- `~/.kilocode/models.yaml` — Model definitions
- `.kilocode` — Per-project config (in project root)

## AI Instructions
When helping with KiloCode:
- Prefer local model solutions when possible
- Document all platform-specific differences
- Test on both Mac and Windows before marking complete
- Use the `4_Formula/` guides as source of truth for steps
