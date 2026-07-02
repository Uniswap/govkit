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
    address blast;
    address bnbChain;
    address celo;
    address ink;
    address megaEth;
    address linea;
    address monad;
    address optimism;
    address polygon;
    address rootStock;
    address soneium;
    address tempo;
    address uniChain;
    address worldChain;
    address xLayer;
    address zora;
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
    address wormholeCore;
    address wormholeReceiver;
}

struct Base {
    address v2Factory;
    address v3Factory;
    address poolManager;
    address v3OpenFeeAdapter;
    address tokenJar;
    address releaser;
    address releaserUni;
    address crossChainAccount;
}

struct Blast {
    address v2Factory;
    address v3Factory;
    address poolManager;
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
    address crossChainAccount;
}

struct Ink {
    address v2Factory;
    address v3Factory;
    address poolManager;
    address crossChainAccount;
}

struct MegaEth {
    address v2Factory;
    address v3Factory;
    address poolManager;
    address wormholeCore;
    address wormholeReceiver;
}

struct Linea {
    address v2Factory;
    address v3Factory;
    address poolManager;
    address crossChainAccountLinea;
}

struct Monad {
    address v2Factory;
    address v3Factory;
    address poolManager;
    address wormholeCore;
    address wormholeReceiver;
}

struct Optimism {
    address v2Factory;
    address v3Factory;
    address poolManager;
    address v3OpenFeeAdapter;
    address tokenJar;
    address releaser;
    address releaserUni;
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

struct RootStock {
    address v3Factory;
    address wormholeCore;
    address wormholeReceiver;
}

struct Soneium {
    address v2Factory;
    address v3Factory;
    address poolManager;
    address v3OpenFeeAdapter;
    address tokenJar;
    address releaser;
    address releaserUni;
    address crossChainAccount;
}

struct Tempo {
    address v2Factory;
    address v3Factory;
    address poolManager;
    address wormholeCore;
    address wormholeReceiver;
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

struct XLayer {
    address v2Factory;
    address v3Factory;
    address poolManager;
    address v3OpenFeeAdapter;
    address tokenJar;
    address releaser;
    address releaserUni;
    address crossChainAccount;
}

struct Zora {
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
