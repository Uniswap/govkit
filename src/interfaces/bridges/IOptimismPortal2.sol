// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

interface IOptimismPortal2 {
    // Structs
    struct WithdrawalTransaction {
        uint256 nonce;
        address sender;
        address target;
        uint256 value;
        uint256 gasLimit;
        bytes data;
    }

    struct OutputRootProof {
        bytes32 version;
        bytes32 stateRoot;
        bytes32 messagePasserStorageRoot;
        bytes32 latestBlockhash;
    }

    // Events
    event Initialized(uint8 version);
    event TransactionDeposited(address indexed from, address indexed to, uint256 indexed version, bytes opaqueData);
    event WithdrawalFinalized(bytes32 indexed withdrawalHash, bool success);
    event WithdrawalProven(bytes32 indexed withdrawalHash, address indexed from, address indexed to);
    event WithdrawalProvenExtension1(bytes32 indexed withdrawalHash, address indexed proofSubmitter);
    event AdminChanged(address previousAdmin, address newAdmin);
    event Upgraded(address indexed implementation);

    // Errors
    error ContentLengthMismatch();
    error EmptyItem();
    error InvalidDataRemainder();
    error InvalidHeader();
    error OptimismPortal_AlreadyFinalized();
    error OptimismPortal_BadTarget();
    error OptimismPortal_CallPaused();
    error OptimismPortal_CalldataTooLarge();
    error OptimismPortal_GasEstimation();
    error OptimismPortal_GasLimitTooLow();
    error OptimismPortal_ImproperDisputeGame();
    error OptimismPortal_InsufficientDeposit();
    error OptimismPortal_InvalidDisputeGame();
    error OptimismPortal_InvalidGasToken();
    error OptimismPortal_InvalidLockboxState();
    error OptimismPortal_InvalidMerkleProof();
    error OptimismPortal_InvalidOutputRootProof();
    error OptimismPortal_InvalidProofTimestamp();
    error OptimismPortal_InvalidRootClaim();
    error OptimismPortal_NoReentrancy();
    error OptimismPortal_NotAllowedOnCGTMode();
    error OptimismPortal_OnlyCustomGasToken();
    error OptimismPortal_ProofNotOldEnough();
    error OptimismPortal_Unproven();
    error OutOfGas();
    error ProxyAdminOwnedBase_NotProxyAdmin();
    error ProxyAdminOwnedBase_NotProxyAdminOrProxyAdminOwner();
    error ProxyAdminOwnedBase_NotProxyAdminOwner();
    error ProxyAdminOwnedBase_NotResolvedDelegateProxy();
    error ProxyAdminOwnedBase_NotSharedProxyAdminOwner();
    error ProxyAdminOwnedBase_ProxyAdminNotFound();
    error ReinitializableBase_ZeroInitVersion();
    error UnexpectedList();
    error UnexpectedString();

    // Functions
    function anchorStateRegistry() external view returns (address);
    function checkWithdrawal(bytes32 _withdrawalHash, address _proofSubmitter) external view;
    function depositERC20Transaction(
        address _to,
        uint256 _mint,
        uint256 _value,
        uint64 _gasLimit,
        bool _isCreation,
        bytes memory _data
    ) external;
    function depositTransaction(address _to, uint256 _value, uint64 _gasLimit, bool _isCreation, bytes memory _data)
        external
        payable;
    function disputeGameBlacklist(address _disputeGame) external view returns (bool);
    function disputeGameFactory() external view returns (address);
    function disputeGameFinalityDelaySeconds() external view returns (uint256);
    function donateETH() external payable;
    function ethLockbox() external view returns (address);
    function finalizeWithdrawalTransaction(WithdrawalTransaction memory _tx) external;
    function finalizeWithdrawalTransactionExternalProof(WithdrawalTransaction memory _tx, address _proofSubmitter)
        external;
    function finalizedWithdrawals(bytes32) external view returns (bool);
    function guardian() external view returns (address);
    function initVersion() external view returns (uint8);
    function initialize(address _systemConfig, address _anchorStateRegistry) external;
    function l2Sender() external view returns (address);
    function minimumGasLimit(uint64 _byteCount) external pure returns (uint64);
    function numProofSubmitters(bytes32 _withdrawalHash) external view returns (uint256);
    function params() external view returns (uint128 prevBaseFee, uint64 prevBoughtGas, uint64 prevBlockNum);
    function paused() external view returns (bool);
    function proofMaturityDelaySeconds() external view returns (uint256);
    function proofSubmitters(bytes32, uint256) external view returns (address);
    function proveWithdrawalTransaction(
        WithdrawalTransaction memory _tx,
        uint256 _disputeGameIndex,
        OutputRootProof memory _outputRootProof,
        bytes[] memory _withdrawalProof
    ) external;
    function provenWithdrawals(bytes32, address) external view returns (address disputeGameProxy, uint64 timestamp);
    function proxyAdmin() external view returns (address);
    function proxyAdminOwner() external view returns (address);
    function respectedGameType() external view returns (uint32);
    function respectedGameTypeUpdatedAt() external view returns (uint64);
    function superchainConfig() external view returns (address);
    function systemConfig() external view returns (address);
    function version() external pure returns (string memory);
    function admin() external returns (address);
    function changeAdmin(address _admin) external;
    function implementation() external returns (address);
    function upgradeTo(address _implementation) external;
    function upgradeToAndCall(address _implementation, bytes memory _data) external payable returns (bytes memory);
}
