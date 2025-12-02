# MsgPrivilegedExecuteContract

`MsgPrivilegedExecuteContract` 定义了一个方法，用于从交易模块执行具有特权能力的 Cosmwasm 合约。

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

* Sender：描述此消息的创建者。
* Funds：定义用户用于资助执行的银行币（例如 100biya）。
* ContractAddress：定义要执行的合约地址。
* Data：定义执行合约时使用的调用数据，详细信息请见下文。

**合约接口**\
如果您希望在合约中启用特权操作，必须实现以下执行方法：

```rust
BiyachainExec {
    origin: String,
    name: String,
    args: MyArgs,
}
```

* origin 字段是发送特权操作的用户地址。您不需要自己设置此字段，它将由交易模块设置。
* name 字段是特权操作的名称。您可以根据需要定义这些名称。
* args 字段是特权操作的参数。您可以根据需要定义这些参数。

在 Golang 中，Data 字符串的完整定义是：

```go
type ExecutionData struct {
	Origin string      `json:"origin"`
	Name   string      `json:"name"`
	MyArgs   interface{} `json:"args"`
}
```

用户可以通过发送带有以下数据的 `MsgPrivilegedExecuteContract` 来调用特权操作：

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

这些特权操作必须设置在 Cosmwasm 响应数据字段内，例如：

```rust
let privileged_action = PrivilegedAction {
    synthetic_trade: None,
    position_transfer: position_transfer_action,
};
response = response.set_data(to_binary(&privileged_action)?);
```

**PositionTransfer**

头寸转移允许合约将衍生头寸从其自身子账户转移到用户的子账户。该头寸不得处于强平状态。仅接收方支付接单商交易手续费，该手续费从其余额中扣除。\
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

合成交易允许合约代表用户在衍生品市场执行合成交易。这不涉及订单簿，仅为纯粹的合成交易。接单商交易手续费仍然适用。子账户 ID 必须设置为合约的子账户 ID 和用户的子账户 ID。

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
