// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

import {ERC1967} from "../constants/ERC1967.sol";
import {vm} from "./Constants.sol";

/// @title ERC-1967 Slot Reader
/// @dev Reads ERC-1967 slots using Foundry's VM logic.
library ERC1967Reader {
    /// @dev Reads the admin of a proxy.
    /// @param proxy Proxy contract to read.
    /// @return Admin address.
    function admin(address proxy) internal view returns (address) {
        bytes32 value = vm.load(proxy, ERC1967.ADMIN_SLOT);

        return address(uint160(uint256(value)));
    }

    /// @dev Reads the beacon of a proxy.
    /// @param proxy Proxy contract to read.
    /// @return Beacon address.
    function beacon(address proxy) internal view returns (address) {
        bytes32 value = vm.load(proxy, ERC1967.BEACON_SLOT);

        return address(uint160(uint256(value)));
    }

    /// @dev Reads the implementation of a proxy.
    /// @param proxy Proxy contract to read.
    /// @return Implementation address.
    function implementation(address proxy) internal view returns (address) {
        bytes32 value = vm.load(proxy, ERC1967.IMPLEMENTATION_SLOT);

        return address(uint160(uint256(value)));
    }
}
