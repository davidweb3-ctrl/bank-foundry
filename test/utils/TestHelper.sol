// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";

/// @title Test Helper Contract
/// @notice Provides common utilities for Bank contract testing
contract TestHelper is Test {
    /// @notice Create funded test addresses
    /// @param count Number of addresses to create
    /// @param fundAmount ETH amount to fund each address with
    /// @return addresses Array of created addresses
    function createFundedAddresses(uint256 count, uint256 fundAmount) 
        internal 
        returns (address[] memory addresses) 
    {
        addresses = new address[](count);
        for (uint256 i = 0; i < count; i++) {
            addresses[i] = makeAddr(string(abi.encodePacked("user", vm.toString(i))));
            vm.deal(addresses[i], fundAmount);
        }
    }

    /// @notice Helper to check if address is in top depositors
    /// @param target Address to check
    /// @param topAddresses Array of top depositor addresses
    /// @return True if address is found
    function isInTopDepositors(address target, address[3] memory topAddresses) 
        internal 
        pure 
        returns (bool) 
    {
        for (uint256 i = 0; i < 3; i++) {
            if (topAddresses[i] == target) {
                return true;
            }
        }
        return false;
    }

    /// @notice Helper to get position of address in top depositors
    /// @param target Address to find
    /// @param topAddresses Array of top depositor addresses
    /// @return position Position in array (0-2), returns 999 if not found
    function getPositionInTopDepositors(address target, address[3] memory topAddresses) 
        internal 
        pure 
        returns (uint256 position) 
    {
        for (uint256 i = 0; i < 3; i++) {
            if (topAddresses[i] == target) {
                return i;
            }
        }
        return 999; // Not found
    }

    /// @notice Verify that top depositors are sorted in descending order
    /// @param amounts Array of top depositor amounts
    /// @return True if properly sorted
    function isTopDepositorsSorted(uint256[3] memory amounts) 
        internal 
        pure 
        returns (bool) 
    {
        return amounts[0] >= amounts[1] && amounts[1] >= amounts[2];
    }
}
