import brownie
from brownie import MyToken, accounts, OtherTokenERC, web3, ProxyAdmin, TransparentUpgradeableProxy, Contract, MyTokenV2
from brownie.network.state import TxHistory
from scripts.helpful_scripts import encode_function_data, upgrade
history = TxHistory()

# https://eth-goerli.g.alchemy.com/v2/G8tBmVsIAQb8Nx_Zw-Po009LE0adsmYJ

def deploy_my_token():
    return MyToken.deploy({"from": accounts[0]})

def deploy_my_token_v2():
    return MyTokenV2.deploy({"from": accounts[0]})

def deploy_other_token(initial_balance):
    return OtherTokenERC.deploy(initial_balance, {"from": accounts[0]})

def check_balance(my_token, amount):
    assert (my_token.balanceOf(accounts[0].address) == amount)

def check_allowance(first, second, amount):
    assert (first.allowance(accounts[0].address, second.address) == amount)

# Deploy Token, proxy admin, and Transparent upgradable contract
def test_deploy():
    global other_token, my_token, proxy_admin, proxy_contract, initial_balance, swap_amount
    initial_balance = 100000
    swap_amount = 1303.46
    
    other_token = deploy_other_token(initial_balance)
    my_token = deploy_my_token()

    proxy_admin = ProxyAdmin.deploy({"from": accounts[0]})
    encoded_initializer_function = encode_function_data(my_token.initialize,"MyToken", "MT", "0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e" ,other_token.address)

    proxy = TransparentUpgradeableProxy.deploy(
        my_token.address,
        proxy_admin.address,
        encoded_initializer_function,
        # {"from": accounts[0], "gas_limit": 1000000},
        {"from": accounts[0]},
    )

    proxy_contract = Contract.from_abi("My Token", proxy.address, MyToken.abi)
    assert(True)

# Test initial balance and if Proxy contract is initiliazed
def test_initial_balance():
    check_balance(proxy_contract, 0) 
    check_balance(other_token, int(web3.toWei(initial_balance, "ether")))
    assert(proxy_contract.name() == "MyToken")
    assert(proxy_contract.symbol() == "MT")

# Check allowance and set allowance  
def test_check_allowance():
    check_allowance(other_token, proxy_contract, 0)
    check_allowance(proxy_contract, other_token, 0)
    other_token.approve(proxy_contract.address, web3.toWei(initial_balance, "ether"), {"from": accounts[0]})
    other_token.approve(accounts[0].address, web3.toWei(initial_balance, "ether"), {"from": proxy_contract.address})
    check_allowance(other_token, proxy_contract, web3.toWei(initial_balance, "ether"))
    assert (other_token.allowance(proxy_contract.address, accounts[0].address) == web3.toWei(initial_balance, "ether"))

# Test swap function
def test_swap():
    global mint_price
    mint_price = proxy_contract.getMintPrice()

    proxy_contract.swap(web3.toWei(swap_amount, "ether"), {"from": accounts[0]})

    other_balance = other_token.balanceOf(accounts[0].address)
    assert(other_balance == web3.toWei((initial_balance-swap_amount), "ether"))
    
    my_token_balance = other_token.balanceOf(proxy_contract.address)
    assert(my_token_balance == web3.toWei(swap_amount, "ether"))

    amountBasedOnFeed = (web3.toWei(swap_amount, "ether") * 100000000) / mint_price
    user_my_token = web3.fromWei(proxy_contract.balanceOf(accounts[0].address), "ether")
    assert(round(user_my_token, 10) == round(web3.fromWei(amountBasedOnFeed, "ether"), 10))

# Test burn function
def test_burn():
    amount = proxy_contract.balanceOf(accounts[0].address)
    bal_before_burn = other_token.balanceOf(proxy_contract.address)
    user_balance = other_token.balanceOf(accounts[0].address)

    assert (proxy_contract.totalSupply() == proxy_contract.balanceOf(accounts[0].address))

    proxy_contract.burnTokens(proxy_contract.balanceOf(accounts[0].address), {"from": accounts[0]})
    assert(proxy_contract.balanceOf(accounts[0].address) == 0)

    tokensInCirculation = proxy_contract.totalSupply()
    otherTokenDeposited = bal_before_burn
    burnPrice = (tokensInCirculation * 1000000000) / (otherTokenDeposited - 0)
    marketPrice = proxy_contract.getMintPrice() * 10
    if (burnPrice < marketPrice): 
        burnPrice = marketPrice
    otherTokenAmount = (amount / burnPrice) * 1000000000

    tot_bal = web3.fromWei((user_balance + otherTokenAmount), "ether")

    assert(user_balance < other_token.balanceOf(accounts[0].address))
    assert(other_token.balanceOf(proxy_contract.address) > 0)
    assert(round(tot_bal, 5) == round(web3.fromWei(other_token.balanceOf(accounts[0].address), "ether"), 5))

# Upgrade Contract with V2
def test_upgrade():
    global my_tokenV2, upgraded_contract
    my_tokenV2 = deploy_my_token_v2()
    upgrade(accounts[0], proxy_contract, my_tokenV2, proxy_admin_contract=proxy_admin)
    upgraded_contract = Contract.from_abi("My Token", proxy_contract.address, MyTokenV2.abi)
    assert(True)

# Check upgraded contract is working ok?
def test_upgrade_ok():
    ret_value = upgraded_contract.upgrade_test()
    assert(ret_value == 100)
    assert(upgraded_contract.address == proxy_contract.address) # Check if both address are same

# Test re-initialization of proxy contract
def test_re_initilize():
    with brownie.reverts():
        upgraded_contract.initialize("MyToken", "MT", "0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e" ,other_token.address, {"from": accounts[0]})