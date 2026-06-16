# Multichain Proposals

A proposal that touches a remote chain cannot call the protocol there directly.
It must call a bridge contract on Ethereum, which delivers the message to
infrastructure on the target chain, which finally runs the call against the
protocol. Each bridge has its own delivery mechanism, its own contracts, and in
some cases its own "chain identifier" values that are unrelated to the EIP-155
chain ID.

We define an encoder per bridge type. Each encoder takes the remote `Call` you
actually want to run and wraps it into a single proposal-ready `Call` against
the appropriate bridge contract on Ethereum.

| Network    | Encoder                         |
| ---------- | ------------------------------- |
| Arbitrum   | `InboxEncoder`                  |
| Avalanche  | N/A (Transitioning)             |
| Base       | `L1CrossDomainMessengerEncoder` |
| BnbChain   | `WormholeEncoder`               |
| Celo       | `L1CrossDomainMessengerEncoder` |
| Optimism   | `L1CrossDomainMessengerEncoder` |
| Polygon    | `FxRootEncoder`                 |
| Soneium    | N/A (Transitioning)             |
| UniChain   | `OptimismPortal2Encoder`        |
| XLayer     | N/A (Transitioning)             |
| WorldChain | `OptimismPortal2Encoder`        |
| Zora       | `L1CrossDomainMessengerEncoder` |

## Chain Identifiers

Chain IDs in the EIP-155 sense (the intuitive sense) are defined together in the
`ChainId` library. Some bridges use their own chain identifier system, which is
unrelated to the EIP-155 chain ID; those are defined in their own libraries
(e.g. `WormholeChainId`).

> On principle, only `ChainId` values should appear in the top-level API. Each
> bridge's identifier has transformer functions to move between the two systems,
> and those transformations happen internally inside the encoders. You should
> rarely need the bridge-specific values directly.

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
    WormholeChainId.chainIdToWormholeChainId(ChainId.Ethereum),
    WormholeChainId.Ethereum
);

assertEq(
    WormholeChainId.wormholeChainIdtoChainId(WormholeChainId.Ethereum),
    ChainId.Ethereum
);
```

## Encoders

Every encoder exposes an `encode` function that returns a single proposal-ready
`Call`. Drop that `Call` into a `Proposal` just like a local one. Most encoders
provide an overload with sensible defaults (e.g. gas limit) and a fuller
overload that lets you set those values explicitly.

### `InboxEncoder` — Arbitrum

The Arbitrum Inbox system requires Uniswap's Timelock to call Arbitrum's Inbox
on Ethereum. Arbitrum then runs the transaction on its chain, originating from
the Timelock address plus Arbitrum's alias offset.

The default overload uses a `200_000` gas limit, a `0.1 gwei` max fee per gas,
and a `0.01 ether` max submission cost; a second overload accepts these
explicitly. The returned call carries enough value to cover
`(gasLimit * maxFeePerGas) + maxSubmissionCost + remoteCall.value`.

```solidity
import {InboxEncoder} from "lib/govkit/src/bridges/InboxEncoder.sol";

InboxEncoder.encode({
    inbox: uniswap.ethereum.bridge.arbitrum,
    timelock: uniswap.ethereum.timelock,
    remoteCall: Call({
        target: uniswap.arbitrum.v3Factory,
        value: 0,
        data: abi.encodeCall(
            IUniswapV3Factory.setOwner,
            (uniswap.arbitrum.v3OpenFeeAdapter)
        )
    })
});
```

### `L1CrossDomainMessengerEncoder` — OP Stack (Base, Celo, Optimism, Zora)

The `L1CrossDomainMessenger` is an abstraction on top of the OP Stack's core
`OptimismPortal`. Uniswap's Timelock calls the `L1CrossDomainMessenger` on
Ethereum, which uses the underlying `OptimismPortal` on Ethereum, which calls
Uniswap's `CrossChainAccount` on the OP Stack chain, which finally runs the call
against the protocol there.

The default overload uses a `200_000` gas limit. The remote call's value must be
zero — a non-zero value reverts with `NonzeroCallValue`.

```solidity
import {L1CrossDomainMessengerEncoder}
    from "lib/govkit/src/bridges/L1CrossDomainMessengerEncoder.sol";

L1CrossDomainMessengerEncoder.encode({
    l1CrossDomainMessenger: uniswap.ethereum.bridge.celo,
    crossChainAccount: uniswap.celo.crossChainAccount,
    remoteCall: Call({
        target: uniswap.celo.v2Factory,
        value: 0,
        data: abi.encodeCall(
            IUniswapV2Factory.setFeeTo,
            (uniswap.celo.tokenJar)
        )
    })
});
```

> This encoder forwards a single remote call. If you need to run several calls on
> the same OP Stack chain, encode each one as its own proposal call.

### `OptimismPortal2Encoder` — UniChain, WorldChain

`OptimismPortal2` is the OP Stack's core bridge contract. We call
`OptimismPortal2` on Ethereum, and the OP Stack chain then runs the transaction
originating from the Timelock plus OP's alias.

The default overload uses a `200_000` gas limit. Unlike the
`L1CrossDomainMessenger` path, the remote call's value is carried through, so
value-bearing calls are supported.

```solidity
import {OptimismPortal2Encoder}
    from "lib/govkit/src/bridges/OptimismPortal2Encoder.sol";

