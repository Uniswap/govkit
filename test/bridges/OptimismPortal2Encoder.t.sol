// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

import {Call} from "src/types/Call.sol";
import {IOptimismPortal2} from "src/interfaces/bridges/IOptimismPortal2.sol";
import {OptimismPortal2Encoder} from "src/bridges/OptimismPortal2Encoder.sol";

import {Test, console} from "lib/forge-std/src/Test.sol";
import {OptimismPortal2Mock} from "test/mock/OptimismPortal2Mock.sol";

contract OptimismPortal2EncoderTest is Test {
    address internal portal;

    function setUp() external {
        portal = address(new OptimismPortal2Mock());
    }

    function testEncode() external {
        Call memory remoteCall = Call({
            target: address(0x04),
            value: 5,
            data: hex"aabbccdd"
        });

        Call memory encoded = OptimismPortal2Encoder.encode({
            portal: portal,
            remoteCall: remoteCall
        });

        (bool success, bytes memory returndata) = encoded.target.call{value: encoded.value}(encoded.data);

        assertTrue(success);

        (
            address to,
            uint256 value,
            uint64 gasLimit,
            bool isCreation,
            bytes memory data
        ) = abi.decode(returndata, (address, uint256, uint64, bool, bytes));

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
        Call memory remoteCall = Call({
            target: address(0x04),
            value: 5,
            data: hex"aabbccdd"
        });

        Call memory encoded = OptimismPortal2Encoder.encode({
            portal: portal,
            gasLimit: gasLimit_,
            remoteCall: remoteCall
        });

        (bool success, bytes memory returndata) = encoded.target.call{value: encoded.value}(encoded.data);

        assertTrue(success);

        (
            address to,
            uint256 value,
            uint64 gasLimit,
            bool isCreation,
            bytes memory data
        ) = abi.decode(returndata, (address, uint256, uint64, bool, bytes));

        assertEq(encoded.target, portal);
        assertEq(encoded.value, remoteCall.value);
        assertEq(to, remoteCall.target);
        assertEq(value, remoteCall.value);
        assertEq(gasLimit, gasLimit_);
        assertFalse(isCreation);
        assertEq(data, remoteCall.data);
    }

    function testFuzzEncode(Call calldata remoteCall) external {
        Call memory encoded = OptimismPortal2Encoder.encode({
            portal: portal,
            remoteCall: remoteCall
        });

        vm.deal(address(this), encoded.value);
        (bool success, bytes memory returndata) = encoded.target.call{value: encoded.value}(encoded.data);

        assertTrue(success);

        (
            address to,
            uint256 value,
            uint64 gasLimit,
            bool isCreation,
            bytes memory data
        ) = abi.decode(returndata, (address, uint256, uint64, bool, bytes));

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
            portal: portal,
            gasLimit: gasLimit_,
            remoteCall: remoteCall
        });

        vm.deal(address(this), encoded.value);
        (bool success, bytes memory returndata) = encoded.target.call{value: encoded.value}(encoded.data);

        assertTrue(success);

        (
            address to,
            uint256 value,
            uint64 gasLimit,
            bool isCreation,
            bytes memory data
        ) = abi.decode(returndata, (address, uint256, uint64, bool, bytes));

        assertEq(encoded.target, portal);
        assertEq(encoded.value, remoteCall.value);
        assertEq(to, remoteCall.target);
        assertEq(value, remoteCall.value);
        assertEq(gasLimit, gasLimit_);
        assertFalse(isCreation);
        assertEq(data, remoteCall.data);
    }
}
