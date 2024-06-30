// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../Imports/AccessControl.sol";
import "../Imports/IERC20.sol";
import "hardhat/console.sol";

contract UserContract is AccessControl {
    struct UserProfile {
        uint256 uid;
        bytes32 hashedUid; // New field for the hashed UID
        uint256 tokenBalance;
        uint256 storeCredit;
        mapping(uint256 => bool) pollsParticipated;
        string[] votingRecords;
    }


    mapping(address => UserProfile) public userProfiles;
    address public loyaltyToken;
    uint256 private nextUid = 1;
    bytes32 public constant USER_MANAGER_ROLE = keccak256("USER_MANAGER_ROLE");

    event UserRegistered(address indexed user, uint256 uid);
    event TokensDeposited(address indexed user, uint256 amount);
    event VoteRecorded(address indexed user, uint256 pollId, string vote);
    event TokensRedeemed(address indexed user, uint256 tokens, uint256 credit);

    constructor(address _loyaltyToken) {
        loyaltyToken = _loyaltyToken;
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function registerUser(address userAddress) public onlyRole(USER_MANAGER_ROLE) {
        require(userProfiles[userAddress].uid == 0, "User already registered");
        userProfiles[userAddress].uid = nextUid++;
        userProfiles[userAddress].hashedUid = sha256(abi.encodePacked(userProfiles[userAddress].uid));
        emit UserRegistered(userAddress, userProfiles[userAddress].uid);
    }

    //For testing
    function testSetupUser(address userAddress, uint256 uid) public {
        require(block.chainid == 1337, "Not allowed except in test environment"); // Chain ID for Hardhat Network
        UserProfile storage profile = userProfiles[userAddress];
        profile.uid = uid;  // Directly setting the UID
        profile.tokenBalance = 1000;  // Setting an initial token balance
        profile.storeCredit = 100;  // Setting initial store credit
    }

    function depositTokens(address userAddress, uint256 amount) public onlyRole(USER_MANAGER_ROLE) {
        require(IERC20(loyaltyToken).transferFrom(msg.sender, address(this), amount), "Token transfer failed");
        userProfiles[userAddress].tokenBalance += amount;
        emit TokensDeposited(userAddress, amount);
    }

    function recordVote(address userAddress, uint256 pollId, string memory vote) public onlyRole(USER_MANAGER_ROLE) {
        require(!userProfiles[userAddress].pollsParticipated[pollId], "User already voted in this poll");
        userProfiles[userAddress].pollsParticipated[pollId] = true;
        userProfiles[userAddress].votingRecords.push(vote);
        emit VoteRecorded(userAddress, pollId, vote);
    }

    function redeemTokensForCredit(address userAddress, uint256 tokenAmount) public {
        require(userProfiles[userAddress].tokenBalance >= tokenAmount, "Insufficient tokens");
        uint256 credit = calculateCredit(tokenAmount);
        userProfiles[userAddress].tokenBalance -= tokenAmount;
        userProfiles[userAddress].storeCredit += credit;
        emit TokensRedeemed(userAddress, tokenAmount, credit);
    }

    function getTokenBalance(address userAddress) public view returns (uint256) {
        return userProfiles[userAddress].tokenBalance;
    }

    function getVotingRecords(address userAddress) public view returns (string[] memory) {
        return userProfiles[userAddress].votingRecords;
    }

    function getStoreCredit(address userAddress) public view returns (uint256) {
        return userProfiles[userAddress].storeCredit;
    }

    function calculateCredit(uint256 tokenAmount) private pure returns (uint256 credit) {
        credit = 0;
        while (tokenAmount >= 10) {
            if (tokenAmount >= 100) {
                credit += 4000; // $40 in cents
                tokenAmount -= 100;
            } else if (tokenAmount >= 50) {
                credit += 1500; // $15 in cents
                tokenAmount -= 50;
            } else if (tokenAmount >= 20) {
                credit += 500;  // $5 in cents
                tokenAmount -= 20;
            } else if (tokenAmount >= 10) {
                credit += 200;  // $2 in cents
                tokenAmount -= 10;
            }
        }
    }
}
