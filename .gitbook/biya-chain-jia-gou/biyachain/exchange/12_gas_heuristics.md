---
sidebar_position: 13
title: Gas 启发式
---

本文档包含针对特定交易所消息的建议 `gasWanted` 值。这些值是通过启发式方法获得的，即观察包含单个消息类型的交易在 MsgServer 执行期间的 gas 消耗。从概念上讲，对于任何交易，以下公式适用：

```
    tx_gas = ante_gas + msg_gas (+ msg2_gas ...)
```

其中 `ante_gas` 是在 `AnteHandler` 期间消耗的 gas，随后的 `msg_gas` 总和是每个特定消息的 MsgServer 消耗的 gas（观察到的最高 `ante_gas` 是 120_000）。

在交易所参数中将 `fixed_gas_enabled` 设置为 `true` 时，可以使用以下值作为 `gasWanted`，以确保交易不会耗尽 gas：

> **注意**：假设交易包含单个消息。

| 消息类型                                          | Gas Wanted                   |
|-------------------------------------------------|------------------------------|
| MsgCreateDerivativeLimitOrder                   | 240,000 (仅挂单: 260,000)     |
| MsgCreateDerivativeMarketOrder                  | 235,000                      |
| MsgCancelDerivativeOrder                        | 190,000                      |
| MsgCreateSpotLimitOrder                         | 220,000 (仅挂单: 240,000)     |
| MsgCreateSpotMarketOrder                        | 170,000                      |
| MsgCancelSpotOrder                              | 185,000                      |
| MsgCreateBinaryOptionsLimitOrder                | 240,000 (仅挂单: 260,000)     |
| MsgCreateBinaryOptionsMarketOrder               | 225,000                      |
| MsgCancelBinaryOptionsOrder                     | 190,000                      |
| MsgDeposit                                      | 158,000                      |
| MsgWithdrawGas                                  | 155,000                      |
| MsgSubaccountTransferGas                        | 135,000                      |
| MsgExternalTransferGas                          | 160,000                      |
| MsgIncreasePositionMarginGas                    | 171,000                      |
| MsgDecreasePositionMarginGas                    | 180,000                      |

如果相关订单也是 GTB（Good-Till-Block，有效至区块）订单，则应在上面的值基础上增加等于上述值 10% 的 gas 量。

**批量消息类型**

批量消息类型的 gas 根据消息本身的内容而变化。此外，`ante_gas` 随订单数量扩展（明显增加约 3000 gas，包含在此公式中）：

`N` - 订单数量

- `MsgBatchCreateSpotLimitOrders`:           `tx_gas = 120_000 + N x 103_000`（例如，3 个订单需要 `329_000`）
- `MsgBatchCancelSpotOrders`:                `tx_gas = 120_000 + N x 68_000`
- `MsgBatchCreateDerivativeLimitOrders`:     `tx_gas = 120_000 + N x 123_000` 
- `MsgBatchCancelDerivativeOrders`:          `tx_gas = 120_000 + N x 73_000` 
- `MsgBatchCancelBinaryOptionsOrders`:       `tx_gas = 120_000 + N x 123_000`

***MsgBatchUpdateOrders***

```go
type MsgBatchUpdateOrders struct {
	Sender string
	
	SubaccountId                      string             // 仅用于全部取消（M - 市场数量，N - 市场中的订单数量）
	SpotMarketIdsToCancelAll          []string           // M x N x 65_000 
	DerivativeMarketIdsToCancelAll    []string           // M x N x 70_000
	BinaryOptionsMarketIdsToCancelAll []string           // M x N x 70_000
	
	SpotOrdersToCancel                []*OrderData       // N x 65_000 + N x 3000
	DerivativeOrdersToCancel          []*OrderData       // N x 70_000 + N x 3000
    BinaryOptionsOrdersToCancel       []*OrderData       // N x 70_000 + N x 3000
    SpotOrdersToCreate                []*SpotOrder       // N x 100_000（仅挂单为 120_000）+ N x 3000
    DerivativeOrdersToCreate          []*DerivativeOrder // N x 120_000（仅挂单为 140_000）+ N x 3000
	BinaryOptionsOrdersToCreate       []*DerivativeOrder // N x 120_000（仅挂单为 140_000）+ N x 3000
}
```

例如，假设您想要：

- 在市场 A 中取消 3 个现货订单
- 在市场 B 中创建 2 个衍生品订单
- 在市场 C 中创建 1 个二元期权仅挂单订单
- 取消现货市场 X 和 Y 中的所有订单（X 中 2 个订单，Y 中 2 个订单）

生成的 gas 计算如下：
```
    total_gas = 3 x 100_000 + 3 x 3000  // 取消 3 个现货订单
                + 2 x 120_000 + 2 x 3000 // 创建 2 个衍生品订单
                + 140_000 // 创建 1 个仅挂单二元期权订单
                + 4 x 65_000 // 全部取消 4 个现货订单
```

最终结果为 `955_000` gas。 
