// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

import {Call} from "src/types/Call.sol";
import {IOptimismPortal2} from "src/interfaces/bridges/IOptimismPortal2.sol";

library OptimismPortal2Encoder {
    uint64 internal constant GAS_LIMIT = 200_000;

    function encode(address portal, Call memory remoteCall) internal pure returns (Call memory) {
        return encode(portal, GAS_LIMIT, remoteCall);
    }

    function encode(address portal, uint64 gasLimit, Call memory remoteCall)
        internal
        pure
        returns (Call memory)
    {
        return Call({
            target: portal,
            value: remoteCall.value,
            data: abi.encodeCall(
                IOptimismPortal2.depositTransaction,
                (remoteCall.target, remoteCall.value, gasLimit, false, remoteCall.data)
            )
        });
    }
}
