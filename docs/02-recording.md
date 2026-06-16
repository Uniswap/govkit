# Recording

Some proposals require prerequisite deployments and configuration before the
proposal itself can run, and those scripts often have to run separately from one
another. When a later script needs an address that an earlier script deployed,
we need somewhere durable to keep it.

So far we have relied on Foundry's broadcast output files (`broadcast/`) or
Foundry's `console` logging to recover newly deployed addresses. In practice
Foundry's native broadcast handling is fragile, unwieldy, and its internal API
for interacting with it is broken.

The `Recorder` type records contract addresses, names, and chain IDs to a clean,
easy-to-read JSON file under `.records/`. Records are keyed by chain ID and then
by name, so any subsequent script can read an address back by the same name.

## When & Why to Use It

Reach for the `Recorder` when a proposal spans multiple scripts and a later step
depends on an address produced by an earlier one — typically prerequisite
deployments that have to land before the proposal can be submitted. It gives you
a stable handle (`chainId` + `name`) instead of copying addresses by hand or
parsing broadcast artifacts.

It also makes mid-script failure recovery practical: a script can check whether a
contract was already recorded and skip redeploying it.

## Setup

The recorder writes to and reads from `.records/`, so Foundry needs read-write
permission for that path. Add it to `foundry.toml`:

```toml
fs_permissions = [
  { access = "read-write", path = ".records/" }
]
```

> If permissions are missing, `initialize` surfaces a clear error pointing at
> this exact `fs_permissions` entry.

## Usage

Initialize the recorder with the name of the script it lives in. The name
determines the record file (`.records/<scriptName>.json`).

`debugMode` performs excessive `STDOUT` logging before each VM action that might
fail. Because Foundry's file I/O API is unintuitive and clunky, this makes it
much clearer where things went wrong if they do, and fills in contextual gaps
for future proposal writers. There is also an overload that omits `debugMode`
(it defaults to `false`).

```solidity
import {Recorder} from "lib/govkit/src/forge/Recorder.sol";
import {ChainId} from "lib/govkit/src/constants/ChainId.sol";

Recorder internal recorder;

// Initialize with the script name.
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
address loadedMyContract = recorder.read(ChainId.Ethereum, "MyContract");

// (Optional): Clear the record.
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

> `write` also has an overload that omits the chain ID and uses the current
> chain (`vm.getChainId()`). All of `write`, `read`, `exists`, and `clear`
> require `initialize` to have been called first.

## Conditional Deployments

Because the record persists across runs, you can guard a deployment on whether
it has already happened. This is what makes mid-script failure recovery work:
re-running the script skips anything already recorded.

> `exists` is **not** required before `read` — it exists specifically for
> conditional deployment guards like this one.

```solidity
import {Recorder} from "lib/govkit/src/forge/Recorder.sol";
import {ChainId} from "lib/govkit/src/constants/ChainId.sol";

Recorder internal recorder;

if (!recorder.exists(ChainId.Ethereum, "MyContract")) {
    recorder.write(
        ChainId.Ethereum,
        "MyContract",
        address(new MyContract())
    );
}
```

`clear` removes the entire `.records/` directory if it exists, and is a no-op
otherwise. Use it to reset state between unrelated runs.
</content>
