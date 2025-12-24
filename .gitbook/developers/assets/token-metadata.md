# 代币元数据

Biya Chain 上的资产表示为 denoms。Denoms（和数量）不是人类可读的，这就是为什么我们需要有一种方法为特定 denom "附加"代币元数据信息。

让我们回顾一下入门部分中的 denoms 类型：

* **原生 denoms** - 这种类型只有一个 denom，即 `biya` denom，它代表 Biya Chain 的原生代币，
* **Peggy denoms** - 这些 denoms 代表使用 Peggy 桥从以太坊桥接到 Biya Chain 的资产。它们具有以下格式 `peggy{ERC20_CONTRACT_ADDRESS}`
* **IBC denoms** - 这些 denoms 代表通过 IBC 从其他 Cosmos 链桥接过来的资产。它们具有以下格式 `ibc/{hash}`。
* **保险基金 Denoms** - 这些 denoms 代表在 Biya Chain 上创建的保险基金的代币份额。它们具有以下格式 `share{id}`
* **工厂 Denoms** - 这些 denoms 代表 Biya Chain 原生银行模块上来自 Cosmwasm 的 CW20 代币。它们具有以下格式 `factory/{CW20_ADAPTER_CONTRACT}/{CW20_CONTRACT_ADDRESS}`，其中 `CW20_ADAPTER_CONTRACT` 是转换 CW20 和原生银行模块的适配器合约地址。

我们在链外维护代币元数据列表，以便更快地访问 [biyachain-lists](https://github.com/biya-coin/biyachain-lists/tree/master/tokens) 存储库。

## 代币验证

验证代币的元数据可以通过几种方式完成。以下是验证级别及其含义：

* **已验证** -> 您的资产元数据已**提交并验证**到 `@biya-coin/token-metadata` 包。您可以在[这里](https://github.com/biya-coin/biyachain-lists/blob/master/CONTRIBUTING.md)找到有关如何将代币元数据添加到包的教程。
* **内部** -> 您的资产元数据已使用 `MsgSetDenomMetadata` 消息在链上验证，如[这里](../developers-native/examples/token-factory.md#msgsetdenommetadata)所述。
* **外部** -> 您的资产元数据已在某些外部来源（如以太坊的合约详细信息等）上验证。
* **未验证** -> 您的资产元数据尚未在任何地方提供。
