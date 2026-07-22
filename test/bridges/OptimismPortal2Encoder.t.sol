// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

import {OptimismPortal2Encoder} from "../../src/bridges/OptimismPortal2Encoder.sol";
import {IOptimismPortal2} from "../../src/interfaces/bridges/IOptimismPortal2.sol";
import {Call} from "../../src/types/Call.sol";
import {DecoderHarness} from "../harness/DecoderHarness.sol";
import {EncoderHarness} from "../harness/EncoderHarness.sol";

import {OptimismPortal2Mock} from "../mock/OptimismPortal2Mock.sol";
import {Test, console} from "forge-std/Test.sol";

contract OptimismPortal2EncoderTest is Test {
    EncoderHarness internal encoder;
    DecoderHarness internal decoder;

    address internal portal;

    function setUp() external {
        encoder = new EncoderHarness();
        decoder = new DecoderHarness();
        portal = address(new OptimismPortal2Mock());
    }

    function testEncode() external {
        Call memory remoteCall = Call({target: address(0x04), value: 5, data: hex"aabbccdd"});

        Call memory encoded =
            OptimismPortal2Encoder.encode({portal: portal, remoteCall: remoteCall});

        (bool success, bytes memory returndata) =
            encoded.target.call{value: encoded.value}(encoded.data);

        assertTrue(success);

        (address to, uint256 value, uint64 gasLimit, bool isCreation, bytes memory data) =
            abi.decode(returndata, (address, uint256, uint64, bool, bytes));

        assertEq(encoded.target, portal);
        assertEq(encoded.value, remoteCall.value);
        assertEq(to, remoteCall.target);
        assertEq(value, remoteCall.value);
        assertEq(gasLimit, OptimismPortal2Encoder.GAS_LIMIT);
        assertFalse(isCreation);
        assertEq(data, remoteCall.data);
    }

    function testEncodeWithGasLimit() external {
        uint64 gasLimit_ = 300_000;
        Call memory remoteCall = Call({target: address(0x04), value: 5, data: hex"aabbccdd"});

        Call memory encoded = OptimismPortal2Encoder.encode({
            portal: portal, gasLimit: gasLimit_, remoteCall: remoteCall
        });

        (bool success, bytes memory returndata) =
            encoded.target.call{value: encoded.value}(encoded.data);

        assertTrue(success);

        (address to, uint256 value, uint64 gasLimit, bool isCreation, bytes memory data) =
            abi.decode(returndata, (address, uint256, uint64, bool, bytes));

        assertEq(encoded.target, portal);
        assertEq(encoded.value, remoteCall.value);
        assertEq(to, remoteCall.target);
        assertEq(value, remoteCall.value);
        assertEq(gasLimit, gasLimit_);
        assertFalse(isCreation);
        assertEq(data, remoteCall.data);
    }

    function testFuzzEncode(Call calldata remoteCall) external {
        Call memory encoded =
            OptimismPortal2Encoder.encode({portal: portal, remoteCall: remoteCall});

        vm.deal(address(this), encoded.value);
        (bool success, bytes memory returndata) =
            encoded.target.call{value: encoded.value}(encoded.data);

        assertTrue(success);

        (address to, uint256 value, uint64 gasLimit, bool isCreation, bytes memory data) =
            abi.decode(returndata, (address, uint256, uint64, bool, bytes));

        assertEq(encoded.target, portal);
        assertEq(encoded.value, remoteCall.value);
        assertEq(to, remoteCall.target);
        assertEq(value, remoteCall.value);
        assertEq(gasLimit, OptimismPortal2Encoder.GAS_LIMIT);
        assertFalse(isCreation);
        assertEq(data, remoteCall.data);
    }

    function testFuzzEncodeWithGasLimit(uint64 gasLimit_, Call calldata remoteCall) external {
        Call memory encoded = OptimismPortal2Encoder.encode({
            portal: portal, gasLimit: gasLimit_, remoteCall: remoteCall
        });

        vm.deal(address(this), encoded.value);
        (bool success, bytes memory returndata) =
            encoded.target.call{value: encoded.value}(encoded.data);

        assertTrue(success);

        (address to, uint256 value, uint64 gasLimit, bool isCreation, bytes memory data) =
            abi.decode(returndata, (address, uint256, uint64, bool, bytes));

        assertEq(encoded.target, portal);
        assertEq(encoded.value, remoteCall.value);
        assertEq(to, remoteCall.target);
        assertEq(value, remoteCall.value);
        assertEq(gasLimit, gasLimit_);
        assertFalse(isCreation);
        assertEq(data, remoteCall.data);
    }

    function testEncodeDecode() external view {
        address portal_ = address(0x01);
        uint64 gasLimit = 200_000;
        Call memory remoteCall = Call({target: address(0x03), value: 5, data: hex"05"});

        Call memory portalCall = encoder.encodeOptimismPortal2(portal_, gasLimit, remoteCall);

        (address decodedPortal, uint64 decodedGasLimit, Call memory decodedRemoteCall) =
            decoder.decodeOptimismPortal2(portalCall);

        assertEq(portal_, decodedPortal);
        assertEq(gasLimit, decodedGasLimit);
        assertEq(remoteCall.target, decodedRemoteCall.target);
        assertEq(remoteCall.value, decodedRemoteCall.value);
        assertEq(remoteCall.data, decodedRemoteCall.data);
    }

    function testFuzzEncodeDecode(address portal_, uint64 gasLimit, Call memory remoteCall)
        external
        view
    {
        Call memory portalCall = encoder.encodeOptimismPortal2(portal_, gasLimit, remoteCall);

        (address decodedPortal, uint64 decodedGasLimit, Call memory decodedRemoteCall) =
            decoder.decodeOptimismPortal2(portalCall);

        assertEq(portal_, decodedPortal);
        assertEq(gasLimit, decodedGasLimit);
        assertEq(remoteCall.target, decodedRemoteCall.target);
        assertEq(remoteCall.value, decodedRemoteCall.value);
        assertEq(remoteCall.data, decodedRemoteCall.data);
    }
}
