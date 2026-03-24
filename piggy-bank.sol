// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PiggyBank {

    // State variables
    address public owner;
    mapping(address => uint) public balances;
    uint public totalDeposits;

    // Events
    event Deposited(address indexed user, uint amount);
    event Withdrawn(address indexed user, uint amount);
    event EmergencyWithdraw(address indexed owner, uint amount);

    // Constructor
    constructor() {
        owner = msg.sender;
    }

    // Modifier
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this!");
        _;
    }

    // Deposit ETH into the piggy bank
    function deposit() public payable {
        require(msg.value > 0, "Must send some ETH");
        balances[msg.sender] += msg.value;
        totalDeposits += msg.value;
        emit Deposited(msg.sender, msg.value);
    }

    // Withdraw your own ETH
    function withdraw(uint amount) public {
        require(amount > 0, "Amount must be greater than zero");
        require(balances[msg.sender] >= amount, "Insufficient balance");
        balances[msg.sender] -= amount;
        totalDeposits -= amount;
        payable(msg.sender).transfer(amount);
        emit Withdrawn(msg.sender, amount);
    }

    // Owner can withdraw everything in an emergency
    function emergencyWithdraw() public onlyOwner {
        uint contractBalance = address(this).balance;
        require(contractBalance > 0, "Nothing to withdraw");
        totalDeposits = 0;
        payable(owner).transfer(contractBalance);
        emit EmergencyWithdraw(owner, contractBalance);
    }

    // Check contract's total ETH balance
    function getContractBalance() public view returns (uint) {
        return address(this).balance;
    }
}
