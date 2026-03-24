// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MyToken is ERC20 {

    address public owner;

    // Modifier
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this!");
        _;
    }

    // Constructor - runs once when deployed
    constructor(uint256 initialSupply) ERC20("MyToken", "MTK") {
        owner = msg.sender;
        _mint(msg.sender, initialSupply * 10 ** decimals());
    }

    // Owner can mint new tokens
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount * 10 ** decimals());
    }

    // Anyone can burn their own tokens
    function burn(uint256 amount) public {
        _burn(msg.sender, amount * 10 ** decimals());
    }
}
