// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

contract FxRootMock {
    function sendMessageToChild(address receiver, bytes memory data) external payable returns (
        address,
        address[] memory,
        bytes[] memory,
        uint256[] memory
    ) {
        (
            address[] memory targets,
            bytes[] memory datas,
            uint256[] memory values
        ) = abi.decode(data, (address[], bytes[], uint256[]));

        return (receiver, targets, datas, values);
    }
}
