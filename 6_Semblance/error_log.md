# 📋 Extended Error Log

> Full error details with stack traces and context

---

## M01: Homebrew PATH on Apple Silicon

**Date:** 2026-02-25
**Platform:** macOS 14, Apple Silicon (M2)
**Symptom:** After Homebrew install, `brew: command not found` in new terminal

**Full Error:**
```
zsh: command not found: brew
```

**Root Cause:** Apple Silicon Homebrew installs to `/opt/homebrew/` (not `/usr/local/`).
`.zprofile` was not updated automatically.

**Fix:**
```bash
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
source ~/.zprofile
```

**Prevention:** The `install_mac.sh` script now handles this automatically.

---

## W01: npm Global Bin Not in Windows PATH

**Date:** 2026-02-25
**Platform:** Windows 11, PowerShell 7
**Symptom:** `kilocode: The term 'kilocode' is not recognized`

**Full Error:**
```
kilocode : The term 'kilocode' is not recognized as the name of a cmdlet...
```

**Root Cause:** npm installs global binaries to `%AppData%\npm`, which is not
automatically added to the system PATH on fresh Windows installs.

**Fix:**
```powershell
$npmPrefix = (npm config get prefix)
[Environment]::SetEnvironmentVariable("PATH", "$env:PATH;$npmPrefix", "User")
# Restart PowerShell
```

**Prevention:** `install_windows.ps1` now checks and adds this path.

---

## A01: Qdrant Vector Dimension Mismatch

**Date:** 2026-02-25
**Platform:** Both
**Symptom:** `kilocode index .` fails at upsert step

**Full Error:**
```json
{
  "status": "error",
  "result": null,
  "message": "Wrong input: Vector dimension error: expected dim: 384, got 4096"
}
```

**Root Cause:** Qdrant collection was created with `"size": 384` (from testing with
`all-minilm`) but `nomic-embed-text` produces 4096-dimensional vectors.

**Fix:**
```bash
# Delete the mismatched collection
curl -X DELETE http://localhost:6333/collections/kilocode_docs

# Recreate with correct dimensions
curl -X PUT http://localhost:6333/collections/kilocode_docs \
  -H 'Content-Type: application/json' \
  -d '{"vectors":{"size":4096,"distance":"Cosine"}}'
```

**Prevention:** Added dimension check to `verify.sh`.

---

## M02: kilocode Command Not Found on Mac (First Run)

**Date:** 2026-02-25
**Platform:** macOS, zsh
**Symptom:** Running `kilocode` in terminal immediately after cloning the repo

**Full Error:**
```
zsh: command not found: kilocode
```

**Root Cause:** The KiloCode CLI npm package has not been installed yet.
Cloning the repo does not install the CLI — the installer script must be run first.

**Fix:**
```bash
# Option 1: Run the full installer (recommended — sets up all dependencies)
chmod +x 5_Symbols/install_mac.sh && ./5_Symbols/install_mac.sh

# Option 2: Install only the CLI (if Node.js is already installed)
npm install -g kilocode
```

**Prevention:** README should clarify that cloning alone is not enough —
the installer must be run before using the `kilocode` command.

---

## M03: npm install -g kilocode — No CLI Binary Created

**Date:** 2026-02-25
**Platform:** macOS, nvm (Node.js v22.22.0)
**Symptom:** `npm install -g kilocode` succeeds but `kilocode` command still not found

**Full Error:**
```
zsh: command not found: kilocode
```

**Root Cause:** The published `kilocode@1.2.0` npm package is an unofficial placeholder.
Its `package.json` has no `bin` field, so npm creates no command-line binary.
The package contains only `index.js` (empty) and a README saying "# testing".

**Diagnosis steps:**
```bash
npm list -g --depth=0           # shows kilocode@1.2.0 installed
ls $(npm config get prefix)/bin # kilocode binary NOT present
cat ~/.nvm/versions/node/.../lib/node_modules/kilocode/package.json
# confirms: no "bin" entry
```

**Fix — exit and reopen terminal first, then:**
```bash
# Uninstall the placeholder
npm uninstall -g kilocode

# KiloCode is actually a VS Code extension, not a standalone npm CLI.
# Install the VS Code extension instead:
# 1. Open VS Code
# 2. Extensions panel → search "Kilo Code"
# 3. Install the official extension
```

**Note on terminal restart:** After npm global installs, always open a new terminal
session (or run `source ~/.zshrc`) before testing a new command. The shell PATH
cache may not reflect new binaries added during the current session.

**Prevention:** Clarify in docs that KiloCode is a VS Code extension, not an npm CLI.
The `install_mac.sh` script's `npm install -g kilocode` step should be removed or corrected.

---

*[← Back to Semblance](../markdown_renderer.html?file=6_Semblance/README.md)*
