// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

library Types {
    enum ServiceStatus {
        Dispute, Closed
    }

    struct ServiceRequest {
        string serviceName;

        address shipperAddress;
        string shipperName;

        address driverAddress;
        string driverName;

        address receiverAddress;
        string receiverName;

        ServiceStatus serviceStatus;

        uint256 endTime;

        uint256 driverVote;
        uint256 receiverVote;
    }

    enum Role {
        Shipper, Driver, Receiver
    }

    struct UserInfo {
        string name;
        address userAddress;
        uint256 stars;
        Role role;
    }

    enum VoteType {
        Driver, Receiver
    }
}