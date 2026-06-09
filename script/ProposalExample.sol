// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

import {Script} from "lib/forge-std/src/Script.sol";

import {Proposal} from "src/types/Proposal.sol";
import {LibCall, Call} from "src/types/Call.sol";
import {GovernanceSeatbelt} from "src/forge/GovernanceSeatbelt.sol";
import {Uniswap} from "src/types/Uniswap.sol";
import {IUniswapV2Factory} from "src/interfaces/IUniswapV2Factory.sol";
import {IUniswapV3Factory} from "src/interfaces/IUniswapV3Factory.sol";
import {IGovernorBravo} from "src/interfaces/IGovernorBravo.sol";

string constant description = "# Example Description\n ...";

contract ProposalExample is Script {
    Uniswap internal uniswap;

    function run() external {
        uniswap.loadLatest();

        Proposal memory proposal = Proposal({
            description: description,
            calls: LibCall.newCalls(
                [
                    Call({
                        target: uniswap.ethereum.v2Factory,
                        value: 0,
                        data: abi.encodeCall(IUniswapV2Factory.setFeeTo, (uniswap.ethereum.tokenJar))
                    }),
                    Call({
                        target: uniswap.ethereum.v3Factory,
                        value: 0,
                        data: abi.encodeCall(IUniswapV3Factory.setOwner, (uniswap.ethereum.v3OpenFeeAdapter))
                    })
                ]
            )
        });

        // -----------------------------------------------------------------------------------------
        // Export proposal to Governance Seatbelt
        //
        string memory json =
            GovernanceSeatbelt.toJson({proposal: proposal, governorBravo: uniswap.ethereum.governorBravo});

        vm.writeFile("./seatbelt-example.json", json);

        // -----------------------------------------------------------------------------------------
        // Send proposal on GovernorBravo
        //
        if (true) return;

        (address[] memory targets, uint256[] memory values, string[] memory signatures, bytes[] memory datas,) =
            proposal.toGovernorBravoInputs();

        IGovernorBravo(uniswap.ethereum.governorBravo).propose(targets, values, signatures, datas, description);
    }
}
