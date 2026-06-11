// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

import {Call} from "./Call.sol";

/// @dev Proposal Type.
struct Proposal {
    string description;
    Call[] calls;
}

using LibProposal for Proposal global;

/// @title Proposal Library
/// @dev Only used for transforming the Proposal into GovernorBravo inputs.
library LibProposal {
    /// @dev Transforms Proposal into GovernorBravo inputs.
    /// @param proposal Proposal to transform.
    /// @return Array of target addresses.
    /// @return Array of call values.
    /// @return Array of function signatures (MUST ALL be empty).
    /// @return Array of call datas.
    /// @return Description string.
    function toGovernorBravoInputs(Proposal memory proposal)
        internal
        pure
        returns (address[] memory, uint256[] memory, string[] memory, bytes[] memory, string memory)
    {
        Call[] memory calls = proposal.calls;
        uint256 length = calls.length;

        address[] memory targets = new address[](length);
        uint256[] memory values = new uint256[](length);
        string[] memory signatures = new string[](length);
        bytes[] memory datas = new bytes[](length);

        for (uint256 i; i < length; i++) {
            targets[i] = calls[i].target;
            values[i] = calls[i].value;
            signatures[i] = "";
            datas[i] = calls[i].data;
        }

        return (targets, values, signatures, datas, proposal.description);
    }
}
