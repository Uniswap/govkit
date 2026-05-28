# GovKit

A lightweight kit for writing Uniswap Governance Proposals

## At a Glance

```solidity
// -------------------------------------------------------------------------------------------------
// Initialize Uniswap protocol addresses.
//
Uniswap internal uniswap;
uniswap.loadLatest();

// -------------------------------------------------------------------------------------------------
// Build proposal.
//
Proposal memory proposal = LibProposal.newProposal(
    "# Activate Fee Switch V2+V3 on Ethereum ....",
    [
        Action({
            target: uniswap.ethereum.v2Factory,
            value: 0,
            signature: "setFeeTo(address)",
            data: abi.encodeCall(
                IUniswapV2Factory.setFeeTo,
                (uniswap.ethereum.tokenJar)
            )
        }),
        Action({
            target: uniswap.ethereum.v3Factory,
            value: 0,
            signature: "setOwner(address)",
            data: abi.encodeCall(
                IUniswapV3Factory.setOwner,
                (uniswap.ethereum.v3OpenFeeAdapter)
            )
        })
    ]
);

// -------------------------------------------------------------------------------------------------
// Export proposal to Governance Seatbelt.
//
string memory json = GovernanceSeatbelt.toJson({
    proposal: proposal,
    governorBravo: uniswap.ethereum.governorBravo
});

vm.writeFile("./seatbelt-example.json", json);

// -------------------------------------------------------------------------------------------------
// Send proposal on GovernorBravo.
//
(
    address[] memory targets,
    uint256[] memory values,
    string[] memory signatures,
    bytes[] memory datas,
) = proposal.toGovernorBravoInputs();

IGovernorBravo(uniswap.ethereum.governorBravo).propose( targets, values, signatures, datas, description);
```

## Guiding Principles

Each proposal requires a series of actions, each containing a target, value, data, and "signature"
(not in the digital signature sense, but the function signature sense, for tooling). `GovernorBravo`
takes each of these as separate arrays, making proposal specification unwieldy. We define a data
type which encapsulates these actions more cleanly, as well as provide a function to transform it
into the input that `GovernorBravo` can accept.

Each action requires contract addresses across networks for calling. At the time of writing, this is
fragmented with no importable source of truth. We implement a collection of data types and constants
which scope, by name, contracts across networks in the protocol; which gives us portability across
proposals instead of re-hard coding them each proposal.

Each action that interacts with remote chains requires the target chain ID, the bridge used to send
the message to the target chain, the target chain infrastructure to receive the message, and in some
cases, it requires bridge-defined "chain identifier" values, which are unrelated to the "chain ID".
We define constants and encoders (TODO) for each bridge type.

Each action requires a handoff to Uniswap Foundation's "Governance Seatbelt" system, which performs
rich multichain call validation. We implement an exporter which produces JSON that can be imported
into the seatbelt program to be interpreted in a more uniform and automated way.

Some actions require prerequisite deployments and configurations before the proposal can run. So far
we have primarily relied purely on Foundry's scripting output files (`broadcast/`) or Foundry's
`console` logging contract to get newly deployed addresses. In short, Foundry's native broadcast
handling is fragile, unwieldy, and its internal API for interacting with it is broken. We implement
a data type which can record contract addresses, names, and chain ID's to disk in a clean and easy
to interpret JSON file, stored in `.records/`.

Also, at times, proxy contracts must be used and dealt with, primarily those of ERC-1967. We provide
a lightweight utility for handling these.

## Proposal

Fairly straight forward, it encapsulates actions and a proposal description. This can then generate
governor bravo inputs.

```solidity
import {Proposal} from "lib/govkit/src/types/Proposal.sol";

Proposal memory proposal = LibProposal.newProposal(
    "Transfer <token> to <receiver>.",
    [
        Action({
            target: token,
            value: 0,
            signature: "transfer(address,uint256)",
            data: abi.encodeCall(ERC20.transfer, (receiver, amount))
        })
    ]
);

(
    address[] memory targets,
    uint256[] memory values,
    string[] memory signatures,
    bytes[] memory datas
) = actions.toGovernorBravoInputs();
```

## Contract Addresses

Complex data type encapsulating each network's contracts by name. This gets us compile time checks
to ensure the particular account is on the given network.

> The `WormholeChainId` will be explained in the next section.

```solidity
import {Uniswap} from "lib/govkit/src/Uniswap.sol";
import {Proposal} from "lib/govkit/src/types/Proposal.sol";
import {WormholeChainId} from "lib/govkit/src/constants/WormholeChainId.sol";

Uniswap internal uniswap;

uniswap.loadLatest();

Proposal memory proposal = LibProposal.newProposal(
    "Send Message over Wormhole to BNB Chain.",
    [
        Action({
            target: uniswap.ethereum.bridge.bnbChain,
            value: 0,
            signature: "sendMessage(address[],uint256[],bytes[],address,uint16)",
            data: abi.encodeCall(
                IWormhole.sendMessage,
                (
                    new address[](0),
                    new uint256[](0),
                    new bytes[](0),
                    uniswap.bnbChain.wormholeReceiver,
                    WormholeChainId.BNBChain
                )
            )
        })
    ]
);
```

