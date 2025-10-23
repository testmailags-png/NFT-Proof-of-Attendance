// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/**
 * @title POAP
 * @dev Soulbound NFT badges for event attendance - cannot be transferred
 */
contract POAP is ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    
    // Event ID => Token ID mapping
    mapping(uint256 => uint256[]) public eventTokens;
    
    // Token ID => Event ID mapping
    mapping(uint256 => uint256) public tokenEvent;
    
    // Wallet => Event ID => claimed status
    mapping(address => mapping(uint256 => bool)) public hasClaimed;
    
    // Token ID => timestamp when minted
    mapping(uint256 => uint256) public mintTimestamp;
    
    // Authorized minters (EventManager and Claimer contracts)
    mapping(address => bool) public authorizedMinters;
    
    // Events
    event BadgeMinted(
        address indexed recipient,
        uint256 indexed tokenId,
        uint256 indexed eventId,
        uint256 timestamp
    );
    
    event MinterAuthorized(address indexed minter);
    event MinterRevoked(address indexed minter);
    
    constructor() ERC721("Proof of Attendance", "POAP") Ownable(msg.sender) {}
    
    /**
     * @dev Authorize a contract to mint badges
     */
    function authorizeMinter(address minter) external onlyOwner {
        require(minter != address(0), "Invalid minter address");
        authorizedMinters[minter] = true;
        emit MinterAuthorized(minter);
    }
    
    /**
     * @dev Revoke minting authorization
     */
    function revokeMinter(address minter) external onlyOwner {
        authorizedMinters[minter] = false;
        emit MinterRevoked(minter);
    }
    
    /**
     * @dev Mint a new badge
     */
    function mintBadge(
        address recipient,
        uint256 eventId,
        string memory tokenURI
    ) external returns (uint256) {
        require(authorizedMinters[msg.sender], "Not authorized to mint");
        require(recipient != address(0), "Invalid recipient");
        require(!hasClaimed[recipient][eventId], "Already claimed");
        
        _tokenIds.increment();
        uint256 newTokenId = _tokenIds.current();
        
        _safeMint(recipient, newTokenId);
        _setTokenURI(newTokenId, tokenURI);
        
        // Record claim
        hasClaimed[recipient][eventId] = true;
        tokenEvent[newTokenId] = eventId;
        eventTokens[eventId].push(newTokenId);
        mintTimestamp[newTokenId] = block.timestamp;
        
        emit BadgeMinted(recipient, newTokenId, eventId, block.timestamp);
        
        return newTokenId;
    }
    
    /**
     * @dev Override transfer functions to make badges soulbound
     */
    function _update(
        address to,
        uint256 tokenId,
        address auth
    ) internal virtual override returns (address) {
        address from = _ownerOf(tokenId);
        
        // Allow minting (from == address(0))
        // Block all transfers (from != address(0))
        require(from == address(0), "Soulbound: Transfer not allowed");
        
        return super._update(to, tokenId, auth);
    }
    
    /**
     * @dev Get all badges for an event
     */
    function getEventBadges(uint256 eventId) external view returns (uint256[] memory) {
        return eventTokens[eventId];
    }
    
    /**
     * @dev Get total badges minted
     */
    function totalSupply() external view returns (uint256) {
        return _tokenIds.current();
    }
    
    /**
     * @dev Check if address has claimed badge for event
     */
    function hasClaimedBadge(address user, uint256 eventId) external view returns (bool) {
        return hasClaimed[user][eventId];
    }
}