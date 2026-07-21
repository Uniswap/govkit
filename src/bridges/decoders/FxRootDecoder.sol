// SPDX-License-Identifier: AGPl-3.0-only
pragma solidity ^0.8.0;

import {IFxRoot} from "../../interfaces/bridges/IFxRoot.sol";
import {Call} from "../../types/Call.sol";
import {SelectorHandler} from "./SelectorHandler.sol";

using SelectorHandler for bytes;

library FxRootDecoder {
    error SelectorMismatch(bytes4, bytes4);
    error LengthsMismatch();

    /// @dev Decodes an FxRoot encoded call.
    /// @dev NOTICE: The inner data encoding order not being `targets, datas, values` is undefined
    ///      behavior.
    /// @param fxRootCall Encoded call as produced by FxRootEncoder.
    /// @return fxRoot FxRoot contract to call on Ethereum.
    /// @return fxReceiver FxReceiver contract that receives the message on Polygon.
    /// @return remoteCalls Array of calls to make on Polygon.
    function decode(Call memory fxRootCall) internal pure returns (
        address,
        address,
        Call[] memory
    ) {
        require(fxRootCall.data.getSelector() == IFxRoot.sendMessageToChild.selector, SelectorMismatch(fxRootCall.data.getSelector(), IFxRoot.sendMessageToChild.selector));

        (address fxReceiver, bytes memory encodedCalls) = abi.decode(
            fxRootCall.data.stripSelector(), (address, bytes)
        );

        (address[] memory targets, bytes[] memory datas, uint256[] memory values) = abi.decode(
            encodedCalls, (address[], bytes[], uint256[])
        );

        uint256 length = targets.length;
        require(length == datas.length && length == values.length, LengthsMismatch());

        Call[] memory remoteCalls = new Call[](length);

        for (uint256 i; i < length; i++) {
            remoteCalls[i] = Call({
                target: targets[i],
                value: values[i],
                data: datas[i]
            });
        }

        return (
            fxRootCall.target,
            fxReceiver,
            remoteCalls
        );
    }
}
