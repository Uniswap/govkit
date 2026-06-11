// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

import {WormholeChainId} from "../constants/WormholeChainId.sol";
import {Call} from "../types/Call.sol";

import {IWormholeSender} from "../interfaces/bridges/IWormholeSender.sol";

/// @title Wormhole Encoder
/// @dev The Wormhole system requires Uniswap's Timelock to call a Uniswap-
///      authenticated WormholeSender on Ethereum, which calls the WormholeCore
///      on Ethereum. The Wormhole system produces a "Verified Action Approval"
///      (VAA) with signatures from its node set, which must be manually sent to
///      Uniswap's WormholeReceiver contract on the remote chain, which will
///      internally validate against the WormholeCore on the remote chain. Once
///      validated, the WormholeReceiver sends the calls to the protocol on the
///      remote chain.
/// @dev A thing worth noting is someone (potentially Wormhole) will sometimes
///      batch-relay messages themselves on some networks. This is worth noting
///      as Uniswap's WormholeReceiver on the remote chain will increment its
///      nonce (disallowing a replay), but no contract in this process will log
///      any observable event and it will not show up as a transaction on
///      Etherscan-based explorers. This is notable because if anyone tries to
///      forward the message after this, they will get an error, making it seem
///      like the message failed when it in fact had already executed.
library WormholeEncoder {
    /// @dev Encodes a Wormhole call.
    /// @param sourceSender Uniswap's WormholeSender contract on Ethereum.
    /// @param remoteReceiver Uniswap's WormholeReceiver contract on the remote chain.
    /// @param chainId Canonical EIP-155 chain ID.
    /// @param value Call value (MAY require a WormholeCore fee query in the future).
    /// @param remoteCalls Calls to be run from the WormholeReceiver on the remote chain.
    /// @return Proposal-ready call.
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
