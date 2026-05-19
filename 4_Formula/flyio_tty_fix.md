# 🔬 Complete Fix Log: Kilo CLI in Fly.io Browser Terminal

> **Date:** 2026-05-19
> **Platform:** Fly.io Machine (Ubuntu 24.04 Docker) + ttyd browser terminal
> **Problem:** `kilo` CLI hangs indefinitely when run inside ttyd's web-based terminal

---

## 1. The Problem

```bash
root@48e4535b96d4e8:/# kilo --version
# (blank screen, requires Ctrl+C to exit)
```

- **ping works** → network is fine
- **Node works** (`node -e "console.log('OK')"`) → Node.js runtime is fine
- **kilo wrapper works** → the Node.js shim doesn't crash
- **But the Go binary hangs** → TUI initialization failure

---

## 2. Root Cause Analysis

`kilo` is a **Go binary** (compiled with TUI libraries like `bubbletea`/`termenv`), not a pure Node.js CLI.

The execution chain:
```
kilo (shell command)
  → Node.js wrapper @kilocode/cli/bin/kilo
    → spawns Go binary @kilocode/cli-linux-x64/bin/kilo
      → Go binary tries to:
        1. Hide cursor
        2. Enter alternate screen buffer
        3. Enable raw terminal mode
        4. Start keyboard event loop
```

**ttyd's web terminal** provides a basic TTY via xterm.js, but it doesn't fully support the low-level `ioctl` syscalls that Go TUI libraries use for terminal manipulation. The binary:
- Prints garbage (`çççççççç` = failed ANSI sequences)
- Hangs waiting for a terminal event loop that never receives proper input
- Even `--version` hangs because the binary enters TUI mode unconditionally

---

## 3. Attempted Fixes (in order)

### Fix #1: Environment Variables (Partially Failed)

**Tried:** Set `TERM=xterm-256color`, `COLUMNS=80`, `LINES=24`

**In Dockerfile:**
```dockerfile
ENV TERM=xterm-256color
ENV NODE_NO_WARNINGS=1
```

**In entrypoint.sh:**
```bash
export TERM=xterm-256color
export COLUMNS=${COLUMNS:-80}
export LINES=${LINES:-24}
```

**Result:** ttyd now reports a proper terminal size (217×63 from browser), but the Go binary still hangs. The TUI library doesn't just check `TERM` — it actively manipulates the terminal.

---

### Fix #2: CI / Non-Interactive Mode (Failed)

**Tried:** Set `CI=true` and `KILO_NONINTERACTIVE=1`

**In Dockerfile + entrypoint:**
```dockerfile
ENV CI=true
```

**Result:** The Go binary ignores these. `CI=true` works for Node.js CLIs (npm, jest) but this is a Go binary with its own TUI detection logic.

---

### Fix #3: Binary Cache Optimization (Irrelevant)

**Tried:** Cache the Go binary path as `.kilo` symlink to bypass Node.js wrapper's `findBinary()` search

**In Dockerfile:**
```dockerfile
RUN KILO_REAL=$(find /usr/lib/node_modules -name kilo -path '*/@kilocode/cli-linux*/bin/*' -print -quit 2>/dev/null) \
    && if [ -n "$KILO_REAL" ]; then \
         ln -sf "$KILO_REAL" /usr/lib/node_modules/@kilocode/cli/.kilo; \
       fi
```

**Result:** The wrapper finds the binary faster, but the binary itself still hangs. This was a performance optimization, not a fix.

---

### Fix #4: Colorful Terminal Setup (Cosmetic)

**Tried:** Add `PS1`, `LS_COLORS`, aliases to `.bashrc`

**In Dockerfile:**
```dockerfile
RUN echo 'export PS1="\[\e[1;32m\]\u@\h\[\e[0m\]:\[\e[1;34m\]\w\[\e[0m\]\$ "' >> /root/.bashrc \
    && echo 'alias ls="ls --color=auto"' >> /root/.bashrc
```

**Result:** Terminal looks great (green prompt, colored `ls`), but doesn't affect the kilo binary.

---

### Fix #5: tmux (Partially Worked)

**Tried:** Install `tmux` and run kilo inside a tmux session

