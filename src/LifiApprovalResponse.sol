```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title LifiApprovalResponse
/// @notice Emits on-chain alert when trap indicates mass-approval / mass-transfer pattern.
contract LifiApprovalResponse {
    address public owner;
    mapping(address => bool) public trustedSpender; // e.g., known routers/bridges that are OK

    event LifiMassApprovalAlert(address indexed spender, uint256 count, bytes32 quote);

    modifier onlyOwner() {
        require(msg.sender == owner, "only owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function setTrusted(address spender, bool ok) external onlyOwner {
        trustedSpender[spender] = ok;
    }

    /// handleResponse expects abi.encode(spender, count, quote)
    function handleResponse(bytes calldata payload) external returns (bool) {
        if (payload.length == 0) return false;
        (address spender, uint256 count, bytes32 quote) = abi.decode(payload, (address, uint256, bytes32));
        if (trustedSpender[spender]) return false;
        emit LifiMassApprovalAlert(spender, count, quote);
        return true;
    }
}
```