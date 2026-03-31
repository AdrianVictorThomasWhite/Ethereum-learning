// ERC3643 Component 2 — Trusted Issuers Registry
// Deployed to Sepolia: 0x6a6CD80e4Bd18099346C3c3949eC6bC5a7d2fBf4
// Date: 2026


// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TrustedIssuersRegistry {

    address public owner;

    // Maps issuer address to their trusted status
    mapping(address => bool) public isTrustedIssuer;

    // Maps issuer to the claim topics they are trusted for
    // Claim topics are uint256 numbers representing claim types
    // e.g. 1 = KYC, 2 = AML, 3 = Accredited Investor
    mapping(address => uint256[]) public issuerClaimTopics;

    // List of all trusted issuers
    address[] public trustedIssuers;

    // Events
    event TrustedIssuerAdded(
        address indexed issuer,
        uint256[] claimTopics
    );

    event TrustedIssuerRemoved(
        address indexed issuer
    );

    event ClaimTopicsUpdated(
        address indexed issuer,
        uint256[] claimTopics
    );

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this!");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function addTrustedIssuer(
        address issuer,
        uint256[] calldata claimTopics
    ) public onlyOwner {
        require(issuer != address(0), "Invalid issuer address");
        require(!isTrustedIssuer[issuer], "Issuer already trusted");
        require(claimTopics.length > 0, "Must have at least one claim topic");
        isTrustedIssuer[issuer] = true;
        issuerClaimTopics[issuer] = claimTopics;
        trustedIssuers.push(issuer);
        emit TrustedIssuerAdded(issuer, claimTopics);
    }

    function removeTrustedIssuer(address issuer) public onlyOwner {
        require(isTrustedIssuer[issuer], "Issuer not trusted");
        isTrustedIssuer[issuer] = false;
        delete issuerClaimTopics[issuer];
        emit TrustedIssuerRemoved(issuer);
    }

    function updateIssuerClaimTopics(
        address issuer,
        uint256[] calldata claimTopics
    ) public onlyOwner {
        require(isTrustedIssuer[issuer], "Issuer not trusted");
        require(claimTopics.length > 0, "Must have at least one claim topic");
        issuerClaimTopics[issuer] = claimTopics;
        emit ClaimTopicsUpdated(issuer, claimTopics);
    }

    function getIssuerClaimTopics(
        address issuer
    ) public view returns (uint256[] memory) {
        return issuerClaimTopics[issuer];
    }

    function getTrustedIssuers()
        public view returns (address[] memory) {
        return trustedIssuers;
    }

    function hasClaimTopic(
        address issuer,
        uint256 claimTopic
    ) public view returns (bool) {
        uint256[] memory topics = issuerClaimTopics[issuer];
        for (uint256 i = 0; i < topics.length; i++) {
            if (topics[i] == claimTopic) {
                return true;
            }
        }
        return false;
    }
}
