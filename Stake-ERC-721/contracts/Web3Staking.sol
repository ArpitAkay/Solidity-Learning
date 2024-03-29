// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";

contract Staking is IERC721Receiver, ERC721Holder {

    IERC721 immutable nft;
    IERC20 immutable token; 

    mapping (address => mapping(uint256 => uint256)) public stakes;

    constructor(address _nft, address _token) {
        nft = IERC721(_nft);
        token = IERC20(_token);
    }

    function stake(uint256 _tokenId) public {
        require(nft.ownerOf(_tokenId) == msg.sender, "You don't own this NFT");

        //Stake the NFT
        stakes[msg.sender][_tokenId] = block.timestamp;

        nft.safeTransferFrom(msg.sender, address(this), _tokenId, "");
    }

    function unstake(uint256 _tokenId) public {
        //Calculate reward
        uint256 reward = calculateReward(_tokenId);
        delete stakes[msg.sender][_tokenId];

        nft.safeTransferFrom(address(this), msg.sender, _tokenId, "");

        token.transfer(msg.sender, reward);
    }

    function calculateReward(uint256 _tokenId) private view returns (uint256){
        require(stakes[msg.sender][_tokenId] > 0, "Nft has not been staked");
        uint256 time = block.timestamp - stakes[msg.sender][_tokenId];
        uint256 reward = calculate(time) * time * (10 ** 18) / 1 minutes;
        return reward;
    } 

    function calculate(uint256 time) private pure returns (uint256) {
        if(time < 1 minutes) {
            return 0;
        } else if(time < 3 minutes) {
            return 3;
        } else if(time < 5 minutes) {
            return 5;
        } else {
            return 10;
        }
    }
}