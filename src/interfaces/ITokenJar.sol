// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

interface ITokenJar {
    // Events
    event OwnershipTransferred(address indexed user, address indexed newOwner);

    // Errors
    error Unauthorized();

    // Functions
    function owner() external view returns (address);
    function release(address[] memory assets, address recipient) external;
    function releaser() external view returns (address);
    function setReleaser(address _releaser) external;
    function transferOwnership(address newOwner) external;
}
