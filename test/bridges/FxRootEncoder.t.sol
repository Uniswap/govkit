// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

import {FxRootEncoder} from "../../src/bridges/FxRootEncoder.sol";
import {IFxRoot} from "../../src/interfaces/bridges/IFxRoot.sol";
import {Call, LibCall} from "../../src/types/Call.sol";
import {DecoderHarness} from "../harness/DecoderHarness.sol";
import {EncoderHarness} from "../harness/EncoderHarness.sol";

import {FxRootMock} from "../mock/FxRootMock.sol";
import {Test, console} from "forge-std/Test.sol";

contract FxRootEncoderTest is Test {
    EncoderHarness internal encoder;
    DecoderHarness internal decoder;

    address internal mockFxRoot;

    function setUp() external {
        encoder = new EncoderHarness();
        decoder = new DecoderHarness();
        mockFxRoot = address(new FxRootMock());
    }

    function testEncode() external {
        address fxReceiver = address(0x02);
        Call[] memory remoteCalls =
            LibCall.newCalls([Call({target: address(0x04), value: 0, data: hex"aabbccdd"})]);

        Call memory encoded = FxRootEncoder.encode({
            fxRoot: mockFxRoot, fxReceiver: fxReceiver, remoteCalls: remoteCalls
        });

        (bool success, bytes memory returndata) = encoded.target.call(encoded.data);

        assertTrue(success);

        (
            address receiver,
            address[] memory targets,
            bytes[] memory datas,
            uint256[] memory values
        ) = abi.decode(returndata, (address, address[], bytes[], uint256[]));

        assertEq(encoded.target, mockFxRoot);
        assertEq(encoded.value, 0);
        assertEq(receiver, fxReceiver);
        assertEq(targets.length, remoteCalls.length);
        assertEq(datas.length, remoteCalls.length);
        assertEq(values.length, remoteCalls.length);

        for (uint256 i; i < remoteCalls.length; i++) {
            assertEq(targets[i], remoteCalls[i].target);
            assertEq(datas[i], remoteCalls[i].data);
            assertEq(values[i], 0);
        }
    }

    function testEncodeDecode() external view {
        address fxRoot = address(0x01);
        address fxReceiver = address(0x02);
        Call[] memory remoteCalls = new Call[](1);
        remoteCalls[0] = Call({target: address(0x03), value: 0, data: hex"05"});

        Call memory fxRootCall = encoder.encodeFxRoot(fxRoot, fxReceiver, remoteCalls);

        (address decodedFxRoot, address decodedFxReceiver, Call[] memory decodedRemoteCalls) =
            decoder.decodeFxRoot(fxRootCall);

        assertEq(fxRoot, decodedFxRoot);
        assertEq(fxReceiver, decodedFxReceiver);

        for (uint256 i; i < remoteCalls.length; i++) {
            assertEq(remoteCalls[i].target, decodedRemoteCalls[i].target);
            assertEq(remoteCalls[i].value, decodedRemoteCalls[i].value);
            assertEq(remoteCalls[i].data, decodedRemoteCalls[i].data);
        }
    }

    function testFuzzEncodeDecode(address fxRoot, address fxReceiver, Call[] memory remoteCalls)
        external
        view
    {
        for (uint256 i; i < remoteCalls.length; i++) {
            remoteCalls[i].value = 0;
        }

        Call memory fxRootCall = encoder.encodeFxRoot(fxRoot, fxReceiver, remoteCalls);

        (address decodedFxRoot, address decodedFxReceiver, Call[] memory decodedRemoteCalls) =
            decoder.decodeFxRoot(fxRootCall);

        assertEq(fxRoot, decodedFxRoot);
        assertEq(fxReceiver, decodedFxReceiver);

        for (uint256 i; i < remoteCalls.length; i++) {
            assertEq(remoteCalls[i].target, decodedRemoteCalls[i].target);
            assertEq(remoteCalls[i].value, decodedRemoteCalls[i].value);
            assertEq(remoteCalls[i].data, decodedRemoteCalls[i].data);
        }
    }
}
