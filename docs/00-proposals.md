# Proposals

## Simple Proposals

Proposals require a description and a series of calls, each containing a target,
value, and data.

We define the `Proposal` type to capture this and the `Call` type for the calls
to be made.

> As an ergonomic feature, we also include `LibCall`, which contains `newCalls`
> functions for making the array of calls more readable when writing a proposal.

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
```

`GovernorBravo` accepts a proposal as separate arrays of targets, values,
signatures, and datas, which makes proposal specification unwieldy. The
`Proposal` type encapsulates these actions more cleanly; transforming it back
into `GovernorBravo`'s inputs is covered in [Exporting](./03-exporting.md).

## Contract Addresses

Each call needs the address of the contract it targets, and those addresses are
fragmented across networks with no importable source of truth. We define a
collection of types and constants that scope, by name, the protocol's contracts
across networks. This gives us portability across proposals instead of
re-hard-coding addresses each time.

The `Uniswap` type holds every network's addresses. Call `loadLatest` to
populate it with the protocol's current deployments.

> `loadLatest` currently hard-codes the addresses. In the future this should
> import them from a unified source of truth.

```solidity
import {Uniswap} from "lib/govkit/src/types/Uniswap.sol";
import {Proposal} from "lib/govkit/src/types/Proposal.sol";
import {Call, LibCall} from "lib/govkit/src/types/Call.sol";

Uniswap internal uniswap;
uniswap.loadLatest();

Proposal memory proposal = Proposal({
    description: "# Activate Fee Switch V2+V3 on Ethereum ....",
    calls: LibCall.newCalls([
        Call({
            target: uniswap.ethereum.v2Factory,
            value: 0,
            data: abi.encodeCall(
                IUniswapV2Factory.setFeeTo,
                (uniswap.ethereum.tokenJar)
            )
        }),
        Call({
            target: uniswap.ethereum.v3Factory,
            value: 0,
            data: abi.encodeCall(
                IUniswapV3Factory.setOwner,
                (uniswap.ethereum.v3OpenFeeAdapter)
            )
        })
    ])
});
```

Because addresses live in plain struct fields, this also makes testing
environments more flexible for protocol mocking. Any address can be overridden
before the proposal is built.

```solidity
import {Uniswap} from "lib/govkit/src/types/Uniswap.sol";

contract MockGovernorBravo {
    // ...
}

Uniswap internal uniswap;

uniswap.ethereum.governorBravo = address(new MockGovernorBravo());
```
</content>
</invoke>
