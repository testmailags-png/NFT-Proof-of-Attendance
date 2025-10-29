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

status	0x1 Transaction mined and execution succeed
transaction hash	0x249997306b85dde36aa6c3e3081298597465c6402febee56e15bcefaa48d9c4d
block hash	0xe7c8edbbc5aff89042c7335cc9ebe53d0b3ba9e5a7bbdf73a068516e638a7221
block number	9504786
contract address	0x0f52a6578c4e60f884244519954842ae4bd8a584
from	0xd3761B4E38C09119266Ce2d74868a80e3c3e5B2b
to	AllInOnePOAP.(constructor)
gas	4955657 gas
transaction cost	4915478 gas 
input	0x608...e0033
decoded input	{}
decoded output	 - 
logs	[
	{
		"from": "0x0f52a6578c4e60f884244519954842ae4bd8a584",
		"topic": "0x8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e0",
		"event": "OwnershipTransferred",
		"args": {
			"0": "0x0000000000000000000000000000000000000000",
			"1": "0xd3761B4E38C09119266Ce2d74868a80e3c3e5B2b"
		}
	}
]
raw logs	[
  {
    "address": "0x0f52a6578c4e60f884244519954842ae4bd8a584",
    "topics": [
      "0x8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e0",
      "0x0000000000000000000000000000000000000000000000000000000000000000",
      "0x000000000000000000000000d3761b4e38c09119266ce2d74868a80e3c3e5b2b"
    ],
    "data": "0x",
    "blockNumber": "0x910812",
    "transactionHash": "0x249997306b85dde36aa6c3e3081298597465c6402febee56e15bcefaa48d9c4d",
    "transactionIndex": "0x0",
    "blockHash": "0xe7c8edbbc5aff89042c7335cc9ebe53d0b3ba9e5a7bbdf73a068516e638a7221",
    "logIndex": "0x0",
    "removed": false
  }
]

## License

MIT License
