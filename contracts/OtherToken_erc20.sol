// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract OtherTokenERC is ERC20{
    constructor(uint total) ERC20("OtherToken", "OT"){
        _mint(msg.sender,total*10**18);
    }
}