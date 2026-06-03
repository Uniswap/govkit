// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

interface IFxRoot {

    // Functions
    function fxChild() external view returns (address);
    function sendMessageToChild(address _receiver, bytes memory _data) external;
    function setFxChild(address _fxChild) external;
    function stateSender() external view returns (address);
}
