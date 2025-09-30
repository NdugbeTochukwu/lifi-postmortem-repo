```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title LifiApprovalTrap
/// @notice Collects off-chain reports of approvals/transfers and triggers when many distinct wallets
///         interact with the same spender within a sliding block window — indicative of mass-drain from infinite approvals.
contract LifiApprovalTrap {
    uint256 public constant ORIGIN_THRESHOLD = 20;   // tune in production
    uint256 public constant WINDOW_BLOCKS = 30;      // sliding window in blocks

    // per spender: list of (origin, txHash, block)
    mapping(address => address[]) internal originsBySpender;
    mapping(address => bytes32[]) internal txsBySpender;
    mapping(address => uint256[]) internal blksBySpender;
    mapping(address => mapping(address => uint256)) internal lastSeen; // spender => origin => last seen block

    event Observed(address indexed origin, address indexed spender, bytes32 txHash, uint256 blockNumber);

    /// Off-chain reporter calls this when it sees an approval or suspicious transfer involving a spender.
    /// Reporters: Drosera node, monitoring service, chainwatcher bot.
    function report(address origin, address spender, bytes32 txHash) external {
        uint256 b = block.number;

        // dedupe if same origin/spender already recorded this block
        if (lastSeen[spender][origin] == b) {
            return;
        }
        lastSeen[spender][origin] = b;

        originsBySpender[spender].push(origin);
        txsBySpender[spender].push(txHash);
        blksBySpender[spender].push(b);

        emit Observed(origin, spender, txHash, b);
    }

    /// collect() packages per-spender evidence for Drosera:
    /// ABI: (address[] spenders, address[][] origins, bytes32[][] txs, uint256[][] blks, uint256 currentBlock)
    function collect(address[] calldata spenders) external view returns (bytes memory) {
        uint256 n = spenders.length;
        address[][] memory origins = new address[][](n);
        bytes32[][] memory txs = new bytes32[][](n);
        uint256[][] memory blks = new uint256[][](n);

        for (uint256 i = 0; i < n; i++) {
            address sp = spenders[i];
            origins[i] = originsBySpender[sp];
            txs[i] = txsBySpender[sp];
            blks[i] = blksBySpender[sp];
        }

        uint256 currentBlock = block.number;
        return abi.encode(spenders, origins, txs, blks, currentBlock);
    }

    /// pure decision function consumed by Drosera. Returns (true, abi.encode(spender,count,quote))
    function shouldRespond(bytes[] calldata data) external pure returns (bool, bytes memory) {
        if (data.length == 0) return (false, bytes(""));

        (
            address[] memory spenders,
            address[][] memory origins,
            bytes32[][] memory txs,
            uint256[][] memory blks,
            uint256 currentBlock
        ) = abi.decode(data[0], (address[], address[][], bytes32[][], uint256[][], uint256));

        uint256 minAllowed = currentBlock > WINDOW_BLOCKS ? currentBlock - WINDOW_BLOCKS + 1 : 0;

        for (uint256 i = 0; i < spenders.length; i++) {
            // count unique origins with evidence inside the window (data pre-deduped by reporter)
            uint256 cnt = 0;
            for (uint256 j = 0; j < blks[i].length; j++) {
                if (blks[i][j] >= minAllowed) cnt++;
            }

            if (cnt >= ORIGIN_THRESHOLD) {
                bytes32 quote = keccak256(abi.encodePacked(spenders[i], cnt, currentBlock, txs[i], blks[i]));
                return (true, abi.encode(spenders[i], cnt, quote));
            }
        }

        return (false, bytes(""));
    }
}
```
