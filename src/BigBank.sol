// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./Bank.sol";

/// @title BigBank Contract
/// @notice Enhanced bank contract with minimum deposit requirements, inherits from Bank
/// @dev Inherits from Bank and adds minimum deposit validation per latest requirements
contract BigBank is Bank {
    /// @notice Minimum deposit amount (0.001 ether)
    uint256 public constant MIN_DEPOSIT = 0.001 ether;

    /// @notice Event emitted when ownership is transferred
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /// @notice Modifier to ensure deposit meets minimum requirement
    modifier minDepositRequired() {
        require(msg.value >= MIN_DEPOSIT, "BigBank: deposit must be at least 0.001 ether");
        _;
    }

    /// @notice Contract constructor
    /// @dev Sets the deployer as the initial owner (inherits Bank constructor)
    constructor() {
        // Bank constructor is called automatically
    }

    /// @notice Enhanced deposit function with minimum deposit requirement
    /// @dev Uses modifier to enforce minimum deposit while maintaining Bank functionality
    function deposit() external payable override minDepositRequired {
        require(msg.value > 0, "BigBank: deposit amount must be greater than 0");
        _deposit(msg.sender, msg.value);
    }
    
    /// @notice Enhanced internal deposit function with minimum deposit requirement
    /// @param user The address making the deposit
    /// @param amount The amount being deposited
    function _deposit(address user, uint256 amount) internal override {
        require(amount >= MIN_DEPOSIT, "BigBank: deposit must be at least 0.001 ether");
        require(amount > 0, "BigBank: deposit amount must be greater than 0");
        require(user != address(0), "BigBank: invalid user address");

        // Update user balance
        balances[user] += amount;
        totalDeposits += amount;

        // Update top depositors
        _updateTopDepositors(user);

        emit Deposit(user, amount, balances[user]);
    }

    /// @notice Transfer ownership to a new address (supports transferring to Admin contract)
    /// @param newOwner The address of the new owner
    /// @dev Can transfer ownership to Admin contract per requirements
    function transferOwnership(address newOwner) external override onlyOwner {
        require(newOwner != address(0), "BigBank: new owner is the zero address");
        require(newOwner != owner, "BigBank: new owner is the same as current owner");
        
        address previousOwner = owner;
        owner = newOwner;
        
        emit OwnershipTransferred(previousOwner, newOwner);
    }

    /// @notice Get minimum deposit requirement
    /// @return The minimum deposit amount in wei
    function getMinDeposit() external pure returns (uint256) {
        return MIN_DEPOSIT;
    }

    /// @notice Check if an amount meets minimum deposit requirement
    /// @param amount Amount to check
    /// @return True if amount meets minimum requirement
    function meetsMinDeposit(uint256 amount) external pure returns (bool) {
        return amount >= MIN_DEPOSIT;
    }
}