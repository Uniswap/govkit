// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

import {ChainId} from "../../src/constants/ChainId.sol";
import {WormholeChainId} from "../../src/constants/WormholeChainId.sol";

import {Test} from "forge-std/Test.sol";

contract WormholeChainIdTest is Test {
    function testChainIdToWormholeChainId() external {
        assertEq(
            WormholeChainId.chainIdToWormholeChainId(ChainId.Avalanche), WormholeChainId.Avalanche
        );
        assertEq(
            WormholeChainId.chainIdToWormholeChainId(ChainId.BNBChain), WormholeChainId.BNBChain
        );
        assertEq(
            WormholeChainId.chainIdToWormholeChainId(ChainId.Ethereum), WormholeChainId.Ethereum
        );
        assertEq(WormholeChainId.chainIdToWormholeChainId(ChainId.MegaEth), WormholeChainId.MegaEth);
        assertEq(WormholeChainId.chainIdToWormholeChainId(ChainId.Monad), WormholeChainId.Monad);
        assertEq(
            WormholeChainId.chainIdToWormholeChainId(ChainId.RootStock), WormholeChainId.RootStock
        );
        assertEq(WormholeChainId.chainIdToWormholeChainId(ChainId.Tempo), WormholeChainId.Tempo);
    }

    function testWormholeChainIdToChainId() external {
        assertEq(
            WormholeChainId.wormholeChainIdToChainId(WormholeChainId.Avalanche), ChainId.Avalanche
        );
        assertEq(
            WormholeChainId.wormholeChainIdToChainId(WormholeChainId.BNBChain), ChainId.BNBChain
        );
        assertEq(
            WormholeChainId.wormholeChainIdToChainId(WormholeChainId.Ethereum), ChainId.Ethereum
        );
        assertEq(WormholeChainId.wormholeChainIdToChainId(WormholeChainId.MegaEth), ChainId.MegaEth);
        assertEq(WormholeChainId.wormholeChainIdToChainId(WormholeChainId.Monad), ChainId.Monad);
        assertEq(
            WormholeChainId.wormholeChainIdToChainId(WormholeChainId.RootStock), ChainId.RootStock
        );
        assertEq(WormholeChainId.wormholeChainIdToChainId(WormholeChainId.Tempo), ChainId.Tempo);
    }
}
