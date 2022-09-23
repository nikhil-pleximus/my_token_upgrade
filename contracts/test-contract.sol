// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract MyFun {
    uint priceFeed_decimals = 8;
	uint otherToken_decimals = 6;
    AggregatorV3Interface public  priceFeed = AggregatorV3Interface(0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e);

    

    function swap_test(uint amount) public view returns (uint) {
		// otherToken.transferFrom(msg.sender, address(this), amount); // Transfer tokens from caller account to THIS Contract

		// // Update Amount of USDT Received
		// otherTokenDeposited += amount;

		// Mint New Token
		// (1000000*(10**8) / 123400000000) / (1*10**6)
        uint swap_decimals = 18 - otherToken_decimals;
        // 126220000000
        // 126220000000
		uint amountBasedOnFeed = ((amount * 10**priceFeed_decimals)/getLatestPrice()) * (1*10**swap_decimals);
		return amountBasedOnFeed;

        // uint amountBasedOnFeed = ((amount * 10**priceFeed_decimals)/126220000000) * (1*10**swap_decimals)
	}

    function burn_test(uint amount) public view returns (uint) {
        // 792000000000000
        uint swap_decimals = 18 + (priceFeed_decimals-otherToken_decimals);
        uint otherTokenAmount = (amount * getLatestPrice()) / (1*10**swap_decimals); 	
        return otherTokenAmount;
    }
    
    function getMintPrice() public view returns (uint) {
		return getLatestPrice();
	}

	// Function fetched latest price data from provided price feed
	// the price is in (10^8) so we must divide it.
	function getLatestPrice() internal view returns (uint) {
		// (,int price,,,) = priceFeed.latestRoundData();
		uint8 price = priceFeed.decimals();
		return uint(price);
	}

	// https://ethereum.stackexchange.com/questions/15090/cant-do-any-integer-division
	function t1() public view returns (uint) {
		// return ((1000000 * (1*10**priceFeed_decimals)) / 773);
		uint r1 = prec_divide((1000000 * (1*10**priceFeed_decimals)), 773, 0);
		return (r1);
	}

	function prec_divide(uint a, uint b, uint precision) internal pure returns ( uint) {
     	return a*(10**precision)/b;
 	}

	function pricefeedD() public view returns (uint8) {
		uint8 dec =  priceFeed.decimals();
		return dec;
	}
}
// priceFeed_decimals = 8
// my_fun = MyFun.deploy({"from": accounts[0]})
// my_fun.t1()

// 100000000000000 