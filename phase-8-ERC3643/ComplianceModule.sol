// ERC3643 Component 3 — Compliance Module
// Deployed to Sepolia: 0x... (paste your address)
// Identity Registry: 0xA31217AaBfA3d17D1120C8f6E6dC61D88f58952b
// Max Investors: 50
// Max Holding: 20% (2000 basis points)
// Date: 2026



// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Interface to interact with Identity Registry
interface IIdentityRegistry {
    function checkIsVerified(address investor) external view returns (bool);
    function getCountry(address investor) external view returns (uint16);
}

contract ComplianceModule {

    address public owner;

    // Identity Registry contract address
    address public identityRegistry;

    // Maximum number of investors allowed
    uint256 public maxInvestors;

    // Current number of investors
    uint256 public currentInvestors;

    // Maximum holding percentage per investor (in basis points)
    // 1000 = 10%, 500 = 5%, 10000 = 100%
    uint256 public maxHoldingPercentage;

    // Total token supply (set by token contract)
    uint256 public totalSupply;

    // Restricted countries mapping
    mapping(uint16 => bool) public restrictedCountries;

    // Lock up period
    bool public isLocked;

    // Track if address is already an investor
    mapping(address => bool) public isInvestor;

    // Events
    event CountryRestricted(uint16 country);
    event CountryUnrestricted(uint16 country);
    event LockupActivated();
    event LockupDeactivated();
    event MaxInvestorsUpdated(uint256 newMax);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this!");
        _;
    }

    constructor(
        address _identityRegistry,
        uint256 _maxInvestors,
        uint256 _maxHoldingPercentage
    ) {
        owner = msg.sender;
        identityRegistry = _identityRegistry;
        maxInvestors = _maxInvestors;
        maxHoldingPercentage = _maxHoldingPercentage;
        isLocked = false;
    }

    // Main compliance check — called before every transfer
    function canTransfer(
        address from,
        address to,
        uint256 amount
    ) public view returns (bool, string memory) {

        // Check 1 — is contract locked?
        if (isLocked) {
            return (false, "Transfers are currently locked");
        }

        // Check 2 — is recipient verified?
        IIdentityRegistry registry = IIdentityRegistry(identityRegistry);
        if (!registry.checkIsVerified(to)) {
            return (false, "Recipient is not a verified investor");
        }

        // Check 3 — is recipient country restricted?
        uint16 country = registry.getCountry(to);
        if (restrictedCountries[country]) {
            return (false, "Recipient country is restricted");
        }

        // Check 4 — would transfer exceed max investors?
        if (!isInvestor[to] && currentInvestors >= maxInvestors) {
            return (false, "Maximum investor limit reached");
        }

        // Check 5 — would transfer exceed holding limit?
        if (totalSupply > 0 && maxHoldingPercentage > 0) {
            uint256 maxAllowed = (totalSupply * maxHoldingPercentage) / 10000;
            if (amount > maxAllowed) {
                return (false, "Transfer exceeds maximum holding limit");
            }
        }

        return (true, "Transfer is compliant");
    }

    // Called when a transfer completes to update investor count
    function transferDone(address from, address to) public onlyOwner {
        if (!isInvestor[to]) {
            isInvestor[to] = true;
            currentInvestors++;
        }
    }

    // Restrict a country
    function restrictCountry(uint16 country) public onlyOwner {
        restrictedCountries[country] = true;
        emit CountryRestricted(country);
    }

    // Unrestrict a country
    function unrestrictCountry(uint16 country) public onlyOwner {
        restrictedCountries[country] = false;
        emit CountryUnrestricted(country);
    }

    // Lock all transfers
    function activateLockup() public onlyOwner {
        isLocked = true;
        emit LockupActivated();
    }

    // Unlock transfers
    function deactivateLockup() public onlyOwner {
        isLocked = false;
        emit LockupDeactivated();
    }

    // Update max investors
    function updateMaxInvestors(uint256 newMax) public onlyOwner {
        maxInvestors = newMax;
        emit MaxInvestorsUpdated(newMax);
    }

    // Update total supply (called by token contract)
    function updateTotalSupply(uint256 _totalSupply) public onlyOwner {
        totalSupply = _totalSupply;
    }
}
