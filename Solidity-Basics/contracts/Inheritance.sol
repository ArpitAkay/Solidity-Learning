// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

contract MultiplayerGame {
    mapping (address => bool) public players;

    function joinGame() public virtual {    //the virtual keyword is used to declare a function as being able to be overridden by functions with the same signature in derived contracts
        players[msg.sender] = true;
    }
}

contract Game is MultiplayerGame {
    string public gameName;
    uint256 public playerCount;

    constructor(string memory _gameName) {
        gameName = _gameName;
    }

    function startGame() public {

    }

    function joinGame() public override  {
        super.joinGame();
        playerCount++;
    }
}