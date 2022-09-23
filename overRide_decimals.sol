// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC777/ERC777.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract MyToken is ERC777 {
	// IERC20 Interface lets us call IERC20 functions in other ERC20 contracts
	// TODO: Replace Address here with the token address you're targetting
	IERC20 otherToken = IERC20(address(0xcC08220af469192C53295fDd34CFb8DF29aa17AB));
    // mumbai DERC20: 0xfe4F5145f6e09952a5ba9e956ED0C25e3Fa4c7F1

	// Owner of the contract
	address private owner;
    uint8 private _decimals;

	// TODO: Replace Token Name and Symbol
	constructor() ERC777("MyToken", "MT", new address[](0)) {
		owner = msg.sender; // Set Deployer Address as the Owner
        _decimals = 6;
        _setupDecimals(_decimals); // set the number of decimals same as USDT, USDC
	}

	// mapping(address => uint) private deposited;
	function swap(uint amount) public {
		otherToken.transferFrom(msg.sender, address(this), amount); // Transfer tokens from caller account to THIS Contract
		_mint(msg.sender, amount, "", ""); // Mint New Tokens
	}

	// Modifier to restrict access to Owner
	modifier onlyOwner() {
		require(msg.sender == owner, "Access Denied");
		_;
	}

	// Function to withdraw
	// Only Owner can call it
	// Transfers a specific amount to Owner's account
	function withdraw(uint amount) public onlyOwner {
		otherToken.transfer(owner, amount);																						// Transfer from THIS Contract to Owner
	}

	// Function to withdraw entire token balance
	// Only Owner can call it
	// address(this) returns the Contract Address
	// Transfers the entire balance to Owner's account
	function withdrawAll() public onlyOwner {
		otherToken.transfer(owner, otherToken.balanceOf(address(this)));							// Transfer entire token balance of THIS Contract to Owner
	}

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     * Tokens usually opt for a value of 18, imitating the relationship between
     * ether and wei. This is the value {ERC20} uses, unless {_setupDecimals} is
     * called.
     * NOTE: This information is only used for display purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() override public pure returns (uint8) {
        return 6;
    }

    /**
     * @dev Sets {decimals} to a value other than the default one of 18.
     *
     * WARNING: This function should only be called from the constructor. Most
     * applications that interact with token contracts will not expect
     * {decimals} to ever change, and may work incorrectly if it does.
     */
    function setupDecimals(uint8 decimals) internal {
        decimals = decimals;
    }

}