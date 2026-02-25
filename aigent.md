# 🤖 Agent Rules — KiloCode CLI

## Purpose
This file defines how AI agents should behave when working in this repository.

## Project Context
This repo documents the setup of KiloCode CLI on Mac and Windows using the
**Project Self-Learning System** (7-stage journey: Unknown → Proven).

## AI Stack
- **Embeddings:** Ollama with `nomic-embed-text` model (4096 dimensions)
- **Vector Store:** Qdrant (local via Docker)
- **LLM:** Claude (Sonnet/Opus) or local Ollama models

## Rules for AI Agents

### Content
1. Follow the 7-stage folder structure strictly
2. Never skip documentation — every error/fix goes into `6_Semblance/`
3. Testing goes into `7_Testing_Known/` with validation against `1_Real_Unknown/` OKRs
4. Move obsolete files to `_obsolete/` sub-folders, never delete directly

### Code Style
- Shell scripts: use `#!/usr/bin/env bash` shebangs
- PowerShell: use strict mode `Set-StrictMode -Version Latest`
- Always handle errors gracefully
- Add comments for non-obvious logic

### Git Workflow
- Commit after every significant change
- Use descriptive commit messages with emojis
- Push after every commit
- Never commit `.env` or `qdrant_storage/`

### Navigation
- All pages must maintain the shared navigation structure
- Debug mode is cookie-based (`debug_mode=true`)
- Links should work relative to repo root

## Persona Files
- `kilocode.md` — KiloCode-specific CLI instructions
- `claude.md` — Claude AI persona instructions (if present)
