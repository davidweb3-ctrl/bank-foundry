// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @title IBank Interface
/// @notice Interface for the Bank contract that manages deposits and top depositors
/// @dev This interface defines all external functions and events for the Bank contract
interface IBank {
    /// @notice Emitted when a user makes a deposit
    /// @param user The address of the depositor
    /// @param amount The amount deposited in wei
    /// @param newBalance The user's new total balance after deposit
    event Deposit(address indexed user, uint256 amount, uint256 newBalance);
    
    /// @notice Emitted when the admin withdraws funds
    /// @param admin The address of the admin
    /// @param amount The amount withdrawn in wei
    event Withdraw(address indexed admin, uint256 amount);
    
    /// @notice Emitted when the top depositors ranking is updated
    /// @param topUsers Array of top 3 depositor addresses
    /// @param topAmounts Array of corresponding deposit amounts
    event TopDepositorsUpdated(address[3] topUsers, uint256[3] topAmounts);

    /// @notice Allows users to deposit ETH into the contract
    /// @dev This function should be payable and update user balances
    function deposit() external payable;

    /// @notice Allows the admin to withdraw funds from the contract
    /// @param amount The amount to withdraw in wei
    /// @dev Only the contract owner should be able to call this function
    function withdraw(uint256 amount) external;

    /// @notice Gets the balance of a specific user
    /// @param user The address to query
    /// @return The user's total deposited balance
    function getBalance(address user) external view returns (uint256);

    /// @notice Gets the top 3 depositors and their amounts
    /// @return addresses Array of top 3 depositor addresses
    /// @return amounts Array of corresponding deposit amounts
    function getTopDepositors() external view returns (address[3] memory addresses, uint256[3] memory amounts);

    /// @notice Gets the total amount deposited in the contract
    /// @return The total deposit amount across all users
    function getTotalDeposits() external view returns (uint256);

    /// @notice Gets the contract's current ETH balance
    /// @return The contract's ETH balance
    function getContractBalance() external view returns (uint256);
}
