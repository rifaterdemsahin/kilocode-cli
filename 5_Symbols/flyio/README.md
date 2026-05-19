# 🚀 Kilo CLI on Fly.io (Production Setup)

Run Kilo CLI on a persistent Fly Machine so you can SSH in from anywhere — including your phone — and use your existing Kilo subscription.

---

> **Quick reference for operators.**  
> For the authoritative reasoning and steps, see the [Formula](../../4_Formula/flyio_deployment.md).

---

## Architecture

```
┌─────────────────┐      SSH (port 2222)      ┌─────────────────────────────┐
│  Your Phone     │  ───────────────────────→ │  Fly Machine (Ubuntu + Kilo)  │
│  (Blink/Termux) │                           │  • Kilo CLI installed         │
└─────────────────┘                           │  • Projects on Fly Volume     │
                                              │  • API key from Fly secrets   │
                                              └──────────────┬──────────────┘
                                                             │
                                                             │ HTTPS
                                                             ↓
                                              ┌─────────────────────────────┐
                                              │     kilo.ai API gateway     │
                                              │   (uses your subscription)  │
                                              └─────────────────────────────┘
```

Key features:

* **Persistent projects** via a Fly Volume mounted at `/root/projects`
* **Zero-downtime SSH** on port `2222`
* **Auto-stop** when idle (`auto_stop_machines = true`) so you only pay for compute while connected
* **Secret management** via Azure Key Vault → Fly secrets (never commit keys)

---

## Prerequisites

1. [Fly.io](https://fly.io/docs/hands-on/install-flyctl/) account and `flyctl` CLI
2. [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) (`az`) and an Azure Key Vault
3. Your public SSH key (to copy into the machine)

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

### 2. Add your SSH public key

```bash
cat ~/.ssh/id_ed25519.pub > authorized_keys
# (Place authorized_keys next to Dockerfile before deploying)
```

### 3. Deploy

```bash
chmod +x deploy.sh
KEY_VAULT_NAME=<your-vault-name> ./deploy.sh
```

The script will:

1. Fetch the secret from Azure Key Vault
2. Inject it into Fly.io as `KILO_API_KEY`
3. Create a 10 GB persistent volume if it doesn't exist
4. Build and deploy the machine

### 4. SSH in from anywhere

```bash
ssh -p 2222 root@kilo-remote.fly.dev
```

From iOS use [Blink Shell](https://blink.sh/); from Android use Termux + OpenSSH client.

### 5. Run Kilo

```bash
kilo --version
kilo run "refactor this function to use async/await"
```

---

## File Layout

| File           | Purpose                                    |
|----------------|--------------------------------------------|
| `Dockerfile`   | Ubuntu 24.04 + Node 20 + `@kilocode/cli`   |
| `fly.toml`     | Fly app config, mount, SSH service         |
| `entrypoint.sh`| Runtime bootstrap for SSH + secret check   |
| `deploy.sh`    | One-shot deploy with AKV → Fly secret    |
| `README.md`    | This file                                  |

---

## Cost Optimization

* `auto_stop_machines = true` pauses the VM when no SSH session is active (you stop paying for CPU/RAM)
* You only pay for the 10 GB volume (~$0.15/GB/month) and brief compute while using it
* Kilo API calls are outbound HTTPS; Fly.io does not charge for reasonable egress

---

## Security Notes

* **Never** commit `KILO_API_KEY` to git. It lives only in Azure Key Vault and Fly.io's encrypted secret store.
* The container runs as `root` for simplicity in a single-tenant VM. For hardened multi-user setups, create unprivileged users in the Dockerfile.
* Keep your `authorized_keys` file restrictive; consider using ED25519 keys.

---

## Troubleshooting

| Symptom                              | Fix                                                                    |
|--------------------------------------|------------------------------------------------------------------------|
| `Connection refused` on SSH          | Ensure `services.ports` in `fly.toml` maps port `2222`.              |
| Projects lost after restart          | Verify the volume is mounted at `/root/projects` and you write there.|
| `kilo: command not found` inside VM| The Dockerfile installs `@kilocode/cli` globally. Re-deploy if missing.|
| Auth errors with Kilo API            | Check `echo $KILO_API_KEY` inside the VM; re-run `deploy.sh` if empty.|

---

*[← Stage 5 Overview](../README.md)*