**In Dockerfile:**
```dockerfile
RUN apt-get install -y tmux
RUN echo 'alias kilo="tmux new-session -A -s kilo -n kilo kilo"' >> /root/.bashrc
```

**Result:**
- `tmux` starts successfully in the browser terminal
- tmux provides a **proper virtual PTY** that supports Go TUI operations
- `kilo --version` **works inside tmux** → prints `7.3.1`
- But the **tmux UI itself** (status bar at bottom) may not render well in xterm.js
- The kilo TUI **renders but screen may clear** and not redraw properly

**Status:** Best solution so far, but requires user to understand tmux.

---

### Fix #6: SSH Access (Working)

**Tried:** SSH from local Mac terminal

```bash
ssh -p 2222 root@kilo-remote.fly.dev
```

**Result:** Native SSH provides a **complete PTY**. `kilo --version` and interactive `kilo` TUI both work perfectly.

**Limitation:** Not a browser-based solution.

---

### Fix #7: Fly.io HTTP Service (Working)

**Tried:** Configure `fly.toml` with `http_service` for ttyd

**In fly.toml:**
```toml
[http_service]
  internal_port = 7681
  force_https = true
```

**Result:** Browser terminal accessible at `https://kilo-remote.fly.dev/`, but the TUI binary issue remains.

---

## 4. Current Workarounds

| Method | Command | Status |
|--------|---------|--------|
| **SSH from Mac/PC** | `ssh -p 2222 root@kilo-remote.fly.dev` then `kilo` | ✅ Perfect |
| **tmux in browser** | `tmux new-session "kilo --version"` | ✅ Works |
| **Direct binary in tmux** | `/usr/lib/.../cli-linux-x64/bin/kilo --version` inside tmux | ✅ Works |
| **Browser terminal direct** | `kilo --version` | ❌ Hangs |
| **Browser terminal with alias** | `kilo` (alias to tmux) | ⚠️ Starts tmux but UI may not fully render |

---

## 5. Recommended Usage

### For quick commands (browser terminal):
```bash
# Use tmux explicitly
# This creates a temporary tmux session, runs kilo, then exits
tmux new-session "kilo run 'explain this codebase'"
```

### For interactive TUI (SSH recommended):
```bash
# From your Mac/PC
ssh -p 2222 root@kilo-remote.fly.dev

# Inside the VM
kilo                    # full interactive TUI
kilo --mode architect   # plan mode
kilo --continue         # resume session
```

### For one-off tasks:
```bash
# These may work even in browser if they bypass TUI init
KILO_NONINTERACTIVE=1 kilo run "refactor this"   # depends on binary behavior
```

---

## 6. Files Modified

| File | Changes |
|------|---------|
| `Dockerfile` | Added tmux, CI env, binary cache, .bashrc colors |
| `entrypoint.sh` | TTY exports, tmux-ready environment |
| `fly.toml` | http_service for ttyd HTTPS |
| `6_Semblance/error_log.md` | F01: Kilo hang error log |
| `4_Formula/flyio_tty_fix.md` | TTY fix documentation |
| `4_Formula/flyio_deployment.md` | Deployment steps |

---

## 7. Lessons Learned

1. **Not all "CLI" tools are terminal-friendly** — Many modern CLIs are actually full TUI apps compiled in Go/Rust
2. **ttyd ≠ real terminal** — Web terminals are great for bash, but may fail for TUI apps
3. **tmux is a lifesaver** — Creates a proper PTY inside containers where TUI apps work
4. **SSH is still king** — For anything beyond basic shell commands, native SSH provides the best terminal emulation
5. **Test the actual binary, not the wrapper** — The Node.js wrapper masked that the issue was in the Go binary

---

## 8. Future Improvements

- [ ] Create a custom wrapper script that pre-detects ttyd and falls back to non-TUI mode
- [ ] Investigate `screen` as lighter alternative to tmux
- [ ] Add a health check endpoint that verifies `kilo --version` inside the container
- [ ] Document SSH key setup for passwordless auth

---

*[← Back to Formula](../README.md) · [Error Log →](../../6_Semblance/error_log.md)*
