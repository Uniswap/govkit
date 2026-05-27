// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

struct ProposalAction {
    address target;
    uint256 value;
    string signature;
    bytes data;
}

// todo:
// add actions checker to read target-data pair encoding

using LibProposalAction for ProposalAction global;

library LibProposalAction {
    function toGovernorBravoInputs(ProposalAction[] memory actions)
        internal
        pure
        returns (
            address[] memory,
            uint256[] memory,
            string[] memory,
            bytes[] memory
        )
    {
        uint256 length = actions.length;

        address[] memory targets = new address[](length);
        uint256[] memory values = new uint256[](length);
        string[] memory signatures = new string[](length);
        bytes[] memory datas = new bytes[](length);

        for (uint256 i; i < length; i++) {
            targets[0] = actions[0].target;
            values[0] = actions[0].value;
            signatures[0] = actions[0].signature;
            datas[0] = actions[0].data;
        }

        return (targets, values, signatures, datas);
    }
}
