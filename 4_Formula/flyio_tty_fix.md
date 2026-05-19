# 🔧 Fix Log: Kilo CLI Hangs in ttyd Browser Terminal

> **Issue:** `kilo` and `kilo --version` hang indefinitely in the Fly.io ttyd browser terminal, while the same binary works during Docker build and on local macOS.

---

## Symptoms

```bash
root@48e4535b96d4e8:/# kilo
^C                # hangs, requires Ctrl+C
root@48e4535b96d4e8:/# kilo --version
^C                # also hangs
root@48e4535b96d4e8:/# ping 1.1.1.1
bash: ping: command not found
```

- `kilo` (no args) starts but never renders — ttyd web terminal may not provide a proper TTY for Node.js TUI libraries
- `kilo --version` also hangs — suggests the binary does TTY detection or network initialization before printing version
- `ping` not found — Ubuntu 24.04 Docker minimal image omits network utilities

---

## Root Causes

### Cause 1: Missing Network Tools (Fixed)

Ubuntu 24.04 Docker base image is minimal. `iputils-ping`, `dnsutils`, `netcat-openbsd` are not included.

**Fix:** Add them to Dockerfile apt install list.

### Cause 2: ttyd TTY Environment Incompatible with Kilo TUI (Fixed)

`kilo` is a Node.js CLI that uses interactive TUI libraries (likely `ink` or similar). When launched:

1. It probes `process.stdin.isTTY` and `process.stdout.isTTY`
2. It tries to read terminal size via `ioctl(STDOUT_FILENO, TIOCGWINSZ, ...)`
3. In ttyd's web terminal, TTY detection can behave differently than a standard xterm
4. If TTY detection hangs or `TERM`/`COLUMNS`/`LINES` are unset, the process blocks

**Evidence:**
- `kilo --version` works during Docker build (output `7.3.1`) because Docker provides a non-interactive pseudo-TTY
- `kilo --version` hangs in ttyd because ttyd's TTY is interactive but the Node.js TUI library may wait for terminal readiness

**Fix:**
1. Set `TERM=xterm-256color` as Dockerfile `ENV`
2. In entrypoint, export `COLUMNS=80` and `LINES=24` before starting ttyd
3. Pass these env vars explicitly through ttyd's command: `bash -c 'export TERM=xterm-256color COLUMNS=80 LINES=24; exec bash'`

---

## Files Changed

| File | Change |
|------|--------|
| `Dockerfile` | Added `ENV TERM=xterm-256color`, `ENV NODE_NO_WARNINGS=1`, added `iputils-ping`, `dnsutils`, `netcat-openbsd` packages |
| `entrypoint.sh` | Set `TERM`, `COLUMNS`, `LINES` exports; pass them through ttyd command |
| `6_Semblance/error_log.md` | Added error entry `F01` documenting the symptoms and fix |
| `4_Formula/flyio_tti_fix.md` | This document |

---

## Verification Steps

After redeploy:

```bash
# In the browser terminal (https://kilo-remote.fly.dev/)
ping 1.1.1.1           # should show ICMP replies
kilo --version         # should print version in < 3 seconds
kilo run "test"        # should start and accept input
```

---

## Prevention

1. Always include `iputils-ping` and `dnsutils` in Ubuntu Docker images for remote VMs
2. For TUI Node.js CLIs, explicitly set `TERM`, `COLUMNS`, `LINES` in container environments
3. Test CLI binaries inside the target terminal environment (ttyd, not just Docker build)

---

*[← Back to Formula](../README.md) · [Error Log →](../../6_Semblance/error_log.md)*
