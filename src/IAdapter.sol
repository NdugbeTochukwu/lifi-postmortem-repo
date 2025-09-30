```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @notice Minimal, explicit adapter interface.
/// @dev Adapters must be audited and registered in AdapterRegistry before being used.
interface IAdapter {
    /// Execute adapter logic. Data is adapter-specific and parsed by the adapter.
    function execute(bytes calldata data) external;
}
```