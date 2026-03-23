// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MappingsEventsModifiers {

    // State variables
    address public owner;
    mapping(address => uint) public balances;

    // Events
    event BalanceUpdated(address indexed user, uint newBalance);
    event OwnerChanged(address indexed oldOwner, address indexed newOwner);

    // Constructor
    constructor() {
        owner = msg.sender;
    }

    // Modifier
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this!");
        _;
    }

    // Set balance for caller
    function setBalance(uint amount) public {
        balances[msg.sender] = amount;
        emit BalanceUpdated(msg.sender, amount);
    }

    // Get balance for any address
    function getBalance(address user) public view returns (uint) {
        return balances[user];
    }

    // Only owner can change owner
    function changeOwner(address newOwner) public onlyOwner {
        emit OwnerChanged(owner, newOwner);
        owner = newOwner;
    }
}
