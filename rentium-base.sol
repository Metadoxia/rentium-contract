pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract NFTRentingContract {
    address private owner;
    mapping(uint256 => NFT) private nfts;

    struct NFT {
        address owner;
        address leasor;
        uint256 tokenId;
        uint256 rentalPrice;
        uint256 leasorReturnPrice;
        uint256 securityDeposit;
        uint256 rentDuration;
        uint256 rentStartTime;
    }

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only contract owner can call this function.");
        _;
    }

    function transferNFT(address _nftContract, uint256 _tokenId) public onlyOwner {
        IERC721 nft = IERC721(_nftContract);
        nft.transferFrom(msg.sender, address(this), _tokenId);
        nfts[_tokenId] = NFT({
            owner: msg.sender,
            leasor: address(0),
            tokenId: _tokenId,
            leasorReturnPrice: 0,
            rentalPrice: 0,
            securityDeposit: 0,
            rentDuration: 0,
            rentStartTime: 0
        });
    }

    function setRentalPrice(uint256 _tokenId, uint256 _price) public onlyOwner {
        require(nfts[_tokenId].owner != address(0), "NFT does not exist.");
        nfts[_tokenId].rentalPrice = _price;
    }

    function setRentalTerms(
        uint256 _tokenId,
        uint256 _securityDeposit,
        uint256 _rentDuration
    ) public onlyOwner {
        require(nfts[_tokenId].owner != address(0), "NFT does not exist.");
        nfts[_tokenId].securityDeposit = _securityDeposit;
        nfts[_tokenId].rentDuration = _rentDuration;
    }

    function rentNFT(uint256 _tokenId) public payable {
        require(nfts[_tokenId].owner != address(0), "NFT does not exist.");
        require(nfts[_tokenId].leasor == address(0), "NFT is already rented.");
        require(msg.value == nfts[_tokenId].securityDeposit, "Insufficient/More security deposit.");

        nfts[_tokenId].leasor = msg.sender;
        nfts[_tokenId].rentStartTime = block.timestamp;

        // Transfer the security deposit to the contract
        payable(address(this)).transfer(msg.value);
    }

    function returnNFT(uint256 _tokenId) public {
        require(nfts[_tokenId].owner == msg.sender || nfts[_tokenId].leasor == msg.sender, "You are not the owner or current leasor.");
        require(nfts[_tokenId].rentStartTime > 0, "NFT is not currently rented.");
        require(block.timestamp >= nfts[_tokenId].rentStartTime + nfts[_tokenId].rentDuration, "Rent period has not expired yet.");

        address currentOwner = nfts[_tokenId].owner;
        nfts[_tokenId].leasor = address(0);
        nfts[_tokenId].rentStartTime = 0;

        // Transfer the NFT back to the original owner
        IERC721 nft = IERC721(nfts[_tokenId].owner);
        nft.transferFrom(address(this), currentOwner, _tokenId);

        // If the NFT is returned on time, transfer the rental price to the owner
        if (msg.sender == nfts[_tokenId].leasor) {

            nfts[_tokenId].leasorReturnPrice = nfts[_tokenId].securityDeposit - nfts[_tokenId].rentalPrice;

            payable(nfts[_tokenId].owner).transfer(nfts[_tokenId].rentalPrice);
            payable(nfts[_tokenId].leasor).transfer(nfts[_tokenId].leasorReturnPrice);
        } else {
            // If the NFT is not returned, transfer the security deposit to the owner
            payable(nfts[_tokenId].owner).transfer(nfts[_tokenId].securityDeposit);
        }
    }

    function getNFTOwner(uint256 _tokenId) public view returns (address) {
        return nfts[_tokenId].owner;
    }

    function getNFTLeasor(uint256 _tokenId) public view returns (address) {
        return nfts[_tokenId].leasor;
    }

    function getRentalPrice(uint256 _tokenId) public view returns (uint256) {
        return nfts[_tokenId].rentalPrice;
    }

    function getRentalTerms(uint256 _tokenId)
        public
        view
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        return (
            nfts[_tokenId].securityDeposit,
            nfts[_tokenId].rentDuration,
            nfts[_tokenId].rentStartTime
        );
    }
}
 
