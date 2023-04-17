// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol"; // import IERC721Enumerable
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract NFTRenting is ERC721Holder, ReentrancyGuard {
    address public owner = msg.sender;
    struct Rental {
        address renter;
        uint256 startBlock;
        uint256 endBlock;
        uint256 deposit;
        uint256 price;
        bool active;
    }

    IERC721Enumerable public nft; // use IERC721Enumerable instead of IERC721
    uint256 public rentalPeriod;
    uint256 public rentalFee;

    mapping(uint256 => Rental) public rentals;

    event NFTRentingCreated(
        uint256 indexed tokenId,
        address indexed owner,
        uint256 rentalPeriod,
        uint256 rentalFee,
        uint256 deposit
    );

    event NFTRented(
        uint256 indexed tokenId,
        address indexed renter,
        uint256 startBlock,
        uint256 endBlock,
        uint256 deposit
    );

    event NFTReturned(
        uint256 indexed tokenId,
        address indexed renter,
        uint256 endBlock,
        uint256 price
    );

    constructor(IERC721Enumerable _nft, uint256 _rentalPeriod, uint256 _rentalFee) { // use IERC721Enumerable instead of IERC721
        nft = _nft;
        rentalPeriod = _rentalPeriod;
        rentalFee = _rentalFee;
    }

    function createRental(
        uint256 tokenId,
        uint256 deposit
    ) external {
        require(nft.ownerOf(tokenId) == msg.sender, "Not the owner of the NFT");
        require(deposit > 0, "Deposit must be greater than 0");

        rentals[tokenId] = Rental({
            renter: address(0),
            startBlock: 0,
            endBlock: 0,
            deposit: deposit,
            price: rentalFee,
            active: false
        });

        emit NFTRentingCreated(tokenId, msg.sender, rentalPeriod, rentalFee, deposit);
    }

    function rentNFT(uint256 tokenId) external payable nonReentrant {
        Rental storage rental = rentals[tokenId];
        require(rental.active == false, "NFT is already rented");
        require(nft.ownerOf(tokenId) == address(this), "NFT is not in the contract's custody");
        require(msg.value == rental.deposit, "Deposit amount incorrect");

        rental.active = true;
        rental.renter = msg.sender;
        rental.startBlock = block.number;
        rental.endBlock = block.number + rentalPeriod;

        nft.safeTransferFrom(address(this), msg.sender, tokenId);

        emit NFTRented(tokenId, msg.sender, rental.startBlock, rental.endBlock, rental.deposit);
    }

    function returnNFT(uint256 tokenId) external nonReentrant {
    Rental storage rental = rentals[tokenId];
    require(rental.active == true, "NFT is not rented");
    require(rental.renter == msg.sender, "Only renter can return the NFT");
    require(block.number >= rental.endBlock, "Rental period is not over yet");

    rental.active = false;
    uint256 price = rental.price;
    uint256 refund = rental.deposit - price;

    if (refund > 0) {
        payable(msg.sender).transfer(refund);
    }

    nft.safeTransferFrom(address(this), rental.renter, tokenId); // transfer the NFT back to the renter

    emit NFTReturned(tokenId, rental.renter, rental.endBlock, price);
    }

}