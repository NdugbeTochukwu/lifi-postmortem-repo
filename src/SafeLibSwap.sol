```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./IAdapter.sol";
import "./AdapterRegistry.sol";

/// @notice SafeLibSwap: adapter-based swap invoker that avoids arbitrary low-level calls.
/// Intended as a drop-in safe replacement for any library function that previously performed attacker-controlled calls.
library SafeLibSwap {
    /// Call a registered adapter via IAdapter.execute(...)
    /// - registry: address of AdapterRegistry
    /// - adapter: adapter address (must be registry.allowed)
    /// - data: adapter-structured calldata
    function callAdapter(AdapterRegistry registry, address adapter, bytes calldata data) internal {
        require(adapter != address(0), "adapter zero");
        require(registry.allowed(adapter), "adapter not allowed");
        IAdapter(adapter).execute(data);
    }
}
```