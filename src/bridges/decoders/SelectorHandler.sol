// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

library SelectorHandler {
    error EncodedDataTooShort();

    function getSelector(bytes memory encodedCall) internal pure returns (bytes4 selector) {
        require(encodedCall.length >= 4, EncodedDataTooShort());

        assembly ("memory-safe") {
            selector := mload(add(encodedCall, 0x20))

            selector := shl(0xe0, shr(0xe0, selector))
        }
    }

    /// @dev Strips the selector from an ABI-Encoded Call.
    /// @param encodedCall Encoded calldata.
    /// @return Copy of the encoded calldata but without the selector.
    function stripSelector(bytes memory encodedCall) internal pure returns (bytes memory) {
        uint256 length = encodedCall.length;
        require(length >= 4, EncodedDataTooShort());
        length -= 4;

        bytes memory encodedArgs;

        assembly ("memory-safe") {
            encodedArgs := mload(0x40)
            mstore(encodedArgs, length)
            mcopy(add(encodedArgs, 0x20), add(encodedCall, 0x24), length)
            mstore(0x40, add(encodedArgs, add(length, 0x20)))
        }

        return encodedArgs;
    }
}
