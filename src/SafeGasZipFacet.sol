```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./AdapterRegistry.sol";
import "./SafeLibSwap.sol";

/// @notice Example replacement facet for GasZipFacet that avoids the arbitrary-call vulnerability.
/// This facet demonstrates: only registered adapters may be invoked; the adapter interface is explicit.
contract SafeGasZipFacet {
    AdapterRegistry public registry;
    address public guardian; // optional emergency actor (owner/multisig should control)

    event GasTopupRequested(address indexed user, uint256 amount, address indexed adapter);
    event GuardianUpdated(address indexed g);

    constructor(address _registry) {
        require(_registry != address(0), "registry zero");
        registry = AdapterRegistry(_registry);
    }

    /// Set a guardian (should be guarded by multisig in production)
    function setGuardian(address g) external {
        // adapt to your ACL (this is a placeholder; wire to multisig/timelock)
        guardian = g;
        emit GuardianUpdated(g);
    }

    /// Example public entrypoint: top up gas via an audited adapter.
    /// - adapter must be registered in AdapterRegistry
    /// - adapterPayload is parsed by adapter (not by this facet)
    function depositToGasZipAdapter(address adapter, bytes calldata adapterPayload) external {
        // Verify adapter is allowed; SafeLibSwap will re-check.
        SafeLibSwap.callAdapter(registry, adapter, adapterPayload);

        // Emit a lightweight audit event containing minimal info
        emit GasTopupRequested(msg.sender, 0, adapter);
    }

    // Note: This facet intentionally does NOT accept a user-controlled (target, data) pair
    // which would otherwise allow arbitrary execution in protocol context.
}
```