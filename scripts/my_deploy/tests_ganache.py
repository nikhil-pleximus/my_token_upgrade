# Initilize both tokens
my_token = Contract.from_abi("my_tok", "0x73Afd6AA2F20d1d3aCA6aEdEa43233dC1A56366A", MyToken.abi)
basic_token = Contract.from_abi("basic", "0x57396cB7f61E6a716A3d1fE84441A5E19aDf2D7f", BasicToken.abi)

my_token.initialize("MyToken", "tok", "0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e", {"from": accounts[0]})


# Check balane of Basic token
basic_token.balanceOf(accounts[0].address)

# Check balance of MyToken
my_token.balanceOf(accounts[0].address)

# Check allowance of erc20 token
basic_token.allowance(accounts[0].address, my_token.address)

# token name       contract address   amount      
basic_token.approve(my_token.address, 1000000, {"from": accounts[0]})
basic_token.approve(accounts[0].address, 1000000, {"from": my_token.address})

basic_token.allowance(my_token.address, accounts[0].address)

basic_token.allowance(accounts[0].address, my_token.address)

my_token.swap(10, {"from": accounts[0]})

my_token.balanceOf(accounts[0])

basic_token.balanceOf(accounts[0])

basic_token.balanceOf(my_token.address)

basic_token.transfer(accounts[0].address, 1, {"from": my_token.address})

basic_token.balanceOf(accounts[0])