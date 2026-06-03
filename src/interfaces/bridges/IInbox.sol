// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

interface IInbox {
    // Events
    event AllowListAddressSet(address indexed user, bool val);
    event AllowListEnabledUpdated(bool isEnabled);
    event InboxMessageDelivered(uint256 indexed messageNum, bytes data);
    event InboxMessageDeliveredFromOrigin(uint256 indexed messageNum);
    event Initialized(uint8 version);
    event Paused(address account);
    event Unpaused(address account);
    event AdminChanged(address previousAdmin, address newAdmin);
    event Upgraded(address indexed implementation);

    // Errors
    error DataTooLarge(uint256 dataLength, uint256 maxDataLength);
    error GasLimitTooLarge();
    error InsufficientSubmissionCost(uint256 expected, uint256 actual);
    error InsufficientValue(uint256 expected, uint256 actual);
    error L1Forked();
    error NotAllowedOrigin(address origin);
    error NotCodelessOrigin();
    error NotForked();
    error NotOrigin();
    error NotOwner(address sender, address owner);
    error NotRollupOrOwner(address sender, address rollup, address owner);
    error RetryableData(
        address from,
        address to,
        uint256 l2CallValue,
        uint256 deposit,
        uint256 maxSubmissionCost,
        address excessFeeRefundAddress,
        address callValueRefundAddress,
        uint256 gasLimit,
        uint256 maxFeePerGas,
        bytes data
    );

    // Functions
    function allowListEnabled() external view returns (bool);
    function bridge() external view returns (address);
    function calculateRetryableSubmissionFee(uint256 dataLength, uint256 baseFee) external view returns (uint256);
    function createRetryableTicket(
        address to,
        uint256 l2CallValue,
        uint256 maxSubmissionCost,
        address excessFeeRefundAddress,
        address callValueRefundAddress,
        uint256 gasLimit,
        uint256 maxFeePerGas,
        bytes memory data
    ) external payable returns (uint256);
    function createRetryableTicketNoRefundAliasRewrite(
        address to,
        uint256 l2CallValue,
        uint256 maxSubmissionCost,
        address excessFeeRefundAddress,
        address callValueRefundAddress,
        uint256 gasLimit,
        uint256 maxFeePerGas,
        bytes memory data
    ) external payable returns (uint256);
    function depositEth(uint256) external payable returns (uint256);
    function depositEth() external payable returns (uint256);
    function getProxyAdmin() external view returns (address);
    function initialize(address _bridge, address _sequencerInbox) external;
    function isAllowed(address) external view returns (bool);
    function maxDataSize() external view returns (uint256);
    function pause() external;
    function paused() external view returns (bool);
    function postUpgradeInit(address) external;
    function sendContractTransaction(
        uint256 gasLimit,
        uint256 maxFeePerGas,
        address to,
        uint256 value,
        bytes memory data
    ) external returns (uint256);
    function sendL1FundedContractTransaction(uint256 gasLimit, uint256 maxFeePerGas, address to, bytes memory data)
        external
        payable
        returns (uint256);
    function sendL1FundedUnsignedTransaction(
        uint256 gasLimit,
        uint256 maxFeePerGas,
        uint256 nonce,
        address to,
        bytes memory data
    ) external payable returns (uint256);
    function sendL1FundedUnsignedTransactionToFork(
        uint256 gasLimit,
        uint256 maxFeePerGas,
        uint256 nonce,
        address to,
        bytes memory data
    ) external payable returns (uint256);
    function sendL2Message(bytes memory messageData) external returns (uint256);
    function sendL2MessageFromOrigin(bytes memory messageData) external returns (uint256);
    function sendUnsignedTransaction(
        uint256 gasLimit,
        uint256 maxFeePerGas,
        uint256 nonce,
        address to,
        uint256 value,
        bytes memory data
    ) external returns (uint256);
    function sendUnsignedTransactionToFork(
        uint256 gasLimit,
        uint256 maxFeePerGas,
        uint256 nonce,
        address to,
        uint256 value,
        bytes memory data
    ) external returns (uint256);
    function sendWithdrawEthToFork(
        uint256 gasLimit,
        uint256 maxFeePerGas,
        uint256 nonce,
        uint256 value,
        address withdrawTo
    ) external returns (uint256);
    function sequencerInbox() external view returns (address);
    function setAllowList(address[] memory user, bool[] memory val) external;
    function setAllowListEnabled(bool _allowListEnabled) external;
    function unpause() external;
    function unsafeCreateRetryableTicket(
        address to,
        uint256 l2CallValue,
        uint256 maxSubmissionCost,
        address excessFeeRefundAddress,
        address callValueRefundAddress,
        uint256 gasLimit,
        uint256 maxFeePerGas,
        bytes memory data
    ) external payable returns (uint256);
    function admin() external returns (address admin_);
    function changeAdmin(address newAdmin) external;
    function implementation() external returns (address implementation_);
    function upgradeTo(address newImplementation) external;
    function upgradeToAndCall(address newImplementation, bytes memory data) external payable;
}
