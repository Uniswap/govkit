// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

import {Call} from "src/types/Call.sol";
import {IL1CrossDomainMessenger} from "src/interfaces/bridges/IL1CrossDomainMessenger.sol";
import {ICrossChainAccount} from "src/interfaces/bridges/ICrossChainAccount.sol";

library L1CrossDomainMessengerEncoder {
    uint32 internal constant GAS_LIMIT = 200_000;

    function encode(address crossChainMessengerSender, address crossChainAccountReceiver, Call memory remoteCall)
        internal
        pure
        returns (Call memory)
    {
        return encode(crossChainMessengerSender, crossChainAccountReceiver, GAS_LIMIT, remoteCall);
    }

    function encode(
        address crossChainMessengerSender,
        address crossChainAccountReceiver,
        uint32 gasLimit,
        Call memory remoteCall
    ) internal pure returns (Call memory) {
        require(
            remoteCall.value == 0,
            "L1CrossDomainMessengerEncoder::Error: L1CrossDomainMessenger cannot send msg.value > 0"
        );

        bytes memory crossChainAccountData =
            abi.encodeCall(ICrossChainAccount.forward, (remoteCall.target, remoteCall.data));

        return Call({
            target: crossChainMessengerSender,
            value: 0,
            data: abi.encodeCall(
                IL1CrossDomainMessenger.sendMessage, (crossChainAccountReceiver, crossChainAccountData, gasLimit)
            )
        });
    }
}
