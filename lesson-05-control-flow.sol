// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ControlFlow {

    address public owner;
    mapping(address => uint) public balances;

    event Deposit(address indexed user, uint amount);
    event Withdrawal(address indexed user, uint amount);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this!");
        _;
    }

    // Deposit ETH into contract
    function deposit() public payable {
        require(msg.value > 0, "Must send some ETH");
        balances[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    // Withdraw ETH from contract
    function withdraw(uint amount) public {
        require(amount > 0, "Amount must be greater than zero");
        require(balances[msg.sender] >= amount, "Insufficient balance");
        balances[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
        emit Withdrawal(msg.sender, amount);
    }

    // Check if an address is the owner
    function isOwner(address user) public view returns (bool) {
        if (user == owner) {
            return true;
        } else {
            return false;
        }
    }

    // Get contract's total ETH balance
    function getContractBalance() public view returns (uint) {
        return address(this).balance;
    }
}
