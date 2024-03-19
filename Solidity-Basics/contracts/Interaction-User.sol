// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

contract User { 
    struct Player {
        address playerAddress;
        string username;
        uint256 score;
    }

    mapping (address => Player) public players;

    function createUser(address userAddress, string memory _username) external  {
        require(players[userAddress].playerAddress == address(0), "Player already exists");     //address(0) is like null pointer exception
        
        Player memory newPlayer = Player({
            playerAddress: userAddress,
            username: _username,
            score: 0
        });

        players[userAddress] = newPlayer;
    }
}