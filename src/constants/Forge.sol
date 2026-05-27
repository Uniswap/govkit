// SPDX-License-Identifier: AGPL-3.0-only 
pragma solidity 0.8.34;

import {VmSafe} from "lib/forge-std/src/Vm.sol";

VmSafe constant vm = VmSafe(address(uint160(uint256(keccak256("hevm cheat code")))));

// Placeholder to avoid Solidity compiler warning:
//
// Warning: AST source not found for <project_root>/src/Networks.sol
library __ {}