OptimismPortal2Encoder.encode({
    portal: uniswap.ethereum.bridge.uniChain,
    remoteCall: Call({
        target: uniswap.uniChain.v2Factory,
        value: 0,
        data: abi.encodeCall(
            IUniswapV2Factory.setFeeTo,
            (uniswap.uniChain.tokenJar)
        )
    })
});
```

### `FxRootEncoder` — Polygon

The Polygon FxRoot/FxChild system requires Uniswap's Timelock to call Polygon's
`FxRoot` on Ethereum. Polygon's `FxChild` then calls Uniswap's `FxReceiver` on
Polygon, which runs the calls against the protocol.

This encoder takes an array of remote calls and bundles them into a single
message. Each remote call's value must be zero — a non-zero value reverts with
`NonZeroValue`.

```solidity
import {FxRootEncoder} from "lib/govkit/src/bridges/FxRootEncoder.sol";

FxRootEncoder.encode({
    fxRoot: uniswap.ethereum.bridge.polygon,
    fxReceiver: uniswap.polygon.fxReceiver,
    remoteCalls: LibCall.newCalls([
        Call({
            target: uniswap.polygon.v2Factory,
            value: 0,
            data: abi.encodeCall(
                IUniswapV2Factory.setFeeTo,
                (uniswap.polygon.tokenJar)
            )
        }),
        Call({
            target: uniswap.polygon.v3Factory,
            value: 0,
            data: abi.encodeCall(
                IUniswapV3Factory.setOwner,
                (uniswap.polygon.v3OpenFeeAdapter)
            )
        })
    ])
});
```

### `WormholeEncoder` — BnbChain

The Wormhole system requires Uniswap's Timelock to call a Uniswap-authenticated
`WormholeSender` on Ethereum, which calls the `WormholeCore` on Ethereum.
Wormhole produces a "Verified Action Approval" (VAA), signed by its node set,
which must be **manually** relayed to Uniswap's `WormholeReceiver` on the remote
chain. The receiver validates the VAA against the remote `WormholeCore` and then
runs the calls against the protocol.

This encoder takes the canonical EIP-155 `chainId` and converts it to a Wormhole
chain ID internally. It accepts an array of remote calls, and remote call values
are carried through.

> The VAA relay is a manual, off-chain step — the proposal only initiates the
> message on Ethereum.
>
> Wormhole (or someone) will sometimes batch-relay messages on certain networks.
> When this happens, the `WormholeReceiver` increments its nonce (preventing a
> replay) but emits no observable event and produces no transaction on
> Etherscan-based explorers. If anyone then tries to forward the message again,
> they get an error that makes it look like delivery failed when it had in fact
> already executed.

```solidity
import {WormholeEncoder} from "lib/govkit/src/bridges/WormholeEncoder.sol";
import {ChainId} from "lib/govkit/src/constants/ChainId.sol";

WormholeEncoder.encode({
    sourceSender: uniswap.ethereum.bridge.bnbChain,
    remoteReceiver: uniswap.bnbChain.wormholeReceiver,
    chainId: ChainId.BNBChain,
    value: 0,
    remoteCalls: LibCall.newCalls([
        Call({
            target: uniswap.bnbChain.v2Factory,
            value: 0,
            data: abi.encodeCall(
                IUniswapV2Factory.setFeeTo,
                (uniswap.bnbChain.tokenJar)
            )
        }),
        Call({
            target: uniswap.bnbChain.v3Factory,
            value: 0,
            data: abi.encodeCall(
                IUniswapV3Factory.setOwner,
                (uniswap.bnbChain.v3OpenFeeAdapter)
            )
        })
    ])
});
```

## Putting it Together

Encoded calls are ordinary `Call`s, so a single proposal can mix local and
remote actions across multiple chains. Each encoded call slots into the same
`LibCall.newCalls([...])` array.

```solidity
Proposal memory proposal = Proposal({
    description: description,
    calls: LibCall.newCalls([
        // ---------------------------------------------------------------------
        // Set feeTo on Uniswap V2 factory on Celo.
        //
        L1CrossDomainMessengerEncoder.encode({
            l1CrossDomainMessenger: uniswap.ethereum.bridge.celo,
            crossChainAccount: uniswap.celo.crossChainAccount,
            remoteCall: Call({
                target: uniswap.celo.v2Factory,
                value: 0,
                data: abi.encodeCall(
                    IUniswapV2Factory.setFeeTo,
                    (uniswap.celo.tokenJar)
                )
            })
        }),
        // ---------------------------------------------------------------------
        // Set owner on Uniswap V3 factory on Celo.
        //
        L1CrossDomainMessengerEncoder.encode({
            l1CrossDomainMessenger: uniswap.ethereum.bridge.celo,
            crossChainAccount: uniswap.celo.crossChainAccount,
            remoteCall: Call({
                target: uniswap.celo.v3Factory,
                value: 0,
                data: abi.encodeCall(
                    IUniswapV3Factory.setOwner,
                    (uniswap.celo.v3OpenFeeAdapter)
                )
            })
        })
    ])
});
```
</content>
