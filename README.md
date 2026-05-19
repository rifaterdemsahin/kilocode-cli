# kilocode-cli
Set up kilo code cli on my mac and windows devices

> 🌐 **Live Site:** https://rifaterdemsahin.github.io/kilocode-cli/
>
> 🖥 **Web Terminal:** https://rifaterdemsahin.github.io/kilocode-cli/terminal.html
>
> ☁️ **Fly.io VM:** https://kilo-remote.fly.dev/

---

## Quick Links

| Resource | URL |
|----------|-----|
| GitHub Pages Home | https://rifaterdemsahin.github.io/kilocode-cli/ |
| Web Command Center | https://rifaterdemsahin.github.io/kilocode-cli/terminal.html |
| Fly.io Live VM | https://kilo-remote.fly.dev/ |
| Fly.io Deployment Formula | https://rifaterdemsahin.github.io/kilocode-cli/markdown_renderer.html?file=4_Formula/flyio_deployment.md |
| Cost Estimation | https://rifaterdemsahin.github.io/kilocode-cli/markdown_renderer.html?file=4_Formula/flyio_cost_estimation.md |
| Source Repo | https://github.com/rifaterdemsahin/kilocode-cli |

---

## What This Is

A structured, 7-stage self-learning system for setting up **KiloCode CLI** across macOS and Windows, plus a **Fly.io remote VM** deployment for terminal access from anywhere — including your phone.

---

## Repository Structure

| Stage | Folder | Purpose |
|-------|--------|---------|
| 1 | `1_Real_Unknown/` | OKRs and problem definitions |
| 2 | `2_Environment/` | Setup guides for Mac, Windows, AI |
| 3 | `3_Simulation/` | UI mockups and vision |
| 4 | `4_Formula/` | Step-by-step authoritative guides |
| 5 | `5_Symbols/` | Scripts, Dockerfiles, source code |
| 6 | `6_Semblance/` | Error logs and workarounds |
| 7 | `7_Testing_Known/` | Test results and validations |

---

## Fly.io Remote VM

Deploy Kilo CLI to a persistent Fly Machine and SSH in from your phone:

```bash
cd 5_Symbols/flyio
KEY_VAULT_NAME=<your-vault> ./deploy.sh
ssh -p 2222 root@kilo-remote.fly.dev
```

Full formula: [`4_Formula/flyio_deployment.md`](4_Formula/flyio_deployment.md)
