// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/Bank.sol";
import "../src/BigBank.sol";
import "../src/Admin.sol";
import "../src/interfaces/IBank.sol";

/// @title New Workflow Test
/// @notice Tests the complete workflow according to latest requirements
contract NewWorkflowTest is Test {
    Bank public bank;
    BigBank public bigBank;
    Admin public admin;
    
    address public deployer;
    address public adminOwner;
    address public user1;
    address public user2;
    address public user3;
    
    /// @notice Events to test
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event AdminWithdrawal(address indexed bankContract, uint256 amount, address indexed owner);
    event Deposit(address indexed user, uint256 amount, uint256 newBalance);

    function setUp() public {
        // Set up test addresses
        deployer = makeAddr("deployer");
        adminOwner = makeAddr("adminOwner");
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");
        user3 = makeAddr("user3");

        // Fund addresses
        vm.deal(deployer, 100 ether);
        vm.deal(adminOwner, 10 ether);
        vm.deal(user1, 10 ether);
        vm.deal(user2, 10 ether);
        vm.deal(user3, 10 ether);

        // Deploy contracts as deployer
        vm.startPrank(deployer);
        
        // Deploy Bank contract
        bank = new Bank();
        
        // Deploy BigBank contract
        bigBank = new BigBank();
        
        vm.stopPrank();
        
        // Deploy Admin contract with adminOwner as owner
        vm.prank(adminOwner);
        admin = new Admin(adminOwner);
    }

    /// @notice Test that Bank implements IBank interface
    function testBankImplementsIBank() public {
        // Test that Bank contract supports IBank interface
        IBank ibank = IBank(address(bank));
        
        // Test basic interface methods exist and work
        assertEq(ibank.getTotalDeposits(), 0);
        assertEq(ibank.getContractBalance(), 0);
        
        // Test deposit through interface
        vm.prank(user1);
        ibank.deposit{value: 1 ether}();
        
        assertEq(ibank.getBalance(user1), 1 ether);
        assertEq(ibank.getTotalDeposits(), 1 ether);
    }

    /// @notice Test that BigBank inherits from Bank
    function testBigBankInheritsBank() public {
        // BigBank should have all Bank functionality
        assertEq(bigBank.getTotalDeposits(), 0);
        assertEq(bigBank.getContractBalance(), 0);
        assertEq(bigBank.owner(), deployer);
        
        // Test inheritance with minimum deposit
        vm.prank(user1);
        bigBank.deposit{value: 0.001 ether}();
        
        assertEq(bigBank.getBalance(user1), 0.001 ether);
        
        // Test that it still maintains top depositors (inherited functionality)
        (address[3] memory addresses, uint256[3] memory amounts) = bigBank.getTopDepositors();
        assertEq(addresses[0], user1);
        assertEq(amounts[0], 0.001 ether);
    }

    /// @notice Test BigBank minimum deposit requirement with modifier
    function testBigBankMinimumDepositModifier() public {
        uint256 minDeposit = bigBank.MIN_DEPOSIT();
        assertEq(minDeposit, 0.001 ether);
        
        // Test deposit below minimum fails
        vm.prank(user1);
        vm.expectRevert("BigBank: deposit must be at least 0.001 ether");
        bigBank.deposit{value: 0.0005 ether}();
        
        // Test deposit at minimum succeeds
        vm.prank(user1);
        bigBank.deposit{value: 0.001 ether}();
        assertEq(bigBank.getBalance(user1), 0.001 ether);
        
        // Test deposit above minimum succeeds
        vm.prank(user2);
        bigBank.deposit{value: 0.002 ether}();
        assertEq(bigBank.getBalance(user2), 0.002 ether);
    }

    /// @notice Test BigBank ownership transfer to Admin contract
    function testBigBankOwnershipTransferToAdmin() public {
        assertEq(bigBank.owner(), deployer);
        
        // Transfer ownership to admin contract
        vm.prank(deployer);
        vm.expectEmit(true, true, false, false);
        emit OwnershipTransferred(deployer, address(admin));
        
        bigBank.transferOwnership(address(admin));
        
        assertEq(bigBank.owner(), address(admin));
        
        // Old owner should no longer be able to withdraw
        vm.prank(user1);
        bigBank.deposit{value: 1 ether}();
        
        vm.prank(deployer);
        vm.expectRevert("Bank: caller is not the owner");
        bigBank.withdraw(0.5 ether);
    }

    /// @notice Test Admin contract with its own owner
    function testAdminContractOwner() public {
        assertEq(admin.owner(), adminOwner);
        assertEq(admin.totalWithdrawn(), 0);
        assertEq(address(admin).balance, 0);
        
        // Test ownership transfer
        address newOwner = makeAddr("newOwner");
        vm.prank(adminOwner);
        admin.transferOwnership(newOwner);
        assertEq(admin.owner(), newOwner);
    }

    /// @notice Test Admin.adminWithdraw(IBank bank) functionality
    function testAdminWithdrawFunction() public {
        // Step 1: Transfer BigBank ownership to Admin contract
        vm.prank(deployer);
        bigBank.transferOwnership(address(admin));
        
        // Step 2: Users make deposits to BigBank
        vm.prank(user1);
        bigBank.deposit{value: 2 ether}();
        
        vm.prank(user2);
        bigBank.deposit{value: 1.5 ether}();
        
        // Verify deposits
        assertEq(bigBank.getContractBalance(), 3.5 ether);
        
        // Step 3: Admin calls adminWithdraw(IBank bank)
        uint256 adminInitialBalance = address(admin).balance;
        
        vm.prank(adminOwner);
        vm.expectEmit(true, false, false, true);
        emit AdminWithdrawal(address(bigBank), 3.5 ether, adminOwner);
        
        admin.adminWithdraw(IBank(address(bigBank)));
        
        // Verify transfer
        assertEq(address(admin).balance, adminInitialBalance + 3.5 ether);
        assertEq(bigBank.getContractBalance(), 0);
        assertEq(admin.totalWithdrawn(), 3.5 ether);
    }

    /// @notice Test complete workflow according to requirements
    function testCompleteWorkflowLatestRequirements() public {
        console.log("=== Testing Latest Requirements Workflow ===");
        
        // Step 1: Verify contracts deployed correctly
        console.log("Step 1: Contracts deployed");
        console.log("- Bank implements IBank:", address(bank) != address(0));
        console.log("- BigBank inherits Bank:", address(bigBank) != address(0));
        console.log("- Admin has own owner:", admin.owner() == adminOwner);
        
        // Step 2: Transfer BigBank ownership to Admin contract
        console.log("\nStep 2: Transfer BigBank ownership to Admin contract");
        vm.prank(deployer);
        bigBank.transferOwnership(address(admin));
        assertEq(bigBank.owner(), address(admin));
        console.log("- BigBank owner transferred to Admin contract");
        
        // Step 3: Simulate multiple users making deposits (>0.001 ether)
        console.log("\nStep 3: Users making deposits (minimum 0.001 ether)");
        
        vm.prank(user1);
        bigBank.deposit{value: 2 ether}();
        console.log("- User1 deposited 2 ETH");
        
        vm.prank(user2);
        bigBank.deposit{value: 1.5 ether}();
        console.log("- User2 deposited 1.5 ETH");
        
        vm.prank(user3);
        bigBank.deposit{value: 0.5 ether}();
        console.log("- User3 deposited 0.5 ETH");
        
        // Verify deposits and minimum requirements
        assertEq(bigBank.getBalance(user1), 2 ether);
        assertEq(bigBank.getBalance(user2), 1.5 ether);
        assertEq(bigBank.getBalance(user3), 0.5 ether);
        assertEq(bigBank.getTotalDeposits(), 4 ether);
        assertEq(bigBank.getContractBalance(), 4 ether);
        
        console.log("- Total deposits in BigBank:", bigBank.getTotalDeposits());
        console.log("- BigBank contract balance:", bigBank.getContractBalance());
        
        // Step 4: Admin contract owner calls adminWithdraw(IBank bank)
        console.log("\nStep 4: Admin owner calling adminWithdraw(IBank bank)");
        
        uint256 adminInitialBalance = address(admin).balance;
        uint256 adminOwnerInitialBalance = adminOwner.balance;
        
        vm.prank(adminOwner);
        vm.expectEmit(true, false, false, true);
        emit AdminWithdrawal(address(bigBank), 4 ether, adminOwner);
        
        // Admin calls adminWithdraw using IBank interface
        admin.adminWithdraw(IBank(address(bigBank)));
        
        // Step 5: Verify funds transferred to Admin contract
        assertEq(address(admin).balance, adminInitialBalance + 4 ether);
        assertEq(bigBank.getContractBalance(), 0);
        assertEq(admin.totalWithdrawn(), 4 ether);
        
        console.log("- Funds transferred to Admin contract:", address(admin).balance);
        console.log("- BigBank balance after withdrawal:", bigBank.getContractBalance());
        console.log("- Admin total withdrawn:", admin.totalWithdrawn());
        
        // Optional: Admin owner withdraws funds to personal address
        console.log("\nStep 5: Admin owner withdrawing to personal address");
        
        vm.prank(adminOwner);
        admin.withdrawAllToOwner();
        
        assertEq(address(admin).balance, 0);
        assertEq(adminOwner.balance, adminOwnerInitialBalance + 4 ether);
        
        console.log("- Final admin owner balance:", adminOwner.balance);
        console.log("- Final admin contract balance:", address(admin).balance);
        
        console.log("\n=== Latest Requirements Workflow Completed Successfully ===");
    }

    /// @notice Test that Admin calls IBank interface withdraw method
    function testAdminCallsIBankWithdraw() public {
        // Setup: Transfer ownership and make deposits
        vm.prank(deployer);
        bigBank.transferOwnership(address(admin));
        
        vm.prank(user1);
        bigBank.deposit{value: 1 ether}();
        
        // Verify BigBank can be used as IBank interface
        IBank ibigBank = IBank(address(bigBank));
        assertEq(ibigBank.getContractBalance(), 1 ether);
        
        // Admin calls withdraw through IBank interface
        vm.prank(adminOwner);
        admin.adminWithdraw(ibigBank);
        
        assertEq(address(admin).balance, 1 ether);
        assertEq(ibigBank.getContractBalance(), 0);
    }

    /// @notice Test error cases for latest requirements
    function testErrorCasesLatestRequirements() public {
        // Test unauthorized adminWithdraw call
        vm.prank(user1);
        vm.expectRevert("Admin: caller is not the owner");
        admin.adminWithdraw(IBank(address(bigBank)));
        
        // Test BigBank minimum deposit enforcement
        vm.prank(user1);
        vm.expectRevert("BigBank: deposit must be at least 0.001 ether");
        bigBank.deposit{value: 0.0001 ether}();
        
        // Test adminWithdraw with no funds
        vm.prank(deployer);
        bigBank.transferOwnership(address(admin));
        
        vm.prank(adminOwner);
        vm.expectRevert("Admin: no funds available in bank");
        admin.adminWithdraw(IBank(address(bigBank)));
        
        // Test adminWithdraw with zero address
        vm.prank(adminOwner);
        vm.expectRevert("Admin: bank cannot be zero address");
        admin.adminWithdraw(IBank(address(0)));
    }

    /// @notice Test that BigBank maintains Bank functionality
    function testBigBankMaintainsBankFunctionality() public {
        // Test that BigBank still has top depositors functionality
        vm.prank(user1);
        bigBank.deposit{value: 3 ether}();
        
        vm.prank(user2);
        bigBank.deposit{value: 2 ether}();
        
        vm.prank(user3);
        bigBank.deposit{value: 1 ether}();
        
        // Check top depositors
        (address[3] memory addresses, uint256[3] memory amounts) = bigBank.getTopDepositors();
        
        assertEq(addresses[0], user1);
        assertEq(addresses[1], user2);
        assertEq(addresses[2], user3);
        
        assertEq(amounts[0], 3 ether);
        assertEq(amounts[1], 2 ether);
        assertEq(amounts[2], 1 ether);
        
        // Test that BigBank still implements IBank
        assertEq(bigBank.getTotalDeposits(), 6 ether);
        assertEq(bigBank.getContractBalance(), 6 ether);
    }
}
