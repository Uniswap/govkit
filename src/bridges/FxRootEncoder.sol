// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

import {Call} from "src/types/Call.sol";
import {IFxRoot} from "src/interfaces/bridges/IFxRoot.sol";

/// @title Polygon FxRoot Encoder
/// @dev The Polygon FxRoot/FxChild system requires Uniswap Timelock to call
///      Polygon's FxRoot on Ethereum, then Polygon's FxChild calls Uniswap's
///      EthereumProxy (receiver contract), which then runs calls against the
///      protocol on Polygon.
library FxRootEncoder {
    error NonZeroValue();

    /// @dev Encodes an FxRoot call.
    /// @param fxRoot Polygon's FxRoot contract on Ethereum.
    /// @param fxReceiver Uniswap's FxReceiver contract on Polygon.
    /// @param remoteCalls Call array to be run from the FxReceiver on Polygon.
    /// @return Proposal-ready call.
    function encode(address fxRoot, address fxReceiver, Call[] memory remoteCalls)
        internal
        pure
        returns (Call memory)
    {
        address[] memory targets = new address[](remoteCalls.length);
        uint256[] memory values = new uint256[](remoteCalls.length);
        bytes[] memory datas = new bytes[](remoteCalls.length);

        for (uint256 i; i < remoteCalls.length; i++) {
            if (remoteCalls[i].value > 0) revert NonZeroValue();

            targets[i] = remoteCalls[i].target;
            datas[i] = remoteCalls[i].data;
        }

        return Call({
            target: fxRoot,
            value: 0,
            data: abi.encodeCall(IFxRoot.sendMessageToChild, (fxReceiver, abi.encode(targets, datas, values)))
        });
    }
}
