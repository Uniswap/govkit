// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

import {ChainId} from "./ChainId.sol";

// source: https://wormhole.com/docs/products/reference/chain-ids/
/// @title Wormhole Chain ID
/// @dev This is Wormhole's chain ID system for arbitrary blockchains. We
///      implement this library to fully encapsulate this system so proposal
///      writers only need to focus on the canonical chain ID system.
/// @dev Note that this is not comprehensive, it only covers chains where we use
///      Wormhole actively.
library WormholeChainId {
    /// @dev Thrown when an EIP-155 chain ID does not map to a Wormhole chain ID.
    error UnsupportedChainId(uint256 chainId);

    /// @dev Thrown when a Wormhole chain ID does not map to an EIP-155 chain ID.
    error UnsupportedWormholeChainId(uint16 wormholeChainId);

    uint16 internal constant Avalanche = 6;
    uint16 internal constant BNBChain = 4;
    uint16 internal constant Ethereum = 2;
    uint16 internal constant MegaEth = 64;
    uint16 internal constant Monad = 48;
    uint16 internal constant RootStock = 33;
    uint16 internal constant Tempo = 68;

    /// @dev Maps an EIP-155 chain ID to a Wormhole chain ID.
    /// @param chainId EIP-155 chain ID.
    /// @return Wormhole chain ID.
    function chainIdToWormholeChainId(uint256 chainId) internal pure returns (uint16) {
        if (chainId == ChainId.Avalanche) {
            return Avalanche;
        } else if (chainId == ChainId.BNBChain) {
            return BNBChain;
        } else if (chainId == ChainId.Ethereum) {
            return Ethereum;
        } else if (chainId == ChainId.MegaEth) {
            return MegaEth;
        } else if (chainId == ChainId.Monad) {
            return Monad;
        } else if (chainId == ChainId.RootStock) {
            return RootStock;
        } else if (chainId == ChainId.Tempo) {
            return Tempo;
        }

        revert UnsupportedChainId(chainId);
    }

    /// @dev Maps a Wormhole chain ID to an EIP-155 chain ID.
    /// @param wormholeChainId Wormhole chain ID.
    /// @return EIP-155 chain ID.
    function wormholeChainIdToChainId(uint16 wormholeChainId) internal pure returns (uint256) {
        if (wormholeChainId == Avalanche) {
            return ChainId.Avalanche;
        } else if (wormholeChainId == BNBChain) {
            return ChainId.BNBChain;
        } else if (wormholeChainId == Ethereum) {
            return ChainId.Ethereum;
        } else if (wormholeChainId == MegaEth) {
            return ChainId.MegaEth;
        } else if (wormholeChainId == Monad) {
            return ChainId.Monad;
        } else if (wormholeChainId == RootStock) {
            return ChainId.RootStock;
        } else if (wormholeChainId == Tempo) {
            return ChainId.Tempo;
        }

        revert UnsupportedWormholeChainId(wormholeChainId);
    }
}
