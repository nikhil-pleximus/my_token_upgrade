import brownie
from brownie import MyToken, accounts, OtherTokenERC, web3, ProxyAdmin, TransparentUpgradeableProxy, Contract, MyTokenV2, config, network
from brownie.network.state import TxHistory
from scripts.helpful_scripts import encode_function_data, upgrade, get_account
history = TxHistory()

# https://eth-goerli.g.alchemy.com/v2/G8tBmVsIAQb8Nx_Zw-Po009LE0adsmYJ

def deploy_my_token():
    return MyToken.deploy({"from": account}, publish_source=config["networks"][network.show_active()].get("verify"))

def deploy_my_token_v2():
    return MyTokenV2.deploy({"from": account})

def deploy_other_token(initial_balance):
    return OtherTokenERC.deploy(initial_balance, {"from": account})

def check_balance(my_token, amount):
    assert (my_token.balanceOf(account.address) == amount)

def check_allowance(first, second, amount):
    assert (first.allowance(account.address, second.address) == amount)


# tnx_amount = 1 * 10**6
# Deploy Token, proxy admin, and Transparent upgradable contract
def test_deploy():
    global other_token, my_token, proxy_admin, proxy_contract, initial_balance, swap_amount, account
    initial_balance = 100000
    swap_amount = 1303.46

    account = get_account()

    # other_token = deploy_other_token(initial_balance)
    my_token = deploy_my_token()

    proxy_admin = ProxyAdmin.deploy({"from": account}, publish_source=config["networks"][network.show_active()].get("verify"))

    # USDC on goerli 0x07865c6e87b9f70255377e024ace6630c1eaa37f
    encoded_initializer_function = encode_function_data(my_token.initialize, "NikhilToken", "NT", "0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e" ,"0x07865c6E87B9F70255377e024ace6630C1Eaa37F", 8, 6)
    proxy = TransparentUpgradeableProxy.deploy(
        my_token.address,
        proxy_admin.address,
        encoded_initializer_function,
        {"from": account, "gas_limit": 1000000},
        publish_source=config["networks"][network.show_active()].get("verify")
    )

    proxy_contract = Contract.from_abi("My Token", proxy.address, MyToken.abi)
    assert(False)


def test_swap():
    global mint_price
    mint_price = proxy_contract.getMintPrice()

    proxy_contract.swap(web3.toWei(swap_amount, "ether"), {"from": account})

    other_balance = other_token.balanceOf(account.address)
    assert(other_balance == web3.toWei((initial_balance-swap_amount), "ether"))
    
    my_token_balance = other_token.balanceOf(proxy_contract.address)
    assert(my_token_balance == web3.toWei(swap_amount, "ether"))

    amountBasedOnFeed = (web3.toWei(swap_amount, "ether") * 100000000) / mint_price
    user_my_token = web3.fromWei(proxy_contract.balanceOf(account.address), "ether")
    assert(round(user_my_token, 10) == round(web3.fromWei(amountBasedOnFeed, "ether"), 10))

# def test_burn():
#     assert(False)
#     amount = my_token.balanceOf(account.address)
#     bal_before_burn = other_token.balanceOf(my_token.address)
#     user_balance = other_token.balanceOf(account.address)

#     # web3.fromWei(other_token.balanceOf(account), "ether")
#     # web3.fromWei(my_token.balanceOf(account), "ether")

#     assert (my_token.totalSupply() == my_token.balanceOf(account.address))

#     my_token.burnTokens(my_token.balanceOf(account.address), {"from": account})
#     assert(my_token.balanceOf(account.address) == 0)
