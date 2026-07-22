// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

import {L1CrossDomainMessengerEncoder} from "../../src/bridges/L1CrossDomainMessengerEncoder.sol";
import {ICrossChainAccount} from "../../src/interfaces/bridges/ICrossChainAccount.sol";
import {IL1CrossDomainMessenger} from "../../src/interfaces/bridges/IL1CrossDomainMessenger.sol";
import {Call} from "../../src/types/Call.sol";
import {DecoderHarness} from "../harness/DecoderHarness.sol";
import {EncoderHarness} from "../harness/EncoderHarness.sol";

import {
    L1CrossDomainMessengerEncoderHarness
} from "../harness/L1CrossDomainMessengerEncoderHarness.sol";
import {L1CrossDomainMessengerMock} from "../mock/L1CrossDomainMessengerMock.sol";
import {Test, console} from "forge-std/Test.sol";

contract L1CrossDomainMessengerEncoderTest is Test {
    EncoderHarness internal encoder;
    DecoderHarness internal decoder;

    address internal messenger;

    function setUp() external {
        encoder = new EncoderHarness();
        decoder = new DecoderHarness();
        messenger = address(new L1CrossDomainMessengerMock());
    }

    function testEncode() external {
        address crossChainAccount = address(0x02);
        Call memory remoteCall = Call({target: address(0x04), value: 0, data: hex"aabbccdd"});

        Call memory encoded = L1CrossDomainMessengerEncoder.encode({
            l1CrossDomainMessenger: messenger,
            crossChainAccount: crossChainAccount,
            remoteCall: remoteCall
        });

        (bool success, bytes memory returndata) =
            encoded.target.call{value: encoded.value}(encoded.data);

        assertTrue(success);

        (
            address accountReceiver,
            address forwardTarget,
            bytes memory forwardData,
            uint32 gasLimit
        ) = abi.decode(returndata, (address, address, bytes, uint32));

        assertEq(encoded.target, messenger);
        assertEq(encoded.value, 0);
        assertEq(accountReceiver, crossChainAccount);
        assertEq(forwardTarget, remoteCall.target);
        assertEq(forwardData, remoteCall.data);
        assertEq(gasLimit, L1CrossDomainMessengerEncoder.GAS_LIMIT);
    }

    function testEncodeWithGasLimit() external {
        address crossChainAccount = address(0x02);
        uint32 gasLimit_ = 300_000;
        Call memory remoteCall = Call({target: address(0x04), value: 0, data: hex"aabbccdd"});

        Call memory encoded = L1CrossDomainMessengerEncoder.encode({
            l1CrossDomainMessenger: messenger,
            crossChainAccount: crossChainAccount,
            gasLimit: gasLimit_,
            remoteCall: remoteCall
        });

        (bool success, bytes memory returndata) =
            encoded.target.call{value: encoded.value}(encoded.data);

        assertTrue(success);

        (
            address accountReceiver,
            address forwardTarget,
            bytes memory forwardData,
            uint32 gasLimit
        ) = abi.decode(returndata, (address, address, bytes, uint32));

        assertEq(encoded.target, messenger);
        assertEq(encoded.value, 0);
        assertEq(accountReceiver, crossChainAccount);
        assertEq(forwardTarget, remoteCall.target);
        assertEq(forwardData, remoteCall.data);
        assertEq(gasLimit, gasLimit_);
    }

    function testFuzzEncode(
        address crossChainAccount,
        address remoteCallTarget,
        bytes calldata remoteCallData
    ) external {
        Call memory remoteCall = Call({target: remoteCallTarget, value: 0, data: remoteCallData});

        Call memory encoded = L1CrossDomainMessengerEncoder.encode({
            l1CrossDomainMessenger: messenger,
            crossChainAccount: crossChainAccount,
            remoteCall: remoteCall
        });

        (bool success, bytes memory returndata) =
            encoded.target.call{value: encoded.value}(encoded.data);

        assertTrue(success);

        (
            address accountReceiver,
            address forwardTarget,
            bytes memory forwardData,
            uint32 gasLimit
        ) = abi.decode(returndata, (address, address, bytes, uint32));

        assertEq(encoded.target, messenger);
        assertEq(encoded.value, 0);
        assertEq(accountReceiver, crossChainAccount);
        assertEq(forwardTarget, remoteCall.target);
        assertEq(forwardData, remoteCall.data);
        assertEq(gasLimit, L1CrossDomainMessengerEncoder.GAS_LIMIT);
    }

    function testFuzzEncodeWithGasLimit(
        address crossChainAccount,
        uint32 gasLimit_,
        address remoteCallTarget,
        bytes calldata remoteCallData
    ) external {
        Call memory remoteCall = Call({target: remoteCallTarget, value: 0, data: remoteCallData});

        Call memory encoded = L1CrossDomainMessengerEncoder.encode({
            l1CrossDomainMessenger: messenger,
            crossChainAccount: crossChainAccount,
            gasLimit: gasLimit_,
            remoteCall: remoteCall
        });

        (bool success, bytes memory returndata) =
            encoded.target.call{value: encoded.value}(encoded.data);

        assertTrue(success);

        (
            address accountReceiver,
            address forwardTarget,
            bytes memory forwardData,
            uint32 gasLimit
        ) = abi.decode(returndata, (address, address, bytes, uint32));

        assertEq(encoded.target, messenger);
        assertEq(encoded.value, 0);
        assertEq(accountReceiver, crossChainAccount);
        assertEq(forwardTarget, remoteCall.target);
        assertEq(forwardData, remoteCall.data);
        assertEq(gasLimit, gasLimit_);
    }

    function testFuzzEncodeRevertsOnNonZeroValue(
        address crossChainAccount,
        uint32 gasLimit_,
        address remoteCallTarget,
        uint256 value,
        bytes calldata remoteCallData
    ) external {
        vm.assume(value != 0);

        Call memory remoteCall =
            Call({target: remoteCallTarget, value: value, data: remoteCallData});

        L1CrossDomainMessengerEncoderHarness harness = new L1CrossDomainMessengerEncoderHarness();

        vm.expectRevert();
        harness.encode(messenger, crossChainAccount, gasLimit_, remoteCall);
    }

    function testEncodeDecode() external view {
        address messenger_ = address(0x01);
        address crossChainAccount = address(0x02);
        uint32 gasLimit = 200_000;
        Call memory remoteCall = Call({target: address(0x03), value: 0, data: hex"05"});

        Call memory messengerCall = encoder.encodeL1CrossDomainMessenger(
            messenger_, crossChainAccount, gasLimit, remoteCall
        );

        (
            address decodedMessenger,
            address decodedCrossChainAccount,
            uint32 decodedGasLimit,
            Call memory decodedRemoteCall
        ) = decoder.decodeL1CrossDomainMessenger(messengerCall);

        assertEq(messenger_, decodedMessenger);
        assertEq(crossChainAccount, decodedCrossChainAccount);
        assertEq(gasLimit, decodedGasLimit);
        assertEq(remoteCall.target, decodedRemoteCall.target);
        assertEq(remoteCall.value, decodedRemoteCall.value);
        assertEq(remoteCall.data, decodedRemoteCall.data);
    }

    function testFuzzEncodeDecode(
        address messenger_,
        address crossChainAccount,
        uint32 gasLimit,
        Call memory remoteCall
    ) external view {
        // L1CrossDomainMessenger does not forward value.
        remoteCall.value = 0;

        Call memory messengerCall = encoder.encodeL1CrossDomainMessenger(
            messenger_, crossChainAccount, gasLimit, remoteCall
        );

        (
            address decodedMessenger,
            address decodedCrossChainAccount,
            uint32 decodedGasLimit,
            Call memory decodedRemoteCall
        ) = decoder.decodeL1CrossDomainMessenger(messengerCall);

        assertEq(messenger_, decodedMessenger);
        assertEq(crossChainAccount, decodedCrossChainAccount);
        assertEq(gasLimit, decodedGasLimit);
        assertEq(remoteCall.target, decodedRemoteCall.target);
        assertEq(remoteCall.value, decodedRemoteCall.value);
        assertEq(remoteCall.data, decodedRemoteCall.data);
    }
}
