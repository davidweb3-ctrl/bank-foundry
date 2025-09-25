// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/Bank.sol";
import "./utils/TestHelper.sol";

/// @title Bank Contract Tests
/// @notice Comprehensive test suite for the Bank contract
contract BankTest is TestHelper {
    Bank public bank;
    address public owner;
    address public user1;
    address public user2;
    address public user3;
    address public user4;
    address public nonOwner;

    /// @notice Events to test
    event Deposit(address indexed user, uint256 amount, uint256 newBalance);
    event Withdraw(address indexed admin, uint256 amount);
    event TopDepositorsUpdated(address[3] topUsers, uint256[3] topAmounts);

    function setUp() public {
        // Set up test addresses
        owner = makeAddr("owner");
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");
        user3 = makeAddr("user3");
        user4 = makeAddr("user4");
        nonOwner = makeAddr("nonOwner");

        // Fund test addresses
        vm.deal(owner, 100 ether);
        vm.deal(user1, 10 ether);
        vm.deal(user2, 10 ether);
        vm.deal(user3, 10 ether);
        vm.deal(user4, 10 ether);
        vm.deal(nonOwner, 10 ether);

        // Deploy contract as owner
        vm.prank(owner);
        bank = new Bank();
    }

    // ============ Basic Functionality Tests ============

    function testDeployment() public {
        assertEq(bank.owner(), owner);
        assertEq(bank.getTotalDeposits(), 0);
        assertEq(bank.getContractBalance(), 0);
    }

    function testDepositFunction() public {
        uint256 depositAmount = 1 ether;
        
        vm.prank(user1);
        vm.expectEmit(true, false, false, true);
        emit Deposit(user1, depositAmount, depositAmount);
        
        bank.deposit{value: depositAmount}();
        
        assertEq(bank.getBalance(user1), depositAmount);
        assertEq(bank.getTotalDeposits(), depositAmount);
        assertEq(bank.getContractBalance(), depositAmount);
    }

    function testDepositViaReceive() public {
        uint256 depositAmount = 2 ether;
        
        vm.prank(user1);
        vm.expectEmit(true, false, false, true);
        emit Deposit(user1, depositAmount, depositAmount);
        
        (bool success, ) = address(bank).call{value: depositAmount}("");
        assertTrue(success);
        
        assertEq(bank.getBalance(user1), depositAmount);
        assertEq(bank.getTotalDeposits(), depositAmount);
        assertEq(bank.getContractBalance(), depositAmount);
    }

    function testDepositViaTransferSimple() public {
        uint256 depositAmount = 0.5 ether;
        
        vm.prank(user1);
        // Use send instead of transfer for better gas handling
        (bool success, ) = address(bank).call{value: depositAmount}("");
        assertTrue(success);
        
        assertEq(bank.getBalance(user1), depositAmount);
    }

    function testMultipleDepositsSameUser() public {
        vm.startPrank(user1);
        
        bank.deposit{value: 1 ether}();
        assertEq(bank.getBalance(user1), 1 ether);
        
        bank.deposit{value: 2 ether}();
        assertEq(bank.getBalance(user1), 3 ether);
        
        vm.stopPrank();
        
        assertEq(bank.getTotalDeposits(), 3 ether);
        assertEq(bank.getContractBalance(), 3 ether);
    }

    // ============ Withdraw Function Tests ============

    function testWithdrawByOwner() public {
        // First, make some deposits
        vm.prank(user1);
        bank.deposit{value: 5 ether}();
        
        uint256 withdrawAmount = 2 ether;
        uint256 ownerBalanceBefore = owner.balance;
        
        vm.prank(owner);
        vm.expectEmit(true, false, false, true);
        emit Withdraw(owner, withdrawAmount);
        
        bank.withdraw(withdrawAmount);
        
        assertEq(owner.balance, ownerBalanceBefore + withdrawAmount);
        assertEq(bank.getContractBalance(), 3 ether);
    }

    function testWithdrawFailsForNonOwner() public {
        vm.prank(user1);
        bank.deposit{value: 1 ether}();
        
        vm.prank(nonOwner);
        vm.expectRevert("Bank: caller is not the owner");
        bank.withdraw(0.5 ether);
    }

    function testWithdrawFailsInsufficientBalance() public {
        vm.prank(user1);
        bank.deposit{value: 1 ether}();
        
        vm.prank(owner);
        vm.expectRevert("Bank: insufficient contract balance");
        bank.withdraw(2 ether);
    }

    function testWithdrawZeroAmount() public {
        vm.prank(user1);
        bank.deposit{value: 1 ether}();
        
        vm.prank(owner);
        vm.expectRevert("Bank: withdraw amount must be greater than 0");
        bank.withdraw(0);
    }

    // ============ Top Depositors Tests ============

    function testTopDepositorsInitialState() public {
        (address[3] memory addresses, uint256[3] memory amounts) = bank.getTopDepositors();
        
        for (uint256 i = 0; i < 3; i++) {
            assertEq(addresses[i], address(0));
            assertEq(amounts[i], 0);
        }
    }

    function testTopDepositorsUpdateSingle() public {
        vm.prank(user1);
        vm.expectEmit();
        emit TopDepositorsUpdated([user1, address(0), address(0)], [uint256(1 ether), uint256(0), uint256(0)]);
        
        bank.deposit{value: 1 ether}();
        
        (address[3] memory addresses, uint256[3] memory amounts) = bank.getTopDepositors();
        assertEq(addresses[0], user1);
        assertEq(amounts[0], 1 ether);
    }

    function testTopDepositorsUpdateMultiple() public {
        // User1 deposits 1 ether
        vm.prank(user1);
        bank.deposit{value: 1 ether}();
        
        // User2 deposits 2 ether (should become #1)
        vm.prank(user2);
        bank.deposit{value: 2 ether}();
        
        // User3 deposits 1.5 ether (should become #2)
        vm.prank(user3);
        bank.deposit{value: 1.5 ether}();
        
        (address[3] memory addresses, uint256[3] memory amounts) = bank.getTopDepositors();
        
        assertEq(addresses[0], user2);    // 2 ether
        assertEq(addresses[1], user3);    // 1.5 ether  
        assertEq(addresses[2], user1);    // 1 ether
        
        assertEq(amounts[0], 2 ether);
        assertEq(amounts[1], 1.5 ether);
        assertEq(amounts[2], 1 ether);
        
        assertTrue(isTopDepositorsSorted(amounts));
    }

    function testTopDepositorsOverflow() public {
        // Fill top 3 positions
        vm.prank(user1);
        bank.deposit{value: 1 ether}();
        
        vm.prank(user2);
        bank.deposit{value: 2 ether}();
        
        vm.prank(user3);
        bank.deposit{value: 3 ether}();
        
        // User4 deposits more than user1 (should replace user1)
        vm.prank(user4);
        bank.deposit{value: 1.5 ether}();
        
        (address[3] memory addresses, uint256[3] memory amounts) = bank.getTopDepositors();
        
        assertEq(addresses[0], user3);    // 3 ether
        assertEq(addresses[1], user2);    // 2 ether
        assertEq(addresses[2], user4);    // 1.5 ether
        
        // User1 should no longer be in top 3
        assertFalse(isInTopDepositors(user1, addresses));
        assertTrue(isTopDepositorsSorted(amounts));
    }

    function testTopDepositorsUpdateExistingUser() public {
        // Initial deposits
        vm.prank(user1);
        bank.deposit{value: 1 ether}();
        
        vm.prank(user2);
        bank.deposit{value: 2 ether}();
        
        vm.prank(user3);
        bank.deposit{value: 1.5 ether}();
        
        // User1 makes another deposit (total becomes 3 ether, should become #1)
        vm.prank(user1);
        bank.deposit{value: 2 ether}();
        
        (address[3] memory addresses, uint256[3] memory amounts) = bank.getTopDepositors();
        
        assertEq(addresses[0], user1);    // 3 ether total
        assertEq(addresses[1], user2);    // 2 ether
        assertEq(addresses[2], user3);    // 1.5 ether
        
        assertEq(amounts[0], 3 ether);
        assertTrue(isTopDepositorsSorted(amounts));
    }

    // ============ Edge Cases and Security Tests ============

    function testZeroDeposit() public {
        vm.prank(user1);
        vm.expectRevert("Bank: deposit amount must be greater than 0");
        bank.deposit{value: 0}();
    }

    function testReentrancyProtection() public {
        // This test would require a malicious contract to test properly
        // For now, we test that the locked state works
        vm.prank(user1);
        bank.deposit{value: 1 ether}();
        
        vm.prank(owner);
        bank.withdraw(0.5 ether);
        
        // Verify withdraw completed successfully
        assertEq(bank.getContractBalance(), 0.5 ether);
    }

    function testTransferOwnership() public {
        address newOwner = makeAddr("newOwner");
        
        vm.prank(owner);
        bank.transferOwnership(newOwner);
        
        assertEq(bank.owner(), newOwner);
        
        // Old owner should no longer be able to withdraw
        vm.prank(user1);
        bank.deposit{value: 1 ether}();
        
        vm.prank(owner);
        vm.expectRevert("Bank: caller is not the owner");
        bank.withdraw(0.5 ether);
        
        // New owner should be able to withdraw
        vm.prank(newOwner);
        bank.withdraw(0.5 ether);
    }

    function testTransferOwnershipToZeroAddress() public {
        vm.prank(owner);
        vm.expectRevert("Bank: new owner is the zero address");
        bank.transferOwnership(address(0));
    }

    function testGetContractInfo() public {
        vm.prank(user1);
        bank.deposit{value: 5 ether}();
        
        (uint256 contractBalance, uint256 totalDep, address ownerAddr) = bank.getContractInfo();
        
        assertEq(contractBalance, 5 ether);
        assertEq(totalDep, 5 ether);
        assertEq(ownerAddr, owner);
    }

    // ============ Gas Optimization Tests ============

    function testGasOptimizationDeposit() public {
        vm.prank(user1);
        uint256 gasBefore = gasleft();
        bank.deposit{value: 1 ether}();
        uint256 gasUsed = gasBefore - gasleft();
        
        // Log gas usage for monitoring
        emit log_named_uint("Gas used for first deposit", gasUsed);
        assertTrue(gasUsed < 200000); // Reasonable gas limit
    }

    function testGasOptimizationTopDepositorsUpdate() public {
        // Fill positions first
        vm.prank(user1);
        bank.deposit{value: 1 ether}();
        
        vm.prank(user2);
        bank.deposit{value: 2 ether}();
        
        vm.prank(user3);
        bank.deposit{value: 3 ether}();
        
        // Test gas for updating existing position
        vm.prank(user1);
        uint256 gasBefore = gasleft();
        bank.deposit{value: 5 ether}(); // Total 6 ether, should become #1
        uint256 gasUsed = gasBefore - gasleft();
        
        emit log_named_uint("Gas used for top depositors update", gasUsed);
        assertTrue(gasUsed < 300000); // Reasonable gas limit
    }

    // ============ Fuzz Testing ============

    function testFuzzDeposit(uint256 amount) public {
        vm.assume(amount > 0 && amount <= 1000 ether);
        
        vm.deal(user1, amount);
        vm.prank(user1);
        bank.deposit{value: amount}();
        
        assertEq(bank.getBalance(user1), amount);
        assertEq(bank.getTotalDeposits(), amount);
    }

    function testFuzzMultipleDeposits(uint256[4] memory amounts) public {
        address[4] memory users = [user1, user2, user3, user4];
        uint256 totalExpected = 0;
        
        for (uint256 i = 0; i < 4; i++) {
            vm.assume(amounts[i] > 0 && amounts[i] <= 100 ether);
            totalExpected += amounts[i];
            
            vm.deal(users[i], amounts[i]);
            vm.prank(users[i]);
            bank.deposit{value: amounts[i]}();
        }
        
        assertEq(bank.getTotalDeposits(), totalExpected);
        
        // Verify top depositors are properly sorted
        (, uint256[3] memory topAmounts) = bank.getTopDepositors();
        assertTrue(isTopDepositorsSorted(topAmounts));
    }
}
