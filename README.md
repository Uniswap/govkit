# GovKit

A lightweight kit for writing Uniswap Governance Proposals

## Guiding Principles

Each proposal requires a series of actions, each containing a target, value, data, and "signature"
(not in the digital signature sense, but the function signature sense, for tooling). `GovernorBravo`
takes each of these as separate arrays, making proposal specification unwieldy. We define a data
type which encapsulates these actions more cleanly, as well as provide a function to transform it
into the input that `GovernorBravo` can accept.

Each action requires contract addresses across networks for calling. At the time of writing, this is
fragmented with no importable source of truth. In time, this will be defined in an external
repository with stricter validation & uniformity checking. For now, we implement a collection of
data types & constants which scope, by name, contracts across networks in the protocol; which gives
us portability across proposals instead of re-hard coding them each proposal.

Each action that interacts with remote chains requires the target chain ID, the bridge used to send
the message to the target chain, the target chain infrastructure to receive the message, and in some
cases, it requires bridge-defined "chain identifier" values, which are unrelated to the "chain ID".
At the time of writing, this is bespoke for every chain. We define constants and encoders (TODO) for
each bridge type.

Each action requires a handoff to Uniswap Foundation's "Governance Seatbelt" system, which performs
rich multichain call validation. At the time of writing, this must be implemented independent of the
proposal as written in Solidity and, at times, is the platform through which the proposal is
executed to begin with. We implement an exporter (TODO) in JSON which can be imported into the
seatbelt program to be interpreted in a more uniform & automated way.

Some actions require prerequisite deployments & configurations before the proposal can run. So far
we have primarily relied purely on Foundry's scripting output files (`broadcast/`) or Foundry's
`console` logging contract to get newly deployed addresses. Foundry's scripting is fragile, it is
difficult to recover from mid-flight RPC failures, logging is insufficient, and broadcast JSON
outputs are infeasible to parse via its `Vm` JSON API, its cheatcode abstraction to read broadcast
files is incompatible with its newest JSON structure, and referencing transactions by index is not
consistent, as external libraries incur implicit transactions which break indices & library
deployments are difficult to automate. So we implement a recorder data type which can record
contract addresses, names, and chain ID's to disk in a clean and easy to interpret JSON file, stored
in `.records/`. This is not perfect and is quite rudimentary, but can get us far with complex script
dependency graphs, reporting new contract addresses, and automation for other inventory-related
infrastructure.

> While external libraries are anti-patterns and we generally avoid them, there have been cases
> where we had to deploy bridge infrastructure using external teams' code which embedded external
> libraries.

Also, at times, proxy contracts must be used and dealt with, primarily those of ERC-1967. We provide
a lightweight utility for handling these.

## ProposalAction

Fairly straight forward, it encapsulates actions & allows them to generate governor bravo inputs.
This is a recurring abstraction in previous proposals.

```solidity
import {ProposalAction} from "lib/govkit/src/types/ProposalAction.sol";

ProposalAction[] memory actions = new ProposalAction[](1);

actions[0] = ProposalAction({
    target: token,
    value: 0,
    signature: "transfer(address,uint256)",
    data: abi.encodeCall(ERC20.transfer, (receiver, amount))
});

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
import {Protocol} from "lib/govkit/src/Protocol.sol";
import {ProposalAction} from "lib/govkit/src/types/ProposalAction.sol";
import {WormholeChainId} from "lib/govkit/src/constants/WormholeChainId.sol";

Protocol internal uniswap;

uniswap.loadLatest();


ProposalAction[] memory actions = new ProposalAction[](1);

actions[0] = ProposalAction({
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
});
```

This also makes testing environments more flexible for protocol mocking.

```solidity
import {Protocol} from "lib/govkit/src/Protocol.sol";

contract MockGovernorBravo {
    // ...
}

Protocol internal uniswap;

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
deduplicates code & streamlines seatbelt usage.

Sketch of the JSON API:

```solidity
import {ProposalAction} from "lib/govkit/src/types/ProposalAction.sol";

string memory seatbeltInputPath = "...";
ProposalAction[] memory actions = new ProposalAction[](1);

actions[0] = ProposalAction({
    target: token,
    value: 0,
    signature: "transfer(address,uint256)",
    data: abi.encodeCall(ERC20.transfer, (receiver, amount))
});

vm.writeJson(seatbeltInputPath, actions.toJson());
```

## Contract Logging

In short, Foundry's native broadcast handling is fragile, unwieldy, and its internal API for
interacting with it is broken. So we're using `Recorder` to record addresses as they're deployed.

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

// Deploy the contract & record it.
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

Output:

```json
// .records/MyScript.json
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
import {Protocol} from "lib/govkit/src/Protocol.sol";

Protocol internal uniswap;
uniswap.loadLatest();

import {ERC1967Reader} from "lib/govkit/src/forge/ERC1967Reader.sol";

address proxy = uniswap.ethereum.bridge.bnbChain;

address admin = ERC1967Reader.admin(proxy);
address beacon = ERC1967Reader.beacon(proxy);
address implementation = ERC1967Reader.implementation(proxy);
```

## TODO's

- Bridge Encoder
- Proposal Exporter
- Conditional deployer
