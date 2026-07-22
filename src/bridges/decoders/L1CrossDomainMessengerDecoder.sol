// SPDX-License-Identifier: AGPl-3.0-only
pragma solidity ^0.8.0;

import {ICrossChainAccount} from "../../interfaces/bridges/ICrossChainAccount.sol";
import {IL1CrossDomainMessenger} from "../../interfaces/bridges/IL1CrossDomainMessenger.sol";
import {Call} from "../../types/Call.sol";
import {SelectorHandler} from "./SelectorHandler.sol";

using SelectorHandler for bytes;

library L1CrossDomainMessengerDecoder {
    error SelectorMismatch();

    /// @dev Decodes an L1CrossDomainMessenger encoded call.
    /// @param l1CrossDomainMessengerCall Encoded call as produced by L1CrossDomainMessengerEncoder.
    /// @return l1CrossDomainMessenger L1CrossDomainMessenger contract address on Ethereum.
    /// @return crossChainAccount CrossChainAccount contract address on OP Stack chain.
    /// @return gasLimit Gas limit.
    /// @return remoteCall Call to make on OP Stack chain
    function decode(Call memory l1CrossDomainMessengerCall)
        internal
        pure
        returns (address, address, uint32, Call memory)
    {
        require(
            l1CrossDomainMessengerCall.data.getSelector()
                == IL1CrossDomainMessenger.sendMessage.selector,
            SelectorMismatch()
        );

        (address crossChainAccount, bytes memory crossChainAccountData, uint32 gasLimit) =
            abi.decode(l1CrossDomainMessengerCall.data.stripSelector(), (address, bytes, uint32));

        require(
            crossChainAccountData.getSelector() == ICrossChainAccount.forward.selector,
            SelectorMismatch()
        );

        (address remoteTarget, bytes memory remoteData) =
            abi.decode(crossChainAccountData.stripSelector(), (address, bytes));

        return (
            l1CrossDomainMessengerCall.target,
            crossChainAccount,
            gasLimit,
            Call({target: remoteTarget, value: 0, data: remoteData})
        );
    }
}
