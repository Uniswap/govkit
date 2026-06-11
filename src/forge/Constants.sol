// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

import {VmSafe} from "forge-std/Vm.sol";

/// @dev Local VM export, making VM accessible outside of Script/Test child contracts.
VmSafe constant vm = VmSafe(address(uint160(uint256(keccak256("hevm cheat code")))));
