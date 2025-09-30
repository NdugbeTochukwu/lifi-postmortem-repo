```md
# Postmortem — LI.FI (July 16, 2024)

## Executive summary

On July 16, 2024 LI.FI experienced a security incident in which attackers drained funds from users who had previously granted infinite ERC-20 approvals to the LI.FI diamond contract. The immediate enabling factor was a newly deployed facet that allowed arbitrary call behavior where attacker-controlled calldata was passed into a low-level `call` path. Because many users had infinite approvals, attackers were able to combine the arbitrary-call capability with `transferFrom` calls to drain funds.

This repository provides a defensive, non-actionable analysis and recommended mitigations.

## Root cause (high level)

- A newly deployed facet introduced a low-level `call` or equivalent arbitrary execution path that could invoke `transferFrom` against user accounts.
- Large numbers of users had granted infinite approvals to LI.FI's contracts, which made assets immediately withdrawable if the contract executed `transferFrom` in an attacker-desired path.
- The facet was insufficiently constrained (no adapter allowlist or explicit interface enforcement) and was deployed without test coverage simulating infinite approvals + the new call path.

## Mitigations

- Replace or restrict arbitrary-call gadgets: use an on-chain AdapterRegistry allowing only vetted adapter contracts.
- Require explicit adapter interfaces (no `call(target, data)` with user-supplied target).
- Use multisig/timelock for registering adapters and enabling risky facets.
- Encourage UI and libraries to avoid infinite approvals where possible and offer easy revoke UX.
- Add detection: mass-approval / mass-transfer traps that raise alerts when many distinct origins interact with the same spender in a short window.

## References

LI.FI official incident report and public analyses (see original LI.FI post for details).
````
