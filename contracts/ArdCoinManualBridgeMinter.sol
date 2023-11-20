// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "./interfaces/IERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";

contract ArdCoinManualBridgeMinter is AccessControl, Pausable {

    IERC20 private immutable _token;
    bytes32 public constant MINT_ROLE = keccak256("MINT_ROLE");
    bytes32 public constant BURN_ROLE = keccak256("BURN_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    /// @notice 
    /// @dev 
    event TokenMinted(uint256 amount);
    /// @notice 
    /// @dev 
    event TokenBurned(uint256 amount);

    constructor(IERC20 token_) {
        _token = token_;
        _grantRole(MINT_ROLE, msg.sender);
        _grantRole(BURN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
    }

    // BUSINESS LOGIC FUNCTIONS
    //

    function mint(address to,uint256 amount) public onlyRole(MINT_ROLE) whenNotPaused() {
      require(to != address(0),"TO ADDRESS EMPTY");
      require(amount != 0,"AMOUNT EMPTY");

      _token.mint(to,amount);
      emit TokenMinted(amount);
    }

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

    // @dev Returns the token being held.
    function token() public view virtual returns (IERC20) {
        return _token;
    }

}
