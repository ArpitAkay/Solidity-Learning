// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

contract Profile {
    struct UserProfile {
        string displayName;
        string bio;
    }

    mapping(address => UserProfile) public profiles;

    function setProfile(string memory _displayName, string memory _bio) public {
        profiles[msg.sender] = UserProfile(_displayName, _bio);
    }

    function getProfile(address _user) external view returns (UserProfile memory){
        return profiles[_user];
    }
}