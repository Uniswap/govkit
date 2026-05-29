// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

struct Ethereum {
    address uni;
    address governorBravo;
    address timelock;
    address v2Factory;
    address v3Factory;
    address poolManager;
    address v3OpenFeeAdapter;
    address tokenJar;
    address releaser;
    EthereumBridgeSender bridge;
}

struct EthereumBridgeSender {
    address arbitrum;
    address avalanche;
    address base;
    address bnbChain;
    address celo;
    address optimism;
    address polygon;
    address uniChain;
    address worldChain;
    address wormholeCore;
}

struct Arbitrum {
    address v2Factory;
    address v3Factory;
    address poolManager;
    address v3OpenFeeAdapter;
    address tokenJar;
    address releaser;
    address releaserUni;
}

struct Avalanche {
    address v2Factory;
    address v3Factory;
    address poolManager;
}

struct Base {
    address v2Factory;
    address v3Factory;
    address poolManager;
    address v3OpenFeeAdapter;
    address tokenJar;
    address releaser;
    address releaserUni;
    address crossDomainMessenger;
    address crossChainAccount;
}

struct BNBChain {
    address v2Factory;
    address v3Factory;
    address poolManager;
    address v3OpenFeeAdapter;
    address tokenJar;
    address releaser;
    address releaserUni;
    address wormholeCore;
    address wormholeReceiver;
}

struct Celo {
    address v2Factory;
    address v3Factory;
    address poolManager;
    address v3OpenFeeAdapter;
    address tokenJar;
    address releaser;
    address releaserUni;
    address crossDomainMessenger;
    address crossChainAccount;
}

struct Optimism {
    address v2Factory;
    address v3Factory;
    address poolManager;
    address v3OpenFeeAdapter;
    address tokenJar;
    address releaser;
    address releaserUni;
    address crossDomainMessenger;
    address crossChainAccount;
}

struct Polygon {
    address v2Factory;
    address v3Factory;
    address poolManager;
    address v3OpenFeeAdapter;
    address tokenJar;
    address releaser;
    address releaserUni;
    address fxReceiver;
}

struct UniChain {
    address v2Factory;
    address v3Factory;
    address poolManager;
    address tokenJar;
    address releaser;
    address releaserUni;
}

struct WorldChain {
    address v2Factory;
    address v3Factory;
    address poolManager;
    address v3OpenFeeAdapter;
    address tokenJar;
    address releaser;
    address releaserUni;
    address crossChainAccount;
}

// Placeholder to avoid Solidity compiler warning:
//
// Warning: AST source not found for <project_root>/src/Networks.sol
library __ {}

