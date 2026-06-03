// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

import {Uniswap} from "src/Uniswap.sol";
import {Proposal} from "src/types/Proposal.sol";
import {Action} from "src/types/Action.sol";

import {ICrossChainAccount} from "src/interfaces/bridges/ICrossChainAccount.sol";
import {IFxRoot} from "src/interfaces/bridges/IFxRoot.sol";
import {IInbox} from "src/interfaces/bridges/IInbox.sol";
import {IL1CrossDomainMessenger} from "src/interfaces/bridges/IL1CrossDomainMessenger.sol";
import {IOptimismPortal2} from "src/interfaces/bridges/IOptimismPortal2.sol";
import {IWormholeSender} from "src/interfaces/bridges/IWormholeSender.sol";

library BridgeChecker {
    error EncodingError(string source, address target, string invalidSignature);

    function checkProposal(
        Uniswap storage uniswap,
        Proposal memory proposal
    ) internal view {
        Action[] memory actions = proposal.actions;

        for (uint256 i; i < actions.length; i++) {
            address target = actions[i].target;

            if (target == uniswap.ethereum.bridge.arbitrum) {
                checkInbox(actions[i]);

                continue;
            }

            if (
                target == uniswap.ethereum.bridge.base ||
                target == uniswap.ethereum.bridge.celo ||
                target == uniswap.ethereum.bridge.optimism ||
                target == uniswap.ethereum.bridge.uniChain ||
                target == uniswap.ethereum.bridge.worldChain
            ) {
                checkCrossDomainMessenger(actions[i]);

                continue;
            }

            if (target == uniswap.ethereum.bridge.bnbChain) {
                checkWormholeSender(actions[i]);

                continue;
            }

            if (target == uniswap.ethereum.bridge.polygon) {
                checkPolygon(actions[i]);

                continue;
            }

            // UNCHECKED:
            //
            // | network   | reason                                             |
            // | --------- | -------------------------------------------------- |
            // | avalanche | Pending LZ -> WH Transition                        |
            //
        }
    }

    function checkInbox(Action memory action) internal pure {
        bytes4 selector = getSelector(action);

        if (selector != IInbox.createRetryableTicket.selector) {
            revert EncodingError(
                "BridgeChecker::checkInbox",
                action.target,
                action.signature
            );
        }
    }

    function checkCrossDomainMessenger(Action memory action) internal pure {
        bytes4 selector = getSelector(action);

        if (selector != IL1CrossDomainMessenger.sendMessage.selector) {
            revert EncodingError(
                "BridgeChecker::checkCrossDomainMessenger",
                action.target,
                action.signature
            );
        }
    }

    function checkOptimismPortal2(Action memory action) internal pure {
        bytes4 selector = getSelector(action);

        if (selector != IOptimismPortal2.depositTransaction.selector) {
            revert EncodingError(
                "BridgeChecker::checkOptimismPortal2",
                action.target,
                action.signature
            );
        }
    }

    function checkWormholeSender(Action memory action) internal pure {
        bytes4 selector = getSelector(action);

        if (
            selector != IWormholeSender.sendMessage.selector &&
            selector != IWormholeSender.setOwner.selector
        ) {
            revert EncodingError(
                "BridgeChecker::checkWormholeSender",
                action.target,
                action.signature
            );
        }
    }

    function checkPolygon(Action memory action) internal pure {
        bytes4 selector = getSelector(action);

        if (selector != IFxRoot.sendMessageToChild.selector) {
            revert EncodingError(
                "BridgeChecker::checkFxRoot",
                action.target,
                action.signature
            );
        }

        (,, bytes memory sendMessageToChilData) = abi.decode(action.data, (bytes4, address, bytes));

        (address[] memory targets, bytes[] memory datas, uint256[] memory values) = abi.decode(
            sendMessageToChilData,
            (address[],bytes[],uint256[])
        );

        require(targets.length == datas.length && targets.length == values.length);
    }

    function getSelector(
        Action memory action
    ) internal pure returns (bytes4 selector) {
        bytes memory data = action.data;

        if (data.length == 0) return 0x00000000;

        assembly {
            selector := mload(add(data, 0x20))
            selector := and(
                selector,
                0xffffffff000000000000000000000000000000000000000000000000000000
            )
        }
    }
}
