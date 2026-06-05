// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

import {Call} from "src/types/Call.sol";
import {Action} from "src/types/Action.sol";
import {IFxRoot} from "src/interfaces/bridges/IFxRoot.sol";

library FxRootEncoder {
    function encodeAction(address fxRoot, address fxReceiver, uint256 value, Call[] memory remoteCalls)
        internal
        pure
        returns (Action memory)
    {
        address[] memory targets = new address[](remoteCalls.length);
        uint256[] memory values = new uint256[](remoteCalls.length);
        bytes[] memory datas = new bytes[](remoteCalls.length);

        for (uint256 i; i < remoteCalls.length; i++) {
            targets[i] = remoteCalls[i].target;
            values[i] = remoteCalls[i].value;
            datas[i] = remoteCalls[i].data;
        }

        return Action({
            target: fxRoot,
            value: value,
            data: abi.encodeCall(IFxRoot.sendMessageToChild, (fxReceiver, abi.encode(targets, datas, values)))
        });
    }
}
