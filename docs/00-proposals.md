# Proposals

## Simple Proposals

Proposals require a description and a series of calls, each containing a target,
value, and data.

We define the `Proposal` type to capture this and the `Call` type for the calls
to be made.

> As an ergonomic feature, we also include `LibCall`, which contains `newCalls`
> functions for making the array of calls more readable when writing a proposal.

```solidity
import {Proposal} from "govkit/types/Proposal.sol";
import {Call, LibCall} from "lib/";

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

## Multichain Proposals

Multichain proposals are complex, often the calls at the top level of the
`Proposal` are bridge calls where the actual actions to take on the respective
remote network are encoded into the bridge call in arbitrary ways. We implement
encoders for all relevant, persistent bridges used in proposal writing. Each
contains a namespaced `encode` function, some of which use ad-hoc polymorphism
to allow for reasonable defaults on parameters like gas limits while allowing a
proposal writer to override them in the event they need more granularity.

### Polygon

Polygon uses an `FxRoot` system for sending proposals.

The Polygon `FxRoot`/`FxChild` system requires Uniswap's `Timelock` to call
Polygon's `FxRoot` on Ethereum, then Polygon's FxChild calls Uniswap's EthereumProxy
(receiver contract), which then runs calls against the protocol on Polygon.
