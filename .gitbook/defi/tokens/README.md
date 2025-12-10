# 代币标准

Biyaliquid 提供了多种不同的代币标准，可在创建 dApp 时使用。在本文档中，我们将介绍不同类型的代币，以及使用每种代币的建议和指导。

## 代币单位（Denom）

代币单位（denom）是资产在 Biyaliquid 的 Bank 模块中的表示方式。这些资产可用于交易、在交易所模块上创建新市场、参与拍卖、转移到另一个地址等。

根据代币单位的来源及其在 Biyaliquid 上的创建方式，我们有不同类型的代币单位：

* **原生代币单位** - 只有一种此类型的代币单位，即 `biya` 代币单位，代表 Biyaliquid 的原生代币，
* **Peggy 代币单位** - 这些代币单位代表使用 Peggy 桥从 Ethereum 桥接到 Biyaliquid 的资产。它们的格式为 `peggy{ERC20_CONTRACT_ADDRESS}`
* **IBC 代币单位** - 这些代币单位代表通过 IBC 从其他 IBC 兼容链桥接过来的资产。它们的格式为 `ibc/{hash}`。
* **保险基金代币单位** - 这些代币单位代表在 Biyaliquid 上创建的保险基金的代币份额。它们的格式为 `share{id}`
* **工厂代币单位** - 这些 `tokenfactory` 代币单位允许任何账户创建一个名为 `factory/{creator address}/{subdenom}` 的新代币。因为代币按创建者地址命名空间化，这使得代币铸造无需许可，因为不需要解决名称冲突。这些代币单位的一个特殊用例是在 Biyaliquid 原生银行模块上表示来自 Cosmwasm 的 CW20 代币。它们的格式为 `factory/{CW20_ADAPTER_CONTRACT}/{CW20_CONTRACT_ADDRESS}`，其中 `CW20_ADAPTER_CONTRACT` 是转换 CW20 和原生 Bank 模块的适配器合约地址。

我们将在本文档后面分享有关这些代币单位类型的更多详细信息。

了解如何获取[代币单位元数据](../../developers/assets/token-metadata.md)。
