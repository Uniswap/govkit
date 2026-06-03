// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

import {Call} from "src/types/Call.sol";
import {Action} from "src/types/Action.sol";
import {IOptimismPortal2} from "src/interfaces/bridges/IOptimismPortal2.sol";

library OptimismPortal2Encoder {
    string internal constant SIGNATURE = "depositTransaction(address,uint256,uint64,bool,bytes)";
    uint64 internal constant GAS_LIMIT = 200_000;

    function encodeAction(
        address portal,
        Call memory remoteCall
    ) internal pure returns (Action memory) {
        return encodeAction(portal, GAS_LIMIT, remoteCall);
    }

    function encodeAction(
        address portal,
        uint64 gasLimit,
        Call memory remoteCall
    ) internal pure returns (Action memory) {
        return Action({
            target: portal,
            value: remoteCall.value,
            signature: SIGNATURE,
            data: abi.encodeCall(
                IOptimismPortal2.depositTransaction,
                (
                    remoteCall.target,
                    remoteCall.value,
                    gasLimit,
                    false,
                    remoteCall.data
                )
            )
        });
    }
}
