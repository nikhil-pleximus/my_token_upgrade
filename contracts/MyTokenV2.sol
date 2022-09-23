// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin_upgrade/contracts/token/ERC777/ERC777Upgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract MyTokenV2 is ERC777Upgradeable {
	// TODO: Replace Address here with the token address you're targetting
	// IERC20 otherToken = IERC20(address(0x57396cB7f61E6a716A3d1fE84441A5E19aDf2D7f)); // ! Local token address

	// Owner of the contract
	address private owner;

	// Chainlink pricefeed
	AggregatorV3Interface internal priceFeed;
	// Interface for erc20 token
	IERC20 internal otherToken;

	uint8 priceFeed_decimals;
	uint8 otherToken_decimals;
	uint8 private _decimals;


	function initialize(string memory _name, string memory _symbol, address _feedAddress, address _otherToken) initializer public {
		__ERC777_init(_name, _symbol, new address[](0));
		owner = msg.sender;
		
		priceFeed = AggregatorV3Interface(_feedAddress);
		priceFeed_decimals = priceFeed.decimals();
		
		otherToken = IERC20(address(_otherToken));
		otherToken_decimals = otherToken.decimals();
		
		// Set decimals of this token same as pricefeed decimals
		_decimals = priceFeed_decimals;
		_setupDecimals(_decimals);
    }

	// change price feed
	function set_price_feed(address _feedAddress) public onlyOwner {
		priceFeed = AggregatorV3Interface(_feedAddress);
	}

	// change address of other token
	function set_other_token(address _otherToken) public onlyOwner {
		otherToken = IERC20(address(_otherToken));
	}

	uint private otherTokenDeposited;
	function swap(uint amount) public {
		otherToken.transferFrom(msg.sender, address(this), amount); // Transfer tokens from caller account to THIS Contract

		// Update Amount of USDT Received
		otherTokenDeposited += amount;

		// Mint New Tokens
		uint swap_decimals = this.decimals() - otherToken_decimals;
		uint amountBasedOnFeed = ((amount * 10**priceFeed_decimals)/getLatestPrice()) * (1*10**swap_decimals);


		// uint amountBasedOnFeed = (amount * 100000000) / getLatestPrice();
		_mint(msg.sender, amountBasedOnFeed, "", "");
	}

	// Modifier to restrict access to Owner
	modifier onlyOwner() {
		require(msg.sender == owner, "Access Denied");
		_;
	}

	// Function to withdraw
	// Only Owner can call it
	// Transfers a specific amount to Owner's account
	function withdraw(uint256 amount) public onlyOwner {
		otherToken.transfer(owner, amount); // Transfer from THIS Contract to Owner
	}

	// Function to withdraw entire token balance
	// Only Owner can call it
	// address(this) returns the Contract Address
	// Transfers the entire balance to Owner's account
	function withdrawAll() public onlyOwner {
		otherToken.transfer(owner, otherToken.balanceOf(address(this))); // Transfer entire token balance of THIS Contract to Owner
	}

	// Burn Function
	uint private tokensBurnt;
	uint private otherTokenWithdrawn;
	function burnTokens(uint256 amount) public {
		// operatorSend(msg.sender, 0x000000000000000000000000000000000000dEaD, amount, "", ""); // Send the tokens to DEAD Address

		_burn(msg.sender, amount, "", "");
		// burnPrice initially set to pool index | if less than market price then it's sent to market price
		uint burnPrice;
		
		burnPrice = getBurnPrice();
		
		uint swap_decimals = this.decimals() + (priceFeed_decimals-otherToken_decimals);
		uint otherTokenAmount = (amount * burnPrice) / (1*10**swap_decimals);	
	
		// (0.5 * 10^18) * (1400 * 10^8) / 10^8
		// uint otherTokenAmount = (amount * burnPrice) / (1 * 10**otherToken_decimals);
		
		otherToken.transfer(msg.sender, otherTokenAmount); 	// Transfer from THIS Contract to sender
		
		// Update records
		tokensBurnt += amount;
		otherTokenWithdrawn += otherTokenAmount;
	}

	function getBurnPrice() public view returns (uint) {
		uint tokensInCirculation = totalSupply();
		if (tokensInCirculation == 0) return getLatestPrice();

		// burnPrice initially set to pool index | if less than market price then it's sent to market price
		// uint burnPrice = (tokensInCirculation * 100000000) / (otherTokenDeposited - otherTokenWithdrawn);
		// uint marketPrice = getLatestPrice();
		// if (burnPrice < marketPrice) burnPrice = marketPrice;

		uint burnPrice;
		// uint poolRatio = prec_divide((getCollateral() * (1*10**priceFeed_decimals)), tokensInCirculation, swap_decimals);
		uint poolRatio = (getCollateral() * (1*10**priceFeed_decimals) / tokensInCirculation);
		uint marketPrice = getLatestPrice();
		burnPrice = poolRatio;
		if (poolRatio > marketPrice) burnPrice = marketPrice;
		return burnPrice;
	}

	function decimals() override public pure returns (uint8) {
        return 6;
    }

	// Set decimals of current Contract
	function _setupDecimals(uint8 decimals_) internal {
        _decimals = decimals_;
    }

	// returns the Collateral when called
	function getCollateral() public view returns (uint) {
		return (otherTokenDeposited - otherTokenWithdrawn);
	}

	function getMintPrice() public view returns (uint) {
		return getLatestPrice();
	}

	// fetch latest price data from provided price feed
	// the price is in (10^8) so we must divide it.
	function getLatestPrice() internal view returns (uint) {
		(,int price,,,) = priceFeed.latestRoundData();
		return uint(price);
	}

	function dummy_func() public pure returns (uint) {
		return 1000;
	}
}