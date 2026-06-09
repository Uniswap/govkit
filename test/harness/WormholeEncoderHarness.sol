// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

import {Call} from "src/types/Call.sol";
import {WormholeEncoder} from "src/bridges/WormholeEncoder.sol";

// Wraps the library so its internal `encode` is reachable across a call boundary, letting `vm.expectRevert`
// observe the `UnknownWormholeChainId` revert (inlined internal library reverts are not caught by `vm.expectRevert`).
contract WormholeEncoderHarness {
    function encode(
        address sourceSender,
        address remoteReceiver,
        uint256 chainId,
        uint256 value,
        Call[] memory remoteCalls
    ) external pure returns (Call memory) {
        return WormholeEncoder.encode(sourceSender, remoteReceiver, chainId, value, remoteCalls);
    }
}
