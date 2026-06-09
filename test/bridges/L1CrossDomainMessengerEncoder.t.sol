// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

import {Call} from "src/types/Call.sol";
import {IL1CrossDomainMessenger} from "src/interfaces/bridges/IL1CrossDomainMessenger.sol";
import {ICrossChainAccount} from "src/interfaces/bridges/ICrossChainAccount.sol";
import {L1CrossDomainMessengerEncoder} from "src/bridges/L1CrossDomainMessengerEncoder.sol";

import {Test, console} from "lib/forge-std/src/Test.sol";
import {L1CrossDomainMessengerMock} from "test/mock/L1CrossDomainMessengerMock.sol";
import {L1CrossDomainMessengerEncoderHarness} from "test/harness/L1CrossDomainMessengerEncoderHarness.sol";

contract L1CrossDomainMessengerEncoderTest is Test {
    address internal messenger;

    function setUp() external {
        messenger = address(new L1CrossDomainMessengerMock());
    }

    function testEncode() external {
        address crossChainAccount = address(0x02);
        Call memory remoteCall = Call({target: address(0x04), value: 0, data: hex"aabbccdd"});

        Call memory encoded = L1CrossDomainMessengerEncoder.encode({
            l1CrossDomainMessenger: messenger, crossChainAccount: crossChainAccount, remoteCall: remoteCall
        });

        (bool success, bytes memory returndata) = encoded.target.call{value: encoded.value}(encoded.data);

        assertTrue(success);

        (address accountReceiver, address forwardTarget, bytes memory forwardData, uint32 gasLimit) =
            abi.decode(returndata, (address, address, bytes, uint32));

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

        (bool success, bytes memory returndata) = encoded.target.call{value: encoded.value}(encoded.data);

        assertTrue(success);

        (address accountReceiver, address forwardTarget, bytes memory forwardData, uint32 gasLimit) =
            abi.decode(returndata, (address, address, bytes, uint32));

        assertEq(encoded.target, messenger);
        assertEq(encoded.value, 0);
        assertEq(accountReceiver, crossChainAccount);
        assertEq(forwardTarget, remoteCall.target);
        assertEq(forwardData, remoteCall.data);
        assertEq(gasLimit, gasLimit_);
    }

    function testFuzzEncode(address crossChainAccount, address remoteCallTarget, bytes calldata remoteCallData)
        external
    {
        Call memory remoteCall = Call({target: remoteCallTarget, value: 0, data: remoteCallData});

        Call memory encoded = L1CrossDomainMessengerEncoder.encode({
            l1CrossDomainMessenger: messenger, crossChainAccount: crossChainAccount, remoteCall: remoteCall
        });

        (bool success, bytes memory returndata) = encoded.target.call{value: encoded.value}(encoded.data);

        assertTrue(success);

        (address accountReceiver, address forwardTarget, bytes memory forwardData, uint32 gasLimit) =
            abi.decode(returndata, (address, address, bytes, uint32));

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

        (bool success, bytes memory returndata) = encoded.target.call{value: encoded.value}(encoded.data);

        assertTrue(success);

        (address accountReceiver, address forwardTarget, bytes memory forwardData, uint32 gasLimit) =
            abi.decode(returndata, (address, address, bytes, uint32));

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

        Call memory remoteCall = Call({target: remoteCallTarget, value: value, data: remoteCallData});

        L1CrossDomainMessengerEncoderHarness harness = new L1CrossDomainMessengerEncoderHarness();

        vm.expectRevert();
        harness.encode(messenger, crossChainAccount, gasLimit_, remoteCall);
    }
}
