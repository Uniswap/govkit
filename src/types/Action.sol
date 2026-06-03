// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

struct Action {
    address target;
    uint256 value;
    string signature;
    bytes data;
}
