solidity

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VariablesExample {

    // State variables - stored on the blockchain
    uint public myNumber = 42;
    bool public isActive = true;
    address public owner = 0x71C7656EC7ab88b098defB751B7401B5f6d8976F;
    string public name = "My Contract";

    function showLocalVariable() public pure returns (uint) {
        // Local variable - only exists while function runs
        uint result = 10 + 5;
        return result;
    }

    function showGlobalVariable() public view returns (address) {
        // Global variable - who called this function
        return msg.sender;
    }
}
