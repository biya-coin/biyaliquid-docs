---
sidebar_position: 12
title: MsgPrivilegedExecuteContract
---

# MsgPrivilegedExecuteContract

MsgPrivilegedExecuteContract 定义了一种从交易所模块执行 Cosmwasm 合约的方法，具有特权功能。

```go
type MsgPrivilegedExecuteContract struct {
	Sender string
	// funds defines the user's bank coins used to fund the execution (e.g. 100biya).
	Funds github_com_cosmos_cosmos_sdk_types.Coins
	// contract_address defines the contract address to execute
	ContractAddress string
	// data defines the call data used when executing the contract
	Data string
}

```

**字段描述**

- `Sender` 描述此消息的创建者。
- `Funds` 定义用于资助执行的用户银行代币（例如 100biya）。
- `ContractAddress` 定义要执行的合约地址。
- `Data` 定义执行合约时使用的调用数据，详见下文。

**合约接口**

如果您想在合约上启用特权操作，必须实现以下执行方法：

```rust
BiyachainExec {
    origin: String,
    name: String,
    args: MyArgs,
}
```

- The `origin` field is the address of the user who sent the privileged action. You don't have to set this field yourself, it will be set by the exchange module.
- The `name` field is the name of the privileged action. You can define these to be whatever you want.
- The `args` field is the arguments of the privileged action. You can define these to be whatever you want.

Golang 中 Data 字符串的完整定义是：

```go
type ExecutionData struct {
	Origin string      `json:"origin"`
	Name   string      `json:"name"`
	MyArgs   interface{} `json:"args"`
}
```

然后，用户可以通过发送带有以下数据的 `MsgPrivilegedExecuteContract` 来调用特权操作：

```json
{
	sender: "biya...",
	funds: "1000000000000000000biya",
	contract_address: "biya...",
	data: {
		origin: "biya...",
		name: "my_privileged_action",
		args: {
			...
		}
	}
}
```

**支持的特权操作**

目前支持两种特权操作：

```go
type PrivilegedAction struct {
	SyntheticTrade   *SyntheticTradeAction `json:"synthetic_trade"`
	PositionTransfer *PositionTransfer     `json:"position_transfer"`
}
```

这些特权操作必须设置在 Cosmwasm 响应数据字段中，例如：

```rust
let privileged_action = PrivilegedAction {
    synthetic_trade: None,
    position_transfer: position_transfer_action,
};
response = response.set_data(to_binary(&privileged_action)?);
```

**PositionTransfer**

持仓转移允许合约将衍生品持仓从其自己的子账户转移到用户的子账户。持仓可能不可清算。只有接收方支付从其余额中扣除的吃单交易费用。

目前仅支持从合约的子账户转移到用户的子账户。

```go
type PositionTransfer struct {
    MarketID                common.Hash `json:"market_id"`
    SourceSubaccountID      common.Hash `json:"source_subaccount_id"`
    DestinationSubaccountID common.Hash `json:"destination_subaccount_id"`
    Quantity                math.LegacyDec     `json:"quantity"`
}
```

**SyntheticTrade**

合成交易允许合约代表用户为衍生品市场执行合成交易。这不触及订单簿，纯粹是合成交易。吃单交易费用仍然适用。子账户 ID 必须设置为合约的子账户 ID 和用户的子账户 ID。

```go
type SyntheticTradeAction struct {
	UserTrades     []*SyntheticTrade `json:"user_trades"`
	ContractTrades []*SyntheticTrade `json:"contract_trades"`
}

type SyntheticTrade struct {
	MarketID     common.Hash `json:"market_id"`
	SubaccountID common.Hash `json:"subaccount_id"`
	IsBuy        bool        `json:"is_buy"`
	Quantity     math.LegacyDec     `json:"quantity"`
	Price        math.LegacyDec     `json:"price"`
	Margin       math.LegacyDec     `json:"margin"`
}
```
