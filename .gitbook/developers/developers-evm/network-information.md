---
description: 关于 Biya Chain EVM 网络的基本信息
---

# EVM 网络信息

{% tabs %}
{% tab title="主网" %}
**网络信息**

* Chain ID: `1776`
* JSON-RPC 端点: `https://sentry.evm-rpc.biyachain.network/`
* WS 端点: `wss://sentry.evm-ws.biyachain.network`
* 水龙头: 不适用，获取主网 BIYA 请访问 [`biyachain.com/getbiya`](https://biyachain.com/getbiya/)
* 区块浏览器: [`blockscout.biyachain.network`](https://blockscout.biyachain.network/)
* 浏览器 API: `https://blockscout-api.biyachain.network/api`

{% hint style="info" %}
请注意，Biya Chain 的原生 Chain ID 是 `biyachain-1`。但是，EVM 使用数字 Chain ID `1776`。虽然这些 ID 不同，但它们映射到**同一个**网络。

更多详情请参阅[网络信息](../kuai-su-kai-shi/network-information.md)。
{% endhint %}

**合约地址**

* **USDT** USDT (MTS) - [`0x88f7F2b685F9692caf8c478f5BADF09eE9B1Cc13`](https://blockscout.biyachain.network/address/0x88f7F2b685F9692caf8c478f5BADF09eE9B1Cc13)
* **wETH** wrapped ETH (MTS) - [`0x83A15000b753AC0EeE06D2Cb41a69e76D0D5c7F7`](https://blockscout.biyachain.network/address/0x83A15000b753AC0EeE06D2Cb41a69e76D0D5c7F7)
* **wBIYA** wrapped BIYA (MTS) - [`0x0000000088827d2d103ee2d9A6b781773AE03FfB`](https://blockscout.biyachain.network/address/0x0000000088827d2d103ee2d9A6b781773AE03FfB)
* **USDC** USDC (MTS) - [`0x2a25fbD67b3aE485e461fe55d9DbeF302B7D3989`](https://blockscout.biyachain.network/address/0x2a25fbD67b3aE485e461fe55d9DbeF302B7D3989)
* **MultiCall** - [`0xcA11bde05977b3631167028862bE2a173976CA11`](https://blockscout.biyachain.network/address/0xcA11bde05977b3631167028862bE2a173976CA11)

{% hint style="info" %}
请注意，标记为 **MTS** 的代币遵循[多虚拟机代币标准](https://docs.biyachain.network/developers-evm/multivm-token-standard)。

这意味着同一代币可以在所有 Biya Chain 模块（EVM、Cosmos）中使用，无需使用桥接。
{% endhint %}

**更多提供商**

* 区块浏览器
  * Blockscout 镜像: [`biyachain.cloud.blockscout.com`](https://biyachain.cloud.blockscout.com)
* JSON-RPC 提供商
  * Quicknode [`quicknode.com/chains/biya`](https://www.quicknode.com/chains/biya)
    * 注意：您需要在 quicknode 上创建账户以获取端点 URL
    * [Quicknode JSON-RPC 文档](https://www.quicknode.com/docs/biyachain/evm/eth_blockNumber)
  * ThirdWeb [`thirdweb.com/biyachain`](https://thirdweb.com/biyachain)
    * 注意：您需要在 thirdweb 上创建账户以获取端点 URL
    * [ThirdWeb Playground](https://playground.thirdweb.com/)
{% endtab %}

{% tab title="测试网" %}
**网络信息**

* Chain ID: `1439`
* JSON-RPC 端点: `https://k8s.testnet.json-rpc.biyachain.network/`
* WS 端点: `https://k8s.testnet.ws.biyachain.network/`
* 水龙头: [`prv.faucet.biya.io/`](https://prv.faucet.biya.io/)
* 区块浏览器: [`testnet.blockscout.biyachain.network/`](https://testnet.blockscout.biyachain.network/)
* 浏览器 API: `https://testnet.blockscout-api.biyachain.network/api`

{% hint style="info" %}
请注意，Biya Chain 的原生 Chain ID 是 `biyachain-888`。但是，EVM 使用数字 Chain ID `1439`。虽然这些 ID 不同，但它们映射到**同一个**网络。

更多详情请参阅[网络信息](../kuai-su-kai-shi/network-information.md)。
{% endhint %}

**合约地址**

* **wBIYA** wrapped BIYA (MTS) - [`0x0000000088827d2d103ee2d9A6b781773AE03FfB`](https://testnet.blockscout.biyachain.network/address/0x0000000088827d2d103ee2d9A6b781773AE03FfB)
* **USDT** USDT (MTS) - [`0xaDC7bcB5d8fe053Ef19b4E0C861c262Af6e0db60`](https://testnet.blockscout.biyachain.network/address/0xaDC7bcB5d8fe053Ef19b4E0C861c262Af6e0db60)

{% hint style="info" %}
请注意，标记为 **MTS** 的代币遵循[多虚拟机代币标准](https://docs.biyachain.network/developers-evm/multivm-token-standard)。

这意味着同一代币可以在所有 Biya Chain 模块（EVM、Cosmos）中使用，无需使用桥接。
{% endhint %}

**更多提供商**

* 区块浏览器
  * Blockscout 镜像: [`testnet-biyachain.cloud.blockscout.com/`](https://testnet-biyachain.cloud.blockscout.com/)
* JSON-RPC 提供商
  * Quicknode [`quicknode.com/chains/biya`](https://www.quicknode.com/chains/biya)
    * 注意：您需要在 quicknode 上创建账户以获取端点 URL
    * [Quicknode JSON-RPC 文档](https://www.quicknode.com/docs/biyachain/evm/eth_blockNumber)
  * ThirdWeb [`thirdweb.com/biyachain-evm-testnet`](https://thirdweb.com/biyachain-evm-testnet)
    * 注意：您需要在 thirdweb 上创建账户以获取端点 URL
    * [ThirdWeb Playground](https://playground.thirdweb.com/)

**更多信息**

有关 Biya Chain EVM 测试网的更多信息，请参阅以下页面：

* 基础知识:
  * [开始在 EVM 上构建](./)
  * [您的第一个 EVM 智能合约](smart-contracts/)
  * [您的第一个 EVM dApp](dapps/)
* 高级内容:
  * [EVM 等效性](evm-equivalence.md)
  * [多虚拟机代币标准](multivm-token-standard.md)
  * [预编译合约](precompiles.md)
{% endtab %}
{% endtabs %}
