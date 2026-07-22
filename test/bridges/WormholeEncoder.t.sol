// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

import {WormholeEncoder} from "../../src/bridges/WormholeEncoder.sol";
import {ChainId} from "../../src/constants/ChainId.sol";
import {WormholeChainId} from "../../src/constants/WormholeChainId.sol";
import {IWormholeSender} from "../../src/interfaces/bridges/IWormholeSender.sol";
import {Call, LibCall} from "../../src/types/Call.sol";
import {DecoderHarness} from "../harness/DecoderHarness.sol";
import {EncoderHarness} from "../harness/EncoderHarness.sol";

import {WormholeEncoderHarness} from "../harness/WormholeEncoderHarness.sol";
import {WormholeSenderMock} from "../mock/WormholeSenderMock.sol";
import {Test, console} from "forge-std/Test.sol";

contract WormholeEncoderTest is Test {
    EncoderHarness internal encoder;
    DecoderHarness internal decoder;

    address internal sourceSender;

    function setUp() external {
        encoder = new EncoderHarness();
        decoder = new DecoderHarness();
        sourceSender = address(new WormholeSenderMock());
    }

    function testEncode() external {
        address remoteReceiver = address(0x02);
        uint256 chainId = ChainId.BNBChain;
        uint256 value = 3;
        Call[] memory remoteCalls =
            LibCall.newCalls([Call({target: address(0x04), value: 5, data: hex"aabbccdd"})]);

        Call memory encoded = WormholeEncoder.encode({
            sourceSender: sourceSender,
            remoteReceiver: remoteReceiver,
            chainId: chainId,
            value: value,
            remoteCalls: remoteCalls
        });

        vm.deal(address(this), encoded.value);
        (bool success, bytes memory returndata) =
            encoded.target.call{value: encoded.value}(encoded.data);

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
        (bool success, bytes memory returndata) =
            encoded.target.call{value: encoded.value}(encoded.data);

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

        vm.expectRevert(
            abi.encodeWithSelector(WormholeChainId.UnsupportedChainId.selector, chainId)
        );
        harness.encode(sourceSender, remoteReceiver, chainId, value, remoteCalls);
    }

    function testEncodeDecode() external view {
        address sourceSender_ = address(0x01);
        address remoteReceiver = address(0x02);
        uint256 chainId = ChainId.BNBChain;
        uint256 value = 3;
        Call[] memory remoteCalls = new Call[](1);
        remoteCalls[0] = Call({target: address(0x03), value: 5, data: hex"05"});

        Call memory wormholeCall =
            encoder.encodeWormhole(sourceSender_, remoteReceiver, chainId, value, remoteCalls);

        (
            address decodedSourceSender,
            address decodedRemoteReceiver,
            uint256 decodedChainId,
            uint256 decodedValue,
            Call[] memory decodedRemoteCalls
        ) = decoder.decodeWormhole(wormholeCall);

        assertEq(sourceSender_, decodedSourceSender);
        assertEq(remoteReceiver, decodedRemoteReceiver);
        assertEq(chainId, decodedChainId);
        assertEq(value, decodedValue);

        for (uint256 i; i < remoteCalls.length; i++) {
            assertEq(remoteCalls[i].target, decodedRemoteCalls[i].target);
            assertEq(remoteCalls[i].value, decodedRemoteCalls[i].value);
            assertEq(remoteCalls[i].data, decodedRemoteCalls[i].data);
        }
    }

    function testFuzzEncodeDecode(
        address sourceSender_,
        address remoteReceiver,
        uint256 chainIdSeed,
        uint256 value,
        Call[] memory remoteCalls
    ) external view {
        uint256 chainId = _knownChainId(chainIdSeed);

        Call memory wormholeCall =
            encoder.encodeWormhole(sourceSender_, remoteReceiver, chainId, value, remoteCalls);

        (
            address decodedSourceSender,
            address decodedRemoteReceiver,
            uint256 decodedChainId,
            uint256 decodedValue,
            Call[] memory decodedRemoteCalls
        ) = decoder.decodeWormhole(wormholeCall);

        assertEq(sourceSender_, decodedSourceSender);
        assertEq(remoteReceiver, decodedRemoteReceiver);
        assertEq(chainId, decodedChainId);
        assertEq(value, decodedValue);

        for (uint256 i; i < remoteCalls.length; i++) {
            assertEq(remoteCalls[i].target, decodedRemoteCalls[i].target);
            assertEq(remoteCalls[i].value, decodedRemoteCalls[i].value);
            assertEq(remoteCalls[i].data, decodedRemoteCalls[i].data);
        }
    }

    function _knownChainIds() internal pure returns (uint256[] memory ids) {
        ids = new uint256[](7);
        ids[0] = ChainId.Avalanche;
        ids[1] = ChainId.BNBChain;
        ids[2] = ChainId.Ethereum;
        ids[3] = ChainId.MegaEth;
        ids[4] = ChainId.Monad;
        ids[5] = ChainId.RootStock;
        ids[6] = ChainId.Tempo;
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
