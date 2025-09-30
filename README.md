# lifi-postmortem-repo
```md
# LI.FI — Postmortem & Defensive Artifacts

This repository contains a public, defensive postmortem and safe remediations for the LI.FI incident (July 16, 2024) where attackers abused an arbitrary-call facet to drain wallets with infinite approvals.

**What this repo provides**

- A non-actionable root-cause analysis and timeline (see `docs/postmortem.md`).
- Safe patch patterns (AdapterRegistry + SafeFacet) to avoid arbitrary-call gadgets.
- Drosera-style detection (trap + response) tuned to mass-approval/mass-drain patterns.
- Foundry-style test skeletons that validate defensive behavior (no exploit code).

**Important:** This repository intentionally does **not** include runnable exploit code or step-by-step attacker instructions. Its purpose is defensive: analysis, patch suggestions, and detection tooling.

## Quick start

1. Copy files from `/src` and `/test` into your repository.
2. Run `forge test` (Foundry) after installing dependencies. Tests are skeletons and may require small wiring.
3. Deploy `AdapterRegistry` and use a multisig/timelock to manage `setAdapter` in production.
