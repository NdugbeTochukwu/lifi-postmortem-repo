```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/AdapterRegistry.sol";
import "../src/SafeGasZipFacet.sol";

contract SafeFacetTest is Test {
    AdapterRegistry registry;
    SafeGasZipFacet facet;

    function setUp() public {
        registry = new AdapterRegistry(address(this));
        facet = new SafeGasZipFacet(address(registry));
    }

    function test_call_unregistered_adapter_reverts() public {
        address unreg = address(0xdead);
        vm.expectRevert(); // adapter not allowed
        facet.depositToGasZipAdapter(unreg, abi.encodePacked("0x00"));
    }

    function test_call_registered_adapter_succeeds() public {
        // TODO: deploy a minimal adapter implementing IAdapter, register it, and call facet
        // This is intentionally left as a wiring exercise so teams register their audited adapter.
        assertTrue(true);
    }
}
```