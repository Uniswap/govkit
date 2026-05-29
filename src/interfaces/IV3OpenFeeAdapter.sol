// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

interface IV3OpenFeeAdapter {

    // Structs
    struct Pair {
        address token0;
        address token1;
    }
    struct CollectParams {
        address pool;
        uint128 amount0Requested;
        uint128 amount1Requested;
    }
    struct Collected {
        uint128 amount0Collected;
        uint128 amount1Collected;
    }

    // Events
    event DefaultFeeUpdated(uint8 feeValue);
    event FeeSetterUpdated(address indexed oldFeeSetter, address indexed newFeeSetter);
    event FeeTierDefaultCleared(uint24 indexed feeTier);
    event FeeTierDefaultUpdated(uint24 indexed feeTier, uint8 feeValue);
    event FeeUpdateTriggered(address indexed caller, address indexed pool, uint8 feeValue);
    event OwnershipTransferred(address indexed user, address indexed newOwner);
    event PoolOverrideCleared(address indexed pool);
    event PoolOverrideUpdated(address indexed pool, uint8 feeValue);

    // Errors
    error InvalidFeeTier();
    error InvalidFeeValue();
    error TierAlreadyStored();
    error Unauthorized();

    // Functions
    function FACTORY() external view returns (address);
    function TOKEN_JAR() external view returns (address);
    function ZERO_FEE_SENTINEL() external view returns (uint8);
    function batchTriggerFeeUpdate(Pair[] memory pairs) external;
    function batchTriggerFeeUpdateByPool(address[] memory pools) external;
    function clearFeeTierDefault(uint24 feeTier) external;
    function clearPoolOverride(address pool) external;
    function collect(CollectParams[] memory collectParams) external returns (Collected[] memory amountsCollected);
    function defaultFee() external view returns (uint8);
    function defaultFees(uint24 feeTier) external view returns (uint8);
    function enableFeeAmount(uint24 fee, int24 tickSpacing) external;
    function feeSetter() external view returns (address);
    function feeTierDefaults(uint24 feeTier) external view returns (uint8 feeValue);
    function feeTiers(uint256) external view returns (uint24);
    function getFee(address pool) external view returns (uint8 fee);
    function owner() external view returns (address);
    function poolOverrides(address pool) external view returns (uint8 feeValue);
    function setDefaultFee(uint8 feeValue) external;
    function setDefaultFeeByFeeTier(uint24 feeTier, uint8 defaultFeeValue) external;
    function setFactoryOwner(address newOwner) external;
    function setFeeSetter(address newFeeSetter) external;
    function setFeeTierDefault(uint24 feeTier, uint8 feeValue) external;
    function setPoolOverride(address pool, uint8 feeValue) external;
    function storeFeeTier(uint24 feeTier) external;
    function transferOwnership(address newOwner) external;
    function triggerFeeUpdate(address pool) external;
    function triggerFeeUpdate(address token0, address token1) external;
}
