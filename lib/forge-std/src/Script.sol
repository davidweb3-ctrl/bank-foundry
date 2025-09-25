// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2 <0.9.0;

import "./Vm.sol";

abstract contract Script {
    Vm internal constant vm = Vm(address(bytes20(uint160(uint256(keccak256("hevm cheat code"))))));

    function console() internal pure {
        // Console functionality would be implemented by forge
    }
}
