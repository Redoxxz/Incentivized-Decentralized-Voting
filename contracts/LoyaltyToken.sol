// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../Imports/ERC20.sol";
import "../Imports/AccessControl.sol";

contract LoyaltyToken is ERC20, AccessControl {
    // Define roles for minting and burning tokens
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");

    constructor() ERC20("LoyaltyToken", "LTY") {
        // Grant the contract deployer the default admin role: they can manage other roles
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    // Function to mint new tokens, accessible only by minters
    function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
        _mint(to, amount);
    }

    // Function to burn tokens from a holder, accessible only by burners
    function burn(address from, uint256 amount) public onlyRole(BURNER_ROLE) {
        _burn(from, amount);
    }

    // Setup a new minter
    function setupMinter(address minter) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _grantRole(MINTER_ROLE, minter);
    }

    // Setup a new burner
    function setupBurner(address burner) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _grantRole(BURNER_ROLE, burner);
    }
}
