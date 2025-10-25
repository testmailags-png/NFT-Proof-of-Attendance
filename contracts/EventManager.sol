// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

// Interface for POAP contract
interface IPOAP {
    function mintBadge(address recipient, uint256 eventId, string memory tokenURI) external returns (uint256);
    function hasClaimedBadge(address user, uint256 eventId) external view returns (bool);
}

/**
 * @title EventManager
 */
contract EventManager is Ownable {
    using Counters for Counters.Counter;
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
    
    // POAP contract reference
    IPOAP public poapContract;
    
    // Events
    event EventCreated(
        uint256 indexed eventId,
        string name,
        address indexed organizer,
        uint256 startTime,
        uint256 endTime
    );
    
    event EventUpdated(uint256 indexed eventId);
    event EventDeactivated(uint256 indexed eventId);
    
    constructor(address _poapContract) Ownable(msg.sender) {
        require(_poapContract != address(0), "Invalid POAP contract");
        poapContract = IPOAP(_poapContract);
    }
    
    /**
     * @dev Create a new event
     */
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
    
    /**
     * @dev Update event details (before start time)
     */
    function updateEvent(
        uint256 eventId,
        string memory name,
        string memory description,
        string memory imageURI
    ) external {
        Event storage evt = events[eventId];
        require(evt.organizer == msg.sender, "Not event organizer");
        require(block.timestamp < evt.startTime, "Event already started");
        require(evt.isActive, "Event not active");
        
        if (bytes(name).length > 0) evt.name = name;
        if (bytes(description).length > 0) evt.description = description;
        if (bytes(imageURI).length > 0) evt.imageURI = imageURI;
        
        emit EventUpdated(eventId);
    }
    
    /**
     * @dev Deactivate an event
     */
    function deactivateEvent(uint256 eventId) external {
        Event storage evt = events[eventId];
        require(evt.organizer == msg.sender || msg.sender == owner(), "Not authorized");
        require(evt.isActive, "Event already inactive");
        
        evt.isActive = false;
        emit EventDeactivated(eventId);
    }
    
    /**
     * @dev Increment claimed count (called by Claimer contract)
     */
    function incrementClaimedCount(uint256 eventId) external {
        require(msg.sender == owner(), "Not authorized");
        events[eventId].claimedCount++;
    }
    
    /**
     * @dev Check if event is claimable
     */
    function isClaimable(uint256 eventId) external view returns (bool) {
        Event memory evt = events[eventId];
        return evt.isActive &&
               block.timestamp >= evt.startTime &&
               block.timestamp <= evt.endTime &&
               evt.claimedCount < evt.maxAttendees;
    }
    
    /**
     * @dev Get event details
     */
    function getEvent(uint256 eventId) external view returns (Event memory) {
        return events[eventId];
    }
    
    /**
     * @dev Get all events by organizer
     */
    function getOrganizerEvents(address organizer) external view returns (uint256[] memory) {
        return organizerEvents[organizer];
    }
    
    /**
     * @dev Get total events created
     */
    function totalEvents() external view returns (uint256) {
        return _eventIds.current();
    }

}
