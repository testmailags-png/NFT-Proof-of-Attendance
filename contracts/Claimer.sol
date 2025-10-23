// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

// Interfaces
interface IPOAP {
    function mintBadge(address recipient, uint256 eventId, string memory tokenURI) external returns (uint256);
    function hasClaimedBadge(address user, uint256 eventId) external view returns (bool);
}

interface IEventManager {
    function events(uint256 eventId) external view returns (
        uint256 eventId,
        string memory name,
        string memory description,
        string memory imageURI,
        address organizer,
        uint256 startTime,
        uint256 endTime,
        uint256 maxAttendees,
        uint256 claimedCount,
        bool isActive
    );
    function isClaimable(uint256 eventId) external view returns (bool);
    function incrementClaimedCount(uint256 eventId) external;
}

/**
 * @title Claimer
 * @dev Handles badge claiming with whitelist and verification
 */
contract Claimer is Ownable {
    
    // References to other contracts
    IPOAP public poapContract;
    IEventManager public eventManager;
    
    // Whitelist: Event ID => Address => whitelisted status
    mapping(uint256 => mapping(address => bool)) public whitelist;
    
    // Event ID => list of whitelisted addresses
    mapping(uint256 => address[]) public whitelistedAddresses;
    
    // Claiming methods
    enum ClaimMethod {
        Whitelist,      // Manual whitelist
        QRCode,         // QR code scan
        Signature       // Organizer signature
    }
    
    // Event claiming config
    mapping(uint256 => ClaimMethod) public eventClaimMethod;
    
    // Events
    event AddressWhitelisted(uint256 indexed eventId, address indexed user);
    event AddressesWhitelistedBatch(uint256 indexed eventId, uint256 count);
    event BadgeClaimed(uint256 indexed eventId, address indexed claimer, uint256 tokenId);
    event ClaimMethodSet(uint256 indexed eventId, ClaimMethod method);
    
    constructor(address _poapContract, address _eventManager) Ownable(msg.sender) {
        require(_poapContract != address(0), "Invalid POAP contract");
        require(_eventManager != address(0), "Invalid EventManager contract");
        
        poapContract = IPOAP(_poapContract);
        eventManager = IEventManager(_eventManager);
    }
    
    /**
     * @dev Set claiming method for an event
     */
    function setClaimMethod(uint256 eventId, ClaimMethod method) external {
        (,,,, address organizer,,,,) = eventManager.events(eventId);
        require(organizer == msg.sender, "Not event organizer");
        
        eventClaimMethod[eventId] = method;
        emit ClaimMethodSet(eventId, method);
    }
    
    /**
     * @dev Whitelist single address
     */
    function whitelistAddress(uint256 eventId, address user) external {
        (,,,, address organizer,,,,) = eventManager.events(eventId);
        require(organizer == msg.sender, "Not event organizer");
        require(user != address(0), "Invalid address");
        require(!whitelist[eventId][user], "Already whitelisted");
        
        whitelist[eventId][user] = true;
        whitelistedAddresses[eventId].push(user);
        
        emit AddressWhitelisted(eventId, user);
    }
    
    /**
     * @dev Batch whitelist addresses
     */
    function whitelistAddressesBatch(uint256 eventId, address[] memory users) external {
        (,,,, address organizer,,,,) = eventManager.events(eventId);
        require(organizer == msg.sender, "Not event organizer");
        require(users.length > 0, "Empty array");
        require(users.length <= 100, "Batch too large");
        
        for (uint256 i = 0; i < users.length; i++) {
            address user = users[i];
            if (user != address(0) && !whitelist[eventId][user]) {
                whitelist[eventId][user] = true;
                whitelistedAddresses[eventId].push(user);
            }
        }
        
        emit AddressesWhitelistedBatch(eventId, users.length);
    }
    
    /**
     * @dev Claim badge for whitelisted address
     */
    function claimBadge(uint256 eventId) external {
        require(eventManager.isClaimable(eventId), "Event not claimable");
        require(whitelist[eventId][msg.sender], "Not whitelisted");
        require(!poapContract.hasClaimedBadge(msg.sender, eventId), "Already claimed");
        
        // Get event details for token URI
        (,, string memory imageURI,,,,,) = eventManager.events(eventId);
        
        // Mint badge
        uint256 tokenId = poapContract.mintBadge(msg.sender, eventId, imageURI);
        
        // Update claimed count
        eventManager.incrementClaimedCount(eventId);
        
        emit BadgeClaimed(eventId, msg.sender, tokenId);
    }
    
    /**
     * @dev Claim badge with QR code (organizer approves on-the-spot)
     */
    function claimBadgeWithQR(uint256 eventId, address claimer) external {
        (,,,, address organizer,,,,) = eventManager.events(eventId);
        require(organizer == msg.sender, "Not event organizer");
        require(eventManager.isClaimable(eventId), "Event not claimable");
        require(!poapContract.hasClaimedBadge(claimer, eventId), "Already claimed");
        
        // Get event details
        (,, string memory imageURI,,,,,) = eventManager.events(eventId);
        
        // Mint badge
        uint256 tokenId = poapContract.mintBadge(claimer, eventId, imageURI);
        
        // Update claimed count
        eventManager.incrementClaimedCount(eventId);
        
        emit BadgeClaimed(eventId, claimer, tokenId);
    }
    
    /**
     * @dev Check if address is whitelisted
     */
    function isWhitelisted(uint256 eventId, address user) external view returns (bool) {
        return whitelist[eventId][user];
    }
    
    /**
     * @dev Get all whitelisted addresses for event
     */
    function getWhitelistedAddresses(uint256 eventId) external view returns (address[] memory) {
        return whitelistedAddresses[eventId];
    }
    
    /**
     * @dev Check if user can claim
     */
    function canClaim(uint256 eventId, address user) external view returns (bool) {
        return eventManager.isClaimable(eventId) &&
               whitelist[eventId][user] &&
               !poapContract.hasClaimedBadge(user, eventId);
    }
}