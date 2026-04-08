// ERC3643 Component 4 — Security Token
// Deployed to Sepolia: 0x54494ed332f361104ca676189a6a8119a64dad77
// Identity Registry: 0xA31217AaBfA3d17D1120C8f6E6dC61D88f58952b
// Compliance Module: 0x15b2e9d3bb29458fbfe943ef2153ecd16f0554c4
// Token Name: MySecurityToken (MST)
// Date: 2026


// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Interface for Identity Registry
interface IIdentityRegistry {
    function checkIsVerified(address investor) external view returns (bool);
    function getCountry(address investor) external view returns (uint16);
}

// Interface for Compliance Module
interface IComplianceModule {
    function canTransfer(
        address from,
        address to,
        uint256 amount
    ) external view returns (bool, string memory);
    function transferDone(address from, address to) external;
    function updateTotalSupply(uint256 _totalSupply) external;
}

contract SecurityToken {

    // Token details
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;

    // Owner
    address public owner;

    // Connected contracts
    address public identityRegistry;
    address public complianceModule;

    // Balances
    mapping(address => uint256) public balanceOf;

    // Allowances
    mapping(address => mapping(address => uint256)) public allowance;

    // Frozen addresses
    mapping(address => bool) public isFrozen;

    // Events
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 value
    );

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    event TokensFrozen(address indexed investor);
    event TokensUnfrozen(address indexed investor);
    event TokensIssued(address indexed investor, uint256 amount);
    event TokensRedeemed(address indexed investor, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this!");
        _;
    }

    modifier notFrozen(address investor) {
        require(!isFrozen[investor], "Investor account is frozen");
        _;
    }

    constructor(
        string memory _name,
        string memory _symbol,
        address _identityRegistry,
        address _complianceModule
    ) {
        owner = msg.sender;
        name = _name;
        symbol = _symbol;
        decimals = 18;
        identityRegistry = _identityRegistry;
        complianceModule = _complianceModule;
    }

    // Issue new tokens to a verified investor
    function issueTokens(
        address investor,
        uint256 amount
    ) public onlyOwner {
        require(investor != address(0), "Invalid address");
        require(amount > 0, "Amount must be greater than zero");

        // Check investor is verified
        IIdentityRegistry registry = IIdentityRegistry(identityRegistry);
        require(
            registry.checkIsVerified(investor),
            "Investor is not verified"
        );

        balanceOf[investor] += amount;
        totalSupply += amount;

        // Update compliance module with new total supply
        IComplianceModule compliance = IComplianceModule(complianceModule);
        compliance.updateTotalSupply(totalSupply);
        compliance.transferDone(address(0), investor);

        emit TokensIssued(investor, amount);
        emit Transfer(address(0), investor, amount);
    }

    // Transfer tokens between verified investors
    function transfer(
        address to,
        uint256 amount
    ) public notFrozen(msg.sender) returns (bool) {
        require(to != address(0), "Invalid address");
        require(balanceOf[msg.sender] >= amount, "Insufficient balance");

        // Run compliance check
        IComplianceModule compliance = IComplianceModule(complianceModule);
        (bool allowed, string memory reason) = compliance.canTransfer(
            msg.sender,
            to,
            amount
        );
        require(allowed, reason);

        // Execute transfer
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;

        // Notify compliance module
        compliance.transferDone(msg.sender, to);

        emit Transfer(msg.sender, to, amount);
        return true;
    }

    // Redeem tokens
    function redeemTokens(uint256 amount) public notFrozen(msg.sender) {
        require(amount > 0, "Amount must be greater than zero");
        require(balanceOf[msg.sender] >= amount, "Insufficient balance");

        balanceOf[msg.sender] -= amount;
        totalSupply -= amount;

        // Update compliance module
        IComplianceModule compliance = IComplianceModule(complianceModule);
        compliance.updateTotalSupply(totalSupply);

        emit TokensRedeemed(msg.sender, amount);
        emit Transfer(msg.sender, address(0), amount);
    }

    // Freeze an investor account
    function freezeInvestor(address investor) public onlyOwner {
        isFrozen[investor] = true;
        emit TokensFrozen(investor);
    }

    // Unfreeze an investor account
    function unfreezeInvestor(address investor) public onlyOwner {
        isFrozen[investor] = false;
        emit TokensUnfrozen(investor);
    }

    // Force transfer - for regulatory requirements
    function forceTransfer(
        address from,
        address to,
        uint256 amount
    ) public onlyOwner {
        require(balanceOf[from] >= amount, "Insufficient balance");
        balanceOf[from] -= amount;
        balanceOf[to] += amount;
        emit Transfer(from, to, amount);
    }

    // Get token details
    function getTokenDetails() public view returns (
        string memory,
        string memory,
        uint256,
        uint256
    ) {
        return (name, symbol, decimals, totalSupply);
    }
}
