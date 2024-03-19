// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

contract EventExample {
    event NewUserRegistered(address indexed user, string username);     //indexed is used so that we can filter out

    struct User {
        string username;
        uint256 age;
    }

    mapping (address => User) public users;

    function registerUser(string memory _username, uint8 _age) public {
        User storage newUser = users[msg.sender];
        newUser.username = _username;
        newUser.age = _age;

        emit NewUserRegistered(msg.sender, _username);
    }
}

