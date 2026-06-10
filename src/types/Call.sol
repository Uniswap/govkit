// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

/// @dev Call Type.
struct Call {
    address target;
    uint256 value;
    bytes data;
}

/// @title Call Library
/// @dev Ergonomics for dynamic call arrays. Provides an API for transforming
///      static call arrays into dynamic ones & for transforming dynamic call
///      arrays into arrays of targets, values, and datas.
library LibCall {
    function decompose(Call[] memory calls)
        internal
        pure
        returns (address[] memory targets, uint256[] memory values, bytes[] memory datas)
    {
        targets = new address[](calls.length);
        values = new uint256[](calls.length);
        datas = new bytes[](calls.length);

        for (uint256 i; i < calls.length; i++) {
            targets[i] = calls[i].target;
            values[i] = calls[i].value;
            datas[i] = calls[i].data;
        }
    }

    function newCalls(Call[1] memory callsArray) internal pure returns (Call[] memory) {
        Call[] memory calls = new Call[](1);
        calls[0] = callsArray[0];
        return calls;
    }

    function newCalls(Call[2] memory callsArray) internal pure returns (Call[] memory) {
        Call[] memory calls = new Call[](2);
        calls[0] = callsArray[0];
        calls[1] = callsArray[1];
        return calls;
    }

    function newCalls(Call[3] memory callsArray) internal pure returns (Call[] memory) {
        Call[] memory calls = new Call[](3);
        for (uint256 i; i < 3; i++) {
            calls[i] = callsArray[i];
        }
        return calls;
    }

    function newCalls(Call[4] memory callsArray) internal pure returns (Call[] memory) {
        Call[] memory calls = new Call[](4);
        for (uint256 i; i < 4; i++) {
            calls[i] = callsArray[i];
        }
        return calls;
    }

    function newCalls(Call[5] memory callsArray) internal pure returns (Call[] memory) {
        Call[] memory calls = new Call[](5);
        for (uint256 i; i < 5; i++) {
            calls[i] = callsArray[i];
        }
        return calls;
    }

    function newCalls(Call[6] memory callsArray) internal pure returns (Call[] memory) {
        Call[] memory calls = new Call[](6);
        for (uint256 i; i < 6; i++) {
            calls[i] = callsArray[i];
        }
        return calls;
    }

    function newCalls(Call[7] memory callsArray) internal pure returns (Call[] memory) {
        Call[] memory calls = new Call[](7);
        for (uint256 i; i < 7; i++) {
            calls[i] = callsArray[i];
        }
        return calls;
    }

    function newCalls(Call[8] memory callsArray) internal pure returns (Call[] memory) {
        Call[] memory calls = new Call[](8);
        for (uint256 i; i < 8; i++) {
            calls[i] = callsArray[i];
        }
        return calls;
    }

    function newCalls(Call[9] memory callsArray) internal pure returns (Call[] memory) {
        Call[] memory calls = new Call[](9);
        for (uint256 i; i < 9; i++) {
            calls[i] = callsArray[i];
        }
        return calls;
    }

    function newCalls(Call[10] memory callsArray) internal pure returns (Call[] memory) {
        Call[] memory calls = new Call[](10);
        for (uint256 i; i < 10; i++) {
            calls[i] = callsArray[i];
        }
        return calls;
    }
}
