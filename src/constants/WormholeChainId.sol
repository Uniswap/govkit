// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.34;

import {ChainId} from "src/constants/ChainId.sol";

// source: https://wormhole.com/docs/products/reference/chain-ids/
library WormholeChainId {
    error UnknownWormholeChainId(uint256 chainId);
    error UnknownChainId(uint16 wormholeChainId);

    uint16 internal constant Arbitrum = 23;
    uint16 internal constant Avalanche = 6;
    uint16 internal constant Base = 30;
    uint16 internal constant BNBChain = 4;
    uint16 internal constant Celo = 14;
    uint16 internal constant Ethereum = 2;
    uint16 internal constant Optimism = 24;
    uint16 internal constant Polygon = 5;
    uint16 internal constant UniChain = 44;
    uint16 internal constant WorldChain = 45;

    function chainIdToWormholeChainId(
        uint256 chainId
    ) internal pure returns (uint16) {
        if (chainId == ChainId.Arbitrum) {
            return Arbitrum;
        } else if (chainId == ChainId.Avalanche) {
            return Avalanche;
        } else if (chainId == ChainId.Base) {
            return Base;
        } else if (chainId == ChainId.BNBChain) {
            return BNBChain;
        } else if (chainId == ChainId.Celo) {
            return Celo;
        } else if (chainId == ChainId.Ethereum) {
            return Ethereum;
        } else if (chainId == ChainId.Optimism) {
            return Optimism;
        } else if (chainId == ChainId.Polygon) {
            return Polygon;
        } else if (chainId == ChainId.UniChain) {
            return UniChain;
        } else if (chainId == ChainId.WorldChain) {
            return WorldChain;
        }

        revert UnknownWormholeChainId(chainId);
    }

    function wormholeChainIdtoChainId(
        uint16 wormholeChainId
    ) internal pure returns (uint256) {
        if (wormholeChainId == Arbitrum) {
            return ChainId.Arbitrum;
        } else if (wormholeChainId == Avalanche) {
            return ChainId.Avalanche;
        } else if (wormholeChainId == Base) {
            return ChainId.Base;
        } else if (wormholeChainId == BNBChain) {
            return ChainId.BNBChain;
        } else if (wormholeChainId == Celo) {
            return ChainId.Celo;
        } else if (wormholeChainId == Ethereum) {
            return ChainId.Ethereum;
        } else if (wormholeChainId == Optimism) {
            return ChainId.Optimism;
        } else if (wormholeChainId == Polygon) {
            return ChainId.Polygon;
        } else if (wormholeChainId == UniChain) {
            return ChainId.UniChain;
        } else if (wormholeChainId == WorldChain) {
            return ChainId.WorldChain;
        }

        revert UnknownChainId(wormholeChainId);
    }
}
