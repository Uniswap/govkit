// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

import {LibCall, Call} from "src/types/Call.sol";
import {IWormholeSender} from "src/interfaces/bridges/IWormholeSender.sol";
import {WormholeEncoder} from "src/bridges/WormholeEncoder.sol";
import {ChainId} from "src/constants/ChainId.sol";
import {WormholeChainId} from "src/constants/WormholeChainId.sol";

import {Test, console} from "lib/forge-std/src/Test.sol";
import {WormholeSenderMock} from "test/mock/WormholeSenderMock.sol";
import {WormholeEncoderHarness} from "test/harness/WormholeEncoderHarness.sol";

contract WormholeEncoderTest is Test {
    address internal sourceSender;

    function setUp() external {
        sourceSender = address(new WormholeSenderMock());
    }

    function testEncode() external {
        address remoteReceiver = address(0x02);
        uint256 chainId = ChainId.Base;
        uint256 value = 3;
        Call[] memory remoteCalls = LibCall.newCalls([
            Call({
                target: address(0x04),
                value: 5,
                data: hex"aabbccdd"
            })
        ]);

        Call memory encoded = WormholeEncoder.encode({
            sourceSender: sourceSender,
            remoteReceiver: remoteReceiver,
            chainId: chainId,
            value: value,
            remoteCalls: remoteCalls
        });

        vm.deal(address(this), encoded.value);
        (bool success, bytes memory returndata) = encoded.target.call{value: encoded.value}(encoded.data);

        assertTrue(success);

        (
            address[] memory targets,
            uint256[] memory values,
            bytes[] memory datas,
            address messageReceiver,
            uint16 receiverChainId
        ) = abi.decode(returndata, (address[], uint256[], bytes[], address, uint16));

        assertEq(encoded.target, sourceSender);
        assertEq(encoded.value, value);
        assertEq(messageReceiver, remoteReceiver);
        assertEq(receiverChainId, WormholeChainId.chainIdToWormholeChainId(chainId));
        assertEq(targets.length, remoteCalls.length);
        assertEq(values.length, remoteCalls.length);
        assertEq(datas.length, remoteCalls.length);

        for (uint256 i; i < remoteCalls.length; i++) {
            assertEq(targets[i], remoteCalls[i].target);
            assertEq(values[i], remoteCalls[i].value);
            assertEq(datas[i], remoteCalls[i].data);
        }
    }

    function testFuzzEncode(
        address remoteReceiver,
        uint256 chainIdSeed,
        uint256 value,
        Call[] calldata remoteCalls
    ) external {
        uint256 chainId = _knownChainId(chainIdSeed);

        Call memory encoded = WormholeEncoder.encode({
            sourceSender: sourceSender,
            remoteReceiver: remoteReceiver,
            chainId: chainId,
            value: value,
            remoteCalls: remoteCalls
        });

        vm.deal(address(this), encoded.value);
        (bool success, bytes memory returndata) = encoded.target.call{value: encoded.value}(encoded.data);

        assertTrue(success);

        (
            address[] memory targets,
            uint256[] memory values,
            bytes[] memory datas,
            address messageReceiver,
            uint16 receiverChainId
        ) = abi.decode(returndata, (address[], uint256[], bytes[], address, uint16));

        assertEq(encoded.target, sourceSender);
        assertEq(encoded.value, value);
        assertEq(messageReceiver, remoteReceiver);
        assertEq(receiverChainId, WormholeChainId.chainIdToWormholeChainId(chainId));
        assertEq(targets.length, remoteCalls.length);
        assertEq(values.length, remoteCalls.length);
        assertEq(datas.length, remoteCalls.length);

        for (uint256 i; i < remoteCalls.length; i++) {
            assertEq(targets[i], remoteCalls[i].target);
            assertEq(values[i], remoteCalls[i].value);
            assertEq(datas[i], remoteCalls[i].data);
        }
    }

    function testFuzzEncodeRevertsOnUnknownChainId(
        address remoteReceiver,
        uint256 chainId,
        uint256 value,
        Call[] calldata remoteCalls
    ) external {
        vm.assume(!_isKnownChainId(chainId));

        WormholeEncoderHarness harness = new WormholeEncoderHarness();

        vm.expectRevert(abi.encodeWithSelector(WormholeChainId.UnknownWormholeChainId.selector, chainId));
        harness.encode(sourceSender, remoteReceiver, chainId, value, remoteCalls);
    }

    function _knownChainIds() internal pure returns (uint256[] memory ids) {
        ids = new uint256[](10);
        ids[0] = ChainId.Arbitrum;
        ids[1] = ChainId.Avalanche;
        ids[2] = ChainId.Base;
        ids[3] = ChainId.BNBChain;
        ids[4] = ChainId.Celo;
        ids[5] = ChainId.Ethereum;
        ids[6] = ChainId.Optimism;
        ids[7] = ChainId.Polygon;
        ids[8] = ChainId.UniChain;
        ids[9] = ChainId.WorldChain;
    }

    function _knownChainId(uint256 seed) internal pure returns (uint256) {
        uint256[] memory ids = _knownChainIds();
        return ids[seed % ids.length];
    }

    function _isKnownChainId(uint256 chainId) internal pure returns (bool) {
        uint256[] memory ids = _knownChainIds();
        for (uint256 i; i < ids.length; i++) {
            if (chainId == ids[i]) return true;
        }
        return false;
    }
}
