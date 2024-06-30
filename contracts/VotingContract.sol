// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../Imports/AccessControl.sol";
import "../Imports/IERC20.sol";

contract VotingContract is AccessControl {
    struct Vote {
        uint256 pollId;
        mapping(uint256 => uint256) optionCounts; // Counts votes per option
        mapping(address => bool) hasVoted; // Tracks if a user has voted
    }

    // Mapping from poll IDs to their voting data
    mapping(uint256 => Vote) public votes;

    // Access control role constants
    bytes32 public constant VOTE_MANAGER_ROLE = keccak256("VOTE_MANAGER_ROLE");
    address public tokenContract; // Address of the Token Contract for rewards

    // Events for vote casting
    event VoteCasted(uint256 indexed pollId, address indexed voter, uint256 option);

    constructor(address _tokenContract) {
        tokenContract = _tokenContract;
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function castVote(uint256 pollId, uint256 option) public onlyRole(VOTE_MANAGER_ROLE) {
        require(!votes[pollId].hasVoted[msg.sender], "You have already voted in this poll.");

        votes[pollId].optionCounts[option]++;
        votes[pollId].hasVoted[msg.sender] = true;

        emit VoteCasted(pollId, msg.sender, option);

        // Assuming there's a method to mint tokens in the Token Contract
        // This would require the Token Contract to have a mint function accessible by this contract
        IERC20(tokenContract).transfer(msg.sender, 1); // Reward 1 token per vote cast, for example
    }

    // Function to check if a user has voted in a specific poll
    function hasVoted(uint256 pollId, address voter) public view returns (bool) {
        return votes[pollId].hasVoted[voter];
    }
}
