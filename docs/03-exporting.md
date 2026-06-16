# Exporting

Once a `Proposal` is built, it has to leave the `Proposal` type in two
directions: into `GovernorBravo`'s argument shape so it can actually be
proposed, and into JSON so it can be handed off to Governance Seatbelt for
validation.

## `toGovernorBravoInputs`

`GovernorBravo` does not accept a `Proposal`. It accepts the proposal as parallel
arrays of targets, values, signatures, and datas, plus the description string.
`toGovernorBravoInputs` transforms a `Proposal` into exactly those inputs.

It walks the proposal's calls and unzips them into the parallel arrays. Every
entry in the `signatures` array is the empty string — GovKit always encodes the
function selector into the call's `data` (via `abi.encodeCall`), so the separate
signature field is unused and **must** be empty.

```solidity
import {Proposal} from "lib/govkit/src/types/Proposal.sol";
import {Call, LibCall} from "lib/govkit/src/types/Call.sol";

Proposal memory proposal = Proposal({
    description: "Transfer <token> to <receiver>.",
    calls: LibCall.newCalls([
        Call({
            target: token,
            value: 0,
            data: abi.encodeCall(ERC20.transfer, (receiver, amount))
        })
    ])
});

(
    address[] memory targets,
    uint256[] memory values,
    string[] memory signatures,
    bytes[] memory datas,
    string memory description
) = proposal.toGovernorBravoInputs();

IGovernorBravo(uniswap.ethereum.governorBravo).propose(
    targets,
    values,
    signatures,
    datas,
    description
);
```

## Governance Seatbelt

Before a proposal is submitted, it should be handed off to Uniswap Foundation's
"Governance Seatbelt" system, which performs rich multichain call validation.
The `GovernanceSeatbelt` exporter produces JSON that can be imported into the
Seatbelt program to be simulated and analyzed in a uniform, automated way. This
streamlines the path between writing the proposal in Solidity and having it run
through Seatbelt.

`toJson` calls `toGovernorBravoInputs` internally, then serializes the result
along with the DAO/governor metadata Seatbelt expects.

```solidity
import {Uniswap} from "lib/govkit/src/types/Uniswap.sol";
import {Proposal} from "lib/govkit/src/types/Proposal.sol";
import {Call, LibCall} from "lib/govkit/src/types/Call.sol";
import {GovernanceSeatbelt} from "lib/govkit/src/forge/GovernanceSeatbelt.sol";

Uniswap internal uniswap;
uniswap.loadLatest();

Proposal memory proposal = Proposal({
    description: "Burn 20 UNI.",
    calls: LibCall.newCalls([
        Call({
            target: uniswap.ethereum.uni,
            value: 0,
            data: abi.encodeCall(ERC20.transfer, (address(0xdead), 20e18))
        })
    ])
});

vm.writeJson(
    "./prop-100.json",
    GovernanceSeatbelt.toJson(proposal, uniswap.ethereum.governorBravo)
);
```

Output (`./prop-100.json`):

```json
{
    "type": "new",
    "daoName": "Uniswap",
    "governorAddress": "0x408ED6354d4973f66138C91495F2f2FCbd8724C3",
    "governorType": "bravo",
    "targets": [
        "0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f"
    ],
    "values": [
        0
    ],
    "signatures": [
        ""
    ],
    "calldatas": [
        "0xa9059cbb000000000000000000000000000000000000000000000000000000000000dead000000000000000000000000000000000000000000000001158e460913d00000"
    ],
    "description": "Burn 20 UNI."
}
```

> Note that `signatures` is a single empty string, matching the
> `toGovernorBravoInputs` contract above: the selector lives in `calldatas`.
</content>
