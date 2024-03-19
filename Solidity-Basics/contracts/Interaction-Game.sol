// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

interface  IUser {
    function createUser(address userAddress, string memory _username) external;
}

contract Game {
    uint public gameCount;
    IUser public userContract;

    constructor(address _userContractAddress) {
        userContract = IUser(_userContractAddress);
    }

    function startGame(string memory username) public {
        gameCount++;
        userContract.createUser(msg.sender, username);
    }
}
