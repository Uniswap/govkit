// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

import {Call} from "src/types/Call.sol";
import {IInbox} from "src/interfaces/bridges/IInbox.sol";
import {InboxEncoder} from "src/bridges/InboxEncoder.sol";

import {Test, console} from "lib/forge-std/src/Test.sol";
import {InboxMock, RetryableTicket} from "test/mock/InboxMock.sol";

contract InboxEncoderTest is Test {
    address internal inbox;

    function setUp() external {
        inbox = address(new InboxMock());
    }

    function testEncode() external {
        address timelock = address(0x03);
        Call memory remoteCall = Call({
            target: address(0x04),
            value: 5,
            data: hex"aabbccdd"
        });

        Call memory encoded = InboxEncoder.encode({
            inbox: inbox,
            timelock: timelock,
            remoteCall: remoteCall
        });

        vm.deal(address(this), encoded.value);
        (bool success, bytes memory returndata) = encoded.target.call{value: encoded.value}(encoded.data);

        assertTrue(success);

        RetryableTicket memory ticket = abi.decode(returndata, (RetryableTicket));

        address refund = InboxEncoder.arbitrumAlias(timelock);

        assertEq(encoded.target, inbox);
        assertEq(
            encoded.value, (InboxEncoder.GAS_LIMIT * InboxEncoder.MAX_FEE_PER_GAS) + InboxEncoder.MAX_SUBMISSION_COST
        );
        assertEq(ticket.to, remoteCall.target);
        assertEq(ticket.l2CallValue, remoteCall.value);
        assertEq(ticket.maxSubmissionCost, InboxEncoder.MAX_SUBMISSION_COST);
        assertEq(ticket.excessFeeRefundAddress, refund);
        assertEq(ticket.callValueRefundAddress, refund);
        assertEq(ticket.gasLimit, InboxEncoder.GAS_LIMIT);
        assertEq(ticket.maxFeePerGas, InboxEncoder.MAX_FEE_PER_GAS);
        assertEq(ticket.data, remoteCall.data);
    }

    function testEncodeWithParams() external {
        address timelock = address(0x03);
        uint256 gasLimit_ = 250_000;
        uint256 maxFeePerGas_ = 0.2 gwei;
        uint256 maxSubmissionCost_ = 0.02 ether;
        Call memory remoteCall = Call({
            target: address(0x04),
            value: 5,
            data: hex"aabbccdd"
        });

        Call memory encoded = InboxEncoder.encode({
            inbox: inbox,
            timelock: timelock,
            gasLimit: gasLimit_,
            maxFeePerGas: maxFeePerGas_,
            maxSubmissionCost: maxSubmissionCost_,
            remoteCall: remoteCall
        });

        vm.deal(address(this), encoded.value);
        (bool success, bytes memory returndata) = encoded.target.call{value: encoded.value}(encoded.data);

        assertTrue(success);

        RetryableTicket memory ticket = abi.decode(returndata, (RetryableTicket));

        address refund = InboxEncoder.arbitrumAlias(timelock);

        assertEq(encoded.target, inbox);
        assertEq(encoded.value, (gasLimit_ * maxFeePerGas_) + maxSubmissionCost_);
        assertEq(ticket.to, remoteCall.target);
        assertEq(ticket.l2CallValue, remoteCall.value);
        assertEq(ticket.maxSubmissionCost, maxSubmissionCost_);
        assertEq(ticket.excessFeeRefundAddress, refund);
        assertEq(ticket.callValueRefundAddress, refund);
        assertEq(ticket.gasLimit, gasLimit_);
        assertEq(ticket.maxFeePerGas, maxFeePerGas_);
        assertEq(ticket.data, remoteCall.data);
    }

    function testFuzzEncode(address timelock, Call calldata remoteCall) external {
        // Keep `arbitrumAlias` from overflowing uint160.
        timelock = address(uint160(bound(uint256(uint160(timelock)), 0, uint256(type(uint160).max - InboxEncoder.ALIAS_OFFSET))));

        Call memory encoded = InboxEncoder.encode({
            inbox: inbox,
            timelock: timelock,
            remoteCall: remoteCall
        });

        vm.deal(address(this), encoded.value);
        (bool success, bytes memory returndata) = encoded.target.call{value: encoded.value}(encoded.data);

        assertTrue(success);

        RetryableTicket memory ticket = abi.decode(returndata, (RetryableTicket));

        address refund = InboxEncoder.arbitrumAlias(timelock);

        assertEq(encoded.target, inbox);
        assertEq(
            encoded.value, (InboxEncoder.GAS_LIMIT * InboxEncoder.MAX_FEE_PER_GAS) + InboxEncoder.MAX_SUBMISSION_COST
        );
        assertEq(ticket.to, remoteCall.target);
        assertEq(ticket.l2CallValue, remoteCall.value);
        assertEq(ticket.maxSubmissionCost, InboxEncoder.MAX_SUBMISSION_COST);
        assertEq(ticket.excessFeeRefundAddress, refund);
        assertEq(ticket.callValueRefundAddress, refund);
        assertEq(ticket.gasLimit, InboxEncoder.GAS_LIMIT);
        assertEq(ticket.maxFeePerGas, InboxEncoder.MAX_FEE_PER_GAS);
        assertEq(ticket.data, remoteCall.data);
    }

    function testFuzzEncodeWithParams(
        address timelock,
        uint256 gasLimit_,
        uint256 maxFeePerGas_,
        uint256 maxSubmissionCost_,
        Call calldata remoteCall
    ) external {
        // Keep `arbitrumAlias` from overflowing uint160 and the value computation from overflowing uint256.
        timelock = address(uint160(bound(uint256(uint160(timelock)), 0, uint256(type(uint160).max - InboxEncoder.ALIAS_OFFSET))));
        gasLimit_ = bound(gasLimit_, 0, type(uint64).max);
        maxFeePerGas_ = bound(maxFeePerGas_, 0, type(uint64).max);
        maxSubmissionCost_ = bound(maxSubmissionCost_, 0, type(uint128).max);

        Call memory encoded = InboxEncoder.encode({
            inbox: inbox,
            timelock: timelock,
            gasLimit: gasLimit_,
            maxFeePerGas: maxFeePerGas_,
            maxSubmissionCost: maxSubmissionCost_,
            remoteCall: remoteCall
        });

        vm.deal(address(this), encoded.value);
        (bool success, bytes memory returndata) = encoded.target.call{value: encoded.value}(encoded.data);

        assertTrue(success);

        RetryableTicket memory ticket = abi.decode(returndata, (RetryableTicket));

        address refund = InboxEncoder.arbitrumAlias(timelock);

        assertEq(encoded.target, inbox);
        assertEq(encoded.value, (gasLimit_ * maxFeePerGas_) + maxSubmissionCost_);
        assertEq(ticket.to, remoteCall.target);
        assertEq(ticket.l2CallValue, remoteCall.value);
        assertEq(ticket.maxSubmissionCost, maxSubmissionCost_);
        assertEq(ticket.excessFeeRefundAddress, refund);
        assertEq(ticket.callValueRefundAddress, refund);
        assertEq(ticket.gasLimit, gasLimit_);
        assertEq(ticket.maxFeePerGas, maxFeePerGas_);
        assertEq(ticket.data, remoteCall.data);
    }
}
