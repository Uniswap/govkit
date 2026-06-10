// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

import {Call} from "src/types/Call.sol";
import {IL1CrossDomainMessenger} from "src/interfaces/bridges/IL1CrossDomainMessenger.sol";
import {ICrossChainAccount} from "src/interfaces/bridges/ICrossChainAccount.sol";

/// @title OP Stack L1 Cross Domain Messenger Encoder
/// @dev OP Stack chains' core bridge system is the Optimism Portal, the
///      L1CrossDomainMessenger is an abstraction on top of this. Uniswap's
///      Timelock calls the L1CrossDomainMessenger on Ethereum, which then uses
///      the underlying OptimismPortal on Ethereum, which then calls Uniswap's
///      CrossChainAccount on the OP Stack chain, which then then runs calls
///      against the protocol on the respective chain.
library L1CrossDomainMessengerEncoder {
    /// @dev Thrown if a remote call's value is non-zero.
    error NonzeroCallValue();

    /// @dev Default gas limit.
    uint32 internal constant GAS_LIMIT = 200_000;

    /// @dev Encodes an L1CrossDomainMessenger call.
    /// @param l1CrossDomainMessenger OP Stack chain's L1CrossDomainMessenger contract on Ethereum.
    /// @param crossChainAccount Uniswap's CrossChainAccount contract on the OP Stack chain.
    /// @param remoteCall Call to be run from the CrossChainAccount on the OP Stack chain.
    /// @return Proposal-ready call.
    function encode(address l1CrossDomainMessenger, address crossChainAccount, Call memory remoteCall)
        internal
        pure
        returns (Call memory)
    {
        return encode(l1CrossDomainMessenger, crossChainAccount, GAS_LIMIT, remoteCall);
    }

    /// @dev Encodes an L1CrossDomainMessenger call.
    /// @param l1CrossDomainMessenger OP Stack chain's L1CrossDomainMessenger contract on Ethereum.
    /// @param crossChainAccount Uniswap's CrossChainAccount contract on the OP Stack chain.
    /// @param gasLimit Gas limit for the call.
    /// @param remoteCall Call to be run from the CrossChainAccount on the OP Stack chain.
    /// @return Proposal-ready call.
    function encode(address l1CrossDomainMessenger, address crossChainAccount, uint32 gasLimit, Call memory remoteCall)
        internal
        pure
        returns (Call memory)
    {
        if (remoteCall.value > 0) revert NonzeroCallValue();

        bytes memory crossChainAccountData =
            abi.encodeCall(ICrossChainAccount.forward, (remoteCall.target, remoteCall.data));

        return Call({
            target: l1CrossDomainMessenger,
            value: 0,
            data: abi.encodeCall(
                IL1CrossDomainMessenger.sendMessage, (crossChainAccount, crossChainAccountData, gasLimit)
            )
        });
    }
}
