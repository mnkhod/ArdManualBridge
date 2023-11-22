// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract BridgeMockToken is ERC20,ERC20Burnable, Ownable {
    constructor()
        ERC20("Bridge Mock Token", "B-MTK")
        Ownable(msg.sender)
    {
        _mint(msg.sender, 10 * 10 ** decimals());
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
}
