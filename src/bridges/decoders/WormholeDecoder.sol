// SPDX-License-Identifier: AGPl-3.0-only
pragma solidity ^0.8.0;

import {WormholeChainId} from "../../constants/WormholeChainId.sol";
import {IWormholeSender} from "../../interfaces/bridges/IWormholeSender.sol";
import {Call} from "../../types/Call.sol";
import {SelectorHandler} from "./SelectorHandler.sol";

using SelectorHandler for bytes;

library WormholeDecoder {
    error SelectorMismatch();
    error LengthsMismatch();

    /// @dev Decodes an Wormhole encoded call.
    /// @param wormholeCall Encoded call as produced by WormholeEncoder.
    /// @return sourceSender Uniswap's WormholeSender contract on Ethereum.
    /// @return remoteReceiver Uniswap's WormholeReceiver contract on the remote chain.
    /// @return chainId Canonical EIP-155 chain ID.
    /// @return value Call value.
    /// @return remoteCalls Calls to be run from the WormholeReceiver on the remote chain.
    function decode(Call memory wormholeCall)
        internal
        pure
        returns (address, address, uint256, uint256, Call[] memory)
    {
        require(
            wormholeCall.data.getSelector() == IWormholeSender.sendMessage.selector,
            SelectorMismatch()
        );

        (
            address[] memory targets,
            uint256[] memory values,
            bytes[] memory datas,
            address remoteReceiver,
            uint16 wormholeChainId
        ) = abi.decode(
            wormholeCall.data.stripSelector(), (address[], uint256[], bytes[], address, uint16)
        );

        uint256 length = targets.length;
        require(length == values.length && length == datas.length, LengthsMismatch());

        Call[] memory remoteCalls = new Call[](length);

        for (uint256 i; i < length; i++) {
            remoteCalls[i] = Call({target: targets[i], value: values[i], data: datas[i]});
        }

        return (
            wormholeCall.target,
            remoteReceiver,
            WormholeChainId.wormholeChainIdToChainId(wormholeChainId),
            wormholeCall.value,
            remoteCalls
        );
    }
}
