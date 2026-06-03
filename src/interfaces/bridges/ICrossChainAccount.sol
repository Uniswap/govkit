// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

interface ICrossChainAccount {

    // Functions
    function forward(address target, bytes memory data) external;
    function l1Owner() external view returns (address);
    function messenger() external view returns (address);
}
