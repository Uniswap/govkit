// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

import {Call} from "../../src/types/Call.sol";
import {FxRootEncoder} from "../../src/bridges/FxRootEncoder.sol";
import {InboxEncoder} from "../../src/bridges/InboxEncoder.sol";
import {L1CrossDomainMessengerEncoder} from "../../src/bridges/L1CrossDomainMessengerEncoder.sol";
import {OptimismPortal2Encoder} from "../../src/bridges/OptimismPortal2Encoder.sol";
import {WormholeEncoder} from "../../src/bridges/WormholeEncoder.sol";

contract EncoderHarness {
    function encodeFxRoot(address fxRoot, address fxReceiver, Call[] memory remoteCalls) external pure returns (Call memory) {
        return FxRootEncoder.encode(fxRoot, fxReceiver, remoteCalls);
    }

    function encodeInbox(
        address inbox,
        address timelock,
        uint256 gasLimit,
        uint256 maxFeePerGas,
        uint256 maxSubmissionCost,
        Call memory remoteCall
    ) external pure returns (Call memory) {
        return InboxEncoder.encode(
            inbox,
            timelock,
            gasLimit,
            maxFeePerGas,
            maxSubmissionCost,
            remoteCall
        );
    }

    function encodeL1CrossDomainMessenger(
        address l1CrossDomainMessenger,
        address crossChainAccount,
        uint32 gasLimit,
        Call memory remoteCall
    ) external pure returns (Call memory) {
        return L1CrossDomainMessengerEncoder.encode(
            l1CrossDomainMessenger,
            crossChainAccount,
            gasLimit,
            remoteCall
        );
    }

    function encodeOptimismPortal2(address portal, uint64 gasLimit, Call memory remoteCall) external pure returns (Call memory) {
        return OptimismPortal2Encoder.encode(portal, gasLimit, remoteCall);
    }

    function encodeWormhole(
        address sourceSender,
        address remoteReceiver,
        uint256 chainId,
        uint256 value,
        Call[] memory remoteCalls
    ) external pure returns (Call memory) {
        return WormholeEncoder.encode(sourceSender, remoteReceiver, chainId, value, remoteCalls);
    }
}
