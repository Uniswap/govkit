// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.34;

import {vm} from "src/forge/Constants.sol";
import {Proposal} from "src/types/Proposal.sol";

library GovernanceSeatbelt {
    function toJson(
        Proposal memory proposal,
        address governorBravo
    ) internal returns (string memory) {
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
