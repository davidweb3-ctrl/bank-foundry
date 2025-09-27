// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./interfaces/IBank.sol";

/// @title Bank Contract
/// @notice A bank contract that allows deposits and tracks top depositors
/// @dev Implements access control and reentrancy protection
contract Bank is IBank {
    /// @notice The owner of the contract (admin)
    address public owner;
    
    /// @notice Mapping of user addresses to their total deposited amounts
    mapping(address => uint256) public balances;
    
    /// @notice Array storing the top 3 depositor addresses
    address[3] public topDepositorsAddresses;
    
    /// @notice Array storing the corresponding amounts for top 3 depositors
    uint256[3] public topDepositorsAmounts;
    
    /// @notice Total amount deposited across all users
    uint256 public totalDeposits;
    
    /// @notice Reentrancy guard state
    bool private locked;

    /// @notice Modifier to restrict access to owner only
    modifier onlyOwner() {
        require(msg.sender == owner, "Bank: caller is not the owner");
        _;
    }

    /// @notice Modifier to prevent reentrancy attacks
    modifier nonReentrant() {
        require(!locked, "Bank: reentrant call");
        locked = true;
        _;
        locked = false;
    }

    /// @notice Contract constructor
    /// @dev Sets the deployer as the initial owner
    constructor() {
        owner = msg.sender;
    }

    /// @notice Receive function to handle direct ETH transfers
    /// @dev Automatically calls deposit when ETH is sent directly to contract
    receive() external payable {
        if (msg.value > 0) {
            balances[msg.sender] += msg.value;
            totalDeposits += msg.value;
            emit Deposit(msg.sender, msg.value, balances[msg.sender]);
        }
    }

    /// @notice Fallback function
    /// @dev Calls deposit function for any data sent with ETH
    fallback() external payable {
        _deposit(msg.sender, msg.value);
    }

    /// @inheritdoc IBank
    function deposit() external payable virtual override {
        require(msg.value > 0, "Bank: deposit amount must be greater than 0");
        _deposit(msg.sender, msg.value);
    }

    /// @notice Internal deposit function
    /// @param user The address making the deposit
    /// @param amount The amount being deposited
    function _deposit(address user, uint256 amount) internal virtual {
        require(amount > 0, "Bank: deposit amount must be greater than 0");
        require(user != address(0), "Bank: invalid user address");

        // Update user balance
        balances[user] += amount;
        totalDeposits += amount;

        // Update top depositors
        _updateTopDepositors(user);

        emit Deposit(user, amount, balances[user]);
    }

    /// @inheritdoc IBank
    function withdraw(uint256 amount) external override onlyOwner nonReentrant {
        require(amount > 0, "Bank: withdraw amount must be greater than 0");
        require(address(this).balance >= amount, "Bank: insufficient contract balance");

        // Transfer funds to owner
        (bool success, ) = payable(owner).call{value: amount}("");
        require(success, "Bank: transfer failed");

        emit Withdraw(owner, amount);
    }

    /// @notice Updates the top depositors array when a new deposit is made
    /// @param user The address that made a deposit
    function _updateTopDepositors(address user) internal {
        uint256 userBalance = balances[user];
        
        // Check if user should be in top 3
        for (uint256 i = 0; i < 3; i++) {
            if (topDepositorsAddresses[i] == user) {
                // User already in list, update position if needed
                _sortTopDepositors();
                emit TopDepositorsUpdated(topDepositorsAddresses, topDepositorsAmounts);
                return;
            }
        }
        
        // Check if user should enter top 3
        for (uint256 i = 0; i < 3; i++) {
            if (topDepositorsAddresses[i] == address(0) || userBalance > topDepositorsAmounts[i]) {
                // Insert user at position i and shift others
                _insertAtPosition(user, userBalance, i);
                emit TopDepositorsUpdated(topDepositorsAddresses, topDepositorsAmounts);
                return;
            }
        }
    }

    /// @notice Inserts a user at a specific position in the top depositors array
    /// @param user The user address to insert
    /// @param amount The user's deposit amount
    /// @param position The position to insert at (0-2)
    function _insertAtPosition(address user, uint256 amount, uint256 position) internal {
        // Shift elements to the right
        for (uint256 i = 2; i > position; i--) {
            topDepositorsAddresses[i] = topDepositorsAddresses[i - 1];
            topDepositorsAmounts[i] = topDepositorsAmounts[i - 1];
        }
        
        // Insert new user
        topDepositorsAddresses[position] = user;
        topDepositorsAmounts[position] = amount;
    }

    /// @notice Sorts the top depositors array to maintain descending order
    function _sortTopDepositors() internal {
        // Update amounts for existing addresses
        for (uint256 i = 0; i < 3; i++) {
            if (topDepositorsAddresses[i] != address(0)) {
                topDepositorsAmounts[i] = balances[topDepositorsAddresses[i]];
            }
        }
        
        // Simple bubble sort for 3 elements
        for (uint256 i = 0; i < 2; i++) {
            for (uint256 j = 0; j < 2 - i; j++) {
                if (topDepositorsAmounts[j] < topDepositorsAmounts[j + 1]) {
                    // Swap amounts
                    uint256 tempAmount = topDepositorsAmounts[j];
                    topDepositorsAmounts[j] = topDepositorsAmounts[j + 1];
                    topDepositorsAmounts[j + 1] = tempAmount;
                    
                    // Swap addresses
                    address tempAddress = topDepositorsAddresses[j];
                    topDepositorsAddresses[j] = topDepositorsAddresses[j + 1];
                    topDepositorsAddresses[j + 1] = tempAddress;
                }
            }
        }
    }

    /// @inheritdoc IBank
    function getBalance(address user) external view override returns (uint256) {
        return balances[user];
    }

    /// @inheritdoc IBank
    function getTopDepositors() external view override returns (address[3] memory addresses, uint256[3] memory amounts) {
        return (topDepositorsAddresses, topDepositorsAmounts);
    }

    /// @inheritdoc IBank
    function getTotalDeposits() external view override returns (uint256) {
        return totalDeposits;
    }

    /// @inheritdoc IBank
    function getContractBalance() external view override returns (uint256) {
        return address(this).balance;
    }

    /// @notice Transfer ownership to a new address
    /// @param newOwner The address of the new owner
    function transferOwnership(address newOwner) external virtual onlyOwner {
        require(newOwner != address(0), "Bank: new owner is the zero address");
        owner = newOwner;
    }

    /// @notice Get contract information
    /// @return contractBalance Current contract ETH balance
    /// @return totalDep Total deposits made
    /// @return ownerAddr Current owner address
    function getContractInfo() external view returns (uint256 contractBalance, uint256 totalDep, address ownerAddr) {
        return (address(this).balance, totalDeposits, owner);
    }
}
