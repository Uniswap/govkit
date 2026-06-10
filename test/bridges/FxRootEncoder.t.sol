// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

import {LibCall, Call} from "src/types/Call.sol";
import {IFxRoot} from "src/interfaces/bridges/IFxRoot.sol";
import {FxRootEncoder} from "src/bridges/FxRootEncoder.sol";

import {Test, console} from "lib/forge-std/src/Test.sol";
import {FxRootMock} from "test/mock/FxRootMock.sol";

contract FxRootEncoderTest is Test {
    address internal fxRoot;

    function setUp() external {
        fxRoot = address(new FxRootMock());
    }

    function testEncode() external {
        address fxReceiver = address(0x02);
        Call[] memory remoteCalls = LibCall.newCalls([Call({target: address(0x04), value: 0, data: hex"aabbccdd"})]);

        Call memory encoded = FxRootEncoder.encode({fxRoot: fxRoot, fxReceiver: fxReceiver, remoteCalls: remoteCalls});

        (bool success, bytes memory returndata) = encoded.target.call(encoded.data);

        assertTrue(success);

        (address receiver, address[] memory targets, bytes[] memory datas, uint256[] memory values) =
            abi.decode(returndata, (address, address[], bytes[], uint256[]));

        assertEq(encoded.target, fxRoot);
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
}
