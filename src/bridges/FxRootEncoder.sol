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
    error InsufficientValue(uint256 minimum, uint256 received);

    /// @dev Encodes an FxRoot call.
    /// @param fxRoot Polygon's FxRoot contract on Ethereum.
    /// @param fxReceiver Uniswap's FxReceiver contract on Polygon.
    /// @param value Total call value (MUST be the sum of all values).
    /// @param remoteCalls Call array to be run from the FxReceiver on Polygon.
    /// @return Proposal-ready call.
    function encode(address fxRoot, address fxReceiver, uint256 value, Call[] memory remoteCalls)
        internal
        pure
        returns (Call memory)
    {
        address[] memory targets = new address[](remoteCalls.length);
        uint256[] memory values = new uint256[](remoteCalls.length);
        bytes[] memory datas = new bytes[](remoteCalls.length);
        uint256 totalValue;

        for (uint256 i; i < remoteCalls.length; i++) {
            targets[i] = remoteCalls[i].target;
            values[i] = remoteCalls[i].value;
            datas[i] = remoteCalls[i].data;

            totalValue += remoteCalls[i].value;
        }

        if (value < totalValue) revert InsufficientValue(totalValue, value);

        return Call({
            target: fxRoot,
            value: value,
            data: abi.encodeCall(IFxRoot.sendMessageToChild, (fxReceiver, abi.encode(targets, datas, values)))
        });
    }
}
