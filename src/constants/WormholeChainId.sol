// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

import {ChainId} from "src/constants/ChainId.sol";

// source: https://wormhole.com/docs/products/reference/chain-ids/
/// @title Wormhole Chain ID
/// @dev This is Wormhole's chain ID system for arbitrary blockchains. We
///      implement this library to fully encapsulate this system so propsal
///      writers only need to focus on the canonical chain ID system.
library WormholeChainId {
    /// @dev Thrown when an EIP-155 chain ID does not map to a Wormhole chain ID.
    error UnknownWormholeChainId(uint256 chainId);

    /// @dev Thrown when a Wormhole chain ID does not map to an EIP-155 chain ID.
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

    /// @dev Maps an EIP-155 chain ID to a Wormhole chain ID.
    /// @param chainId EIP-155 chain ID.
    /// @return Wormhole chain ID.
    function chainIdToWormholeChainId(uint256 chainId) internal pure returns (uint16) {
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

    /// @dev Maps an EIP-155 chain ID to a Wormhole chain ID.
    /// @param wormholeChainId Wormhole chain ID.
    /// @return EIP-155 chain ID.
    function wormholeChainIdtoChainId(uint16 wormholeChainId) internal pure returns (uint256) {
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
