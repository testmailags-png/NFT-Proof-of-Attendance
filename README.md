# NFT Proof of Attendance 

A blockchain platform for issuing digital badges as NFTs to verify event attendance. Simple, permanent, and trustless.

## Overview

Event organizers create NFT badges for their events. Attendees claim these badges as proof they were there. All badges are stored on the blockchain forever and cannot be transferred or sold.

## Features

- **Create Event Badges**: Design unique NFT badges for any event
- **Claim Attendance**: Attendees get NFTs by claiming them
- **Soulbound NFTs**: Badges cannot be transferred (tied to your wallet forever)
- **Verify Attendance**: Anyone can check if someone attended an event
- **Badge Gallery**: Display all your collected event badges
- **Event Browser**: Explore past and upcoming events

## Tech Stack

### Blockchain
- **Solidity**: Smart contracts
- **Hardhat**: Testing and deployment
- **OpenZeppelin**: ERC-721 standard

### Frontend
- **React**: User interface
- **Ethers.js**: Blockchain connection
- **IPFS**: Badge image storage
- **MetaMask**: Wallet

## Project Structure

```
NFT-Proof-of-Attendance/
├── contracts/
│   ├── POAP.sol           # Main NFT contract
│   ├── EventManager.sol   # Event creation
│   └── Claimer.sol        # Claiming logic
├── scripts/               # Deploy scripts
├── test/                  # Tests
└── frontend/
    └── src/
        ├── components/
        ├── pages/
        └── utils/
```

## How It Works

### Create Event
1. Organizer creates event with details
2. Uploads badge design to IPFS
3. Sets claim period and max attendees
4. Event goes live on blockchain

### Claim Badge
1. Attendee gets whitelisted by organizer
2. Connects wallet to platform
3. Claims badge during event window
4. NFT minted to their wallet
5. One badge per person

### View Collection
- All badges visible in wallet
- Gallery shows event details
- Permanent proof of attendance
- Cannot be sold or given away

## Design Choices

### Why Soulbound NFTs?

**No Trading**: Badges represent real attendance, not purchased proof

**Authentic**: Each badge truly belongs to the person who attended

**Identity**: Build reputation through genuine participation

**Simple**: No marketplace complexity needed

### Why Onchain?

**Permanent**: Records never disappear

**Verifiable**: Anyone can check attendance instantly

**Trustless**: No need to trust event organizer later

**Portable**: Your badges work across all platforms

## Core Components

### POAP.sol
- Modified ERC-721 with transfers disabled
- Mints one badge per attendee
- Links to event data
- Tracks who claimed

### EventManager.sol
- Creates new events
- Stores event information
- Controls who can create events
- Manages event lifecycle

### Claimer.sol
- Whitelist management
- Claim verification
- Prevents double claims
- Time window enforcement

## Features Breakdown

### For Organizers
- Create unlimited events
- Custom badge artwork
- Whitelist attendees
- Set claiming windows
- View statistics

### For Attendees
- Claim event badges
- View badge collection
- Prove attendance
- Share achievements

## Claiming Options

### Manual Whitelist
Organizer adds wallet addresses manually
- Good for small events
- Full control
- No automation needed

### QR Code
Attendees scan code at venue
- Fast check-in
- Medium-sized events
- Real-time claiming

### Signature
Organizer signs proof offline
- Scalable for large events
- Gas efficient
- Batch processing

## Event Types

- Conferences and summits
- Meetups and gatherings
- Workshops and courses
- Concerts and festivals
- Online webinars
- Hackathons
- Community events

## Use Cases

**Professional**: Prove conference attendance for resume

**Education**: Certificate of course completion

**Community**: Show active participation in DAO

**Gaming**: Tournament participation badges

**Networking**: Display shared experiences

**Marketing**: Reward early supporters

## Why This Approach?

### Benefits

**Trust**: Smart contracts enforce rules automatically

**Proof**: Undeniable record of attendance

**Reputation**: Build credibility through participation

**Composability**: Other apps can read your badges

**Free**: No recurring platform fees

## Future Ideas

- Multi-chain support
- Batch claiming
- Privacy options
- Mobile app
- Dynamic badges that evolve
- Event series bundles
- 
##remix logs...

contract address	0x0f52a6578c4e60f884244519954842ae4bd8a584

<img width="1399" height="798" alt="image" src="https://github.com/user-attachments/assets/38618c50-3659-47a5-87c1-09b53bcc8294" />



## License

MIT License
