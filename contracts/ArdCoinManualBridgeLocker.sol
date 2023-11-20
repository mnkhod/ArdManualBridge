// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "./interfaces/IERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";

contract ArdCoinManualBridgeLocker is AccessControl, Pausable {

    IERC20 private immutable _token;
    bytes32 public constant LOCK_ROLE = keccak256("LOCK_ROLE");
    bytes32 public constant UNLOCK_ROLE = keccak256("UNLOCK_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    /// @notice 
    /// @dev 
    event TokenLocked(uint256 amount);
    /// @notice 
    /// @dev 
    event TokenUnlocked(uint256 amount);

    constructor(IERC20 token_) {
        _token = token_;
        _grantRole(LOCK_ROLE, msg.sender);
        _grantRole(UNLOCK_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
    }

    // BUSINESS LOGIC FUNCTIONS
    //

    function lock(address from,uint256 amount) public onlyRole(LOCK_ROLE) whenNotPaused() {
      require(from != address(0),"FROM ADDRESS EMPTY");
      require(amount != 0,"AMOUNT EMPTY");

      _token.transferFrom(from,address(this),amount);
      emit TokenLocked(amount);
    }

    function unlock(address to,uint256 amount) public onlyRole(UNLOCK_ROLE) whenNotPaused() {
      require(to != address(0),"TO ADDRESS EMPTY");
      require(amount != 0,"AMOUNT EMPTY");

      _token.transfer(to,amount);
      emit TokenUnlocked(amount);
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

    function lockBalance() public view returns (uint256) {
      return _token.balanceOf(address(this));
    }

    // @dev Returns the token being held.
    function token() public view virtual returns (IERC20) {
        return _token;
    }

}
