# Reference

## Directory Structure

```
src/
├── bridges/                                # Bridge Encoders
│   ├── FxRootEncoder.sol                   #   - Polygon
│   ├── InboxEncoder.sol                    #   - Arbitrum Orbit
│   ├── L1CrossDomainMessengerEncoder.sol   #   - OP Stack (CrossChainAccount)
│   ├── OptimismPortal2Encoder.sol          #   - OP Stack (OptimismPortal)
│   └── WormholeEncoder.sol                 #   - All chains with Wormhole
│
├── constants/                              # Constants
│   ├── ChainId.sol                         #   - Canonical chain ID's (EIP-155)
│   ├── ERC1967.sol                         #   - ERC-1967 slots
│   └── WormholeChainId.sol                 #   - Wormhole chain ID's
│
├── forge/                                  # Forge Logic
│   ├── Constants.sol                       #   - Forge constants
│   ├── ERC1967Reader.sol                   #   - ERC-1967 slot reader
│   ├── GovernanceSeatbelt.sol              #   - Governance Seatbelt exporter
│   └── Recorder.sol                        #   - Contract deployment recorder
│
├── interfaces/                             # Interfaces
│   ├── bridges/                            #   - Bridge-specific
│   └── ...                                 #   - All others
│
└── types/                                  # Data Types
    ├── Call.sol                            #   - External call/action
    ├── Networks.sol                        #   - Network deployments
    ├── Proposal.sol                        #   - Governance proposal
    └── Uniswap.sol                         #   - All network+bridge addresses
```

## Bridge Encoders

### `FxRootEncoder.sol`

Import:

```solidity
import {FxRootEncoder} from "lib/govkit/src/bridges/FxRootEncoder.sol";
```

API:

```solidity
library FxRootEncoder {
    function encode(
        address fxRoot,
        address fxReceiver,
        uint256 value,
        Call[] memory remoteCalls
    )
        internal
        pure
        returns (Call memory);
}
```

## Constants

## Forge Logic

## Interfaces

## Data Types
