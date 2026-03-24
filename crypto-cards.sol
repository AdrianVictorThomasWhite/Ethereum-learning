// CryptoCards NFT Contract
// Deployed to Sepolia: 0x470452bEADa4FC54afEf490001EC963F289Ff1cd
// Max Supply: 100 cards
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract CryptoCards is ERC721, ERC721URIStorage {

    address public owner;
    uint256 public tokenCounter;
    uint256 public maxSupply;

    // Events
    event CardMinted(address indexed to, uint256 tokenId, string tokenURI);

    // Modifier
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this!");
        _;
    }

    // Constructor
    constructor(uint256 _maxSupply) ERC721("CryptoCards", "CARD") {
        owner = msg.sender;
        tokenCounter = 0;
        maxSupply = _maxSupply;
    }

    // Mint a new NFT
    function mintCard(address to, string memory uri) public onlyOwner {
        require(tokenCounter < maxSupply, "Max supply reached!");
        uint256 tokenId = tokenCounter;
        tokenCounter++;
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
        emit CardMinted(to, tokenId, uri);
    }

    // How many cards exist
    function totalSupply() public view returns (uint256) {
        return tokenCounter;
    }

    // Required overrides for ERC721URIStorage
    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage)
        returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721URIStorage)
        returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
