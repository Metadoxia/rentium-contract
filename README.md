
# RentiumNFT Contract

A Solidity contract for renting out ERC721 tokens for a set period of time. This contract is built on the OpenZeppelin library and uses the ERC721 token standard.

## Requirements
* Solidity compiler version 0.8.0 or higher
* OpenZeppelin library version 4.0.0 or higher
* An ERC721 token that implements the IERC721Enumerable interface

## Features
* Allows NFT owners to rent out their NFTs for a set period of time
* Allows renters to rent NFTs for a set period of time by paying a deposit
* Provides a refund to renters if they return the NFT before the rental period is over
* Allows NFT owners to set a rental fee and a deposit for each rental

# Diagrams
## Leasor perspective flow chart:
![renterSide](https://github.com/Metadoxia/rentium-contract/assets/73427323/45b8361d-c0cc-4924-9536-74c3c0916948)


## Owner perspective flow chart:
![ownerSide](https://github.com/Metadoxia/rentium-contract/assets/73427323/f6d2f173-b619-4b04-abae-0d5402fc9b8b)




# Usage

## Contract Deployment
To deploy the contract, you will need to provide the following parameters:

* An instance of an ERC721 token that implements the IERC721Enumerable interface
* The rental period in blocks
* The rental fee in wei

```
constructor(IERC721Enumerable _nft, uint256 _rentalPeriod, uint256 _rentalFee)

```

## Creating a rental

To create a rental, the NFT owner needs to call the createRental function and provide the following parameters:

* The token ID of the NFT to rent out
* The deposit amount in wei

```
function createRental(uint256 tokenId, uint256 deposit) external

```

## Renting an NFT

To rent an NFT, the renter needs to call the rentNFT function and provide the following parameters:

* The token ID of the NFT to rent
* The deposit amount in wei

```
function rentNFT(uint256 tokenId) external payable nonReentrant

```

## Returning an NFT

To return an NFT, the renter needs to call the returnNFT function and provide the following parameters:

* The token ID of the NFT to return

# Events
The contract emits the following events:
## NFTRentingCreated
Emitted when a rental is created.

```
event NFTRentingCreated(
    uint256 indexed tokenId,
    address indexed owner,
    uint256 rentalPeriod,
    uint256 rentalFee,
    uint256 deposit
);

```

## NFTRented
Emitted when an NFT is rented.
```
event NFTRented(
    uint256 indexed tokenId,
    address indexed renter,
    uint256 startBlock,
    uint256 endBlock,
    uint256 deposit
);

```

## NFTReturned
Emitted when an NFT is returned.

```
event NFTReturned(
    uint256 indexed tokenId,
    address indexed renter,
    uint256 endBlock,
    uint256 price
);

```
