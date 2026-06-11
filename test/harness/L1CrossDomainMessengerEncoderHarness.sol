// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

import {Call} from "../../src/types/Call.sol";
import {L1CrossDomainMessengerEncoder} from "../../src/bridges/L1CrossDomainMessengerEncoder.sol";

// Wraps the library so its internal `encode` is reachable across a call boundary, letting `vm.expectRevert`
// observe the `require` revert (inlined internal library reverts are not caught by `vm.expectRevert`).
contract L1CrossDomainMessengerEncoderHarness {
    function encode(
        address crossChainMessengerSender,
        address crossChainAccountReceiver,
        uint32 gasLimit,
        Call memory remoteCall
    ) external pure returns (Call memory) {
        return L1CrossDomainMessengerEncoder.encode(
            crossChainMessengerSender, crossChainAccountReceiver, gasLimit, remoteCall
        );
    }
}
