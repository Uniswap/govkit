// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

import {Uniswap} from "src/Uniswap.sol";
import {Proposal} from "src/types/Proposal.sol";
import {Action} from "src/types/Action.sol";

library SignatureChecker {
    error SignatureError(bytes4 expectedSelector, bytes4 signatureSelector);

    function checkProposal(Proposal memory proposal) internal pure {
        Action[] memory actions = proposal.actions;

        for (uint256 i; i < actions.length; i++) {
            bytes4 selector = getSelector(actions[i]);

            bytes4 signatureSelector = bytes4(keccak256(bytes(actions[i].signature)));

            require(selector == signatureSelector, SignatureError(selector, signatureSelector));
        }
    }

    function getSelector(Action memory action) internal pure returns (bytes4 selector) {
        bytes memory data = action.data;

        if (data.length == 0) return 0x00000000;

        assembly {
            selector := mload(add(data, 0x20))
            selector := and(selector, 0xffffffff000000000000000000000000000000000000000000000000000000)
        }
    }
}
