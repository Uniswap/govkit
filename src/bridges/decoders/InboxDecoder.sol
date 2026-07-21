// SPDX-License-Identifier: AGPl-3.0-only
pragma solidity ^0.8.0;

import {Call} from "../../types/Call.sol";
import {InboxEncoder} from "../InboxEncoder.sol";
import {IInbox} from "../../interfaces/bridges/IInbox.sol";

import {SelectorHandler} from "./SelectorHandler.sol";

using SelectorHandler for bytes;

library InboxDecoder {
    error SelectorMismatch();
    error RefundAddressMismatch();

    /// @dev Decodes an Inbox encoded call.
    /// @param inboxCall Encoded call as produced by InboxEncoder.
    /// @return inbox Inbox of Arbitrum Orbit chain.
    /// @return timelock Uniswap Timelock on Ethereum.
    /// @return gasLimit Gas limit.
    /// @return maxFeePerGas Max fee per gas.
    /// @return maxSubmissionCost Max submission cost.
    /// @return remoteCall Call to make on Arbitrum Orbit chain.
    function decode(Call memory inboxCall) internal pure returns (
        address,
        address,
        uint256,
        uint256,
        uint256,
        Call memory
    ) {
        require(inboxCall.data.getSelector() == IInbox.createRetryableTicket.selector, SelectorMismatch());

        (
            address to,
            uint256 l2CallValue,
            uint256 maxSubmissionCost,
            address excessFeeRefundAddress,
            address callValueRefundAddress,
            uint256 gasLimit,
            uint256 maxFeePerGas,
            bytes memory data
        ) = abi.decode(inboxCall.data.stripSelector(), (address, uint256, uint256, address, address, uint256, uint256, bytes));

        address timelock = InboxEncoder.arbitrumDeAlias(excessFeeRefundAddress);

        require(excessFeeRefundAddress == callValueRefundAddress, RefundAddressMismatch());

        return (
            inboxCall.target,
            timelock,
            gasLimit,
            maxFeePerGas,
            maxSubmissionCost,
            Call({
                target: to,
                value: l2CallValue,
                data: data
            })
        );
    }
}
