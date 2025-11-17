# 代币标准

Biyachain 提供了多种不同的代币标准，供在创建 dApp 时使用。在本文件中，我们将介绍不同类型的代币，以及使用每种代币的建议和指南。

## Denom

Denom 是 Biyachain 的银行模块中用于表示资产的方式。这些资产可以用于交易、在交易模块上创建新市场、参与拍卖、转账到另一个地址等。\
根据 denom 的来源及其在 Biyachain 上的创建方式，我们有不同类型的 denom：

* **本地 denom** - 这种类型只有一个 denom，即 `biya` denom，代表 Biyachain 的本地代币。
* **Peggy denom** - 这些 denom 代表通过 Peggy 桥从以太坊桥接到 Biyachain 的资产。它们的格式为 `peggy{ERC20_CONTRACT_ADDRESS}`。
* **IBC denom** - 这些 denom 代表通过 IBC 从其他 IBC 兼容链桥接过来的资产。它们的格式为 `ibc/{hash}`。
* **保险基金 denom** - 这些 denom 代表在 Biyachain 上创建的保险基金的代币份额。它们的格式为 `share{id}`。
* **工厂 denom** - 这些 `tokenfactory` denom 允许任何账户使用名称 `factory/{creator address}/{subdenom}` 创建新代币。由于代币是按创建者地址命名空间组织的，这使得代币铸造变得无需许可，因为不需要解决名称冲突。对于这些 denom 的一个特殊用例是表示来自 Cosmwasm 的 CW20 代币，在 Biyachain 的本地银行模块中使用。它们的格式为 `factory/{CW20_ADAPTER_CONTRACT}/{CW20_CONTRACT_ADDRESS}`，其中 `CW20_ADAPTER_CONTRACT` 是将 CW20 和本地银行模块转换的适配器合约地址。

我们将在本文件后续部分提供关于这些 denom 类型的更多细节。\
在[这里](https://docs.ts.injective.network/getting-started/assets)了解如何获取 denom 元数据。
