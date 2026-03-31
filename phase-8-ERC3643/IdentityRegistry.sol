// ERC3643 Component 1 — Identity Registry
// Deployed to Sepolia: 0xA31217AaBfA3d17D1120C8f6E6dC61D88f58952b
// Date: 2026


// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract IdentityRegistry {

    address public owner;

    mapping(address => address) public investorIdentity;
    mapping(address => uint16) public investorCountry;
    mapping(address => bool) public isVerified;

    event IdentityRegistered(
        address indexed investor,
        address indexed identity,
        uint16 country
    );

    event IdentityRemoved(
        address indexed investor
    );

    event IdentityUpdated(
        address indexed investor,
        address indexed newIdentity
    );

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this!");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function registerIdentity(
        address investor,
        address identity,
        uint16 country
    ) public onlyOwner {
        require(investor != address(0), "Invalid investor address");
        require(identity != address(0), "Invalid identity address");
        require(
            investorIdentity[investor] == address(0),
            "Investor already registered"
        );
        investorIdentity[investor] = identity;
        investorCountry[investor] = country;
        isVerified[investor] = true;
        emit IdentityRegistered(investor, identity, country);
    }

    function removeIdentity(address investor) public onlyOwner {
        require(
            investorIdentity[investor] != address(0),
            "Investor not registered"
        );
        delete investorIdentity[investor];
        delete investorCountry[investor];
        isVerified[investor] = false;
        emit IdentityRemoved(investor);
    }

    function updateIdentity(
        address investor,
        address newIdentity
    ) public onlyOwner {
        require(
            investorIdentity[investor] != address(0),
            "Investor not registered"
        );
        require(newIdentity != address(0), "Invalid identity address");
        investorIdentity[investor] = newIdentity;
        emit IdentityUpdated(investor, newIdentity);
    }

    function updateCountry(
        address investor,
        uint16 country
    ) public onlyOwner {
        require(
            investorIdentity[investor] != address(0),
            "Investor not registered"
        );
        investorCountry[investor] = country;
    }

    function checkIsVerified(
        address investor
    ) public view returns (bool) {
        return isVerified[investor];
    }

    function getCountry(
        address investor
    ) public view returns (uint16) {
        return investorCountry[investor];
    }
}
