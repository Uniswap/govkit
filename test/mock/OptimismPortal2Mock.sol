// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

contract OptimismPortal2Mock {
    function depositTransaction(
        address to,
        uint256 value,
        uint64 gasLimit,
        bool isCreation,
        bytes memory data
    ) external payable returns (address, uint256, uint64, bool, bytes memory) {
        return (to, value, gasLimit, isCreation, data);
    }
}
