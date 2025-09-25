// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../../src/Bank.sol";

/// @title Bank Deposit Interaction Script
/// @notice Script to interact with deployed Bank contract for deposits
contract DepositScript is Script {
    function run() external {
        // Get configuration from environment
        address bankAddress = vm.envAddress("BANK_CONTRACT_ADDRESS");
        uint256 userPrivateKey = vm.envUint("USER_PRIVATE_KEY");
        uint256 depositAmount = vm.envUint("DEPOSIT_AMOUNT"); // Amount in wei
        
        address user = vm.addr(userPrivateKey);
        Bank bank = Bank(payable(bankAddress));
        
        // Bank Deposit Interaction
        
        // Check user has sufficient balance
        require(user.balance >= depositAmount, "Insufficient user balance");
        
        // Get initial state
        uint256 initialUserBalance = bank.getBalance(user);
        uint256 initialTotalDeposits = bank.getTotalDeposits();
        uint256 initialContractBalance = bank.getContractBalance();
        
        // Record initial state
        
        // Start broadcasting
        vm.startBroadcast(userPrivateKey);
        
        // Make deposit
        bank.deposit{value: depositAmount}();
        
        vm.stopBroadcast();
        
        // Check final state
        uint256 finalUserBalance = bank.getBalance(user);
        uint256 finalTotalDeposits = bank.getTotalDeposits();
        uint256 finalContractBalance = bank.getContractBalance();
        
        // Get top depositors
        (address[3] memory topAddresses, uint256[3] memory topAmounts) = bank.getTopDepositors();
        
        // Verify deposit
        require(finalUserBalance == initialUserBalance + depositAmount, "User balance not updated correctly");
        require(finalTotalDeposits == initialTotalDeposits + depositAmount, "Total deposits not updated correctly");
        require(finalContractBalance == initialContractBalance + depositAmount, "Contract balance not updated correctly");
        
        // Deposit successful
    }
    
    /// @notice Helper function to deposit a specific amount for testing
    /// @param bankAddress The Bank contract address
    /// @param amount Amount to deposit in ether (will be converted to wei)
    function depositEther(address bankAddress, uint256 amount) external {
        uint256 userPrivateKey = vm.envUint("USER_PRIVATE_KEY");
        Bank bank = Bank(payable(bankAddress));
        
        vm.startBroadcast(userPrivateKey);
        bank.deposit{value: amount * 1 ether}();
        vm.stopBroadcast();
        
        // Deposited ETH to bank
    }
}
