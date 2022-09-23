from brownie import network, Contract, MyToken, web3, ProxyAdmin, TransparentUpgradeableProxy, config

from scripts.helpful_scripts import get_account, encode_function_data

def main():
    account = get_account()
    balance = web3.fromWei(account.balance(),"ether")
    print(f"You are on {network.show_active()} and have  {balance} ether")

    my_token = MyToken.deploy({"from": account}, publish_source=config["networks"][network.show_active()].get("verify")) # 0x73Afd6AA2F20d1d3aCA6aEdEa43233dC1A56366A
   
    proxy_admin = ProxyAdmin.deploy({"from": account}, publish_source=config["networks"][network.show_active()].get("verify"))

    # USDC on goerli 0x07865c6e87b9f70255377e024ace6630c1eaa37f
    encoded_initializer_function = encode_function_data(my_token.initialize, "MyToken", "NT", "0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e" ,"0x07865c6E87B9F70255377e024ace6630C1Eaa37F")
    proxy = TransparentUpgradeableProxy.deploy(
        my_token.address,
        proxy_admin.address,
        encoded_initializer_function,
        {"from": account, "gas_limit": 1000000},
        publish_source=config["networks"][network.show_active()].get("verify")
    )

    proxy_contract = Contract.from_abi("My Token", proxy.address, MyToken.abi)

    print("Name of Deployed token is", proxy_contract.name())