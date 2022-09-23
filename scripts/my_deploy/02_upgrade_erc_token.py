from brownie import network, Contract, MyTokenV2, web3, ProxyAdmin, TransparentUpgradeableProxy, config, Contract

from scripts.helpful_scripts import get_account, encode_function_data, upgrade

def main():
    account = get_account()
    print(f"Deploying to {network.show_active()}")

    my_token_v2 = MyTokenV2.deploy({"from": account}, publish_source=config["networks"][network.show_active()].get("verify"))

    proxy = TransparentUpgradeableProxy[-1]
    proxy_admin = ProxyAdmin[-1]

    # Upgrade method calls upgrade method from proxy admin like following
    # proxy_admin.upgrade(proxy.address, my_token_v2.address, {"from": account})
    upgrade(account, proxy, my_token_v2, proxy_admin_contract=proxy_admin) # this upgrade method is imported from helpful scripts

    print("Proxy has been upgraded!")

    proxy_new_contract = Contract.from_abi("TokenV2", proxy.address, my_token_v2.abi)

    print("New implementation method", proxy_new_contract.dummy_func())