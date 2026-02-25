# 🍎 How to Run KiloCode CLI on Mac

> Complete guide — install, configure, and start coding with AI in your terminal.

---

## 📺 Watch First
🎬 [KiloCode Introduction — YouTube](https://www.youtube.com/@RifatErdemSahin)

---

## What is KiloCode CLI?

**KiloCode CLI** (`kilo`) is an open-source, agentic AI coding assistant that runs
entirely in your terminal. It connects to AI providers (xAI Grok, Claude, GPT, Ollama)
and helps you write, debug, refactor, and understand code — no browser required.

- 1.5M+ users · #1 on OpenRouter · MIT License
- Supports 400+ models · local Ollama · bring your own API key

---

## Step 1 — Prerequisites

```bash
# Check Node.js version (need 18+)
node --version

# If missing, install via Homebrew
brew install node
```

> For older Macs **without AVX CPU support** (pre-2013 Intel): skip npm install —
> download the pre-built binary instead (see Step 2B below).

---

## Step 2A — Install via npm (Recommended)

```bash
# Install globally
npm install -g @kilocode/cli

# Verify
kilo --version
```

That's it. The command is **`kilo`**, not `kilocode`.

---

## Step 2B — Install Binary (Older Macs, no AVX)

```bash
# Download baseline build for macOS x64
curl -L https://github.com/Kilo-Org/kilocode/releases/latest/download/kilo-darwin-x64-baseline.zip \
  -o kilo.zip

unzip kilo.zip
chmod +x kilo
sudo mv kilo /usr/local/bin/kilo

# Verify
kilo --version
```

---

## Step 3 — First Launch & Authentication

```bash
# Run from any project directory
cd ~/your-project
kilo
```

This opens the interactive TUI. Inside the TUI, type:

```
/connect
```

Choose your provider and paste your API key:

| Provider | Key format |
|----------|-----------|
| xAI (Grok) | `xai-...` |
| Anthropic (Claude) | `sk-ant-...` |
| OpenAI (GPT) | `sk-...` |
| Ollama (local) | no key needed |

---

## Step 4 — Configure with xAI (Grok)

Create the global config file:

```bash
mkdir -p ~/.config/kilo
```

```bash
cat > ~/.config/kilo/opencode.json << 'EOF'
{
  "$schema": "https://app.kilo.ai/config.json",
  "model": "xai/grok-3",
  "provider": {
    "xai": {
      "options": {
        "apiKey": "{env:XAI_API_KEY}"
      }
    }
  }
}
EOF
```

Then set your key in the shell:

```bash
# Add to ~/.zshrc for persistence
echo 'export XAI_API_KEY="xai-YOUR-KEY-HERE"' >> ~/.zshrc
source ~/.zshrc
```

> Your key is stored in `.env` (gitignored) in this repo.
> Never hardcode keys directly in `opencode.json` — use `{env:VAR_NAME}` syntax.

---

## Step 5 — Run KiloCode

### Interactive mode (TUI)
```bash
kilo
```

### Run a one-off task
```bash
kilo run "explain what this codebase does"
kilo run "add error handling to main.ts"
```

### Resume last session
```bash
kilo --continue
```

### Use a specific mode
```bash
kilo --mode architect   # Plan and design
kilo --mode code        # Write code
kilo --mode debug       # Debug issues
kilo --mode ask         # Ask questions only (no edits)
```

### Set a specific workspace
```bash
kilo --workspace /path/to/project
```

---

## Step 6 — Update KiloCode

```bash
# Update to latest version
kilo upgrade

# Or via npm
npm update -g @kilocode/cli
```

---

## ⚙️ Configuration Reference

| Location | Purpose |
|----------|---------|
| `~/.config/kilo/opencode.json` | Global config (all projects) |
| `./opencode.json` | Per-project config (takes precedence) |
| `~/.config/kilo/config.json` | Additional global settings |

### Permission Settings
Control what KiloCode can do automatically:

```json
{
  "permission": {
    "*": "ask",
    "bash": "allow",
    "edit": "ask",
    "browser": "deny"
  }
}
```

| Value | Meaning |
|-------|---------|
| `"allow"` | Runs automatically, no prompt |
| `"ask"` | Prompts you before running |
| `"deny"` | Always blocked |

---

## 🔑 Useful TUI Commands

Once inside `kilo`, type these slash commands:

| Command | Action |
|---------|--------|
| `/connect` | Add or update a provider API key |
| `/teams` | Switch organizations |
| `/model` | Change the active AI model |
| `/help` | Show all commands |
| `Ctrl+C` | Exit |

---

## 🩹 Common Issues on Mac

| Issue | Fix |
|-------|-----|
| `kilo: command not found` | Run `npm bin -g` and add that path to `~/.zshrc` |
| TUI doesn't render correctly | Try a different terminal (iTerm2 recommended) |
| `Killed: 9` on Apple Silicon | Download arm64 binary from GitHub releases |
| API key not found | Confirm `export XAI_API_KEY=...` is in `~/.zshrc` and `source ~/.zshrc` |
| `EACCES` on npm install | Use `sudo npm install -g @kilocode/cli` or fix npm permissions |

---

## ✅ Quick Verification Checklist

- [ ] `kilo --version` prints a version number
- [ ] `kilo` opens the TUI without errors
- [ ] `/connect` shows xAI as a provider option
- [ ] `kilo run "say hello"` returns a response
- [ ] Config file exists at `~/.config/kilo/opencode.json`

---

## 🔗 References

- [Official CLI Docs](https://kilo.ai/docs/cli)
- [npm Package: @kilocode/cli](https://www.npmjs.com/package/@kilocode/cli)
- [GitHub: Kilo-Org/kilocode](https://github.com/Kilo-Org/kilocode)
- [VS Code Marketplace](https://marketplace.visualstudio.com/items?itemName=kilocode.Kilo-Code)

---

*[← Back to Formula](../markdown_renderer.html?file=4_Formula/README.md) · [Back to Home →](../index.html)*
