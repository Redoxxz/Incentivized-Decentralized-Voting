// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../Imports/Ownable.sol";
import "../Imports/AccessControl.sol";

interface IUserContract {
    function setUserActive(address user, bool isActive) external;
}

contract CompanyMaster is Ownable, AccessControl {
    // Define roles using keccak256 hash
    bytes32 public constant POLL_MANAGER_ROLE = keccak256("POLL_MANAGER_ROLE");
    bytes32 public constant TOKEN_MANAGER_ROLE = keccak256("TOKEN_MANAGER_ROLE");
    bytes32 public constant USER_MANAGER_ROLE = keccak256("USER_MANAGER_ROLE");

    // Addresses of child contracts for easy access and management
    address public loyaltyToken;
    address public userContract;
    address public pollContract;

    // Event logging for contract deployments and critical actions
    event ContractDeployed(string contractType, address deployedAddress);

    constructor() Ownable(msg.sender) {
        // Grant the default admin role to the deployer
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);

        // Set admin roles for manageable roles
        _setRoleAdmin(POLL_MANAGER_ROLE, DEFAULT_ADMIN_ROLE);
        _setRoleAdmin(TOKEN_MANAGER_ROLE, DEFAULT_ADMIN_ROLE);
        _setRoleAdmin(USER_MANAGER_ROLE, DEFAULT_ADMIN_ROLE);
    }

    // Function to deploy Token Contract
    function deployLoyaltyToken(address _loyaltyToken) public onlyOwner {
        loyaltyToken = _loyaltyToken;
        emit ContractDeployed("LoyaltyToken", _loyaltyToken);
    }

    // Function to deploy User Contract
    function deployUserContract(address _userContract) public onlyOwner {
        userContract = _userContract;
        emit ContractDeployed("UserContract", _userContract);
    }

    // Function to deploy Poll Contract
    function deployPollContract(address _pollContract) public onlyOwner {
        pollContract = _pollContract;
        emit ContractDeployed("PollContract", _pollContract);
    }

    function manageUser(address user, bool isActive) public onlyRole(USER_MANAGER_ROLE) {
        require(user != address(0), "Invalid user address");
        IUserContract(userContract).setUserActive(user, isActive);
    }

    // Setup roles for different functionalities
    function setupRole(bytes32 role, address account) public onlyOwner {
        _grantRole(role, account);
    }
}