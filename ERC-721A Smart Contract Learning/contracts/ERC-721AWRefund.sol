// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.9;

import "https://github.com/chiru-labs/ERC721A/blob/main/contracts/ERC721A.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Web3Builders is ERC721A, Ownable {
    uint256 public constant mintPrice = 1 ether;
    uint256 public constant maxMintPerUser = 5;
    uint256 public constant maxMintSupply = 100;

    uint256 public constant refundPeriod = 3 minutes;
    uint256 public refundEndTimestamp;

    address public refundAddress;

    mapping(uint256 => uint256) public refundEndTimestamps;
    mapping(uint256 => bool) public hasRefunded;

    constructor(address initialOwner)
        ERC721A("Web3Builders", "WE3")
        Ownable(initialOwner)
    {
        refundAddress = address(this);
        }

    function safeMint(uint256 quantity) public payable { 
        require(msg.value >= mintPrice * quantity, "Not enough funds");
        require(_numberMinted(msg.sender) + quantity <= maxMintPerUser, "Mint Limit");
        require(_totalMinted() + quantity <= maxMintSupply, "Sold out");
        _safeMint(msg.sender, quantity);
        refundEndTimestamp = block.timestamp + refundPeriod;

        for(uint256 i= _nextTokenId() - quantity; i<_nextTokenId(); i++) {
            refundEndTimestamps[i] = refundEndTimestamp;
        }
    }

    function refund(uint256 tokenId) external {
        require(block.timestamp < getRefundDeadline(tokenId), "Refund period expired");

        //you have to be the owner of the NFT
        require(msg.sender == ownerOf(tokenId), "Not your NFT");
        uint256 refundAmount = getRefundAmount(tokenId);

        //transfer the ownership of NFT
        transferFrom(msg.sender, refundAddress, tokenId);

        //mark refund
        hasRefunded[tokenId] = true;

        //refund the price
        payable(msg.sender).transfer(refundAmount);
    }

    function getRefundDeadline(uint256 tokenId) internal view returns (uint256){
        if(hasRefunded[tokenId]) {
            return 0;
        }

        return refundEndTimestamps[tokenId];
    }

    function getRefundAmount(uint256 tokenId) internal view returns (uint256){
        if(hasRefunded[tokenId]) {
            return 0;
        }

        return mintPrice;
    }

    function withDraw() external payable onlyOwner {
        require(block.timestamp > refundEndTimestamp, "It's not past the refund period");
        uint256 balance = address(this).balance;
        payable(msg.sender).transfer(balance);
    }

    function nextTokenId() external view returns (uint256) {
        return _nextTokenId();
    }
}
