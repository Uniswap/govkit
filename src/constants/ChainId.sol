// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

/// @title Chain ID (EIP-155)
/// @dev This is the canonical chain ID system for EVM based blockchains. Note
///      that most non-native L2 bridge systems use their own chain ID. We
///      implement this library for the canonical constants, then each bridge
///      which is relevant to us has its own chain ID's defined in this
///      directory.
/// @dev On principle, we SHOULD always use these chain ID's in external API's,
///      then transform internally when necessary. If this is ever not the case,
///      it MUST be documented thoroughly.
/// @dev Source: https://chainlist.org
library ChainId {
    uint256 internal constant Arbitrum = 42161;
    uint256 internal constant Avalanche = 43114;
    uint256 internal constant Base = 8453;
    uint256 internal constant BNBChain = 56;
    uint256 internal constant Celo = 42220;
    uint256 internal constant Ethereum = 1;
    uint256 internal constant Optimism = 10;
    uint256 internal constant Polygon = 137;
    uint256 internal constant UniChain = 130;
    uint256 internal constant WorldChain = 480;
}
