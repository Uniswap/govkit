// SPDX-License-Identifier: AGPl-3.0-only
pragma solidity ^0.8.0;

import {Call} from "../../types/Call.sol";
import {IOptimismPortal2} from "../../interfaces/bridges/IOptimismPortal2.sol";
import {SelectorHandler} from "./SelectorHandler.sol";

using SelectorHandler for bytes;

library OptimismPortal2Decoder {
    error SelectorMismatch();

    /// @dev Decodes an OptimismPortal2 encoded call.
    /// @param optimismPortal2Call Encoded call as produced by OptimismPortal2Encoder.
    /// @return portal OptimismPortal2 address.
    /// @return gasLimit Gas limit of the call.
    /// @return remoteCall Call to be run from the aliased Timelock address on the OP Stack chain.
    function decode(Call memory optimismPortal2Call) internal pure returns (
        address,
        uint64,
        Call memory
    ) {
        require(optimismPortal2Call.data.getSelector() == IOptimismPortal2.depositTransaction.selector, SelectorMismatch());

        (address target, uint256 value, uint64 gasLimit,, bytes memory data) = abi.decode(
            optimismPortal2Call.data.stripSelector(), (address, uint256, uint64, bool, bytes)
        );

        return (
            optimismPortal2Call.target,
            gasLimit,
            Call({
                target: target,
                value: value,
                data: data
            })
        );
    }
}
