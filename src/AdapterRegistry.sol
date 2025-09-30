```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @notice Registry of allowed adapter contracts. Only registered adapters may be called by high-privilege facets.
/// @dev In production, setAdapter MUST be guarded by a multisig/timelock.
contract AdapterRegistry {
    address public owner;
    mapping(address => bool) public allowed;

    event AdapterUpdated(address indexed adapter, bool allowedFlag);

    modifier onlyOwner() {
        require(msg.sender == owner, "AdapterRegistry: only owner");
        _;
    }

    constructor(address _owner) {
        owner = _owner == address(0) ? msg.sender : _owner;
    }

    function setAdapter(address adapter, bool ok) external onlyOwner {
        require(adapter != address(0), "zero adapter");
        allowed[adapter] = ok;
        emit AdapterUpdated(adapter, ok);
    }
}
````