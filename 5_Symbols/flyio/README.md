# 🚀 Kilo CLI on Fly.io (Production Setup)

Run Kilo CLI on a persistent Fly Machine. Access via **SSH** or a **real browser terminal** (ttyd) — both connect to the same live bash shell.

---

> **Quick reference for operators.**
> For the authoritative reasoning and steps, see the [Formula](../../4_Formula/flyio_deployment.md).

---

## Architecture

```
┌─────────────────┐      SSH (port 2222)      ┌─────────────────────────────┐
│  Your Phone     │  ───────────────────────→ │  Fly Machine (Ubuntu + Kilo)  │
│  (Blink/Termux) │                           │  • Node 20 + @kilocode/cli   │
└─────────────────┘                           │  • ttyd on port 7681 → HTTPS  │
                                              │  • Projects on Fly Volume     │
┌─────────────────┐      HTTPS (port 443)       │  • API key from Fly secrets   │
│  Browser        │  ───────────────────────→ │                               │
│  (any device)   │   Real bash via ttyd        └───────────────────────────────┘
└─────────────────┘                                                           │
                                                                             │ HTTPS
                                                                             ↓
                                              ┌─────────────────────────────┐
                                              │     kilo.ai API gateway     │
                                              │   (uses your subscription)  │
                                              └─────────────────────────────┘
```

Key features:

* **Real browser terminal** — open `https://kilo-remote.fly.dev` in any browser, get a live bash shell
* **Persistent projects** via a Fly Volume mounted at `/root/projects`
* **Auto-stop** when idle (`auto_stop_machines = true`) so you only pay for compute while connected
* **Secret management** via Azure Key Vault → Fly secrets (never commit keys)

---

## Prerequisites

1. [Fly.io](https://fly.io/docs/hands-on/install-flyctl/) account and `flyctl` CLI
2. [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) (`az`) and an Azure Key Vault
3. Your public SSH key (optional — for SSH access; browser terminal works without it)

---

## Quick Start

### 1. Store your API key in Azure Key Vault

```bash
az keyvault secret set \
  --vault-name <your-vault-name> \
  --name kilo-api-key \
  --value "<your-kilo-api-key>"
```

> Your key comes from https://app.kilo.ai/profile
> Do **not** commit it to this repo.

### 2. Deploy

```bash
chmod +x deploy.sh
KEY_VAULT_NAME=<your-vault-name> ./deploy.sh
```

The script will:

1. Fetch the secret from Azure Key Vault
2. Inject it into Fly.io as `KILO_API_KEY`
3. Set a random `TTYD_PASSWORD` for browser terminal auth (if not already set)
4. Create a 10 GB persistent volume if it doesn't exist
5. Build and deploy the machine

### 3. Access the real terminal in your browser

```
https://kilo-remote.fly.dev
```

Login: `root` / password: the `TTYD_PASSWORD` from `flyctl secrets list --app kilo-remote`

This is a **real bash shell** — `kilo`, `git`, `node`, `vim` all work exactly as they would in SSH.

### 4. Or SSH in from anywhere

```bash
ssh -p 2222 root@kilo-remote.fly.dev
```

From iOS use [Blink Shell](https://blink.sh/); from Android use Termux + OpenSSH client.

### 5. Run Kilo

```bash
kilo --version
kilo run "refactor this function to use async/await"
```

All agentic workflows available in the VS Code extension work identically here because the CLI uses the same underlying engine.

---

## File Layout

| File           | Purpose                                    |
|----------------|--------------------------------------------|
| `Dockerfile`   | Ubuntu 24.04 + Node 20 + `@kilocode/cli` + ttyd |
| `fly.toml`     | Fly app config, mount, SSH (2222), HTTP (443) |
| `entrypoint.sh`| Runtime bootstrap for SSH + ttyd + secret check |
| `deploy.sh`    | One-shot deploy with AKV → Fly secrets    |
| `README.md`    | This file                                  |

---

## Cost Optimization

* `auto_stop_machines = true` pauses the VM when no SSH or browser session is active (you stop paying for CPU/RAM)
* You only pay for the 10 GB volume (~$0.15/GB/month) and brief compute while using it
* Kilo API calls are outbound HTTPS; Fly.io does not charge for reasonable egress

---

## Security Notes

* **Never** commit `KILO_API_KEY` to git. It lives only in Azure Key Vault and Fly.io's encrypted secret store.
* The container runs as `root` for simplicity in a single-tenant VM. For hardened multi-user setups, create unprivileged users in the Dockerfile.
* Keep your `authorized_keys` file restrictive; consider using ED25519 keys.
* **Browser terminal** is protected by `TTYD_PASSWORD`. If you want to disable auth (not recommended), unset the secret: `flyctl secrets unset TTYD_PASSWORD --app kilo-remote`

---

## Troubleshooting

| Symptom                              | Fix                                                                    |
|--------------------------------------|------------------------------------------------------------------------|
| `Connection refused` on SSH          | Ensure `services.ports` in `fly.toml` maps port `2222`.              |
| Browser terminal shows login prompt  | Use `root` as user and `TTYD_PASSWORD` from `flyctl secrets list`.     |
| Projects lost after restart          | Verify the volume is mounted at `/root/projects` and you write there.|
| `kilo: command not found` inside VM| The Dockerfile installs `@kilocode/cli` globally. Re-deploy if missing.|
| Auth errors with Kilo API            | Check `echo $KILO_API_KEY` inside the VM; re-run `deploy.sh` if empty.|

---

*[← Stage 5 Overview](../README.md)*
