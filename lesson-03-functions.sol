// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract FunctionsExample {

    uint private storedNumber;
    address public owner;

    // Runs once when contract is deployed
    constructor() {
        owner = msg.sender;
        storedNumber = 0;
    }

    // Set a new number (costs gas - changes state)
    function setNumber(uint newNumber) public {
        storedNumber = newNumber;
    }

    // Get the stored number (free - just reading)
    function getNumber() public view returns (uint) {
        return storedNumber;
    }

    // Pure function - just does maths, no blockchain interaction
    function multiply(uint a, uint b) public pure returns (uint) {
        return a * b;
    }

    // Only owner can call this
    function resetNumber() public {
        require(msg.sender == owner, "Only owner can reset!");
        storedNumber = 0;
    }
}
