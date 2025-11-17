# Gas 和 Fees

## Gas 和 Fees

{% hint style="info" %}
了解 `Gas` 和 `Fees` 在 Biyachain 上的区别。

前置阅读-> [Cosmos SDK Gas](https://docs.cosmos.network/main/build/modules/auth#gas--fees)
{% endhint %}

Gas代表执行特定操作所需的计算工作量。

Biyachain 利用 gas 的概念来跟踪在执行过程中操作的资源使用情况。Biyachain 上的操作表示对区块链存储的读写操作。

在消息执行过程中，会计算并向用户收取Fees。这个Fees是根据消息执行中消耗的所有gas的总和来计算的：

```
fee = gas * gas price
```

Gas用于确保操作完成时不会消耗过多的计算力，并且能够防止恶意用户对网络进行垃圾信息攻击。

{% hint style="info" %}
最低 gas 价格：验证者设置的最低 gas 价格当前为 `160,000,000 BIYA`。要计算支付的 `biya` 数量，可以将 gas 价格乘以 gas 数量，然后除以 1e18（BIYA 有 18 位小数）。

例如：如果 `gasWanted` 为 104,519，则 `gasFees` = 160,000,000 \* 104,519 / 1e18 = 0.000016723 `biya`
{% endhint %}

### Cosmos SDK `Gas`

在 Cosmos SDK 中，gas 通过主 GasMeter 和 BlockGasMeter 进行追踪：

* **GasMeter**：用于跟踪执行过程中消耗的 gas，这些执行会导致状态转移。它在每次交易执行时会被重置。
* **BlockGasMeter**：用于跟踪一个区块中消耗的 gas，并确保消耗的 gas 不超过预定的限制。这个限制由 Tendermint 共识参数定义，并且可以通过治理参数变更提案进行修改。

有关 Cosmos SDK 中 gas 的更多信息，可以在[此处](https://docs.cosmos.network/main/learn/beginner/gas-fees)找到。

在 Cosmos 中，有些操作并不是由交易触发的，但也可能导致状态转移。具体的例子包括 BeginBlock 和 EndBlock 操作，以及 AnteHandler 检查，这些操作可能在运行交易的状态转移之前，也会读取和写入存储。

#### **`BeginBlock` 和 `EndBlock`**

这些操作由 Tendermint Core 的应用区块链接口（ABCI）定义，并由每个 Cosmos SDK 模块定义。顾名思义，它们分别在每个区块处理的开始和结束时执行（即，在交易执行之前和之后）。

#### **`AnteHandler`**

Cosmos SDK 的 `AnteHandler` 在交易执行之前执行基本检查。这些检查通常包括签名验证、交易字段验证、交易费用等。
