// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

import {
    Ethereum,
    EthereumBridgeSender,
    Arbitrum,
    Avalanche,
    Base,
    BNBChain,
    Celo,
    Optimism,
    Polygon,
    UniChain,
    WorldChain
} from "src/types/Networks.sol";

// -------------------------------------------------------------------------------------------------
// The Uniswap Protocol
//
/// @dev Uniswap Protocol Addresses
struct Uniswap {
    Ethereum ethereum;
    Arbitrum arbitrum;
    Avalanche avalanche;
    Base base;
    BNBChain bnbChain;
    Celo celo;
    Optimism optimism;
    Polygon polygon;
    UniChain uniChain;
    WorldChain worldChain;
}

using LibUniswap for Uniswap global;

/// @title Uniswap Protocol Library
/// @dev Primarily used for loading addresses into the Uniswap type.
library LibUniswap {
    /// @dev Loads all relevant addresses into the Uniswap type. In the future,
    ///      this should be importing addresses from a unified source of truth.
    /// @param uniswap Uniswap type stored in the local state for easy access.
    function loadLatest(Uniswap storage uniswap) internal {
        // -----------------------------------------------------------------------------------------
        // Ethereum
        //
        uniswap.ethereum = Ethereum({
            uni: 0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984,
            governorBravo: 0x408ED6354d4973f66138C91495F2f2FCbd8724C3,
            timelock: 0x1a9C8182C09F50C8318d769245beA52c32BE35BC,
            v2Factory: 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f,
            v3Factory: 0x1F98431c8aD98523631AE4a59f267346ea31F984,
            poolManager: 0x000000000004444c5dc75cB358380D2e3dE08A90,
            v3OpenFeeAdapter: 0xf2371551Fe3937Db7c750f4DfABe5c2fFFdcBf5A,
            tokenJar: 0xf38521f130fcCF29dB1961597bc5d2B60F995f85,
            releaser: 0x0D5Cd355e2aBEB8fb1552F56c965B867346d6721,
            bridge: EthereumBridgeSender({
                arbitrum: 0x4Dbd4fc535Ac27206064B68FfCf827b0A60BAB3f,
                avalanche: 0xeb0BCF27D1Fb4b25e708fBB815c421Aeb51eA9fc,
                base: 0x866E82a600A1414e583f7F13623F1aC5d58b0Afa,
                bnbChain: 0xf5F4496219F31CDCBa6130B5402873624585615a,
                celo: 0x1AC1181fc4e4F877963680587AEAa2C90D7EbB95,
                optimism: 0x25ace71c97B33Cc4729CF772ae268934F7ab5fA1,
                polygon: 0xfe5e5D361b2ad62c541bAb87C45a0B9B018389a2,
                uniChain: 0x9A3D64E386C18Cb1d6d5179a9596A4B5736e98A6,
                worldChain: 0xf931a81D18B1766d15695ffc7c1920a62b7e710a,
                wormholeCore: 0x98f3c9e6E3fAce36bAAd05FE09d375Ef1464288B
            })
        });

        // -----------------------------------------------------------------------------------------
        // Arbitrum
        //
        uniswap.arbitrum = Arbitrum({
            v2Factory: 0xf1D7CC64Fb4452F05c498126312eBE29f30Fbcf9,
            v3Factory: 0x1F98431c8aD98523631AE4a59f267346ea31F984,
            poolManager: 0x360E68faCcca8cA495c1B759Fd9EEe466db9FB32,
            v3OpenFeeAdapter: 0xFF7aD5dA31fECdC678796c88B05926dB896b0699,
            tokenJar: 0x95E337C5B155385945D407f5396387D0c2a3A263,
            releaser: 0xB8018422bcE25D82E70cB98FdA96a4f502D89427,
            releaserUni: 0xFa7F8980b0f1E64A2062791cc3b0871572f1F7f0
        });

        // -----------------------------------------------------------------------------------------
        // Avalanche
        //
        uniswap.avalanche = Avalanche({
            v2Factory: 0x9e5A52f57b3038F1B8EeE45F28b3C1967e22799C,
            v3Factory: 0x740b1c1de25031C31FF4fC9A62f554A55cdC1baD,
            poolManager: 0x06380C0e0912312B5150364B9DC4542BA0DbBc85
        });

        // -----------------------------------------------------------------------------------------
        // Base
        //
        uniswap.base = Base({
            v2Factory: 0x8909Dc15e40173Ff4699343b6eB8132c65e18eC6,
            v3Factory: 0x33128a8fC17869897dcE68Ed026d694621f6FDfD,
            poolManager: 0x498581fF718922c3f8e6A244956aF099B2652b2b,
            v3OpenFeeAdapter: 0xaBEA76658b205696d49B5F91b2a03536cB8A3bE1,
            tokenJar: 0x9bD25e67bF390437C8fAF480AC735a27BcF6168c,
            releaser: 0xFf77c0ED0B6b13A20446969107E5867abc46f53a,
            releaserUni: 0xc3De830EA07524a0761646a6a4e4be0e114a3C83,
            crossDomainMessenger: 0x4200000000000000000000000000000000000007,
            crossChainAccount: 0x31FAfd4889FA1269F7a13A66eE0fB458f27D72A9
        });

        // -----------------------------------------------------------------------------------------
        // BNB Chain
        //
        uniswap.bnbChain = BNBChain({
            v2Factory: 0x8909Dc15e40173Ff4699343b6eB8132c65e18eC6,
            v3Factory: 0xdB1d10011AD0Ff90774D0C6Bb92e5C5c8b4461F7,
            poolManager: 0x28e2Ea090877bF75740558f6BFB36A5ffeE9e9dF,
            v3OpenFeeAdapter: 0x3F07F08b45912dCd6691C5B9412975D5113B2910,
            tokenJar: 0xc6Ae6373CEcc9e595A6C8b9fe581925a8c84f70A,
            releaser: 0xa59FfbB55D91Fc32b44A06F0b9cc6036a4afbcE2,
            releaserUni: 0x06e8bdE95BE4ce5cB1134BD47aD18a79fFB35822,
            wormholeCore: 0x98f3c9e6E3fAce36bAAd05FE09d375Ef1464288B,
            wormholeReceiver: 0x341c1511141022cf8eE20824Ae0fFA3491F1302b
        });

        // -----------------------------------------------------------------------------------------
        // Celo
        //
        uniswap.celo = Celo({
            v2Factory: 0x114A43DF6C5f54EBB8A9d70Cd1951D3dD68004c7,
            v3Factory: 0xAfE208a311B21f13EF87E33A90049fC17A7acDEc,
            poolManager: 0x288dc841A52FCA2707c6947B3A777c5E56cd87BC,
            v3OpenFeeAdapter: 0xB9952C01830306ea2fAAe1505f6539BD260Bfc48,
            tokenJar: 0x190c22c5085640D1cB60CeC88a4F736Acb59bb6B,
            releaser: 0x2758FbaA228D7d3c41dD139F47dab1a27bF9bc25,
            releaserUni: 0xd7493e84a060292CDca6B67619402F7702336bF4,
            crossDomainMessenger: 0x4200000000000000000000000000000000000007,
            crossChainAccount: 0x044aAF330d7fD6AE683EEc5c1C1d1fFf5196B6b7
        });

        // -----------------------------------------------------------------------------------------
        // Optimism
        //
        uniswap.optimism = Optimism({
            v2Factory: 0x0c3c1c532F1e39EdF36BE9Fe0bE1410313E074Bf,
            v3Factory: 0x1F98431c8aD98523631AE4a59f267346ea31F984,
            poolManager: 0x9a13F98Cb987694C9F086b1F5eB990EeA8264Ec3,
            v3OpenFeeAdapter: 0xec23Cf5A1db3dcC6595385D28B2a4D9B52503Be4,
            tokenJar: 0xb13285DF724ea75f3f1E9912010B7e491dCd5EE3,
            releaser: 0x94460443Ca27FFC1baeCa61165fde18346C91AbD,
            releaserUni: 0x6fd9d7AD17242c41f7131d257212c54A0e816691,
            crossDomainMessenger: 0x4200000000000000000000000000000000000007,
            crossChainAccount: 0xa1dD330d602c32622AA270Ea73d078B803Cb3518
        });

        // -----------------------------------------------------------------------------------------
        // Polygon
        //
        uniswap.polygon = Polygon({
            v2Factory: 0x9e5A52f57b3038F1B8EeE45F28b3C1967e22799C,
            v3Factory: 0x1F98431c8aD98523631AE4a59f267346ea31F984,
            poolManager: 0x67366782805870060151383F4BbFF9daB53e5cD6,
            v3OpenFeeAdapter: 0x3F07F08b45912dCd6691C5B9412975D5113B2910,
            tokenJar: 0xc6Ae6373CEcc9e595A6C8b9fe581925a8c84f70A,
            releaser: 0xa59FfbB55D91Fc32b44A06F0b9cc6036a4afbcE2,
            releaserUni: 0x06e8bdE95BE4ce5cB1134BD47aD18a79fFB35822,
            fxReceiver: 0x8a1B966aC46F42275860f905dbC75EfBfDC12374
        });

        // -----------------------------------------------------------------------------------------
        // UniChain
        //
        uniswap.uniChain = UniChain({
            v2Factory: 0x1F98400000000000000000000000000000000002,
            v3Factory: 0x1F98400000000000000000000000000000000003,
            poolManager: 0x1F98400000000000000000000000000000000004,
            tokenJar: 0xD576BDF6b560079a4c204f7644e556DbB19140b5,
            releaser: 0xe0A780E9105aC10Ee304448224Eb4A2b11A77eeB,
            releaserUni: 0x8f187aA05619a017077f5308904739877ce9eA21
        });

        // -----------------------------------------------------------------------------------------
        // WorldChain
        //
        uniswap.worldChain = WorldChain({
            v2Factory: 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f,
            v3Factory: 0x7a5028BDa40e7B173C278C5342087826455ea25a,
            poolManager: 0xb1860D529182ac3BC1F51Fa2ABd56662b7D13f33,
            v3OpenFeeAdapter: 0x1CE9d4DfB474Ef9ea7dc0e804a333202e40d6201,
            tokenJar: 0xbDb82c2dE7D8748A3e499e771604ef8ef8544918,
            releaser: 0x455e844D286631566cF98D6cb2996149734618C6,
            releaserUni: 0x1CE9d4DfB474Ef9ea7dc0e804a333202e40d6201,
            crossChainAccount: 0xcb2436774C3e191c85056d248EF4260ce5f27A9D
        });
    }
}
