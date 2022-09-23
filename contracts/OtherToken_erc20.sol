// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract OtherTokenERC is ERC20{
    IERC20 internal otherToken;
    uint8 private _decimals;
    constructor(uint total) ERC20("OtherToken", "OT") {
        _mint(msg.sender,total);
        _decimals = 6;
        setupDecimals(_decimals);
    }

    function swap(uint amount) public {
        _mint(msg.sender, amount*10**18);
    }

    function burnTokens(uint256 amount) public {
        _burn(msg.sender, amount);
    }

    function return_dec() public view returns (uint8) {
        return this.decimals();
    }

    function decimals() override public pure returns (uint8) {
        return 6;
    }

    function setupDecimals(uint8 decimals) internal {
        decimals = decimals;
    }
}