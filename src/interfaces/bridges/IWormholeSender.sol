// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

interface IWormholeSender {
    // Events
    event MessageSent(bytes payload, address indexed messageReceiver);

    // Functions
    function CONSISTENCY_LEVEL() external view returns (uint8);
    function NAME() external view returns (string memory);
    function NONCE() external view returns (uint32);
    function owner() external view returns (address);
    function sendMessage(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        address messageReceiver,
        uint16 receiverChainId
    ) external payable;
    function setOwner(address newOwner) external;
}
