// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

import {Uniswap} from "src/Uniswap.sol";
import {Proposal} from "src/types/Proposal.sol";
import {Call} from "src/types/Call.sol";

import {ICrossChainAccount} from "src/interfaces/bridges/ICrossChainAccount.sol";
import {IFxRoot} from "src/interfaces/bridges/IFxRoot.sol";
import {IInbox} from "src/interfaces/bridges/IInbox.sol";
import {IL1CrossDomainMessenger} from "src/interfaces/bridges/IL1CrossDomainMessenger.sol";
import {IOptimismPortal2} from "src/interfaces/bridges/IOptimismPortal2.sol";
import {IWormholeSender} from "src/interfaces/bridges/IWormholeSender.sol";

library BridgeChecker {
    error EncodingError(string source, address target, bytes4 selector);

    function checkProposal(Uniswap storage uniswap, Proposal memory proposal) internal view {
        Call[] memory calls = proposal.calls;

        for (uint256 i; i < calls.length; i++) {
            address target = calls[i].target;

            if (target == uniswap.ethereum.bridge.arbitrum) {
                checkInbox(calls[i]);

                continue;
            }

            if (
                target == uniswap.ethereum.bridge.base || target == uniswap.ethereum.bridge.celo
                    || target == uniswap.ethereum.bridge.optimism || target == uniswap.ethereum.bridge.uniChain
                    || target == uniswap.ethereum.bridge.worldChain
            ) {
                checkCrossDomainMessenger(calls[i]);

                continue;
            }

            if (target == uniswap.ethereum.bridge.bnbChain) {
                checkWormholeSender(calls[i]);

                continue;
            }

            if (target == uniswap.ethereum.bridge.polygon) {
                checkPolygon(calls[i]);

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

    function checkInbox(Call memory call) internal pure {
        bytes4 selector = getSelector(call);

        if (selector != IInbox.createRetryableTicket.selector) {
            revert EncodingError("BridgeChecker::checkInbox", call.target, selector);
        }
    }

    function checkCrossDomainMessenger(Call memory call) internal pure {
        bytes4 selector = getSelector(call);

        if (selector != IL1CrossDomainMessenger.sendMessage.selector) {
            revert EncodingError("BridgeChecker::checkCrossDomainMessenger", call.target, selector);
        }
    }

    function checkOptimismPortal2(Call memory call) internal pure {
        bytes4 selector = getSelector(call);

        if (selector != IOptimismPortal2.depositTransaction.selector) {
            revert EncodingError("BridgeChecker::checkOptimismPortal2", call.target, selector);
        }
    }

    function checkWormholeSender(Call memory call) internal pure {
        bytes4 selector = getSelector(call);

        if (selector != IWormholeSender.sendMessage.selector && selector != IWormholeSender.setOwner.selector) {
            revert EncodingError("BridgeChecker::checkWormholeSender", call.target, selector);
        }
    }

    function checkPolygon(Call memory call) internal pure {
        bytes4 selector = getSelector(call);

        if (selector != IFxRoot.sendMessageToChild.selector) {
            revert EncodingError("BridgeChecker::checkFxRoot", call.target, selector);
        }

        (,, bytes memory sendMessageToChilData) = abi.decode(call.data, (bytes4, address, bytes));

        (address[] memory targets, bytes[] memory datas, uint256[] memory values) =
            abi.decode(sendMessageToChilData, (address[], bytes[], uint256[]));

        require(targets.length == datas.length && targets.length == values.length);
    }

    function getSelector(Call memory call) internal pure returns (bytes4 selector) {
        bytes memory data = call.data;

        if (data.length == 0) return 0x00000000;

        assembly {
            selector := mload(add(data, 0x20))
            selector := and(selector, 0xffffffff000000000000000000000000000000000000000000000000000000)
        }
    }
}
