// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

import {
    Ethereum,
    EthereumBridgeSender,
    Arbitrum,
    Avalanche,
    Base,
    Blast,
    BNBChain,
    Celo,
    Ink,
    MegaEth,
    Linea,
    Monad,
    Optimism,
    Polygon,
    RootStock,
    Soneium,
    Tempo,
    UniChain,
    XLayer,
    WorldChain,
    Zora
} from "./Networks.sol";

// -------------------------------------------------------------------------------------------------
// The Uniswap Protocol
//
/// @dev Uniswap Protocol Addresses
struct Uniswap {
    Ethereum ethereum;
    Arbitrum arbitrum;
    Avalanche avalanche;
    Base base;
    Blast blast;
    BNBChain bnbChain;
    Celo celo;
    Ink ink;
    MegaEth megaEth;
    Linea linea;
    Monad monad;
    Optimism optimism;
    Polygon polygon;
    RootStock rootStock;
    Soneium soneium;
    Tempo tempo;
    UniChain uniChain;
    WorldChain worldChain;
    XLayer xLayer;
    Zora zora;
}

using LibUniswap for Uniswap global;

/// @title Uniswap Protocol Library
/// @dev Primarily used for loading addresses into the Uniswap type.
/// @dev WARNING: LINEA DOES NOT HAVE AN ENCODER. This is beyond the V1 scope.
library LibUniswap {
    address internal constant UNIMPLEMENTED = address(0x00);

    /// @dev Loads all relevant addresses into the Uniswap type. In the future,
    ///      this should be importing addresses from a unified source of truth.
    /// @param uniswap Uniswap type stored in the local state for easy access.
    function loadLatest(Uniswap storage uniswap) internal {
        // -----------------------------------------------------------------------------------------
        // Ethereum
        //
        // Note: crossChainAccountLinea UNIMPLEMENTED
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
                avalanche: 0xf5F4496219F31CDCBa6130B5402873624585615a,
                base: 0x866E82a600A1414e583f7F13623F1aC5d58b0Afa,
                blast: 0x5D4472f31Bd9385709ec61305AFc749F0fA8e9d0,
                bnbChain: 0xf5F4496219F31CDCBa6130B5402873624585615a,
                celo: 0x1AC1181fc4e4F877963680587AEAa2C90D7EbB95,
                ink: 0x69d3Cf86B2Bf1a9e99875B7e2D9B6a84426c171f,
                megaEth: 0xf5F4496219F31CDCBa6130B5402873624585615a,
                linea: UNIMPLEMENTED,
                monad: 0xf5F4496219F31CDCBa6130B5402873624585615a,
                optimism: 0x25ace71c97B33Cc4729CF772ae268934F7ab5fA1,
                polygon: 0xfe5e5D361b2ad62c541bAb87C45a0B9B018389a2,
                rootStock: 0xf5F4496219F31CDCBa6130B5402873624585615a,
                soneium: 0x9CF951E3F74B644e621b36Ca9cea147a78D4c39f,
                tempo: 0xf5F4496219F31CDCBa6130B5402873624585615a,
                uniChain: 0x0bd48f6B86a26D3a217d0Fa6FfE2B491B956A7a2,
                worldChain: 0xf931a81D18B1766d15695ffc7c1920a62b7e710a,
                xLayer: 0xF94B553F3602a03931e5D10CaB343C0968D793e3,
                zora: 0xdC40a14d9abd6F410226f1E6de71aE03441ca506,
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
            poolManager: 0x06380C0e0912312B5150364B9DC4542BA0DbBc85,
            wormholeCore: 0x54a8e5f9c4CbA08F9943965859F6c34eAF03E26c,
            wormholeReceiver: 0x47eB0Cf11a1626462Da3C830bCDe64c3F582B5a6
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
            crossChainAccount: 0x31FAfd4889FA1269F7a13A66eE0fB458f27D72A9
        });

        // -----------------------------------------------------------------------------------------
        // Blast
        //
        uniswap.blast = Blast({
            v2Factory: 0x5C346464d33F90bABaf70dB6388507CC889C1070,
            v3Factory: 0x792edAdE80af5fC680d96a2eD80A44247D2Cf6Fd,
            poolManager: 0x1631559198A9e474033433b2958daBC135ab6446,
            crossChainAccount: 0x2339C0d23b60739B3E5ABF201F05903D24A26C77
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
            crossChainAccount: 0x044aAF330d7fD6AE683EEc5c1C1d1fFf5196B6b7
        });

        // -----------------------------------------------------------------------------------------
        // Ink
        //
        uniswap.ink = Ink({
            v2Factory: 0xfe57A6BA1951F69aE2Ed4abe23e0f095DF500C04,
            v3Factory: 0x640887A9ba3A9C53Ed27D0F7e8246A4F933f3424,
            poolManager: 0x360E68faCcca8cA495c1B759Fd9EEe466db9FB32,
            crossChainAccount: 0x66c5D722Fc52671c7F839BBbF752BC38E0520B91
        });

        // -----------------------------------------------------------------------------------------
        // Linea
        //
        uniswap.linea = Linea({
            v2Factory: 0x114A43DF6C5f54EBB8A9d70Cd1951D3dD68004c7,
            v3Factory: 0x31FAfd4889FA1269F7a13A66eE0fB458f27D72A9,
            poolManager: 0x248083Fb965359d82b06C1F5322480Dcfc1AD857,
            crossChainAccountLinea: 0x581F86Da293A1D5Cd087a10E7227a75d2d2201A8
        });

        // -----------------------------------------------------------------------------------------
        // MegaETH
        //
        uniswap.megaEth = MegaEth({
            v2Factory: 0xbf56488c857A881ae7e3BED27Cf99c10A7Ab7e50,
            v3Factory: 0x3a5F0CD7d62452b7f899B2A5758BFa57be0dE478,
            poolManager: 0xaCB7e78fa05D562e0A5D3089ec896D57D057d38E,
            wormholeCore: 0xaBf89de706B583424328B54dD05a8fC986750Da8,
            wormholeReceiver: 0xa107580F73BD797Bd8b87Ff24e98346D99F93DdB
        });

        // -----------------------------------------------------------------------------------------
        // Monad
        //
        uniswap.monad = Monad({
            v2Factory: 0x182a927119D56008d921126764bF884221b10f59,
            v3Factory: 0x204FAca1764B154221e35c0d20aBb3c525710498,
            poolManager: 0x188d586Ddcf52439676Ca21A244753fA19F9Ea8e,
            wormholeCore: 0x194B123c5E96B9b2E49763619985790Dc241CAC0,
            wormholeReceiver: 0xE783DE89a7F0408687f051e3E6D0BEb62719EbAd
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
        // RootStock
        //
        uniswap.rootStock = RootStock({
            v3Factory: 0xaF37EC98A00FD63689CF3060BF3B6784E00caD82,
            wormholeCore: 0xbebdb6C8ddC678FfA9f8748f85C815C556Dd8ac6,
            wormholeReceiver: 0x38aE7De6f9c51e17f49cF5730DD5F2d29fa20758
        });

        // -----------------------------------------------------------------------------------------
        // Soneium
        //
        uniswap.soneium = Soneium({
            v2Factory: 0x97FeBbC2AdBD5644ba22736E962564B23F5828CE,
            v3Factory: 0x42aE7Ec7ff020412639d443E245D936429Fbe717,
            poolManager: 0x360E68faCcca8cA495c1B759Fd9EEe466db9FB32,
            v3OpenFeeAdapter: 0x47Cf920815344Fd684A48BBEFcbfbed9C7AE09CF,
            tokenJar: 0x85aeb792b94a9d79741002FC871423Ec5dAD29e9,
            releaser: 0xc9CC50A75cE2a5f88fa77B43e3b050480c731b6e,
            releaserUni: 0x8f187aA05619a017077f5308904739877ce9eA21,
            crossChainAccount: 0x044aAF330d7fD6AE683EEc5c1C1d1fFf5196B6b7
        });

        // -----------------------------------------------------------------------------------------
        // Tempo
        //
        uniswap.tempo = Tempo({
            v2Factory: 0xf9EC577a4E45B5278BB7Cf60FCBc20c3acAef68f,
            v3Factory: 0x24a3d4757E330890A8b8978028c9e58E04611fd6,
            poolManager: 0x33620f62C5b9B2086dD6b62F4A297A9f30347029,
            wormholeCore: 0xbebdb6C8ddC678FfA9f8748f85C815C556Dd8ac6,
            wormholeReceiver: 0xCFB43dC56B55bE9611deD8384201cECf06A9811b
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
            releaserUni: 0x6fD31f56eb971113bEA12C5883deC68337b3B7b5,
            crossChainAccount: 0xcb2436774C3e191c85056d248EF4260ce5f27A9D
        });

        // -----------------------------------------------------------------------------------------
        // XLayer
        //
        uniswap.xLayer = XLayer({
            v2Factory: 0xDf38F24fE153761634Be942F9d859f3DBA857E95,
            v3Factory: 0x4B2ab38DBF28D31D467aA8993f6c2585981D6804,
            poolManager: 0x360E68faCcca8cA495c1B759Fd9EEe466db9FB32,
            v3OpenFeeAdapter: 0x6A88EF2e6511CAFfE2D006e260e7A5d1E7D4d7D7,
            tokenJar: 0x8Dd8B6D56e4a4A158EDbBfE7f2f703B8FFC1a754,
            releaser: 0xe122E231cb52aea99690963Fd73E91e33E97468f,
            releaserUni: 0x57FB37d035e6Ad0E687E0a50dC3F515691deB815,
            crossChainAccount: 0x044aAF330d7fD6AE683EEc5c1C1d1fFf5196B6b7
        });

        // -----------------------------------------------------------------------------------------
        // Zora
        //
        uniswap.zora = Zora({
            v2Factory: 0x0F797dC7efaEA995bB916f268D919d0a1950eE3C,
            v3Factory: 0x7145F8aeef1f6510E92164038E1B6F8cB2c42Cbb,
            poolManager: 0x0575338e4C17006aE181B47900A84404247CA30f,
            v3OpenFeeAdapter: 0xbfc49b47637a4DC9b7B8dE8E71BF41E519103B95,
            tokenJar: 0x4753C137002D802f45302b118E265c41140e73C2,
            releaser: 0x2f98eD4D04e633169FbC941BFCc54E785853b143,
            releaserUni: 0xE7798f023fC62146e8Aa1b36Da45fb70855a77Ea,
            crossChainAccount: 0x36eEC182D0B24Df3DC23115D64DB521A93D5154f
        });
    }
}
