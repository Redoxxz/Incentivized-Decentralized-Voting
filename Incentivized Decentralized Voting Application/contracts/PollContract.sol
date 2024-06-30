// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../Imports/AccessControl.sol";
import "../Imports/IERC20.sol";
import "hardhat/console.sol";

interface ITokenContract {
    function mint(address to, uint256 amount) external;
}

contract PollContract is AccessControl {
    struct Poll {
        uint256 id;
        string question;
        string[] options;
        bool isActive;
        mapping(address => bool) hasVoted; // Mapping to track if a voter has voted
        mapping(uint256 => uint256) votes; // Mapping to track votes per option
    }

    Poll[] public polls;
    bytes32 public constant POLL_MANAGER_ROLE = keccak256("POLL_MANAGER_ROLE");
    ITokenContract public tokenContract; // Using the ITokenContract interface

    event PollCreated(uint256 id, string question);
    event PollActivated(uint256 id);
    event PollClosed(uint256 id);
    event Voted(address voter, uint256 pollId, uint256 option);

    constructor(address _tokenContract) {
        tokenContract = ITokenContract(_tokenContract);  // Initialize the token contract interface
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function createPoll(string memory question, string[] memory options) public onlyRole(POLL_MANAGER_ROLE) {
        Poll storage newPoll = polls.push();
        newPoll.id = polls.length - 1;
        newPoll.question = question;
        newPoll.options = options;
        newPoll.isActive = false;
        emit PollCreated(newPoll.id, question);
    }

    function activatePoll(uint256 pollId) public onlyRole(POLL_MANAGER_ROLE) {
        require(pollId < polls.length, "Poll does not exist.");
        polls[pollId].isActive = true;
        emit PollActivated(pollId);
    }

    function closePoll(uint256 pollId) public onlyRole(POLL_MANAGER_ROLE) {
        require(pollId < polls.length, "Poll does not exist.");
        polls[pollId].isActive = false;
        emit PollClosed(pollId);
    }

    function vote(uint256 pollId, uint256 option) public {
        require(pollId < polls.length, "Poll does not exist.");
        require(polls[pollId].isActive, "Poll is not active.");
        require(!polls[pollId].hasVoted[msg.sender], "Already voted.");

        polls[pollId].votes[option]++;
        polls[pollId].hasVoted[msg.sender] = true;
        emit Voted(msg.sender, pollId, option);

        // Reward the voter with tokens
        tokenContract.mint(msg.sender, 1);
    }
}
