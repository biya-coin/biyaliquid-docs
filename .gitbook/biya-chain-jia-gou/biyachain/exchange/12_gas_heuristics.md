---
sidebar_position: 13
title: Gas Heuristics
---

This doc contains suggested `gasWanted` values for specific Exchange messages. Values were obtained heuristically 
by observing gas consumption during MsgServer execution for a transaction containing a single Msg type. Conceptually, 
for any transaction the following formula applies:

```
    tx_gas = ante_gas + msg_gas (+ msg2_gas ...)
```

其中 `ante_gas` 是在 `AnteHandler` 期间消耗的 gas，随后的 `msg_gas` 总和是每个特定消息的 MsgServer 消耗的 gas（观察到的最高 `ante_gas` 是 120_000）。

在交易所参数中将 `fixed_gas_enabled` 设置为 `true` 时，可以使用以下值作为 `gasWanted`，以确保交易不会耗尽 gas：

> **注意**：假设交易包含单个消息。

| Message Type                                    | Gas Wanted                   |
|-------------------------------------------------|------------------------------|
| MsgCreateDerivativeLimitOrder                   | 240,000 (post-only: 260,000) |
| MsgCreateDerivativeMarketOrder                  | 235,000                      |
| MsgCancelDerivativeOrder                        | 190,000                      |
| MsgCreateSpotLimitOrder                         | 220,000 (post-only: 240,000) |
| MsgCreateSpotMarketOrder                        | 170,000                      |
| MsgCancelSpotOrder                              | 185,000                      |
| MsgCreateBinaryOptionsLimitOrder                | 240,000 (post-only: 260,000) |
| MsgCreateBinaryOptionsMarketOrder               | 225,000                      |
| MsgCancelBinaryOptionsOrder                     | 190,000                      |
| MsgDeposit                                      | 158,000                      |
| MsgWithdrawGas                                  | 155,000                      |
| MsgSubaccountTransferGas                        | 135,000                      |
| MsgExternalTransferGas                          | 160,000                      |
| MsgIncreasePositionMarginGas                    | 171,000                      |
| MsgDecreasePositionMarginGas                    | 180,000                      |

如果相关订单也是 GTB（Good-Till-Block）订单，则应在上面的值基础上增加等于上述值 10% 的 gas 量。

**批量消息类型**

批量消息类型的 gas 根据消息本身的内容而变化。此外，`ante_gas` 随订单数量扩展（明显增加约 3000 gas，包含在此公式中）。：

`N` - 是订单数量

- `MsgBatchCreateSpotLimitOrders`:           `tx_gas = 120_000 + N x 103_000` (e.g. for 3 orders you get `329_000`)
- `MsgBatchCancelSpotOrders`:                `tx_gas = 120_000 + N x 68_000`
- `MsgBatchCreateDerivativeLimitOrders`:     `tx_gas = 120_000 + N x 123_000` 
- `MsgBatchCancelDerivativeOrders`:          `tx_gas = 120_000 + N x 73_000` 
- `MsgBatchCancelBinaryOptionsOrders`:       `tx_gas = 120_000 + N x 123_000`

***MsgBatchUpdateOrders***

```go
type MsgBatchUpdateOrders struct {
	Sender string
	
	SubaccountId                      string             // used only with cancel-all ((M - number of markets, N number of orders in a market) 
	SpotMarketIdsToCancelAll          []string           // M x N x 65_000 
	DerivativeMarketIdsToCancelAll    []string           // M x N x 70_000
	BinaryOptionsMarketIdsToCancelAll []string           // M x N x 70_000
	
	SpotOrdersToCancel                []*OrderData       // N x 65_000 + N x 3000
	DerivativeOrdersToCancel          []*OrderData       // N x 70_000 + N x 3000
    BinaryOptionsOrdersToCancel       []*OrderData       // N x 70_000 + N x 3000
    SpotOrdersToCreate                []*SpotOrder       // N x 100_000 (120_000 if post-only) + N x 3000
    DerivativeOrdersToCreate          []*DerivativeOrder // N x 120_000 (140_000 if post-only) + N x 3000
	BinaryOptionsOrdersToCreate       []*DerivativeOrder // N x 120_000 (140_000 if post-only) + N x 3000
}
```

For example, let's suppose you want to:

- cancel 3 spot orders in market A
- create 2 derivative orders in market B
- create 1 binary-options post-only order in market C
- cancel all orders in spot markets X and Y (2 orders in X and 2 orders in Y)

The resulting gas would be computed as such:
```
    total_gas = 3 x 100_000 + 3 x 3000  // cancel 3x spot
                + 2 x 120_000 + 2 x 3000 // create 2x derv
                + 140_000 // create 1x post-only bo
                + 4 x 65_000 // cancel-all 4x spot orders
```

which ends up being `955_000` gas. 
