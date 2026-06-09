// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

import {Call} from "src/types/Call.sol";
import {IInbox} from "src/interfaces/bridges/IInbox.sol";

/// @title Arbitrum Inbox Encoder
/// @dev The Arbitrum Inbox system requires Uniswap Timelock to call Arbitrum's
///      Inbox on Ethereum, then the Arbitrum chain runs a transaction on
///      the Arbitrum chain originating from the Timelock address plus
///      Arbitrum's alias.
library InboxEncoder {
    /// @dev Default gas limit.
    uint256 internal constant GAS_LIMIT = 200_000;

    /// @dev Default max fee per gas.
    uint256 internal constant MAX_FEE_PER_GAS = 0.1 gwei;

    /// @dev Default max submission cost.
    uint256 internal constant MAX_SUBMISSION_COST = 0.01 ether;

    /// @dev Arbitrum adress alias offset.
    uint160 internal constant ALIAS_OFFSET = uint160(0x1111000000000000000000000000000000001111);

    /// @dev Encodes an Arbitrum Inbox call with defaults.
    /// @param inbox Arbitrum's Inbox contract on Ethereum.
    /// @param timelock Uniswap's Timelock contract on Ethereum.
    /// @param remoteCall Call to be run from the aliased Timelock address on Arbitrum.
    /// @return Proposal-ready call.
    function encode(address inbox, address timelock, Call memory remoteCall) internal pure returns (Call memory) {
        return encode({
            inbox: inbox,
            timelock: timelock,
            gasLimit: GAS_LIMIT,
            maxFeePerGas: MAX_FEE_PER_GAS,
            maxSubmissionCost: MAX_SUBMISSION_COST,
            remoteCall: remoteCall
        });
    }

    /// @dev Encodes an Arbitrum Inbox call.
    /// @param inbox Arbitrum's Inbox contract on Ethereum.
    /// @param timelock Uniswap's Timelock contract on Ethereum.
    /// @param gasLimit Gas limit of the call.
    /// @param maxFeePerGas Max fee-per-gas of the call.
    /// @param maxSubmissionCost Max submission cost of the call.
    /// @param remoteCall Call to be run from the aliased Timelock address on Arbitrum.
    /// @return Proposal-ready call.
    function encode(
        address inbox,
        address timelock,
        uint256 gasLimit,
        uint256 maxFeePerGas,
        uint256 maxSubmissionCost,
        Call memory remoteCall
    ) internal pure returns (Call memory) {
        address refundAddress = arbitrumAlias(timelock);

        return Call({
            target: inbox,
            value: (gasLimit * maxFeePerGas) + maxSubmissionCost,
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

    /// @dev Arbitrum alias operation.
    function arbitrumAlias(address l1Address) internal pure returns (address) {
        // safety: arbitrum's alias system intends for this to overflow.
        unchecked {
            return address(uint160(l1Address) + ALIAS_OFFSET);
        }
    }

    /// @dev Arbitrum de-alias operation.
    function arbitrumDeAlias(address l2Address) internal pure returns (address) {
        // safety: arbitrum's alias system intends for this to underflow.
        unchecked {
            return address(uint160(l2Address) - ALIAS_OFFSET);
        }
    }
}
