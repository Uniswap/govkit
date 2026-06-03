// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

import {Call} from "src/types/Call.sol";
import {Action} from "src/types/Action.sol";
import {IInbox} from "src/interfaces/bridges/IInbox.sol";

library InboxEncoder {
    string internal constant SIGNATURE = "createRetryableTicket(address,uint256,uint256,address,address,uint256,uint256,bytes)";

    uint256 internal constant GAS_LIMIT = 200_000;
    uint256 internal constant MAX_FEE_PER_GAS = 0.1 gwei;
    uint256 internal constant MAX_SUBMISSION_COST = 0.01 ether;
    uint160 internal constant ALIAS_OFFSET = uint160(0x1111000000000000000000000000000000001111);

    function encodeAction(
        address inbox,
        address timelock,
        Call memory remoteCall
    ) internal pure returns (Action memory) {
        return encodeAction({
            inbox: inbox,
            timelock: timelock,
            gasLimit: GAS_LIMIT,
            maxFeePerGas: MAX_FEE_PER_GAS,
            maxSubmissionCost: MAX_SUBMISSION_COST,
            remoteCall: remoteCall
        });
    }

    function encodeAction(
        address inbox,
        address timelock,
        uint256 gasLimit,
        uint256 maxFeePerGas,
        uint256 maxSubmissionCost,
        Call memory remoteCall
    ) internal pure returns (Action memory) {
        address refundAddress = arbitrumAlias(timelock);

        return Action({
            target: inbox,
            value: (gasLimit * maxFeePerGas) + maxSubmissionCost,
            signature: SIGNATURE,
            data: abi.encodeCall(
                IInbox.createRetryableTicket,
                (
                    remoteCall.target,
                    remoteCall.value,
                    maxSubmissionCost,
                    refundAddress,
                    refundAddress,
                    gasLimit,
                    maxFeePerGas,
                    remoteCall.data
                )
            )
        });
    }

    function arbitrumAlias(address l1Address) internal pure returns (address) {
        return address(uint160(l1Address) + ALIAS_OFFSET);
    }
}
