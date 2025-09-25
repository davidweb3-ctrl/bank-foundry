// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../src/Bank.sol";

/// @title Bank Deployment Script
/// @notice Deploys the Bank contract and sets up initial configuration
contract DeployScript is Script {
    function run() external {
        // Get the deployer's private key from environment
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        
        // Start broadcasting transactions
        vm.startBroadcast(deployerPrivateKey);
        
        // Deploy the Bank contract
        Bank bank = new Bank();
        
        // Stop broadcasting
        vm.stopBroadcast();
        
        // Verify deployment
        require(bank.owner() == deployer, "Owner not set correctly");
        require(bank.getTotalDeposits() == 0, "Initial deposits should be zero");
        require(bank.getContractBalance() == 0, "Initial balance should be zero");
        
        // Save deployment info to file
        _saveDeploymentInfo(address(bank), deployer);
    }
    
    /// @notice Save deployment information to a JSON file
    /// @param bankAddress The deployed Bank contract address
    /// @param owner The owner address
    function _saveDeploymentInfo(address bankAddress, address owner) internal {
        string memory deploymentInfo = string(
            abi.encodePacked(
                '{\n',
                '  "bankAddress": "', vm.toString(bankAddress), '",\n',
                '  "owner": "', vm.toString(owner), '",\n',
                '  "network": "', _getNetworkName(), '",\n',
                '  "deployedAt": "', vm.toString(block.timestamp), '",\n',
                '  "blockNumber": "', vm.toString(block.number), '"\n',
                '}'
            )
        );
        
        string memory filename = string(
            abi.encodePacked("deployment-", _getNetworkName(), ".json")
        );
        
        vm.writeFile(filename, deploymentInfo);
    }
    
    /// @notice Get current network name
    /// @return Network name as string
    function _getNetworkName() internal view returns (string memory) {
        if (block.chainid == 1) return "mainnet";
        if (block.chainid == 11155111) return "sepolia";
        if (block.chainid == 31337) return "anvil";
        return "unknown";
    }
}
