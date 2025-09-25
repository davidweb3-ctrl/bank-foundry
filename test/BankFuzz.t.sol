// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/Bank.sol";
import "./utils/TestHelper.sol";

/// @title Bank Fuzz Tests
/// @notice Fuzz testing for Bank contract edge cases and security
contract BankFuzzTest is TestHelper {
    Bank public bank;
    address public owner;

    function setUp() public {
        owner = makeAddr("owner");
        vm.deal(owner, 1000 ether);
        
        vm.prank(owner);
        bank = new Bank();
    }

    /// @notice Fuzz test for deposit amounts
    function testFuzzDepositAmount(uint256 amount) public {
        // Bound amount to reasonable values
        amount = bound(amount, 1, 1000 ether);
        
        address user = makeAddr("fuzzer");
        vm.deal(user, amount);
        
        vm.prank(user);
        bank.deposit{value: amount}();
        
        assertEq(bank.getBalance(user), amount);
        assertEq(bank.getTotalDeposits(), amount);
        assertEq(bank.getContractBalance(), amount);
    }

    /// @notice Fuzz test for multiple random deposits
    function testFuzzMultipleRandomDeposits(
        uint256[10] memory amounts,
        uint8[10] memory userIndexes
    ) public {
        // Create test users
        address[] memory users = createFundedAddresses(5, 1000 ether);
        uint256 totalExpected = 0;
        
        for (uint256 i = 0; i < 10; i++) {
            // Bound inputs
            amounts[i] = bound(amounts[i], 1, 50 ether);
            userIndexes[i] = uint8(bound(userIndexes[i], 0, 4));
            
            address currentUser = users[userIndexes[i]];
            totalExpected += amounts[i];
            
            vm.prank(currentUser);
            bank.deposit{value: amounts[i]}();
        }
        
        assertEq(bank.getTotalDeposits(), totalExpected);
        
        // Verify top depositors are sorted
        (, uint256[3] memory topAmounts) = bank.getTopDepositors();
        assertTrue(isTopDepositorsSorted(topAmounts));
    }

    /// @notice Fuzz test for withdraw operations
    function testFuzzWithdraw(uint256 depositAmount, uint256 withdrawAmount) public {
        // Bound amounts
        depositAmount = bound(depositAmount, 1 ether, 100 ether);
        withdrawAmount = bound(withdrawAmount, 1, depositAmount);
        
        // Make deposit
        address user = makeAddr("depositor");
        vm.deal(user, depositAmount);
        vm.prank(user);
        bank.deposit{value: depositAmount}();
        
        // Test withdraw
        uint256 ownerBalanceBefore = owner.balance;
        vm.prank(owner);
        bank.withdraw(withdrawAmount);
        
        assertEq(owner.balance, ownerBalanceBefore + withdrawAmount);
        assertEq(bank.getContractBalance(), depositAmount - withdrawAmount);
    }

    /// @notice Fuzz test for top depositors with random amounts
    function testFuzzTopDepositors(uint256[7] memory amounts) public {
        address[] memory users = createFundedAddresses(7, 1000 ether);
        
        // Bound amounts and make deposits
        for (uint256 i = 0; i < 7; i++) {
            amounts[i] = bound(amounts[i], 1, 100 ether);
            
            vm.prank(users[i]);
            bank.deposit{value: amounts[i]}();
        }
        
        // Get top depositors
        (address[3] memory topAddresses, uint256[3] memory topAmounts) = bank.getTopDepositors();
        
        // Verify sorting
        assertTrue(isTopDepositorsSorted(topAmounts));
        
        // Verify top amounts match actual balances
        for (uint256 i = 0; i < 3; i++) {
            if (topAddresses[i] != address(0)) {
                assertEq(topAmounts[i], bank.getBalance(topAddresses[i]));
            }
        }
        
        // Verify top 3 are actually the highest
        for (uint256 i = 0; i < 7; i++) {
            uint256 userBalance = bank.getBalance(users[i]);
            bool isInTop3 = isInTopDepositors(users[i], topAddresses);
            
            // If user is not in top 3, their balance should be <= the lowest top 3 balance
            if (!isInTop3 && topAmounts[2] > 0) {
                assertLe(userBalance, topAmounts[2]);
            }
        }
    }

    /// @notice Fuzz test for edge cases with zero addresses and amounts
    function testFuzzEdgeCases(uint256 amount, bool useZeroAmount) public {
        if (useZeroAmount) {
            // Test zero amount deposits should fail
            address user = makeAddr("zeroUser");
            vm.deal(user, 1 ether);
            
            vm.prank(user);
            vm.expectRevert("Bank: deposit amount must be greater than 0");
            bank.deposit{value: 0}();
        } else {
            // Test normal deposits
            amount = bound(amount, 1, 1000 ether);
            address user = makeAddr("normalUser");
            vm.deal(user, amount);
            
            vm.prank(user);
            bank.deposit{value: amount}();
            
            assertEq(bank.getBalance(user), amount);
        }
    }

    /// @notice Fuzz test for ownership transfer
    function testFuzzOwnershipTransfer(address newOwner) public {
        vm.assume(newOwner != address(0) && newOwner != owner);
        vm.assume(newOwner.code.length == 0); // Not a contract
        
        vm.prank(owner);
        bank.transferOwnership(newOwner);
        
        assertEq(bank.owner(), newOwner);
        
        // Test that old owner can't withdraw
        address depositor = makeAddr("depositor");
        vm.deal(depositor, 1 ether);
        vm.prank(depositor);
        bank.deposit{value: 1 ether}();
        
        vm.prank(owner);
        vm.expectRevert("Bank: caller is not the owner");
        bank.withdraw(0.5 ether);
        
        // Test that new owner can withdraw
        vm.prank(newOwner);
        bank.withdraw(0.5 ether);
    }

    /// @notice Fuzz test for gas usage optimization
    function testFuzzGasUsage(uint256[5] memory amounts) public {
        address[] memory users = createFundedAddresses(5, 1000 ether);
        
        for (uint256 i = 0; i < 5; i++) {
            amounts[i] = bound(amounts[i], 1, 10 ether);
            
            vm.prank(users[i]);
            uint256 gasBefore = gasleft();
            bank.deposit{value: amounts[i]}();
            uint256 gasUsed = gasBefore - gasleft();
            
            // Gas usage should be reasonable
            assertTrue(gasUsed < 300000, "Gas usage too high for deposit");
        }
    }

    /// @notice Fuzz test for contract balance consistency
    function testFuzzBalanceConsistency(uint256[3] memory amounts) public {
        address[] memory users = createFundedAddresses(3, 1000 ether);
        uint256 totalDeposited = 0;
        
        // Make deposits
        for (uint256 i = 0; i < 3; i++) {
            amounts[i] = bound(amounts[i], 1, 50 ether);
            totalDeposited += amounts[i];
            
            vm.prank(users[i]);
            bank.deposit{value: amounts[i]}();
        }
        
        assertEq(bank.getTotalDeposits(), totalDeposited);
        assertEq(bank.getContractBalance(), totalDeposited);
        
        // Test partial withdrawal
        uint256 withdrawAmount = bound(totalDeposited / 2, 1, totalDeposited);
        
        vm.prank(owner);
        bank.withdraw(withdrawAmount);
        
        assertEq(bank.getContractBalance(), totalDeposited - withdrawAmount);
        // Total deposits should remain the same (it tracks deposits, not current balance)
        assertEq(bank.getTotalDeposits(), totalDeposited);
    }
}
