// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

import {vm} from "src/forge/Constants.sol";
import {ERC1967} from "src/constants/ERC1967.sol";

library ERC1967Reader {
    function admin(address proxy) internal view returns (address) {
        bytes32 value = vm.load(proxy, ERC1967.ADMIN_SLOT);

        return address(uint160(uint256(value)));
    }

    function beacon(address proxy) internal view returns (address) {
        bytes32 value = vm.load(proxy, ERC1967.BEACON_SLOT);

        return address(uint160(uint256(value)));
    }

    function implementation(address proxy) internal view returns (address) {
        bytes32 value = vm.load(proxy, ERC1967.IMPLEMENTATION_SLOT);

        return address(uint160(uint256(value)));
    }
}
