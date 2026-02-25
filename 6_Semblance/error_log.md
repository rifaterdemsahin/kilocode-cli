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

*[← Back to Semblance](../markdown_renderer.html?file=6_Semblance/README.md)*
