// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

struct RetryableTicket {
    address to;
    uint256 l2CallValue;
    uint256 maxSubmissionCost;
    address excessFeeRefundAddress;
    address callValueRefundAddress;
    uint256 gasLimit;
    uint256 maxFeePerGas;
    bytes data;
}

contract InboxMock {
    function createRetryableTicket(
        address to,
        uint256 l2CallValue,
        uint256 maxSubmissionCost,
        address excessFeeRefundAddress,
        address callValueRefundAddress,
        uint256 gasLimit,
        uint256 maxFeePerGas,
        bytes memory data
    ) external payable returns (RetryableTicket memory) {
        return RetryableTicket({
            to: to,
            l2CallValue: l2CallValue,
            maxSubmissionCost: maxSubmissionCost,
            excessFeeRefundAddress: excessFeeRefundAddress,
            callValueRefundAddress: callValueRefundAddress,
            gasLimit: gasLimit,
            maxFeePerGas: maxFeePerGas,
            data: data
        });
    }
}
