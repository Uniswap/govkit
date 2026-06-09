// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

import {Call} from "src/types/Call.sol";
import {IOptimismPortal2} from "src/interfaces/bridges/IOptimismPortal2.sol";

/// @title OP Stack Portal Encoder.
/// @dev OP Stack chains' core bridge system is the Optimism Portal, in
///      particular, the OptimismPortal2. We call the OptimismPortal2 contract
///      on Ethereum, then the OP Stack chain runs a transaction on the OP Stack
///      chain originating from the Timelock plus OP's alias.
library OptimismPortal2Encoder {
    /// @dev Default gas limit.
    uint64 internal constant GAS_LIMIT = 200_000;

    /// @dev Encodes an OptimismPortal2 call with a default gas limit.
    /// @param portal OP Stack chain's OptimismPortal2 contract on Ethereum
    /// @param remoteCall Call to be run from the aliased Timelock address on the
    ///        OP Stack chain.
    /// @return Proposal-ready call.
    function encode(address portal, Call memory remoteCall) internal pure returns (Call memory) {
        return encode(portal, GAS_LIMIT, remoteCall);
    }

    /// @dev Encodes an OptimismPortal2 call.
    /// @param portal OP Stack chain's OptimismPortal2 contract on Ethereum
    /// @param gasLimit Gas limit of the call.
    /// @param remoteCall Call to be run from the aliased Timelock address on the
    ///        OP Stack chain.
    /// @return Proposal-ready call.
    function encode(address portal, uint64 gasLimit, Call memory remoteCall) internal pure returns (Call memory) {
        return Call({
            target: portal,
            value: remoteCall.value,
            data: abi.encodeCall(
                IOptimismPortal2.depositTransaction,
                (remoteCall.target, remoteCall.value, gasLimit, false, remoteCall.data)
            )
        });
    }
}
