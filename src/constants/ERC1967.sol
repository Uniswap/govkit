// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

/// @title ERC-1967 Proxy Slots
/// @dev These are the ERC-1967 proxy constants, often used in Foundry tooling
///      for state & proxy validation. The logic for reading these slots is
///      contained in `src/forge/ERC1967Reader.sol` to keep the Foundry-specific
///      logic separated.
library ERC1967 {
    bytes32 constant ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    bytes32 constant BEACON_SLOT = 0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50;

    bytes32 constant IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
}
