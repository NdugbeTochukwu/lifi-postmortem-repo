```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/LifiApprovalTrap.sol";

contract LifiTrapTest is Test {
    LifiApprovalTrap trap;

    function setUp() public {
        trap = new LifiApprovalTrap();
    }

    function test_trap_triggers_on_many_reports() public {
        address spender = address(0x100);

        for (uint i = 0; i < 25; i++) {
            address origin = address(uint160(i + 0x1000));
            trap.report(origin, spender, keccak256(abi.encodePacked(i)));
        }

        address[] memory spenders = new address[](1);
        spenders[0] = spender;
        bytes memory packed = trap.collect(spenders);

        bytes[] memory arr = new bytes[](1);
        arr[0] = packed;

        (bool ok, bytes memory resp) = trap.shouldRespond(arr);
        assertTrue(ok, "trap should have triggered");
    }
}
```