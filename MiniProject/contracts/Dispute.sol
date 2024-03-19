// SPDX-License-Identifier: MIT

import "./Types.sol";

pragma solidity ^0.8.24;

contract Dispute {
    // Errors
    error AlreadyVoted(address serviceReqAddress);
    error SelfVoteNotAllowed(address serviceReqAddress);
    error VotingEndedAlready(address serviceReqAddress);
    error VotingInProgress(address serviceReqAddress);
    error ServiceDoesNotExists(address serviceReqAddress);

    // State Variables
    mapping(address => Types.ServiceRequest) public serviceRequests;
    mapping(address => Types.UserInfo) public users;
    mapping(address => address[]) public peopleWhoAlreadyVoted;

    // Initialize the users and service request
    constructor() {
        Types.UserInfo memory shipper = Types.UserInfo("Arpit Kumar", msg.sender, 0 * 1e18, Types.Role.Shipper);
        Types.UserInfo memory driver = Types.UserInfo("Mohamed Farhan S", 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2, 5 * 1e18, Types.Role.Driver);
        Types.UserInfo memory receiver = Types.UserInfo("Dibyaprakash Pradhan", 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db, 5 * 1e18, Types.Role.Receiver);
        users[msg.sender] = shipper;
        users[0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2] = driver;
        users[0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db] = receiver;
        serviceRequests[msg.sender] = Types.ServiceRequest("Cricket Kit", shipper.userAddress, shipper.name, driver.userAddress, driver.name, receiver.userAddress, receiver.name, Types.ServiceStatus.Dispute, block.timestamp + 5 minutes, 0, 0);
    }

    // Function to give vote
    function vote(address _serviceReqAddress, Types.VoteType whomToVote) external returns (string memory){
        if(bytes(serviceRequests[_serviceReqAddress].serviceName).length == 0) {
            revert ServiceDoesNotExists({ serviceReqAddress: _serviceReqAddress});
        }

        Types.ServiceRequest memory sr = serviceRequests[_serviceReqAddress];

        if(block.timestamp > sr.endTime) {
            sr.serviceStatus = Types.ServiceStatus.Closed;

            if(sr.driverVote == sr.receiverVote && msg.sender == sr.shipperAddress) {
                increaseVote(whomToVote, _serviceReqAddress);
                peopleWhoAlreadyVoted[_serviceReqAddress].push(msg.sender);
                return "Voted successfully by shipper";
            }

            revert VotingEndedAlready({ serviceReqAddress: _serviceReqAddress});
        }

        if(msg.sender == sr.shipperAddress || msg.sender == sr.driverAddress || msg.sender == sr.receiverAddress) {
            revert SelfVoteNotAllowed({ serviceReqAddress: _serviceReqAddress });
        }

        address[] memory addressesOfPeopleWhoAlreadyVoted = peopleWhoAlreadyVoted[_serviceReqAddress];

        for(uint256 i=0; i<addressesOfPeopleWhoAlreadyVoted.length; i++) {
            if(addressesOfPeopleWhoAlreadyVoted[i] == msg.sender) {
                revert AlreadyVoted({ serviceReqAddress: _serviceReqAddress });
            }
        }

        peopleWhoAlreadyVoted[_serviceReqAddress].push(msg.sender);
        increaseVote(whomToVote, _serviceReqAddress);

        return "Voted successfully";
    }

    // Increase vote
    function increaseVote(Types.VoteType whomToVote, address _serviceReqAddress) internal {
        if(whomToVote == Types.VoteType.Driver)
            serviceRequests[_serviceReqAddress].driverVote++;
        else
            serviceRequests[_serviceReqAddress].receiverVote++;
    }

    // Declare Winner
    function decideWinner(address _serviceReqAddress) external returns(string memory){
        if(bytes(serviceRequests[_serviceReqAddress].serviceName).length == 0) {
            revert ServiceDoesNotExists({ serviceReqAddress: _serviceReqAddress});
        }

        Types.ServiceRequest memory sr = serviceRequests[_serviceReqAddress];

        if(block.timestamp > sr.endTime) {
            if(sr.driverVote > sr.receiverVote) {
                deductStars(sr.receiverAddress);
                return "Driver wins";
            }
            else if(sr.driverVote < sr.receiverVote) {
                deductStars(sr.driverAddress);
                return "Receiver wins";
            } else {
                return "Draw, shipper needs to vote";
            }
        } else {
            revert VotingInProgress({ serviceReqAddress: _serviceReqAddress });
        }
    }

    // Deduct stars
    function deductStars(address _addr) internal {
        if(users[_addr].stars > 0) {
            users[_addr].stars -= 0.1 * 1e18;
        }
    }
}