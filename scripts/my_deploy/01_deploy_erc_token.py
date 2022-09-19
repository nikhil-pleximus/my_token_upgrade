from brownie import network, Contract, MyToken, web3, BasicToken, ProxyAdmin, TransparentUpgradeableProxy

from scripts.helpful_scripts import get_account, encode_function_data

def main():
    account = get_account()
    balance = web3.fromWei(account.balance(),"ether")
    print(f"You are on {network.show_active()} and have  {balance} ether")

    my_token = MyToken.deploy({"from": account}) # 0x73Afd6AA2F20d1d3aCA6aEdEa43233dC1A56366A
    # proxy_admin = ProxyAdmin.deploy({"from": account}) # 0x1cBCb8C504f360751ccCD31b31922CD4f4F4A861
    # encoded_initializer_function = encode_function_data(my_token.initialize,"MyTokenVersion2", "MT_V2","0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e")
    # proxy = TransparentUpgradeableProxy.deploy(
    #     my_token.address,
    #     # account.address,
    #     proxy_admin.address,
    #     encoded_initializer_function,
    #     {"from": account, "gas_limit": 1000000},
    # ) # 0xba10E183D6981952cB726B6FC2359dAE05deC220
    # basic_token = BasicToken.deploy("100000",{"from":account}) #ganache 0x57396cB7f61E6a716A3d1fE84441A5E19aDf2D7f



    # print("Mint price is", web3.fromWei(my_token.getMintPrice(),"ether"))
    # print("Burn price is", web3.fromWei(my_token.getMintPrice(),"ether"))

    # Goerli fork https://eth-goerli.g.alchemy.com/v2/G8tBmVsIAQb8Nx_Zw-Po009LE0adsmYJ