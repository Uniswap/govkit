// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface IFirepit {

    // Events
    event OwnershipTransferred(address indexed user, address indexed newOwner);
    event Released(uint256 indexed nonce, address indexed recipient, address[] assets);

    // Errors
    error InvalidNonce();
    error TooManyAssets();
    error Unauthorized();

    // Functions
    function MAX_RELEASE_LENGTH() external view returns (uint256);
    function RESOURCE() external view returns (address);
    function RESOURCE_RECIPIENT() external view returns (address);
    function TOKEN_JAR() external view returns (address);
    function nonce() external view returns (uint256);
    function owner() external view returns (address);
    function release(uint256 _nonce, address[] memory assets, address recipient) external;
    function setThreshold(uint256 _threshold) external;
    function setThresholdSetter(address _thresholdSetter) external;
    function threshold() external view returns (uint256);
    function thresholdSetter() external view returns (address);
    function transferOwnership(address newOwner) external;
}
