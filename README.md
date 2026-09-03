# EverChain Bridge Helper

A single-page static helper for moving ETE across the EverChain L1 ↔ L2
(EtherEver ↔ ArbiEver) — replacing the multi-step **Blockscout Write Contract**
UI with a focused, three-tab page.

[![Docker Hub](https://img.shields.io/badge/Docker-silverruler%2Feverchain--bridge--helper-2496ED?logo=docker)](https://hub.docker.com/r/silverruler/everchain-bridge-helper)
[![Repo](https://img.shields.io/badge/Repo-makewalletfirst%2FEverChain--Bridge--Helper-181717?logo=github)](https://github.com/makewalletfirst/EverChain-Bridge-Helper)

---

## What it does

The three steps of an L1↔L2 fund movement, collapsed into a single page with
three tabs:

| Tab | Action | Contract | Chain |
|---|---|---|---|
| ⬇️ **L1 → L2 Deposit** | `DepositHelper.depositEthTo` / `depositEthToSelf` | `0x1d69eA04…0eC2` | EtherEver L1 |
| ⬆️ **L2 → L1 Withdraw (start)** | `WithdrawHelper.withdrawEth` / `withdrawEthToSelf` | `0x9c17CAc3…7c33` | ArbiEver L2 |
| ✅ **L1 Execute Withdrawal** | `Outbox.executeTransaction` (auto Merkle proof) | `0xDBA33e4e…64Ae` | EtherEver L1 |

Additional UX:
- Auto-display of balances on both chains when the wallet connects, plus a
  manual refresh button
- Click either chain chip to switch networks via
  `wallet_switchEthereumChain`
- One-click address copy / wallet disconnect
- Dark / light theme toggle (localStorage-persisted, follows OS preference by
  default)
- After a withdrawal start, the recommended L1 execution time is shown
  (15 min challenge period + 1 min safety margin)
- The withdrawal tx hash is auto-populated into the "Execute" tab
- **Pending withdrawals are stored in localStorage** — if you close the tab
  before executing the L1 withdrawal, the hash is still there next time you
  open the page; a live countdown is rendered until the execute window opens

---

## Run

### Docker Compose (recommended for ops)

```bash
git clone https://github.com/makewalletfirst/EverChain-Bridge-Helper.git
cd EverChain-Bridge-Helper
docker compose up -d
```

Open `http://<host>:8765/`. Host port 8765 maps to container port 80.

```bash
# stop / restart
docker compose down
docker compose up -d
```

### docker run (one-liner)

```bash
docker run -d -p 8765:80 --name everchain-helper --restart unless-stopped \
  silverruler/everchain-bridge-helper:latest
```

### Build locally

```bash
git clone https://github.com/makewalletfirst/EverChain-Bridge-Helper.git
cd EverChain-Bridge-Helper
docker compose up -d --build
```

### No-Docker quick preview

```bash
cd EverChain-Bridge-Helper
python3 -m http.server 8765
```

---

## Files

| File | Role |
|---|---|
| `index.html` | The helper itself (single file; only runtime dep is ethers.js v5 via CDN) |
| `contracts.html` | Separate page listing the verified contract addresses |
| `Dockerfile` | `nginx:alpine` static hosting |
| `docker-compose.yml` | One-shot `compose up -d` definition |
| `arbiicon512.png` | Favicon |
| `etherarbiswap.png` | OG image for Kakao / Instagram / Facebook preview |
| `src/executor.html` | Mirror of `index.html` for source-control diffing |
| `src/260529ARBI_Executor.md` | Internal notes on flow + hosting options + code structure |

---

## OG metadata note

The `og:image` / `twitter:image` tags in `index.html` use a **relative path**
(`etherarbiswap.png`). Kakao / Facebook / Instagram require absolute URLs to
show previews. Once a permanent domain is fixed, swap and rebuild:

```bash
sed -i 's|content="etherarbiswap.png"|content="https://<domain>/etherarbiswap.png"|g' index.html
docker build -t silverruler/everchain-bridge-helper:latest .
docker push silverruler/everchain-bridge-helper:latest
```

---

## Contracts in use (all verified on-chain)

| Contract | Chain | Address |
|---|---|---|
| DepositHelper | EtherEver L1 | [`0x1d69eA04188Bf5e34AaDdc277a8cDE70076a0eC2`](https://etherever.ever-chain.xyz/address/0x1d69eA04188Bf5e34AaDdc277a8cDE70076a0eC2) |
| WithdrawHelper | ArbiEver L2 | [`0x9c17CAc31EB788b36Aac600cB623854359c67c33`](https://arbiever.ever-chain.xyz/address/0x9c17CAc31EB788b36Aac600cB623854359c67c33) |
| Outbox | EtherEver L1 | [`0xDBA33e4eFbEf4467eD0228C2b43b606B5F2964Ae`](https://etherever.ever-chain.xyz/address/0xDBA33e4eFbEf4467eD0228C2b43b606B5F2964Ae) |
| Inbox | EtherEver L1 | [`0x76b3772769cDD09Fb6A33e5f65fd13256808fc08`](https://etherever.ever-chain.xyz/address/0x76b3772769cDD09Fb6A33e5f65fd13256808fc08) |
| ArbSys (precompile) | ArbiEver L2 | `0x0000000000000000000000000000000000000064` |
| NodeInterface (precompile) | ArbiEver L2 | `0x00000000000000000000000000000000000000C8` |

---

## CI

`.github/workflows/ci.yml` runs on push / PR to verify the static site doesn't
break:
- Asset existence check (`index.html`, `contracts.html`, both PNGs)
- HTML syntax validation
- Dockerfile build (no push; pushes are manual on tagged builds)

---

## License

MIT
