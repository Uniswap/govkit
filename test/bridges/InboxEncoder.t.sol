// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

import {Call} from "../../src/types/Call.sol";
import {IInbox} from "../../src/interfaces/bridges/IInbox.sol";
import {InboxEncoder} from "../../src/bridges/InboxEncoder.sol";
import {EncoderHarness} from "../harness/EncoderHarness.sol";
import {DecoderHarness} from "../harness/DecoderHarness.sol";

import {Test, console} from "forge-std/Test.sol";
import {InboxMock, RetryableTicket} from "../mock/InboxMock.sol";

contract InboxEncoderTest is Test {
    EncoderHarness internal encoder;
    DecoderHarness internal decoder;

    address internal inbox;

    function setUp() external {
        encoder = new EncoderHarness();
        decoder = new DecoderHarness();
        inbox = address(new InboxMock());
    }

    function testEncode() external {
        address timelock = address(0x03);
        Call memory remoteCall = Call({target: address(0x04), value: 5, data: hex"aabbccdd"});

        Call memory encoded = InboxEncoder.encode({inbox: inbox, timelock: timelock, remoteCall: remoteCall});

        vm.deal(address(this), encoded.value);
        (bool success, bytes memory returndata) = encoded.target.call{value: encoded.value}(encoded.data);

        assertTrue(success);

        RetryableTicket memory ticket = abi.decode(returndata, (RetryableTicket));

        address refund = InboxEncoder.arbitrumAlias(timelock);

        assertEq(encoded.target, inbox);
        assertEq(
            encoded.value,
            (InboxEncoder.GAS_LIMIT * InboxEncoder.MAX_FEE_PER_GAS) + InboxEncoder.MAX_SUBMISSION_COST
                + remoteCall.value
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
        Call memory remoteCall = Call({target: address(0x04), value: 5, data: hex"aabbccdd"});

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
        assertEq(encoded.value, (gasLimit_ * maxFeePerGas_) + maxSubmissionCost_ + remoteCall.value);
        assertEq(ticket.to, remoteCall.target);
        assertEq(ticket.l2CallValue, remoteCall.value);
        assertEq(ticket.maxSubmissionCost, maxSubmissionCost_);
        assertEq(ticket.excessFeeRefundAddress, refund);
        assertEq(ticket.callValueRefundAddress, refund);
        assertEq(ticket.gasLimit, gasLimit_);
        assertEq(ticket.maxFeePerGas, maxFeePerGas_);
        assertEq(ticket.data, remoteCall.data);
    }

    function testFuzzEncode(address timelock, Call memory remoteCall) external {
        // Keep `arbitrumAlias` from overflowing uint160.
        timelock = address(
            uint160(bound(uint256(uint160(timelock)), 0, uint256(type(uint160).max - InboxEncoder.ALIAS_OFFSET)))
        );
        // Keep the value computation from overflowing uint256.
        remoteCall.value = bound(
            remoteCall.value,
            0,
            type(uint256).max - (InboxEncoder.GAS_LIMIT * InboxEncoder.MAX_FEE_PER_GAS)
                - InboxEncoder.MAX_SUBMISSION_COST
        );

        Call memory encoded = InboxEncoder.encode({inbox: inbox, timelock: timelock, remoteCall: remoteCall});

        vm.deal(address(this), encoded.value);
        (bool success, bytes memory returndata) = encoded.target.call{value: encoded.value}(encoded.data);

        assertTrue(success);

        RetryableTicket memory ticket = abi.decode(returndata, (RetryableTicket));

        address refund = InboxEncoder.arbitrumAlias(timelock);

        assertEq(encoded.target, inbox);
        assertEq(
            encoded.value,
            (InboxEncoder.GAS_LIMIT * InboxEncoder.MAX_FEE_PER_GAS) + InboxEncoder.MAX_SUBMISSION_COST
                + remoteCall.value
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
        Call memory remoteCall
    ) external {
        // Keep `arbitrumAlias` from overflowing uint160 and the value computation from overflowing uint256.
        timelock = address(
            uint160(bound(uint256(uint160(timelock)), 0, uint256(type(uint160).max - InboxEncoder.ALIAS_OFFSET)))
        );
        gasLimit_ = bound(gasLimit_, 0, type(uint64).max);
        maxFeePerGas_ = bound(maxFeePerGas_, 0, type(uint64).max);
        maxSubmissionCost_ = bound(maxSubmissionCost_, 0, type(uint128).max);
        remoteCall.value = bound(remoteCall.value, 0, type(uint128).max);

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
        assertEq(encoded.value, (gasLimit_ * maxFeePerGas_) + maxSubmissionCost_ + remoteCall.value);
        assertEq(ticket.to, remoteCall.target);
        assertEq(ticket.l2CallValue, remoteCall.value);
        assertEq(ticket.maxSubmissionCost, maxSubmissionCost_);
        assertEq(ticket.excessFeeRefundAddress, refund);
        assertEq(ticket.callValueRefundAddress, refund);
        assertEq(ticket.gasLimit, gasLimit_);
        assertEq(ticket.maxFeePerGas, maxFeePerGas_);
        assertEq(ticket.data, remoteCall.data);
    }

    function testEncodeDecode() external view {
        address inbox_ = address(0x01);
        address timelock = address(0x02);
        uint256 gasLimit = 200_000;
        uint256 maxFeePerGas = 0.1 gwei;
        uint256 maxSubmissionCost = 0.01 ether;
        Call memory remoteCall = Call({
            target: address(0x03),
            value: 5,
            data: hex"05"
        });

        Call memory inboxCall =
            encoder.encodeInbox(inbox_, timelock, gasLimit, maxFeePerGas, maxSubmissionCost, remoteCall);

        (
            address decodedInbox,
            address decodedTimelock,
            uint256 decodedGasLimit,
            uint256 decodedMaxFeePerGas,
            uint256 decodedMaxSubmissionCost,
            Call memory decodedRemoteCall
        ) = decoder.decodeInbox(inboxCall);

        assertEq(inbox_, decodedInbox);
        assertEq(timelock, decodedTimelock);
        assertEq(gasLimit, decodedGasLimit);
        assertEq(maxFeePerGas, decodedMaxFeePerGas);
        assertEq(maxSubmissionCost, decodedMaxSubmissionCost);
        assertEq(remoteCall.target, decodedRemoteCall.target);
        assertEq(remoteCall.value, decodedRemoteCall.value);
        assertEq(remoteCall.data, decodedRemoteCall.data);
    }

    function testFuzzEncodeDecode(
        address inbox_,
        address timelock,
        uint256 gasLimit,
        uint256 maxFeePerGas,
        uint256 maxSubmissionCost,
        Call memory remoteCall
    ) external view {
        // Keep the value computation from overflowing uint256.
        gasLimit = bound(gasLimit, 0, type(uint64).max);
        maxFeePerGas = bound(maxFeePerGas, 0, type(uint64).max);
        maxSubmissionCost = bound(maxSubmissionCost, 0, type(uint128).max);
        remoteCall.value = bound(remoteCall.value, 0, type(uint128).max);

        Call memory inboxCall =
            encoder.encodeInbox(inbox_, timelock, gasLimit, maxFeePerGas, maxSubmissionCost, remoteCall);

        (
            address decodedInbox,
            address decodedTimelock,
            uint256 decodedGasLimit,
            uint256 decodedMaxFeePerGas,
            uint256 decodedMaxSubmissionCost,
            Call memory decodedRemoteCall
        ) = decoder.decodeInbox(inboxCall);

        assertEq(inbox_, decodedInbox);
        assertEq(timelock, decodedTimelock);
        assertEq(gasLimit, decodedGasLimit);
        assertEq(maxFeePerGas, decodedMaxFeePerGas);
        assertEq(maxSubmissionCost, decodedMaxSubmissionCost);
        assertEq(remoteCall.target, decodedRemoteCall.target);
        assertEq(remoteCall.value, decodedRemoteCall.value);
        assertEq(remoteCall.data, decodedRemoteCall.data);
    }
}
