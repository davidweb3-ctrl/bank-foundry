// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../../src/Bank.sol";

/// @title Bank Withdraw Interaction Script
/// @notice Script to interact with deployed Bank contract for withdrawals (admin only)
contract WithdrawScript is Script {
    function run() external {
        // Get configuration from environment
        address bankAddress = vm.envAddress("BANK_CONTRACT_ADDRESS");
        uint256 adminPrivateKey = vm.envUint("ADMIN_PRIVATE_KEY");
        uint256 withdrawAmount = vm.envUint("WITHDRAW_AMOUNT"); // Amount in wei
        
        address admin = vm.addr(adminPrivateKey);
        Bank bank = Bank(payable(bankAddress));
        
        // Bank Withdraw Interaction
        
        // Verify admin is the owner
        require(bank.owner() == admin, "Admin is not the contract owner");
        
        // Get initial state
        uint256 initialAdminBalance = admin.balance;
        uint256 initialContractBalance = bank.getContractBalance();
        uint256 totalDeposits = bank.getTotalDeposits();
        
        // Record initial state
        
        // Check contract has sufficient balance
        require(initialContractBalance >= withdrawAmount, "Insufficient contract balance");
        
        // Start broadcasting
        vm.startBroadcast(adminPrivateKey);
        
        // Perform withdrawal
        bank.withdraw(withdrawAmount);
        
        vm.stopBroadcast();
        
        // Check final state
        uint256 finalAdminBalance = admin.balance;
        uint256 finalContractBalance = bank.getContractBalance();
        
        // Record final state
        
        // Verify withdrawal
        require(finalAdminBalance >= initialAdminBalance + withdrawAmount, "Admin balance not increased correctly");
        require(finalContractBalance == initialContractBalance - withdrawAmount, "Contract balance not decreased correctly");
        
        // Withdrawal successful
    }
    
    /// @notice Helper function to withdraw all funds
    /// @param bankAddress The Bank contract address
    function withdrawAll(address bankAddress) external {
        uint256 adminPrivateKey = vm.envUint("ADMIN_PRIVATE_KEY");
        Bank bank = Bank(payable(bankAddress));
        
        uint256 contractBalance = bank.getContractBalance();
        require(contractBalance > 0, "No funds to withdraw");
        
        vm.startBroadcast(adminPrivateKey);
        bank.withdraw(contractBalance);
        vm.stopBroadcast();
        
        // Withdrew all funds
    }
    
    /// @notice Helper function to withdraw a percentage of contract balance
    /// @param bankAddress The Bank contract address
    /// @param percentage Percentage to withdraw (1-100)
    function withdrawPercentage(address bankAddress, uint256 percentage) external {
        require(percentage > 0 && percentage <= 100, "Invalid percentage");
        
        uint256 adminPrivateKey = vm.envUint("ADMIN_PRIVATE_KEY");
        Bank bank = Bank(payable(bankAddress));
        
        uint256 contractBalance = bank.getContractBalance();
        uint256 withdrawAmount = (contractBalance * percentage) / 100;
        
        require(withdrawAmount > 0, "Withdraw amount is zero");
        
        vm.startBroadcast(adminPrivateKey);
        bank.withdraw(withdrawAmount);
        vm.stopBroadcast();
        
        // Withdrew percentage of funds
    }
}
