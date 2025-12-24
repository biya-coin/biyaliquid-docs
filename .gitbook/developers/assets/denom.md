# Denom

Denom 是资产在 Biya Chain 的银行模块中的表示方式。这些资产可用于交易、在交易所模块上创建新市场、参与拍卖、转账到其他地址等。

根据 denom 的来源以及它在 Biya Chain 上的创建方式，我们有不同类型的 denoms：

* **原生 denoms** - 这种类型只有一个 denom，即 `biya` denom，它代表 Biya Chain 的原生代币，
* **Peggy denoms** - 这些 denoms 代表使用 Peggy 桥从以太坊桥接到 Biya Chain 的资产。它们具有以下格式 `peggy{ERC20_CONTRACT_ADDRESS}`
* **IBC denoms** - 这些 denoms 代表通过 IBC 从其他 Cosmos 链桥接过来的资产。它们具有以下格式 `ibc/{hash}`。
* **保险基金 Denoms** - 这些 denoms 代表在 Biya Chain 上创建的保险基金的代币份额。它们具有以下格式 `share{id}`
* **工厂 Denoms** - 这些 denoms 是 Biya Chain 原生银行模块上来自 Cosmwasm 的 CW20 代币的表示。它们具有以下格式 `factory/{OWNER}/{SUBDENOM}`，其中 `OWNER` 是创建工厂 denom 的所有者。一个例子是 CW20 代币工厂 denom `factory/{CW20_ADAPTER_CONTRACT}/{CW20_CONTRACT_ADDRESS}`，其中 `CW20_ADAPTER_CONTRACT` 是在 CW20 和原生银行模块之间进行转换的适配器合约地址。

## 代币

代币只是 Biya Chain 链上带有一些元信息的 denom。元数据包括特定 denom 的符号、名称、小数位、徽标等信息。denom 的元数据对于 dApp 开发者来说非常重要，因为链上的信息以其原始形式存储（例如，链上的 `1biya` 表示为 `1*10^18biya`），所以我们需要有一种方法向用户显示人类可读的信息（数字、徽标、符号等）。

{% hint style="warning" %}
**弃用通知**

请注意，Biya Chain SDK 中曾有一个"Denom Client"可用。
这已被弃用，改为使用 [Biya Chain 列表](./biyachain-list.md)。
{% endhint %}
