// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin_upgrade/contracts/token/ERC777/ERC777Upgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract MyTokenV2 is ERC777Upgradeable {
	// IERC20 Interface lets us call IERC20 functions in other ERC20 contracts
	// TODO: Replace Address here with the token address you're targetting
	// IERC20 otherToken = IERC20(address(0x57396cB7f61E6a716A3d1fE84441A5E19aDf2D7f)); // ! Local token address

	// Owner of the contract
	address private owner;

	// Chainlink pricefeed
	AggregatorV3Interface internal priceFeed;
	IERC20 internal otherToken;
	uint8 private _decimals;

    address[] private this_array = [address(this)]; //! passed as array

	// TODO: Replace Token Name and Symbol
    // constructor() ERC777("MyTokenVersion2", "MT_V2", address(this)) {
	// constructor() ERC777("MyTokenVersion2", "MT_V2", temp) {
	// 	owner = msg.sender; // Set Deployer Address as the Owner
	// 	// priceFeed = AggregatorV3Interface(0xd0D5e3DB44DE05E9F294BB0a3bEEaF030DE24Ada); // MATIC/USD	on Matic Mumbai
	// 	priceFeed = AggregatorV3Interface(0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e); // ETH/USD 	on Ethereum Mainnet
	// }

	function initialize(string memory _name, string memory _symbol, address _feedAddress, address _otherToken) initializer public {
		__ERC777_init(_name, _symbol, this_array);
		owner = msg.sender;
		priceFeed = AggregatorV3Interface(_feedAddress);
		otherToken = IERC20(address(_otherToken));
		_decimals = 6;
		setupDecimals(_decimals);
    }

	function set_price_feed(address _feedAddress) public onlyOwner {
		priceFeed = AggregatorV3Interface(_feedAddress);
	}

	function set_other_token(address _otherToken) public onlyOwner {
		otherToken = IERC20(address(_otherToken));
	}

	uint private otherTokenDeposited;
	function swap(uint amount) public {
		otherToken.transferFrom(msg.sender, address(this), amount); // Transfer tokens from caller account to THIS Contract

		// Update Amount of USDT Received
		otherTokenDeposited += amount;

		// Mint New Tokens
		uint amountBasedOnFeed = (amount * 100000000) / getLatestPrice();
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
		operatorSend(msg.sender, 0x000000000000000000000000000000000000dEaD, amount, "", ""); // Send the tokens to DEAD Address

		uint tokensInCirculation = totalSupply() - tokensBurnt;

		// burnPrice initially set to pool index | if less than market price then it's sent to market price
		uint burnPrice = (tokensInCirculation * 1000000000) / (otherTokenDeposited - otherTokenWithdrawn);
		uint marketPrice = getLatestPrice() * 10;
		if (burnPrice < marketPrice) burnPrice = marketPrice;

		uint otherTokenAmount = (amount / burnPrice) * 1000000000;
		otherToken.transfer(msg.sender, otherTokenAmount); 																		// Transfer from THIS Contract to sender
		
		// Update records
		tokensBurnt += amount;
		otherTokenWithdrawn += otherTokenAmount;
	}

	function getBurnPrice() public view returns (uint) {
		uint tokensInCirculation = totalSupply() - tokensBurnt;
		if (tokensInCirculation == 0) return getLatestPrice();

		// burnPrice initially set to pool index | if less than market price then it's sent to market price
		uint burnPrice = (tokensInCirculation * 100000000) / (otherTokenDeposited - otherTokenWithdrawn);
		uint marketPrice = getLatestPrice();
		if (burnPrice < marketPrice) burnPrice = marketPrice;

		return burnPrice;
	}

	function decimals() override public pure returns (uint8) {
        return 6;
    }

	function setupDecimals(uint8 decimals) internal {
        decimals = decimals;
    }

	function getMintPrice() public view returns (uint) {
		return getLatestPrice();
	}

	function getLatestPrice() internal view returns (uint) {
		(
			uint80 _roundID,
			int price,
			uint _startedAt,
			uint _timeStamp,
			uint80 _answeredInRound
		) = priceFeed.latestRoundData();
		return uint(price);
	}

	function upgrade_test() public pure returns (uint) {
		return 100;
	}
}