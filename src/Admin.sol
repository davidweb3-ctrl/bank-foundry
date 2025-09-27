// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./interfaces/IBank.sol";

/// @title Admin Contract
/// @notice Administrative contract with owner that can withdraw from IBank contracts
/// @dev Has its own owner and implements adminWithdraw(IBank bank) per latest requirements
contract Admin {
    /// @notice The owner of this Admin contract
    address public owner;
    
    /// @notice Total amount withdrawn through this admin contract
    uint256 public totalWithdrawn;
    
    /// @notice Reentrancy guard
    bool private locked;

    /// @notice Event emitted when ownership is transferred
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    
    /// @notice Event emitted when admin withdrawal is made
    event AdminWithdrawal(address indexed bankContract, uint256 amount, address indexed owner);
    
    /// @notice Event emitted when funds are received
    event FundsReceived(address indexed from, uint256 amount);

    /// @notice Modifier to restrict access to owner only
    modifier onlyOwner() {
        require(msg.sender == owner, "Admin: caller is not the owner");
        _;
    }

    /// @notice Modifier to prevent reentrancy attacks
    modifier nonReentrant() {
        require(!locked, "Admin: reentrant call");
        locked = true;
        _;
        locked = false;
    }

    /// @notice Contract constructor
    /// @param _owner Initial owner address
    constructor(address _owner) {
        require(_owner != address(0), "Admin: owner cannot be zero address");
        owner = _owner;
        emit OwnershipTransferred(address(0), _owner);
    }

    /// @notice Admin withdraw function that calls IBank's withdraw method
    /// @param bank The IBank contract to withdraw from
    /// @dev Withdraws all available funds from the bank contract to this Admin contract
    function adminWithdraw(IBank bank) external onlyOwner nonReentrant {
        require(address(bank) != address(0), "Admin: bank cannot be zero address");
        
        // Get the bank's contract balance
        uint256 bankBalance = bank.getContractBalance();
        require(bankBalance > 0, "Admin: no funds available in bank");
        
        // Store initial balance of this contract
        uint256 initialBalance = address(this).balance;
        
        // Call the bank's withdraw function - this should transfer funds to this contract
        bank.withdraw(bankBalance);
        
        // Verify funds were received
        uint256 finalBalance = address(this).balance;
        uint256 actualReceived = finalBalance - initialBalance;
        require(actualReceived > 0, "Admin: no funds received from bank");
        
        // Update total withdrawn
        totalWithdrawn += actualReceived;
        
        emit AdminWithdrawal(address(bank), actualReceived, owner);
    }

    /// @notice Partial admin withdraw function
    /// @param bank The IBank contract to withdraw from  
    /// @param amount Specific amount to withdraw
    function adminWithdrawAmount(IBank bank, uint256 amount) external onlyOwner nonReentrant {
        require(address(bank) != address(0), "Admin: bank cannot be zero address");
        require(amount > 0, "Admin: amount must be greater than 0");
        
        // Check bank has sufficient balance
        uint256 bankBalance = bank.getContractBalance();
        require(bankBalance >= amount, "Admin: insufficient bank balance");
        
        // Store initial balance of this contract
        uint256 initialBalance = address(this).balance;
        
        // Call the bank's withdraw function
        bank.withdraw(amount);
        
        // Verify funds were received
        uint256 finalBalance = address(this).balance;
        uint256 actualReceived = finalBalance - initialBalance;
        require(actualReceived > 0, "Admin: no funds received from bank");
        
        // Update total withdrawn
        totalWithdrawn += actualReceived;
        
        emit AdminWithdrawal(address(bank), actualReceived, owner);
    }

    /// @notice Transfer ownership to a new address
    /// @param newOwner New owner address
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Admin: new owner cannot be zero address");
        require(newOwner != owner, "Admin: new owner is the same as current owner");
        
        address previousOwner = owner;
        owner = newOwner;
        
        emit OwnershipTransferred(previousOwner, newOwner);
    }

    /// @notice Withdraw ETH from this Admin contract to owner
    /// @param amount Amount to withdraw to owner
    function withdrawToOwner(uint256 amount) external onlyOwner nonReentrant {
        require(amount > 0, "Admin: amount must be greater than 0");
        require(address(this).balance >= amount, "Admin: insufficient contract balance");
        
        (bool success, ) = payable(owner).call{value: amount}("");
        require(success, "Admin: transfer to owner failed");
    }

    /// @notice Withdraw all ETH from this Admin contract to owner
    function withdrawAllToOwner() external onlyOwner nonReentrant {
        uint256 balance = address(this).balance;
        require(balance > 0, "Admin: no funds to withdraw");
        
        (bool success, ) = payable(owner).call{value: balance}("");
        require(success, "Admin: transfer to owner failed");
    }

    /// @notice Get admin contract information
    /// @return ownerAddr Current owner address
    /// @return contractBalance This contract's ETH balance
    /// @return totalWithdrawnAmount Total amount withdrawn through this contract
    function getAdminInfo() external view returns (
        address ownerAddr,
        uint256 contractBalance,
        uint256 totalWithdrawnAmount
    ) {
        return (
            owner,
            address(this).balance,
            totalWithdrawn
        );
    }

    /// @notice Get bank contract information
    /// @param bank The IBank contract to query
    /// @return contractBalance Bank's ETH balance
    /// @return totalDeposits Total deposits in bank
    /// @return topDepositors Top 3 depositors
    /// @return topAmounts Corresponding amounts
    function getBankInfo(IBank bank) external view returns (
        uint256 contractBalance,
        uint256 totalDeposits,
        address[3] memory topDepositors,
        uint256[3] memory topAmounts
    ) {
        require(address(bank) != address(0), "Admin: bank cannot be zero address");
        
        contractBalance = bank.getContractBalance();
        totalDeposits = bank.getTotalDeposits();
        (topDepositors, topAmounts) = bank.getTopDepositors();
    }

    /// @notice Receive function to accept ETH
    /// @dev Emits event when funds are received
    receive() external payable {
        emit FundsReceived(msg.sender, msg.value);
    }

    /// @notice Fallback function
    fallback() external payable {
        emit FundsReceived(msg.sender, msg.value);
    }
}