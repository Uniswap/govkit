// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

contract L1CrossDomainMessengerMock {
    function sendMessage(address target, bytes calldata message, uint32 minGasLimit)
        external
        payable
        returns (address, address, bytes memory, uint32)
    {
        // `message` is abi.encodeCall(ICrossChainAccount.forward, (forwardTarget, forwardData)); strip the selector.
        (address forwardTarget, bytes memory forwardData) =
            abi.decode(message[4:], (address, bytes));

        return (target, forwardTarget, forwardData, minGasLimit);
    }
}
