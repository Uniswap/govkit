// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

import {Call} from "src/types/Call.sol";

struct Proposal {
    string description;
    Call[] calls;
}

using LibProposal for Proposal global;

library LibProposal {
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

    function newProposal(string memory description, Call[1] memory callsArray)
        internal
        pure
        returns (Proposal memory)
    {
        Call[] memory calls = new Call[](1);
        calls[0] = callsArray[0];
        return Proposal({description: description, calls: calls});
    }

    function newProposal(string memory description, Call[2] memory callsArray)
        internal
        pure
        returns (Proposal memory)
    {
        Call[] memory calls = new Call[](2);
        calls[0] = callsArray[0];
        calls[1] = callsArray[1];
        return Proposal({description: description, calls: calls});
    }

    function newProposal(string memory description, Call[3] memory callsArray)
        internal
        pure
        returns (Proposal memory)
    {
        Call[] memory calls = new Call[](3);
        for (uint256 i; i < 3; i++) {
            calls[i] = callsArray[i];
        }
        return Proposal({description: description, calls: calls});
    }

    function newProposal(string memory description, Call[4] memory callsArray)
        internal
        pure
        returns (Proposal memory)
    {
        Call[] memory calls = new Call[](4);
        for (uint256 i; i < 4; i++) {
            calls[i] = callsArray[i];
        }
        return Proposal({description: description, calls: calls});
    }

    function newProposal(string memory description, Call[5] memory callsArray)
        internal
        pure
        returns (Proposal memory)
    {
        Call[] memory calls = new Call[](5);
        for (uint256 i; i < 5; i++) {
            calls[i] = callsArray[i];
        }
        return Proposal({description: description, calls: calls});
    }

    function newProposal(string memory description, Call[6] memory callsArray)
        internal
        pure
        returns (Proposal memory)
    {
        Call[] memory calls = new Call[](6);
        for (uint256 i; i < 6; i++) {
            calls[i] = callsArray[i];
        }
        return Proposal({description: description, calls: calls});
    }

    function newProposal(string memory description, Call[7] memory callsArray)
        internal
        pure
        returns (Proposal memory)
    {
        Call[] memory calls = new Call[](7);
        for (uint256 i; i < 7; i++) {
            calls[i] = callsArray[i];
        }
        return Proposal({description: description, calls: calls});
    }

    function newProposal(string memory description, Call[8] memory callsArray)
        internal
        pure
        returns (Proposal memory)
    {
        Call[] memory calls = new Call[](8);
        for (uint256 i; i < 8; i++) {
            calls[i] = callsArray[i];
        }
        return Proposal({description: description, calls: calls});
    }

    function newProposal(string memory description, Call[9] memory callsArray)
        internal
        pure
        returns (Proposal memory)
    {
        Call[] memory calls = new Call[](9);
        for (uint256 i; i < 9; i++) {
            calls[i] = callsArray[i];
        }
        return Proposal({description: description, calls: calls});
    }

    function newProposal(string memory description, Call[10] memory callsArray)
        internal
        pure
        returns (Proposal memory)
    {
        Call[] memory calls = new Call[](10);
        for (uint256 i; i < 10; i++) {
            calls[i] = callsArray[i];
        }
        return Proposal({description: description, calls: calls});
    }
}
