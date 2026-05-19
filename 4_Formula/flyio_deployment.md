# 🚀 Formula: Kilo CLI on Fly.io

> **Authoritative steps** for deploying Kilo CLI to a persistent Fly Machine with Azure Key Vault secret management.
>
> *Prerequisites:* Fly.io account, Azure CLI, SSH key pair.

---

## 1. Why Fly.io?

| Requirement | How Fly.io Delivers |
|-------------|---------------------|
| Access from anywhere | Global Anycast network + SSH on port 2222 |
| Persist projects across restarts | Fly Volume mounted at `/root/projects` |
| Pay only when using | `auto_stop_machines = true` pauses VM when idle |
| No API key in code | Azure Key Vault → Fly secrets at deploy time |
| Works with existing subscription | Outbound HTTPS to `kilo.ai` consumes your credits normally |

---

## 2. Architecture

```
┌─────────────────┐      SSH (port 2222)      ┌─────────────────────────────┐
│  Your Phone     │  ───────────────────────→ │  Fly Machine (Ubuntu + Kilo)  │
│  (Blink/Termux) │                           │  • Node 20 + @kilocode/cli   │
└─────────────────┘                           │  • Projects on Fly Volume     │
                                              │  • API key from Fly secrets   │
                                              └──────────────┬──────────────┘
                                                             │ HTTPS
                                                             ↓
                                              ┌─────────────────────────────┐
                                              │     kilo.ai API gateway     │
                                              │   (uses your subscription)  │
                                              └─────────────────────────────┘
```

---

## 3. Prepare Secrets

### 3.1 Store the API key in Azure Key Vault

Get your key from https://app.kilo.ai/profile.

```bash
az login
az keyvault secret set \
  --vault-name <YOUR_VAULT_NAME> \
  --name kilo-api-key \
  --value "<PASTE_KEY_HERE>"
```

> **Rule:** The key must never touch disk in plain text inside this repo.

### 3.2 Prepare your SSH public key

```bash
cat ~/.ssh/id_ed25519.pub > authorized_keys
```

Place `authorized_keys` next to the Dockerfile so it is copied into the image at build time.

---

## 4. Build & Deploy

### 4.1 Provision infrastructure

The deploy script handles the entire flow:

```bash
cd 5_Symbols/flyio
chmod +x deploy.sh
KEY_VAULT_NAME=<YOUR_VAULT_NAME> ./deploy.sh
```

What `deploy.sh` does (in order):

1. Validates `az` and `flyctl` are installed and authenticated.
2. Fetches the secret value from Azure Key Vault (`kilo-api-key`).
3. Injects it into Fly.io as `KILO_API_KEY`.
4. Creates a 10 GB persistent volume `kilo_data` in `lhr` (idempotent — skips if exists).
5. Builds the Docker image and deploys the machine.

### 4.2 Verify deployment

```bash
flyctl status --app kilo-remote
flyctl logs --app kilo-remote
```

You should see:

```
✓ KILO_API_KEY is set (length: 342)
Starting SSH daemon on port 2222...
```

---

## 5. Connect and Use

### 5.1 SSH from desktop

```bash
ssh -p 2222 root@kilo-remote.fly.dev
```

### 5.2 SSH from mobile

* **iOS:** [Blink Shell](https://blink.sh/) — add host `kilo-remote.fly.dev:2222`
* **Android:** Termux + `pkg install openssh` then `ssh -p 2222 root@kilo-remote.fly.dev`

### 5.3 Run Kilo CLI

Inside the VM:

```bash
kilo --version
kilo run "refactor this function to use async/await"
```

All agentic workflows available in the VS Code extension work identically here because the CLI uses the same underlying engine.

---

## 6. Formula Logic

### 6.1 Why Ubuntu 24.04 + NodeSource?

* Ubuntu LTS gives a 5-year support window.
* Nodesource GPG-signed repo guarantees Node 20 without compilation.
* `@kilocode/cli` installed globally so `kilo` is on `$PATH` for root.

### 6.2 Why port 2222 instead of 22?

Fly.io reserves port 22 internally. Using 2222 avoids collision and maps cleanly through Fly Proxy.

### 6.3 Why a Fly Volume instead of the root filesystem?

Fly Machines are ephemeral. Anything written outside a mounted volume is lost on restart. Projects live in `/root/projects` which is the mount point.

### 6.4 Cost model

| Component | Billing |
|-----------|---------|
| Volume (10 GB) | ~$0.15/GB/month |
| Compute while SSHed | Shared-cpu-1x RAM rates, prorated to seconds |
| Idle (auto-stopped) | $0 compute; only volume storage |
| Outbound API calls | Free on Fly.io for reasonable egress |

---

## 7. Troubleshooting

| Symptom | Root Cause | Fix |
|---------|-----------|-----|
| `Connection refused` on SSH | Port mapping mismatch | Verify `fly.toml` exposes `2222` and you use `-p 2222` |
| Projects gone after restart | Written to root FS instead of volume | Ensure you `cd /root/projects` before working |
| `kilo: command not found` | npm global path issue | Re-deploy; check `npm root -g` is on `$PATH` |
| Auth errors with Kilo API | `KILO_API_KEY` missing | Re-run `deploy.sh`; check `echo $KILO_API_KEY` inside VM |
| Deploy script fails at AKV step | Vault name wrong or no RBAC | Confirm `az keyvault secret show` works locally first |

---

## 8. Security Checklist

- [ ] API key stored only in Azure Key Vault and Fly secrets
- [ ] `authorized_keys` restricted to ED25519 or RSA ≥ 4096
- [ ] `auto_stop_machines = true` enabled to reduce attack surface when idle
- [ ] No hardcoded credentials in `Dockerfile`, `fly.toml`, or `entrypoint.sh`
- [ ] Volume backup strategy considered (Fly does not snapshot volumes automatically)

---

## 9. Files Map

| Stage | Path | Role |
|-------|------|------|
| **Formula (this doc)** | `4_Formula/flyio_deployment.md` | Authoritative reasoning and steps |
| **Symbols** | `5_Symbols/flyio/Dockerfile` | Build image definition |
| **Symbols** | `5_Symbols/flyio/fly.toml` | Fly platform configuration |
| **Symbols** | `5_Symbols/flyio/entrypoint.sh` | Container runtime bootstrap |
| **Symbols** | `5_Symbols/flyio/deploy.sh` | Azure Key Vault → Fly deploy automation |
| **Symbols** | `5_Symbols/flyio/README.md` | Quick reference for operators |

---

*[← Stage 4 Overview](./README.md) · [Stage 5: Symbols →](../5_Symbols/README.md)*