This also makes testing environments more flexible for protocol mocking.

```solidity
import {Uniswap} from "lib/govkit/src/Uniswap.sol";

contract MockGovernorBravo {
    // ...
}

Uniswap internal uniswap;

uniswap.ethereum.governorBravo = address(new MockGovernorBravo());
```

## Chain Identifiers and Encoders

Chain ID in the EIP-155 sense (the intuitive sense) are define together in a `ChainId` library,
while bridge protocols' chain identifiers are defined together in their respective libraries as
necessary. We also provide converters for these as well.

```solidity
import {ChainId} from "lib/govkit/src/constants/ChainId.sol";
import {WormholeChainId} from "lib/govkit/src/constants/WormholeChainId.sol";

// EIP-155
//
// ChainId.Ethereum = 1
vm.chainId(ChainId.Ethereum);

// Wormhole's chain ID
//
// WormholeChainId.Ethereum = 2
WormholeChainId.Ethereum;

// Converters
assertEq(
    WormholeChainId.chainIdToWormholeChainId(
        ChainId.Ethereum
    ),
    WormholeChainId.Ethereum
);

assertEq(
    WormholeChainId.wormholeChainIdtoChainId(
        WormholeChainId.Ethereum
    ),
    ChainId.Ethereum
);
```

## Seatbelt Handoff

This allows `ProposalAction` to be exported to JSON for interpretation by a seatbelt script. This
deduplicates code and streamlines seatbelt usage.

```solidity
import {Uniswap} from "lib/govkit/src/Uniswap.sol";
import {Proposal} from "lib/govkit/src/types/Proposal.sol";
import {GovernanceSeatbelt} from "lib/govkit/src/forge/GovernanceSeatbelt.sol";

Uniswap internal uniswap;
uniswap.loadLatest();
Proposal memory proposal = LibProposal.newProposal(
    "Burn 20 UNI.",
    [
        Action({
            target: uniswap.ethereum.uni,
            value: 0,
            signature: "transfer(address,uint256)",
            data: abi.encodeCall(ERC20.transfer, (address(0xdead), 20))
        })
    ]
);

vm.writeJson("./prop-100.json", GovernanceSeatbelt.toJson(proposal));
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
        "transfer(address,uint256)"
    ],
    "calldatas": [
        "0xa9059cbb000000000000000000000000000000000000000000000000000000000000dead000000000000000000000000000000000000000000000001158e460913d00000"
    ],
    "description": "Burn 20 UNI.",
}
```

## Contract Logging

Foundry's scripting is fragile, it is difficult to recover from mid-flight RPC failures, logging is
insufficient, and broadcast JSON outputs are infeasible to parse via its `Vm` JSON API, its
cheatcode abstraction to read broadcast files is incompatible with its newest JSON structure, and
referencing transactions by index break with external library deployments.

> While external libraries are anti-patterns and we generally avoid them, there have been cases
> where we had to deploy bridge infrastructure using external teams' code which embedded external
> libraries.

So we're using `Recorder` to record addresses as they're deployed.

```solidity
import {Recorder} from "lib/govkit/src/forge/Recorder.sol";

Recorder internal recorder;

// Initialize with script name.
//
// recorder.debugMode uses excessive STDOUT logging in case things go wrong.
recorder.initialize({
    scriptName: "MyScript",
    debugMode: true
});

// Deploy the contract and record it.
//
// `write` returns the address as a passthrough for ergonomics.
address myContract = recorder.write(
    ChainId.Ethereum,
    "MyContract", 
    address(new MyContract())
);

// Load the contract's address.
//
// This can be done in any subsequent script.
//
address loadedMyContract = recorder.read(ChainId.Ethereum, "MyContract");

// (Optional): Clear the record.
//
recorder.clear();
```

Output (`.records/MyScript.json`):

```json
{
    "1": {
        "MyContract": "0x.."
    }
}
```

Conditional deployer sketch:

```solidity
import {Recorder} from "lib/govkit/src/forge/Recorder.sol";

Recorder internal recorder;

if (!recorder.exists(ChainId.Ethereum, "MyContract")) {
    recorder.write(
        ChainId.Ethereum,
        "MyContract", 
        address(new MyContract())
    );
}
```

## ERC1967 Proxy

The `ERC1967` library is independent of Foundry, it contains only the constants, while
`ERC1967Reader` is a Foundry-specific reader, using its Vm to load the relevant addresses.

```solidity
import {Uniswap} from "lib/govkit/src/Uniswap.sol";
import {ERC1967Reader} from "lib/govkit/src/forge/ERC1967Reader.sol";

Uniswap internal uniswap;
uniswap.loadLatest();

address proxy = uniswap.ethereum.bridge.bnbChain;

address admin = ERC1967Reader.admin(proxy);
address beacon = ERC1967Reader.beacon(proxy);
address implementation = ERC1967Reader.implementation(proxy);
```

## TODO's

- Bridge Encoder
- Conditional deployer
