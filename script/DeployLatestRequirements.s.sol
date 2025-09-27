// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../src/Bank.sol";
import "../src/BigBank.sol";
import "../src/Admin.sol";
import "../src/interfaces/IBank.sol";

/// @title Deploy Latest Requirements Script
/// @notice Deploys contracts according to latest requirements
contract DeployLatestRequirementsScript is Script {
    function run() external {
        // Get deployment parameters
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        
        // Get admin owner address (can be same as deployer for demo)
        address adminOwner;
        try vm.envAddress("ADMIN_OWNER_ADDRESS") returns (address addr) {
            adminOwner = addr;
        } catch {
            adminOwner = deployer;
        }
        
        vm.startBroadcast(deployerPrivateKey);
        
        // Step 1: Deploy contracts
        Bank bank = new Bank();
        BigBank bigBank = new BigBank();
        Admin admin = new Admin(adminOwner);
        
        // Step 2: Transfer BigBank ownership to Admin contract
        bigBank.transferOwnership(address(admin));
        
        vm.stopBroadcast();
        
        // Verify deployments
        require(bank.owner() == deployer, "Bank owner incorrect");
        require(bigBank.owner() == address(admin), "BigBank owner incorrect");
        require(admin.owner() == adminOwner, "Admin owner incorrect");
        
        // Log deployment information
        // Removed console.log to avoid compilation issues
    }
}
