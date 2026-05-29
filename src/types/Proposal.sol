// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

struct Proposal {
    string description;
    Action[] actions;
}

struct Action {
    address target;
    uint256 value;
    string signature;
    bytes data;
}

// todo:
// add actions checker to read target-data pair encoding

using LibProposal for Proposal global;

library LibProposal {
    function toGovernorBravoInputs(Proposal memory proposal)
        internal
        pure
        returns (
            address[] memory,
            uint256[] memory,
            string[] memory,
            bytes[] memory,
            string memory
        )
    {
        uint256 length = proposal.actions.length;

        address[] memory targets = new address[](length);
        uint256[] memory values = new uint256[](length);
        string[] memory signatures = new string[](length);
        bytes[] memory datas = new bytes[](length);

        for (uint256 i; i < length; i++) {
            Action memory action = proposal.actions[i];

            targets[i] = action.target;
            values[i] = action.value;
            signatures[i] = action.signature;
            datas[i] = action.data;
        }

        return (targets, values, signatures, datas, proposal.description);
    }

    function newProposal(
        string memory description,
        Action[1] memory actionsArray
    ) internal pure returns (Proposal memory) {
        Action[] memory actions = new Action[](1);
        actions[0] = actionsArray[0];
        return Proposal({
            description: description,
            actions: actions
        });
    }

    function newProposal(
        string memory description,
        Action[2] memory actionsArray
    ) internal pure returns (Proposal memory) {
        Action[] memory actions = new Action[](2);
        actions[0] = actionsArray[0];
        actions[1] = actionsArray[1];
        return Proposal({
            description: description,
            actions: actions
        });
    }

    function newProposal(
        string memory description,
        Action[3] memory actionsArray
    ) internal pure returns (Proposal memory) {
        Action[] memory actions = new Action[](3);
        for (uint256 i; i < 3; i++) {
            actions[i] = actionsArray[i];
        }
        return Proposal({
            description: description,
            actions: actions
        });
    }

    function newProposal(
        string memory description,
        Action[4] memory actionsArray
    ) internal pure returns (Proposal memory) {
        Action[] memory actions = new Action[](4);
        for (uint256 i; i < 4; i++) {
            actions[i] = actionsArray[i];
        }
        return Proposal({
            description: description,
            actions: actions
        });
    }

    function newProposal(
        string memory description,
        Action[5] memory actionsArray
    ) internal pure returns (Proposal memory) {
        Action[] memory actions = new Action[](5);
        for (uint256 i; i < 5; i++) {
            actions[i] = actionsArray[i];
        }
        return Proposal({
            description: description,
            actions: actions
        });
    }

    function newProposal(
        string memory description,
        Action[6] memory actionsArray
    ) internal pure returns (Proposal memory) {
        Action[] memory actions = new Action[](6);
        for (uint256 i; i < 6; i++) {
            actions[i] = actionsArray[i];
        }
        return Proposal({
            description: description,
            actions: actions
        });
    }

    function newProposal(
        string memory description,
        Action[7] memory actionsArray
    ) internal pure returns (Proposal memory) {
        Action[] memory actions = new Action[](7);
        for (uint256 i; i < 7; i++) {
            actions[i] = actionsArray[i];
        }
        return Proposal({
            description: description,
            actions: actions
        });
    }

    function newProposal(
        string memory description,
        Action[8] memory actionsArray
    ) internal pure returns (Proposal memory) {
        Action[] memory actions = new Action[](8);
        for (uint256 i; i < 8; i++) {
            actions[i] = actionsArray[i];
        }
        return Proposal({
            description: description,
            actions: actions
        });
    }

    function newProposal(
        string memory description,
        Action[9] memory actionsArray
    ) internal pure returns (Proposal memory) {
        Action[] memory actions = new Action[](9);
        for (uint256 i; i < 9; i++) {
            actions[i] = actionsArray[i];
        }
        return Proposal({
            description: description,
            actions: actions
        });
    }

    function newProposal(
        string memory description,
        Action[10] memory actionsArray
    ) internal pure returns (Proposal memory) {
        Action[] memory actions = new Action[](10);
        for (uint256 i; i < 10; i++) {
            actions[i] = actionsArray[i];
        }
        return Proposal({
            description: description,
            actions: actions
        });
    }
}
