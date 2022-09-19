import brownie
from tabnanny import check
from brownie import BasicToken, accounts, MyToken
from scripts.helpful_scripts import get_account, encode_function_data, upgrade


def deploy_token(initial_balance):
    return BasicToken.deploy(initial_balance,{"from": accounts[0]})

def deploy_my_token():
    return MyToken.deploy({"from": accounts[0]})

def check_balance(my_token, amount):
    assert (my_token.balanceOf(accounts[0].address) == amount)

def check_allowance(first, second, amount):
    assert (first.allowance(accounts[0].address, second.address) == amount)

def test_deploy():
    global basic_token, my_token, initial_balance, swap_amount
    initial_balance = 100000
    swap_amount = 10
    basic_token = deploy_token(initial_balance) # deploy erc20 with initial balance
    my_token = deploy_my_token() # deploy my_token 
    my_token.initialize("MyToken", "tok", "0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e", basic_token.address, {"from": accounts[0]}) # Initilize my_token

    assert (my_token.name() == "MyToken")
    assert (my_token.symbol() == "tok")

def test_re_initilize():
    with brownie.reverts():
        my_token.initialize("MyToken", "tok", "0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e", basic_token.address, {"from": accounts[0]})

def test_initial_balance():
    check_balance(my_token, 0) 
    check_balance(basic_token, initial_balance)
    

def test_check_allowance():
    check_allowance(basic_token, my_token, 0)
    check_allowance(my_token, basic_token, 0)
    basic_token.approve(my_token.address, initial_balance, {"from": accounts[0]})
    basic_token.approve(accounts[0].address, initial_balance, {"from": my_token.address})
    check_allowance(basic_token, my_token, initial_balance)

def test_swap():
    balance = int(my_token.getMintPrice()/100000000)
    my_token.swap(swap_amount, {"from": accounts[0]})
    total_tokens  = balance * swap_amount
    check_balance(my_token, total_tokens)
    check_balance(basic_token, initial_balance-swap_amount)

def test_burn():
    balance = int(my_token.getMintPrice()/100000000)
    total_tokens  = balance * swap_amount
    my_token.burnTokens(total_tokens, {"from": accounts[0]})
    # tokensInCirculation = my_token.totalSupply() - 0
    # burnPrice = (tokensInCirculation * 1000000000) / (swap_amount - 0)
    # marketPrice = my_token.getMintPrice() * 10
    # if (burnPrice < marketPrice):
    #     burnPrice = marketPrice
    # otherTokenAmount = (total_tokens / burnPrice) * 1000000000
    check_balance(my_token, 0)
    basic_token_balance = basic_token.balanceOf(accounts[0].address)
    otherTokenAmount = my_token.t1()
    assert(otherTokenAmount == 0)
    assert (basic_token_balance > (initial_balance-swap_amount))