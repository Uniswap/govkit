// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

import {vm} from "./Constants.sol";
import {Proposal} from "../types/Proposal.sol";

/// @title Governance Seatbelt Exporter
/// @dev Serializes a proposal to JSON, which can be parsed, simulated, &
///      analyzed by Governance Seatbelt. This streamlines the process between
///      writing the proposal in Solidity and that proposal being analyzed &
///      run from the Seatbelt application.
library GovernanceSeatbelt {
    /// @dev Serializes the proposal to a JSON object.
    /// @param proposal Proposal to serialize.
    /// @param governorBravo GovernorBravo address (used in Seatbelt).
    /// @return Serialized JSON.
    function toJson(Proposal memory proposal, address governorBravo) internal returns (string memory) {
        (
            address[] memory targets,
            uint256[] memory values,
            string[] memory signatures,
            bytes[] memory datas,
            string memory description
        ) = proposal.toGovernorBravoInputs();

        string memory object = "placeholder";

        vm.serializeString(object, "type", "new");
        vm.serializeString(object, "daoName", "Uniswap");
        vm.serializeAddress(object, "governorAddress", governorBravo);
        vm.serializeString(object, "governorType", "bravo");
        vm.serializeAddress(object, "targets", targets);
        vm.serializeUint(object, "values", values);
        vm.serializeString(object, "signatures", signatures);
        vm.serializeBytes(object, "calldatas", datas);
        object = vm.serializeString(object, "description", description);

        return object;
    }
}
