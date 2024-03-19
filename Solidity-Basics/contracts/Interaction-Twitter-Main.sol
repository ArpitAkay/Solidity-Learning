// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";

pragma solidity ^0.8.24;

interface IProfile {
    struct UserProfile {
        string displayName;
        string bio;
    }

    function getProfile(address _user) external view returns (UserProfile memory);
}

contract Twitter is Ownable {
    IProfile public profileContract;

    event TweetCreated(uint256 id, address author, string content, uint256 timestamp);
    event TweetLiked(address liker, address tweetAuthor, uint256 tweetId, uint256 newLikeCount);
    event TweetUnliked(address unliker, address tweetAuthor, uint256 tweetId, uint256 newLikeCount);

    struct Tweet {
        uint256 id;
        address author;
        string content;
        uint256 timestamp;
        uint256 likes;
    }

    uint16 public  MAX_TWEET_LENGTH = 280;
    
    // address public owner;

    // constructor() {
    //     owner = msg.sender;     //owner is the person who deploys the contract
    // }

    constructor(address _profileContract) Ownable(msg.sender) {
        profileContract = IProfile(_profileContract);
    }

    modifier onlyRegistered() {
        IProfile.UserProfile memory tempUserProfile = profileContract.getProfile(msg.sender);
        require(bytes(tempUserProfile.displayName).length > 0, "User not registered");
        _;
    }

    // modifier onlyOwner() {
    //     require(msg.sender == owner, "You are not the owner");
    //     _;
    // }

    // mapping(address => string[]) public tweets;
    mapping(address => Tweet[]) public tweets;

    function createTweet(string memory _tweet) public onlyRegistered {     //_tweet is being stored in temporary memory
        // tweets[msg.sender] = _tweet;
        // tweets[msg.sender].push(_tweet);
        require(bytes(_tweet).length <= MAX_TWEET_LENGTH, "Tweet is too long" );
        Tweet memory newTweet = Tweet({
            id: tweets[msg.sender].length,
            author: msg.sender,
            content: _tweet,
            timestamp: block.timestamp,
            likes: 0
        });

        tweets[msg.sender].push(newTweet);

        emit TweetCreated(newTweet.id, newTweet.author, newTweet.content, newTweet.timestamp);
    }

    function getTweet(uint _idx) public view returns (Tweet memory){
        return tweets[msg.sender][_idx];
    }

    function getAllTweets(address _owner) public view returns (Tweet[] memory) {
        return tweets[_owner];
    }

    function changeTweetLength(uint16 newTweetLength) public onlyOwner {
        MAX_TWEET_LENGTH = newTweetLength;
    }

    function likeTweet( address author, uint256 id) external onlyRegistered {
        require(tweets[author][id].id == id, "Tweet does not exists");
        tweets[author][id].likes++;

        emit TweetLiked(msg.sender, author, id, tweets[author][id].likes);
    }

    function unlikeTweet(address author, uint256 id) external onlyRegistered {
        require(tweets[author][id].id == id, "Tweet does not exists");
        require(tweets[author][id].likes > 0, "Tweet has no Likes");
        tweets[author][id].likes--;

        emit TweetUnliked(msg.sender, author, id, tweets[author][id].likes);
    }

    function getTotalLikes(address _author) external view returns (uint){
        Tweet[] memory totalTweets = tweets[_author];
        uint totalLikes = 0;
        for(uint i=0; i<totalTweets.length; i++) {
            if(totalTweets[i].likes > 0) {
                totalLikes += totalTweets[i].likes;
            }
        }

        return totalLikes;
    } 
}