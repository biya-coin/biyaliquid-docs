---
description: Essential information about the Biya Chain EVM networks
---

# EVM 网络信息

{% tabs %}
{% tab title="Mainnet" %}
**Network Info**

* Chain ID: `1776`
* JSON-RPC Endpoint: `https://sentry.evm-rpc.biyachain.network/`
* WS Endpoint: `wss://sentry.evm-ws.biyachain.network`
* Faucet: N/A, to obtain Mainnet BIYA see [`biyachain.com/getbiya`](https://biyachain.com/getbiya/)
* Explorer: [`blockscout.biyachain.network`](https://blockscout.biyachain.network/)
* Explorer API: `https://blockscout-api.biyachain.network/api`

{% hint style="info" %}
Note that the Biya Chain Chain ID is natively `biyachain-1`. However, EVM uses a numeric chain ID of `1776`. While these are different, they map to the **same** network.

See [network information](../kuai-su-kai-shi/network-information.md) for more details.
{% endhint %}

**Contracts**

* **USDT** USDT (MTS) - [`0x88f7F2b685F9692caf8c478f5BADF09eE9B1Cc13`](https://blockscout.biyachain.network/address/0x88f7F2b685F9692caf8c478f5BADF09eE9B1Cc13)
* **wETH** wrapped ETH (MTS) - [`0x83A15000b753AC0EeE06D2Cb41a69e76D0D5c7F7`](https://blockscout.biyachain.network/address/0x83A15000b753AC0EeE06D2Cb41a69e76D0D5c7F7)
* **wBIYA** wrapped BIYA (MTS) - [`0x0000000088827d2d103ee2d9A6b781773AE03FfB`](https://blockscout.biyachain.network/address/0x0000000088827d2d103ee2d9A6b781773AE03FfB)
* **USDC** USDC (MTS) - [`0x2a25fbD67b3aE485e461fe55d9DbeF302B7D3989`](https://blockscout.biyachain.network/address/0x2a25fbD67b3aE485e461fe55d9DbeF302B7D3989)
* **MultiCall** - [`0xcA11bde05977b3631167028862bE2a173976CA11`](https://blockscout.biyachain.network/address/0xcA11bde05977b3631167028862bE2a173976CA11)

{% hint style="info" %}
Note that tokens that are **MTS** follow the [MultiVM Token Standard](https://docs.biyachain.network/developers-evm/multivm-token-standard).

This means the same token can be used in all Biya Chain modules (EVM, Cosmos) without using a bridge.
{% endhint %}

**More Providers**

* Explorers
  * Blockscout mirror: [`biyachain.cloud.blockscout.com`](https://biyachain.cloud.blockscout.com)
* JSON-RPC Providers
  * Quicknode [`quicknode.com/chains/biya`](https://www.quicknode.com/chains/biya)
    * Note that you will need to create an account on quicknode to obtain an endpoint URL
    * [Quicknode JSON-RPC documentation](https://www.quicknode.com/docs/biyachain/evm/eth_blockNumber)
  * ThirdWeb [`thirdweb.com/biyachain`](https://thirdweb.com/biyachain)
    * Note that you will need to create an account on thirdweb to obtain an endpoint URL
    * [ThirdWeb Playground](https://playground.thirdweb.com/)
{% endtab %}

{% tab title="Testnet" %}
**Network Info**

* Chain ID: `1439`
* JSON-RPC Endpoint: `https://k8s.testnet.json-rpc.biyachain.network/`
* WS Endpoint: `https://k8s.testnet.ws.biyachain.network/`
* Faucet: [`testnet.faucet.biyachain.network/`](https://testnet.faucet.biyachain.network/)
* Explorer: [`testnet.blockscout.biyachain.network/`](https://testnet.blockscout.biyachain.network/)
* Explorer API: `https://testnet.blockscout-api.biyachain.network/api`

{% hint style="info" %}
Note that the Biya Chain Chain ID is natively `biyachain-888`. However, EVM uses a numeric chain ID of `1439`. While these are different, they map to the **same** network.

See [network information](../kuai-su-kai-shi/network-information.md) for more details.
{% endhint %}

**Contracts**

* **wBIYA** wrapped BIYA (MTS) - [`0x0000000088827d2d103ee2d9A6b781773AE03FfB`](https://testnet.blockscout.biyachain.network/address/0x0000000088827d2d103ee2d9A6b781773AE03FfB)
* **USDT** USDT (MTS) - [`0xaDC7bcB5d8fe053Ef19b4E0C861c262Af6e0db60`](https://testnet.blockscout.biyachain.network/address/0xaDC7bcB5d8fe053Ef19b4E0C861c262Af6e0db60)

{% hint style="info" %}
Note that tokens that are **MTS** follow the [MultiVM Token Standard](https://docs.biyachain.network/developers-evm/multivm-token-standard).

This means the same token can be used in all Biya Chain modules (EVM, Cosmos) without using a bridge.
{% endhint %}

**More Providers**

* Explorers
  * Blockscout mirror: [`testnet-biyachain.cloud.blockscout.com/`](https://testnet-biyachain.cloud.blockscout.com/)
* JSON-RPC Providers
  * Quicknode [`quicknode.com/chains/biya`](https://www.quicknode.com/chains/biya)
    * Note that you will need to create an account on quicknode to obtain an endpoint URL
    * [Quicknode JSON-RPC documentation](https://www.quicknode.com/docs/biyachain/evm/eth_blockNumber)
  * ThirdWeb [`thirdweb.com/biyachain-evm-testnet`](https://thirdweb.com/biyachain-evm-testnet)
    * Note that you will need to create an account on thirdweb to obtain an endpoint URL
    * [ThirdWeb Playground](https://playground.thirdweb.com/)

**More Info**

For more information about Biya Chain EVM Testnet see the following pages:

* Basics:
  * [Start Building on EVM](./)
  * [Your first EVM smart contract](smart-contracts/)
  * [Your first EVM dApp](dapps/)
* Advanced:
  * [EVM Equivalence](evm-equivalence.md)
  * [MultiVM Token Standard](multivm-token-standard.md)
  * [Precompiles](precompiles.md)
{% endtab %}
{% endtabs %}
