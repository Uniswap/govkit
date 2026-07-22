// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

import {FxRootDecoder} from "../../src/bridges/decoders/FxRootDecoder.sol";
import {InboxDecoder} from "../../src/bridges/decoders/InboxDecoder.sol";
import {
    L1CrossDomainMessengerDecoder
} from "../../src/bridges/decoders/L1CrossDomainMessengerDecoder.sol";
import {OptimismPortal2Decoder} from "../../src/bridges/decoders/OptimismPortal2Decoder.sol";
import {WormholeDecoder} from "../../src/bridges/decoders/WormholeDecoder.sol";
import {Call} from "../../src/types/Call.sol";

contract DecoderHarness {
    function decodeFxRoot(Call memory fxRootCall)
        external
        pure
        returns (address, address, Call[] memory)
    {
        return FxRootDecoder.decode(fxRootCall);
    }

    function decodeInbox(Call memory inboxCall)
        external
        pure
        returns (address, address, uint256, uint256, uint256, Call memory)
    {
        return InboxDecoder.decode(inboxCall);
    }

    function decodeL1CrossDomainMessenger(Call memory l1CrossDomainMessengerCall)
        external
        pure
        returns (address, address, uint32, Call memory)
    {
        return L1CrossDomainMessengerDecoder.decode(l1CrossDomainMessengerCall);
    }

    function decodeOptimismPortal2(Call memory optimismPortal2Call)
        external
        pure
        returns (address, uint64, Call memory)
    {
        return OptimismPortal2Decoder.decode(optimismPortal2Call);
    }

    function decodeWormhole(Call memory wormholeCall)
        external
        pure
        returns (address, address, uint256, uint256, Call[] memory)
    {
        return WormholeDecoder.decode(wormholeCall);
    }
}
