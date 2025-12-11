# Gas 和费用

## Gas 和费用

{% hint style="info" %}
了解 Biyaliquid 上 `Gas` 和 `Fees` 之间的区别。

前置阅读 -> [Cosmos SDK Gas](https://docs.cosmos.network/main/build/modules/auth#gas--fees)
{% endhint %}

Gas 表示在状态机上执行特定操作所需的计算工作量。

Biyaliquid 利用 gas 的概念来跟踪执行期间操作的资源使用情况。Biyaliquid 上的操作表示为对链存储的读取或写入。

费用在消息执行期间计算并向用户收取。该费用根据消息执行中消耗的所有 gas 的总和计算：

```
fee = gas * gas price
```

Gas 用于确保操作不需要过多的计算能力来完成，并阻止恶意用户对网络进行垃圾邮件攻击。

{% hint style="info" %}
**最低 gas 价格：** 验证者设置的最低 gas 价格目前为 `160,000,000biya`。要计算以 `biya` 支付的金额，请将 gas 价格乘以 gas 数量并除以 1e18（BIYA 有 18 位小数）。

**例如：** 如果 `gasWanted` 是 104,519，那么 `gasFees` = 160,000,000 \* 104,519 / 1e18 = 0.000016723`biya`
{% endhint %}

### Cosmos SDK `Gas`

在 Cosmos SDK 中，gas 在主 `GasMeter` 和 `BlockGasMeter` 中跟踪：

* `GasMeter`：跟踪导致状态转换的执行期间消耗的 gas。它在每次交易执行时重置。
* `BlockGasMeter`：跟踪区块中消耗的 gas，并确保 gas 不超过预定义的限制。此限制在 Tendermint 共识参数中定义，可以通过治理参数更改提案进行更改。

有关 Cosmos SDK 中 gas 的更多信息可以在[这里](https://docs.cosmos.network/main/learn/beginner/gas-fees)找到。

在 Cosmos 中，有些操作不是由交易触发的，但也可能导致状态转换。具体例子是 `BeginBlock` 和 `EndBlock` 操作以及 `AnteHandler` 检查，它们也可能在运行交易的状态转换之前读取和写入存储。

#### `BeginBlock` 和 `EndBlock`

这些操作由 Tendermint Core 的应用程序区块链接口（ABCI）定义，并由每个 Cosmos SDK 模块定义。正如它们的名称所示，它们分别在每个区块处理的开始和结束时执行（即交易执行前和执行后）。

#### `AnteHandler`

Cosmos SDK [`AnteHandler`](https://docs.cosmos.network/v0.45/modules/auth/03_antehandlers.html) 在交易执行之前执行基本检查。这些检查通常是签名验证、交易字段验证、交易费用等。
