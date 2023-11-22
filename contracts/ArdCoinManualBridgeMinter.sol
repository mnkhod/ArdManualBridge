// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "./interfaces/IERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";

/// @notice BridgeMinter contract is meant to be deployed on targeted EVM chains other than the main chain.
/// @notice BridgeMinter contract will need bridgeTokens henceforth bridgeTokens must be deployed first before contract is deployed.
/// @notice BridgeMinter contract has core mint/burn functionality.

/// @notice BridgeMinter contract mint functionality must be used when Main Chain BridgeLocker Contract locks x amount of main token. X amount of tokens must be minted using this contract.
/// @notice BridgeMinter contract burn functionality must be used first before manual bridging the x amount from target chain to x main chain. BridgeLocker Contract must unlock x amount of main token. X amount of bridgeTokens must be burned.

/// @notice Contract is meant to be very centralized.
/// @notice Contract is meant so business can have on-chain security & visibility for the token.
/// @notice Contract is only meant to be used for token owner to have manual bridge process flow and NOT MEANT FOR NORMAL TOKEN CONSUMERS.

/// @notice Bridge Token Owner must approve main token supply to the smart contract before using mint/burn functionality.

/// @dev Contract has main mint/burn business logic functions with some view functions.
/// @dev Contract has the current latest OpenZeppelin AccessControl,Pausable Extensions added for versatility.
/// @dev Contract has pausable functionality for mint/burn core business logic.
/// @dev Contract has access control functionality for better visibility and scope for responsibilities.
/// @dev Contract ADMIN will be a Multisignature Wallet for better security.
contract ArdCoinManualBridgeMinter is AccessControl, Pausable {

    /// @dev Token that will be locked and unlocked.
    /// @dev Token variable used to scope to that token only.
    IERC20 private immutable _token;

    /// @dev Access Control Roles for better visibility and scope for responsibilities.
    bytes32 public constant MINT_ROLE = keccak256("MINT_ROLE");
    bytes32 public constant BURN_ROLE = keccak256("BURN_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    /// @notice Event will be fired when token is minted.
    /// @dev Event will be used for indexing purposes.
    event TokenMinted(uint256 amount);
    /// @notice Event will be fired when token is burned.
    /// @dev Event will be used for indexing purposes.
    event TokenBurned(uint256 amount);

    /// @notice Initial Contract Deployer Address will be ADMIN of the smart contract with the rest of the roles.
    /// @notice Constructor will need the token that will be used to be locked and unlocked.
    constructor(IERC20 token_) {
        _token = token_;
        _grantRole(MINT_ROLE, msg.sender);
        _grantRole(BURN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    // BUSINESS LOGIC FUNCTIONS
    //

    /// @notice To bridge to from main chain to another chain, you must first lock main tokens then mint bridgeTokens here using mint functionality.
    /// @notice Bridge Token Owner must approve token supply to the smart contract before using this function.
    /// @dev Only MINT Role User can use this function.
    /// @dev Function fires TokenMinted Event.
    /// @dev Function only works when smart contract isn't paused.
    function mint(address to,uint256 amount) public onlyRole(MINT_ROLE) whenNotPaused() {
      require(to != address(0),"TO ADDRESS EMPTY");
      require(amount != 0,"AMOUNT EMPTY");

      _token.mint(to,amount);
      emit TokenMinted(amount);
    }

    /// @notice To bridge back to main chain, you must burn bridgeTokens first before calling main chain BridgeLocker smart contract unlock functionality.
    /// @notice Bridge Token Owner must approve token supply to the smart contract before using this function.
    /// @dev Only BURN Role User can use this function.
    /// @dev Function fires TokenBurned Event.
    /// @dev Function only works when smart contract isn't paused.
    function burn(address from,uint256 amount) public onlyRole(BURN_ROLE) whenNotPaused() {
      require(from != address(0),"FROM ADDRESS EMPTY");
      require(amount != 0,"AMOUNT EMPTY");

      _token.burnFrom(from,amount);
      emit TokenBurned(amount);
    }

    /// @notice OpenZeppelin Pausable Preset function
    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    /// @notice OpenZeppelin Pausable Preset function
    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    // VIEW FUNCTIONS
    //

    // @dev Returns the token address.
    function token() public view virtual returns (IERC20) {
        return _token;
    }

}
