// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2 <0.9.0;

interface Vm {
    function prank(address) external;
    function startPrank(address) external;
    function stopPrank() external;
    function deal(address to, uint256 give) external;
    function addr(uint256 privateKey) external pure returns (address);
    function envUint(string calldata) external view returns (uint256);
    function envAddress(string calldata) external view returns (address);
    function startBroadcast() external;
    function startBroadcast(uint256) external;
    function stopBroadcast() external;
    function expectRevert() external;
    function expectRevert(bytes4) external;
    function expectRevert(bytes calldata) external;
    function expectEmit() external;
    function expectEmit(bool, bool, bool, bool) external;
    function assume(bool) external;
    function toString(uint256) external pure returns (string memory);
    function toString(address) external pure returns (string memory);
    function writeFile(string calldata, string calldata) external;
}
