// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "./interfaces/IERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";

/// @notice BridgeLocker contract is meant for the token Main Chain where lock/unlock functionality of the manual bridge flow will take place.
/// @notice When Tokens are locked then Minter contracts on other EVM Chain is responsible for minting the locked amount of bridgedAsset.
/// @notice When Tokens are unlocked then Minter contracts on other EVM Chain is responsible for burning the locked amount of bridgedAsset.
/// @notice Contract is meant to be very centralized.
/// @notice Contract is meant so business can have on-chain security & visibility for the token.
/// @notice Contract is only meant to be used for token owner to have manual bridge process flow and NOT MEANT FOR NORMAL TOKEN CONSUMERS.
/// @notice Token Owner must approve token supply to the smart contract before using lock/unlock functionality.
/// @dev Contract has main lock/unlock business logic functions with some view functions.
/// @dev Contract has the current latest OpenZeppelin AccessControl,Pausable Extensions added for versatility.
/// @dev Contract has pausable functionality for lock/unlock core business logic.
/// @dev Contract has access control functionality for better visibility and scope for responsibilities.
/// @dev Contract ADMIN will be a Multisignature Wallet for better security.
contract ArdCoinManualBridgeLocker is AccessControl, Pausable {

    /// @dev Token that will be locked and unlocked.
    /// @dev Token variable used to scope to that token only.
    IERC20 private immutable _token;

    /// @dev Access Control Roles for better visibility and scope for responsibilities.
    bytes32 public constant LOCK_ROLE = keccak256("LOCK_ROLE");
    bytes32 public constant UNLOCK_ROLE = keccak256("UNLOCK_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    /// @notice Event will be fired when token is locked.
    /// @dev Event will be used for indexing purposes.
    event TokenLocked(uint256 amount);
    /// @notice Event will be fired when token is unlocked.
    /// @dev Event will be used for indexing purposes.
    event TokenUnlocked(uint256 amount);

    /// @notice Initial Contract Deployer Address will be ADMIN of the smart contract with the rest of the roles.
    /// @notice Constructor will need the token that will be used to be locked and unlocked.
    constructor(IERC20 token_) {
        _token = token_;
        _grantRole(LOCK_ROLE, msg.sender);
        _grantRole(UNLOCK_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    // BUSINESS LOGIC FUNCTIONS
    //

    /// @notice To bridge from main chain to another chain , you must lock the tokens first here.
    /// @notice Token Owner must approve token supply to the smart contract before using this function.
    /// @dev Only LOCK Role User can use this function.
    /// @dev Function fires TokenLocked Event.
    /// @dev Function only works when smart contract isn't paused.
    /// @dev Function uses the ERC-20 Token TransferFrom Functionality.
    function lock(address from,uint256 amount) public onlyRole(LOCK_ROLE) whenNotPaused() {
      require(from != address(0),"FROM ADDRESS EMPTY");
      require(amount != 0,"AMOUNT EMPTY");

      _token.transferFrom(from,address(this),amount);
      emit TokenLocked(amount);
    }

    /// @notice To bridge from another chain to main chain , you must burn the bridge tokens then unlock the tokens using this function.
    /// @notice Must Burn the bridge amount on the other chain BEFORE UNLOCKING THE AMOUNT.
    /// @dev Only UNLOCK Role User can use this function.
    /// @dev Function fires TokenUnlocked Event.
    /// @dev Function only works when smart contract isn't paused.
    /// @dev Function uses the ERC-20 Token Transfer Functionality.
    function unlock(address to,uint256 amount) public onlyRole(UNLOCK_ROLE) whenNotPaused() {
      require(to != address(0),"TO ADDRESS EMPTY");
      require(amount != 0,"AMOUNT EMPTY");

      _token.transfer(to,amount);
      emit TokenUnlocked(amount);
    }

    /// @notice OpenZeppelin Pausable Preset function.
    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    /// @notice OpenZeppelin Pausable Preset function.
    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    // VIEW FUNCTIONS
    //

    // @dev Returns the locked token balance of smart contract.
    function lockBalance() public view returns (uint256) {
      return _token.balanceOf(address(this));
    }

    // @dev Returns the token address.
    function token() public view virtual returns (IERC20) {
        return _token;
    }

}
