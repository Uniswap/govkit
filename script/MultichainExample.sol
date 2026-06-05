// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

import {Script} from "lib/forge-std/src/Script.sol";

import {WormholeChainId} from "src/constants/WormholeChainId.sol";
import {LibProposal, Proposal} from "src/types/Proposal.sol";
import {Call, LibCall} from "src/types/Call.sol";
import {GovernanceSeatbelt} from "src/forge/GovernanceSeatbelt.sol";
import {WormholeEncoder} from "src/bridges/WormholeEncoder.sol";
import {L1CrossDomainMessengerEncoder} from "src/bridges/L1CrossDomainMessengerEncoder.sol";
import {Uniswap} from "src/Uniswap.sol";

import {IUniswapV2Factory} from "src/interfaces/IUniswapV2Factory.sol";
import {IUniswapV3Factory} from "src/interfaces/IUniswapV3Factory.sol";

string constant description = "" "# Turn on Fees BNB Chain & Celo \n\n"
    "Activates fee switch on BNB Chain & Celo by: \n\n"
    "- Setting V2Factory's `feeTo` on BNB Chain to TokenJar \n"
    "- Setting V3Factory's `owner` on BNB Chain to V3OpenFeeAdapter \n"
    "- Setting V2Factory's `feeTo` on Celo to TokenJar \n"
    "- Setting V3Factory's `owner` on Celo to V3OpenFeeAdapter \n\n"
    "> Note: Celo's OP Portal can only take one call each, so this is two calls.";

contract ProposalExample is Script {
    Uniswap internal uniswap;

    function run() external {
        uniswap.loadLatest();

        // -----------------------------------------------------------------------------------------
        // BNB Chain Call
        //
        Call memory bnbChainCall = WormholeEncoder.encode(
            uniswap.ethereum.bridge.bnbChain,
            uniswap.bnbChain.wormholeReceiver,
            WormholeChainId.BNBChain,
            0,
            LibCall.newCalls(
                [
                    Call({
                        target: uniswap.bnbChain.v2Factory,
                        value: 0,
                        data: abi.encodeCall(IUniswapV2Factory.setFeeTo, (uniswap.bnbChain.tokenJar))
                    }),
                    Call({
                        target: uniswap.bnbChain.v3Factory,
                        value: 0,
                        data: abi.encodeCall(IUniswapV3Factory.setOwner, (uniswap.bnbChain.v3OpenFeeAdapter))
                    })
                ]
            )
        );

        // -----------------------------------------------------------------------------------------
        // Celo Calls (Post-Optimism Bridge Transition)
        //
        Call memory celoCall0 = L1CrossDomainMessengerEncoder.encode({
            crossChainMessengerSender: uniswap.ethereum.bridge.celo,
            crossChainAccountReceiver: uniswap.celo.crossChainAccount,
            remoteCall: Call({
                target: uniswap.celo.v2Factory,
                value: 0,
                data: abi.encodeCall(IUniswapV2Factory.setFeeTo, (uniswap.celo.tokenJar))
            })
        });

        Call memory celoCall1 = L1CrossDomainMessengerEncoder.encode({
            crossChainMessengerSender: uniswap.ethereum.bridge.celo,
            crossChainAccountReceiver: uniswap.celo.crossChainAccount,
            remoteCall: Call({
                target: uniswap.celo.v3Factory,
                value: 0,
                data: abi.encodeCall(IUniswapV3Factory.setOwner, (uniswap.celo.v3OpenFeeAdapter))
            })
        });

        // -----------------------------------------------------------------------------------------
        // Construct Proposal
        //
        Proposal memory proposal = LibProposal.newProposal(description, [bnbChainCall, celoCall0, celoCall1]);

        // -----------------------------------------------------------------------------------------
        // Export proposal to Governance Seatbelt
        //
        string memory json =
            GovernanceSeatbelt.toJson({proposal: proposal, governorBravo: uniswap.ethereum.governorBravo});

        vm.writeFile("./seatbelt-example.json", json);
    }
}
