// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2 <0.9.0;

import "./Vm.sol";

abstract contract Test {
    Vm internal constant vm = Vm(address(bytes20(uint160(uint256(keccak256("hevm cheat code"))))));

    function assertTrue(bool condition) internal pure {
        require(condition, "Assertion failed");
    }

    function assertTrue(bool condition, string memory err) internal pure {
        require(condition, err);
    }

    function assertFalse(bool condition) internal pure {
        require(!condition, "Assertion failed");
    }

    function assertFalse(bool condition, string memory err) internal pure {
        require(!condition, err);
    }

    function assertEq(address a, address b) internal pure {
        require(a == b, "Assertion failed: addresses not equal");
    }

    function assertEq(uint256 a, uint256 b) internal pure {
        require(a == b, "Assertion failed: uints not equal");
    }

    function assertEq(string memory a, string memory b) internal pure {
        require(keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b)), "Assertion failed: strings not equal");
    }

    function assertLe(uint256 a, uint256 b) internal pure {
        require(a <= b, "Assertion failed: a not <= b");
    }

    function assertLt(uint256 a, uint256 b) internal pure {
        require(a < b, "Assertion failed: a not < b");
    }

    function assertGe(uint256 a, uint256 b) internal pure {
        require(a >= b, "Assertion failed: a not >= b");
    }

    function assertGt(uint256 a, uint256 b) internal pure {
        require(a > b, "Assertion failed: a not > b");
    }

    function makeAddr(string memory name) internal pure returns (address) {
        return address(uint160(uint256(keccak256(abi.encodePacked(name)))));
    }

    // Events for logging
    event log(string);
    event log_named_uint(string key, uint256 val);
    event log_named_address(string key, address val);

    function bound(uint256 x, uint256 min, uint256 max) internal pure returns (uint256 result) {
        require(min <= max, "Test: max is less than min");
        if (x >= min && x <= max) return x;
        uint256 size = max - min + 1;
        if (size == 0) return min;
        return min + (x % size);
    }
}
