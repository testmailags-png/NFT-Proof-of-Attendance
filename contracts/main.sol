// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/*
 * @title main file
 * @dev Complete POAP system: NFT badges + Event Management + Claiming in one contract
 */
contract AllInOnePOAP is ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    Counters.Counter private _eventIds;
    
    // Event structure
    struct Event {
        uint256 eventId;
        string name;
        string description;
        string imageURI;
        address organizer;
        uint256 startTime;
        uint256 endTime;
        uint256 maxAttendees;
        uint256 claimedCount;
        bool isActive;
    }
    
    // Storage
    mapping(uint256 => Event) public events;
    mapping(address => uint256[]) public organizerEvents;
    mapping(uint256 => uint256[]) public eventTokens;
    mapping(uint256 => uint256) public tokenEvent;
    mapping(address => mapping(uint256 => bool)) public hasClaimed;
    mapping(uint256 => uint256) public mintTimestamp;
    
    // Whitelist
    mapping(uint256 => mapping(address => bool)) public whitelist;
    mapping(uint256 => address[]) public whitelistedAddresses;
    
    // Events
    event EventCreated(uint256 indexed eventId, string name, address indexed organizer, uint256 startTime, uint256 endTime);
    event EventUpdated(uint256 indexed eventId);
    event EventDeactivated(uint256 indexed eventId);
    event AddressWhitelisted(uint256 indexed eventId, address indexed user);
    event AddressesWhitelistedBatch(uint256 indexed eventId, uint256 count);
    event BadgeClaimed(uint256 indexed eventId, address indexed claimer, uint256 tokenId);
    
    constructor() ERC721("Proof of Attendance", "POAP") Ownable(msg.sender) {}
    
    // ==================== EVENT MANAGEMENT ====================
    
    function createEvent(
        string memory name,
        string memory description,
        string memory imageURI,
        uint256 startTime,
        uint256 endTime,
        uint256 maxAttendees
    ) external returns (uint256) {
        require(bytes(name).length > 0, "Name required");
        require(startTime > block.timestamp, "Start time must be in future");
        require(endTime > startTime, "End time must be after start");
        require(maxAttendees > 0, "Max attendees must be > 0");
        
        _eventIds.increment();
        uint256 newEventId = _eventIds.current();
        
        events[newEventId] = Event({
            eventId: newEventId,
            name: name,
            description: description,
            imageURI: imageURI,
            organizer: msg.sender,
            startTime: startTime,
            endTime: endTime,
            maxAttendees: maxAttendees,
            claimedCount: 0,
            isActive: true
        });
        
        organizerEvents[msg.sender].push(newEventId);
        emit EventCreated(newEventId, name, msg.sender, startTime, endTime);
        
        return newEventId;
    }
    
    function updateEvent(uint256 eventId, string memory name, string memory description, string memory imageURI) external {
        Event storage evt = events[eventId];
        require(evt.organizer == msg.sender, "Not event organizer");
        require(block.timestamp < evt.startTime, "Event already started");
        require(evt.isActive, "Event not active");
        
        if (bytes(name).length > 0) evt.name = name;
        if (bytes(description).length > 0) evt.description = description;
        if (bytes(imageURI).length > 0) evt.imageURI = imageURI;
        
        emit EventUpdated(eventId);
    }
    
    function deactivateEvent(uint256 eventId) external {
        Event storage evt = events[eventId];
        require(evt.organizer == msg.sender || msg.sender == owner(), "Not authorized");
        require(evt.isActive, "Event already inactive");
        
        evt.isActive = false;
        emit EventDeactivated(eventId);
    }
    
    function isClaimable(uint256 eventId) public view returns (bool) {
        Event memory evt = events[eventId];
        return evt.isActive && 
               block.timestamp >= evt.startTime && 
               block.timestamp <= evt.endTime && 
               evt.claimedCount < evt.maxAttendees;
    }
    
    function getEvent(uint256 eventId) external view returns (Event memory) {
        return events[eventId];
    }
    
    function getOrganizerEvents(address organizer) external view returns (uint256[] memory) {
        return organizerEvents[organizer];
    }
    
    function totalEvents() external view returns (uint256) {
        return _eventIds.current();
    }
    
    // ==================== WHITELIST MANAGEMENT ====================
    
    function whitelistAddress(uint256 eventId, address user) external {
        Event storage evt = events[eventId];
        require(evt.organizer == msg.sender, "Not event organizer");
        require(user != address(0), "Invalid address");
        require(!whitelist[eventId][user], "Already whitelisted");
        
        whitelist[eventId][user] = true;
        whitelistedAddresses[eventId].push(user);
        
        emit AddressWhitelisted(eventId, user);
    }
    
    function whitelistAddressesBatch(uint256 eventId, address[] memory users) external {
        Event storage evt = events[eventId];
        require(evt.organizer == msg.sender, "Not event organizer");
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
    
    function isWhitelisted(uint256 eventId, address user) external view returns (bool) {
        return whitelist[eventId][user];
    }
    
    function getWhitelistedAddresses(uint256 eventId) external view returns (address[] memory) {
        return whitelistedAddresses[eventId];
    }
    
    // ==================== BADGE CLAIMING ====================
    
    function claimBadge(uint256 eventId) external {
        require(isClaimable(eventId), "Event not claimable");
        require(whitelist[eventId][msg.sender], "Not whitelisted");
        require(!hasClaimed[msg.sender][eventId], "Already claimed");
        
        _mintBadge(msg.sender, eventId);
    }
    
    function claimBadgeWithQR(uint256 eventId, address claimer) external {
        Event storage evt = events[eventId];
        require(evt.organizer == msg.sender, "Not event organizer");
        require(isClaimable(eventId), "Event not claimable");
        require(!hasClaimed[claimer][eventId], "Already claimed");
        
        _mintBadge(claimer, eventId);
    }
    
    function _mintBadge(address recipient, uint256 eventId) internal {
        Event storage evt = events[eventId];
        
        _tokenIds.increment();
        uint256 newTokenId = _tokenIds.current();
        
        _safeMint(recipient, newTokenId);
        _setTokenURI(newTokenId, evt.imageURI);
        
        hasClaimed[recipient][eventId] = true;
        tokenEvent[newTokenId] = eventId;
        eventTokens[eventId].push(newTokenId);
        mintTimestamp[newTokenId] = block.timestamp;
        evt.claimedCount++;
        
        emit BadgeClaimed(eventId, recipient, newTokenId);
    }
    
    function canClaim(uint256 eventId, address user) external view returns (bool) {
        return isClaimable(eventId) && 
               whitelist[eventId][user] && 
               !hasClaimed[user][eventId];
    }
    
    // ==================== SOULBOUND (Non-transferable) ====================
    
    function _update(address to, uint256 tokenId, address auth) internal virtual override returns (address) {
        address from = _ownerOf(tokenId);
        require(from == address(0), "Soulbound: Transfer not allowed");
        return super._update(to, tokenId, auth);
    }
    
    // ==================== VIEW FUNCTIONS ====================
    
    function getEventBadges(uint256 eventId) external view returns (uint256[] memory) {
        return eventTokens[eventId];
    }
    
    function totalSupply() external view returns (uint256) {
        return _tokenIds.current();
    }
    
    function hasClaimedBadge(address user, uint256 eventId) external view returns (bool) {
        return hasClaimed[user][eventId];
    }
}

