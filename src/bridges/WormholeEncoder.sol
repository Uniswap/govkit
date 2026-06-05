// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

import {WormholeChainId} from "src/constants/WormholeChainId.sol";
import {Call} from "src/types/Call.sol";

import {IWormholeSender} from "src/interfaces/bridges/IWormholeSender.sol";

library WormholeEncoder {
    function encode(
        address sourceSender,
        address remoteReceiver,
        uint256 chainId,
        uint256 value,
        Call[] memory remoteCalls
    ) internal pure returns (Call memory) {
        address[] memory targets = new address[](remoteCalls.length);
        uint256[] memory values = new uint256[](remoteCalls.length);
        bytes[] memory datas = new bytes[](remoteCalls.length);

        for (uint256 i; i < remoteCalls.length; i++) {
            targets[i] = remoteCalls[i].target;
            values[i] = remoteCalls[i].value;
            datas[i] = remoteCalls[i].data;
        }

        uint16 wormholeChainId = WormholeChainId.chainIdToWormholeChainId(chainId);

        return Call({
            target: sourceSender,
            value: value,
            data: abi.encodeCall(IWormholeSender.sendMessage, (targets, values, datas, remoteReceiver, wormholeChainId))
        });
    }
}
