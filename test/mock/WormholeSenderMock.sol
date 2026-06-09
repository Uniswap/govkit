// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

contract WormholeSenderMock {
    function sendMessage(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        address messageReceiver,
        uint16 receiverChainId
    ) external payable returns (address[] memory, uint256[] memory, bytes[] memory, address, uint16) {
        return (targets, values, calldatas, messageReceiver, receiverChainId);
    }
}
