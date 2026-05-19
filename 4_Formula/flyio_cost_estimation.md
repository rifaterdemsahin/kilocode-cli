# 💰 Formula: Fly.io Cost Estimation for Kilo Remote VM

> **Authoritative cost analysis** for running Kilo CLI on Fly.io with ttyd browser terminal.
>
> *Last updated:* 2026-05-19

---

## Architecture Recap

```
┌─────────────────────────────┐
│  Fly Machine (shared-1x CPU)  │
│  • 256 MB RAM (minimal)       │
│  • ttyd on :7681 → HTTPS 443  │
│  • sshd on :2222              │
│  • 10 GB persistent volume    │
│  • auto_stop_machines = true  │
└───────────────────────────────┘
```

`auto_stop_machines = true` means the VM **pauses when idle** — you pay $0 for compute when nobody is connected.

---

## Fly.io Pricing Model (2026)

| Resource | Price | Notes |
|----------|-------|-------|
| **Shared-1x CPU** | ~$0.87 / month (prorated to seconds) | Cheapest tier; 1 vCPU shared |
| **RAM** | ~$1.56 / GB / month (prorated) | We use 256 MB = ~$0.39 / month while running |
| **Volume Storage** | ~$0.15 / GB / month | Always charged, even when machine is stopped |
| **Outbound Bandwidth** | $0.02 / GB (first 100 GB/mo) | API calls to kilo.ai, terminal traffic |
| **IPv4 Address** | ~$2 / month | If using dedicated IPv4; shared IPv6 is free |

*Source: [Fly.io Pricing Calculator](https://fly.io/calculator) and [Pricing Docs](https://fly.io/docs/about/pricing/)*

---

## Cost Scenarios

### Scenario A: Light Usage (1 hour/day)

You connect for 1 hour per day, 30 days/month.

| Item | Calculation | Monthly Cost |
|------|-------------|--------------|
| Compute (shared-1x) | 30 hrs × $0.0012/hr | ~$0.04 |
| RAM (256 MB) | 30 hrs × $0.0021/hr | ~$0.06 |
| Volume (10 GB) | 10 GB × $0.15/GB | **$1.50** |
| Bandwidth (API calls) | ~50 MB × $0.02/GB | ~$0.00 |
| **Total** | | **~$1.60 / month** |

### Scenario B: Moderate Usage (4 hours/day)

You work actively for 4 hours per day.

| Item | Calculation | Monthly Cost |
|------|-------------|--------------|
| Compute (shared-1x) | 120 hrs × $0.0012/hr | ~$0.14 |
| RAM (256 MB) | 120 hrs × $0.0021/hr | ~$0.25 |
| Volume (10 GB) | 10 GB × $0.15/GB | **$1.50** |
| Bandwidth (API calls) | ~200 MB × $0.02/GB | ~$0.00 |
| **Total** | | **~$1.90 / month** |

### Scenario C: Always On (no auto-stop)

If you disabled `auto_stop_machines` and kept it running 24/7.

| Item | Calculation | Monthly Cost |
|------|-------------|--------------|
| Compute (shared-1x) | 730 hrs × $0.0012/hr | ~$0.87 |
| RAM (256 MB) | 730 hrs × $0.0021/hr | ~$1.56 |
| Volume (10 GB) | 10 GB × $0.15/GB | **$1.50** |
| Bandwidth | Variable | ~$0.00–$0.50 |
| **Total** | | **~$4.00 / month** |

---

## Comparison Table

| Setup | Monthly Cost | Use Case |
|-------|-------------|----------|
| **Fly.io (light, 1 hr/day)** | ~$1.60 | Phone access, occasional debugging |
| **Fly.io (moderate, 4 hrs/day)** | ~$1.90 | Daily remote work from browser/phone |
| **Fly.io (always on)** | ~$4.00 | 24/7 availability, no startup delay |
| **Local Mac/PC** | $0 | Primary development environment |
| **GitHub Codespaces** | ~$4–$18 | Cloud IDE with pre-configured stacks |
| **AWS EC2 t3.micro** | ~$8.50 | 24/7 Linux VM (not pay-per-second) |
| **Hetzner CX11** | ~$5 | 24/7 VPS (very cheap, no auto-stop) |

**Key insight:** Fly.io wins for **intermittent usage** because you only pay for seconds of compute. For 24/7 workloads, Hetzner or dedicated VPS may be cheaper.

---

## Cost Optimization Tips

1. **Keep `auto_stop_machines = true`** — This is the biggest savings. A paused machine costs $0 compute.
2. **Minimize RAM** — 256 MB is enough for a single-user shell + ttyd. Only increase if running heavy indexing.
3. **Use shared CPU** — `performance` CPUs cost ~4× more. Shared is fine for terminal workloads.
4. **Reserve if 24/7** — If you need always-on, a Fly Machine reservation gives 40% off.
5. **Monitor bandwidth** — Kilo API calls are small, but streaming ttyd output adds up. Set alerts at 1 GB egress.

---

## Billing Alerts

Set up in the [Fly.io dashboard](https://fly.io/dashboard):

| Alert Threshold | Why |
|-----------------|-----|
| $5 / month | Catch runaway usage early |
| 5 GB egress | Unusually high terminal traffic |
| 100 machine hours | Something kept the VM awake unexpectedly |

---

## Files Map

| Stage | Path | Role |
|-------|------|------|
| **Formula (this doc)** | `4_Formula/flyio_cost_estimation.md` | Cost reasoning and scenarios |
| **Formula** | `4_Formula/flyio_deployment.md` | Deployment steps |
| **Symbols** | `5_Symbols/flyio/fly.toml` | Where `auto_stop_machines` is configured |

---

*[← Stage 4 Overview](./README.md) · [Fly.io Deployment Formula →](./flyio_deployment.md)*
