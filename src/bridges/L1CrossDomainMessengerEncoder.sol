// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

import {Call} from "src/types/Call.sol";
import {Action} from "src/types/Action.sol";
import {IL1CrossDomainMessenger} from "src/interfaces/bridges/IL1CrossDomainMessenger.sol";
import {ICrossChainAccount} from "src/interfaces/bridges/ICrossChainAccount.sol";

library L1CrossDomainMessengerEncoder {
    string internal constant SIGNATURE = "sendMessage(address,bytes,uint32)";

    uint32 internal constant GAS_LIMIT = 200_000;

    function encodeAction(
        address crossChainMessengerSender,
        address crossChainAccountReceiver,
        Call memory remoteCall
    ) internal pure returns (Action memory) {
        return encodeAction(
            crossChainMessengerSender,
            crossChainAccountReceiver,
            GAS_LIMIT,
            remoteCall
        );
    }

    function encodeAction(
        address crossChainMessengerSender,
        address crossChainAccountReceiver,
        uint256 gasLimit,
        Call memory remoteCall
    ) internal pure returns (Action memory) {
        require(
            remoteCall.value == 0,
            "L1CrossDomainMessengerEncoder::Error: L1CrossDomainMessenger cannot send msg.value > 0"
        );

        bytes memory crossChainAccountData = abi.encodeCall(
            ICrossChainAccount.forward,
            (remoteCall.target, remoteCall.data)
        );

        return Action({
            target: crossChainMessengerSender,
            value: 0,
            signature: SIGNATURE,
            data: abi.encodeCall(
                IL1CrossDomainMessenger.sendMessage,
                (crossChainAccountReceiver, crossChainAccountData, gasLimit)
            )
        })
    }
}
