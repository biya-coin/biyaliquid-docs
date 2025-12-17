---
sidebar_position: 6
title: Messages
---

# 消息

在本节中，我们描述交易所消息的处理以及相应的状态更新。每个消息指定的所有创建/修改的状态对象都在[状态转换](04_state_transitions.md)部分中定义。

## Msg/Deposit

`MsgDeposit` 定义了一个 SDK 消息，用于将代币从发送者的银行余额转移到子账户的交易所存款。

```go
type MsgDeposit struct {
	Sender        string
	// (Optional) bytes32 subaccount ID to deposit funds into. If empty, the coin will be deposited to the sender's default
	// subaccount address.
	SubaccountId string
	Amount       types.Coin
}
```

**字段描述**

* `Sender` 字段描述存款人的地址。
* `SubaccountId` 描述接收存款的子账户 ID。
* `Amount` 指定存款金额。

## Msg/Withdraw

`MsgWithdraw` 定义了一个 SDK 消息，用于从子账户的存款中提取代币到用户的银行余额。

```go
type MsgWithdraw struct {
	Sender       string
	// bytes32 subaccount ID to withdraw funds from
	SubaccountId string
	Amount       types.Coin
}
```

**字段描述**

* `Sender` 字段描述接收提取的地址。
* `SubaccountId` 描述要从中提取的子账户 ID。
* `Amount` 指定提取金额。

## Msg/InstantSpotMarketLaunch

`MsgInstantSpotMarketLaunch` 定义了一个 SDK 消息，用于通过支付上币费创建新的现货市场，无需治理。费用发送到社区支出池。

```go
type MsgInstantSpotMarketLaunch struct {
	Sender              string
	Ticker              string
	BaseDenom           string
	QuoteDenom          string
	MinPriceTickSize    math.LegacyDec
	MinQuantityTickSize math.LegacyDec
    MinNotional         math.LegacyDec
}
```

**字段描述**

* `Sender` 字段描述此消息的创建者。
* `Ticker` 描述现货市场的交易代码。
* `BaseDenom` 指定用作基础货币的代币类型。
* `QuoteDenom` 指定用作报价货币的代币类型。
* `MinPriceTickSize` 定义订单价格的最小变动单位。
* `MinQuantityTickSize` 定义订单数量的最小变动单位。

## Msg/InstantPerpetualMarketLaunch

`MsgInstantPerpetualMarketLaunch` 定义了一个 SDK 消息，用于通过支付上币费创建新的永续期货市场，无需治理。费用发送到社区支出池。

```go
type MsgInstantPerpetualMarketLaunch struct {
	Sender                  string
	Ticker                  string
	QuoteDenom              string
	OracleBase              string
	OracleQuote             string
	OracleScaleFactor       uint32
	OracleType              types1.OracleType
	MakerFeeRate            math.LegacyDec
	TakerFeeRate            math.LegacyDec
	InitialMarginRatio      math.LegacyDec
	MaintenanceMarginRatio  math.LegacyDec
	MinPriceTickSize        math.LegacyDec
	MinQuantityTickSize     math.LegacyDec
    MinNotional             math.LegacyDec
}
```

**字段描述**

* `Sender` 字段描述此消息的创建者。
* `Ticker` 字段描述衍生品市场的交易代码。
* `QuoteDenom` 字段描述用作报价货币的代币类型。
* `OracleBase` 字段描述预言机基础货币。
* `OracleQuote` 字段描述预言机报价货币。
* `OracleScaleFactor` 字段描述预言机价格的缩放因子。
* `OracleType` 字段描述预言机类型。
* `MakerFeeRate` 字段描述衍生品市场上做市商的交易费率。
* `TakerFeeRate` 字段描述衍生品市场上吃单者的交易费率。
* `InitialMarginRatio` 字段描述衍生品市场的初始保证金比率。
* `MaintenanceMarginRatio` 字段描述衍生品市场的维持保证金比率。
* `MinPriceTickSize` 字段描述订单价格和保证金的最小变动单位。
* `MinQuantityTickSize` 字段描述订单数量的最小变动单位。

## Msg/InstantExpiryFuturesMarketLaunch

`MsgInstantExpiryFuturesMarketLaunch` 定义了一个 SDK 消息，用于通过支付上币费创建新的到期期货市场，无需治理。费用发送到社区支出池。

```go
type MsgInstantExpiryFuturesMarketLaunch struct {
	Sender                  string
	Ticker                  string
	QuoteDenom              string
	OracleBase              string
	OracleQuote             string
	OracleType              types1.OracleType
	OracleScaleFactor       uint32
	Expiry                  int64
	MakerFeeRate            math.LegacyDec
	TakerFeeRate            math.LegacyDec
	InitialMarginRatio      math.LegacyDec
	MaintenanceMarginRatio  math.LegacyDec
	MinPriceTickSize        math.LegacyDec
	MinQuantityTickSize     math.LegacyDec
    MinNotional             math.LegacyDec
}
```

**字段描述**

* `Sender` 字段描述此消息的创建者。
* `Ticker` 字段描述衍生品市场的交易代码。
* `QuoteDenom` 字段描述用作报价货币的代币类型。
* `OracleBase` 字段描述预言机基础货币。
* `OracleQuote` 字段描述预言机报价货币。
* `OracleScaleFactor` 字段描述预言机价格的缩放因子。
* `OracleType` 字段描述预言机类型。
* `Expiry` 字段描述市场的到期时间。
* `MakerFeeRate` 字段描述衍生品市场上做市商的交易费率。
* `TakerFeeRate` 字段描述衍生品市场上吃单者的交易费率。
* `InitialMarginRatio` 字段描述衍生品市场的初始保证金比率。
* `MaintenanceMarginRatio` 字段描述衍生品市场的维持保证金比率。
* `MinPriceTickSize` 字段描述订单价格和保证金的最小变动单位。
* `MinQuantityTickSize` 字段描述订单数量的最小变动单位。

## Msg/CreateSpotLimitOrder

`MsgCreateSpotLimitOrder` defines a SDK message for creating a new spot limit order.

```go
type MsgCreateSpotLimitOrder struct {
	Sender string
	Order  SpotOrder
}
```

**Fields description**

* `Sender` field describes the creator of this msg.
* `Order` field describes the order info.

## Msg/BatchCreateSpotLimitOrders

`MsgBatchCreateSpotLimitOrders` defines a SDK message for creating a new batch of spot limit orders.

```go
type MsgBatchCreateSpotLimitOrders struct {
	Sender string
	Orders []SpotOrder
}
```

**Fields description**

* `Sender` field describes the creator of this msg.
* `Orders` field describes the orders info.

## Msg/CreateSpotMarketOrder

`MsgCreateSpotMarketOrder` defines a SDK message for creating a new spot market order.

```go
type MsgCreateSpotMarketOrder struct {
	Sender string
	Order  SpotOrder
}
```

**Fields description**

* `Sender` field describes the creator of this msg.
* `Order` field describes the order info.

## Msg/CancelSpotOrder

`MsgCancelSpotOrder` defines the message to cancel a spot order.

```go
type MsgCancelSpotOrder struct {
	Sender       string
	MarketId     string
	SubaccountId string
	OrderHash    string
    Cid          string
}
```

**Fields description**

* `Sender` field describes the creator of this msg.
* `MarketId` field describes the id of the market where the order is placed.
* `SubaccountId` field describes the subaccount id that placed the order.
* `OrderHash` field describes the hash of the order.

## Msg/BatchCancelSpotOrders

`MsgBatchCancelSpotOrders` defines the message to cancel the spot orders in batch.

```go
type MsgBatchCancelSpotOrders struct {
	Sender string
	Data   []OrderData
}
```

**Fields description**

* `Sender` field describes the creator of this msg.
* `Data` field describes the orders to cancel.

## Msg/CreateDerivativeLimitOrder

`MsgCreateDerivativeLimitOrder` 定义了创建衍生品限价单的消息。

```go
type MsgCreateDerivativeLimitOrder struct {
	Sender string
	Order  DerivativeOrder
}
```

**字段描述**

* `Sender` 字段描述此消息的创建者。
* `Order` 字段描述订单信息。

## 批量创建衍生品限价单

`MsgBatchCreateDerivativeLimitOrders` 描述批量创建衍生品限价单。

```go
type MsgBatchCreateDerivativeLimitOrders struct {
	Sender string
	Orders []DerivativeOrder
}
```

**字段描述**

* `Sender` 字段描述此消息的创建者。
* `Orders` 字段描述订单信息。

## Msg/CreateDerivativeMarketOrder

`MsgCreateDerivativeMarketOrder` 是创建衍生品市价单的消息。

```go
// A Cosmos-SDK MsgCreateDerivativeMarketOrder
type MsgCreateDerivativeMarketOrder struct {
	Sender string
	Order  DerivativeOrder
}
```

**字段描述**

* `Sender` 字段描述此消息的创建者。
* `Order` 字段描述订单信息。

## Msg/CancelDerivativeOrder

`MsgCancelDerivativeOrder` is a message to cancel a derivative order.

```go
type MsgCancelDerivativeOrder struct {
	Sender       string
	MarketId     string
	SubaccountId string
	OrderHash    string
    OrderMask    int32
    Cid          string
}
```

**Fields description**

* `Sender` field describes the creator of this msg.
* `MarketId` field describes the id of the market where the order is placed.
* `SubaccountId` field describes the subaccount id that placed the order.
* `OrderHash` field describes the hash of the order.

## Msg/BatchCancelDerivativeOrders

`MsgBatchCancelDerivativeOrders` is a message to cancel derivative orders in batch.

```go
type MsgBatchCancelDerivativeOrders struct {
	Sender string
	Data   []OrderData
}
```

**Fields description**

* `Sender` field describes the creator of this msg.
* `Data` field describes the orders to cancel.

## Msg/SubaccountTransfer

`MsgSubaccountTransfer` is a message to transfer balance between sub-accounts.

```go
type MsgSubaccountTransfer struct {
	Sender                  string
	SourceSubaccountId      string
	DestinationSubaccountId string
	Amount                  types.Coin
}
```

**Fields description**

* `Sender` field describes the creator of this msg.
* `SourceSubaccountId` field describes a source subaccount to send coins from.
* `DestinationSubaccountId` field describes a destination subaccount to send coins to.
* `Amount` field describes the amount of coin to send.

## Msg/ExternalTransfer

`MsgExternalTransfer` is a message to transfer balance from one of source account to external sub-account.

```go
type MsgExternalTransfer struct {
	Sender                  string
	SourceSubaccountId      string
	DestinationSubaccountId string
	Amount                  types.Coin
}
```

**Fields description**

* `Sender` field describes the creator of this msg.
* `SourceSubaccountId` field describes a source subaccount to send coins from.
* `DestinationSubaccountId` field describes a destination subaccount to send coins to.
* `Amount` field describes the amount of coin to send.

## Msg/LiquidatePosition

`MsgLiquidatePosition` describes a message to liquidate an account's position

```go
type MsgLiquidatePosition struct {
	Sender       string
	SubaccountId string
	MarketId     string
	// optional order to provide for liquidation
	Order        *DerivativeOrder
}
```

**Fields description**

* `Sender` field describes the creator of this msg.
* `SubaccountId` field describes a subaccount to receive liquidation amount.
* `MarketId` field describes a market where the position is in.
* `Order` field describes the order info.

## Msg/IncreasePositionMargin

`MsgIncreasePositionMargin` describes a message to increase margin of an account.

```go
// A Cosmos-SDK MsgIncreasePositionMargin
type MsgIncreasePositionMargin struct {
	Sender                  string
	SourceSubaccountId      string
	DestinationSubaccountId string
	MarketId                string
	// amount defines the amount of margin to add to the position
	Amount                  math.LegacyDec
}
```

**Fields description**

* `Sender` field describes the creator of this msg.
* `SourceSubaccountId` field describes a source subaccount to send balance from.
* `DestinationSubaccountId` field describes a destination subaccount to receive balance.
* `MarketId` field describes a market where positions are in.
* `Amount` field describes amount to increase.

## Msg/BatchUpdateOrders

`MsgBatchUpdateOrders` 允许原子性地取消和创建现货和衍生品限价单，以及新的订单取消模式。执行时，订单取消（如果有）首先发生，然后是订单创建（如果有）。

```go
// A Cosmos-SDK MsgBatchUpdateOrders
// SubaccountId only used for the spot_market_ids_to_cancel_all and derivative_market_ids_to_cancel_all.
type MsgBatchUpdateOrders struct {
	Sender                          string
	SubaccountId                    string
	SpotMarketIdsToCancelAll        []string
	DerivativeMarketIdsToCancelAll  []string
	SpotOrdersToCancel              []OrderData
	DerivativeOrdersToCancel        []OrderData
	SpotOrdersToCreate              []SpotOrder
	DerivativeOrdersToCreate        []DerivativeOrder
}
```

**字段描述**

* `Sender` 字段描述此消息的创建者。
* `SubaccountId` 字段描述发送者的子账户 ID。
* `SpotMarketIdsToCancelAll` 字段描述发送者想要取消所有开放订单的现货市场 ID 列表。
* `DerivativeMarketIdsToCancelAll` 字段描述发送者想要取消所有开放订单的衍生品市场 ID 列表。
* `SpotOrdersToCancel` 字段描述发送者想要取消的特定现货订单。
* `DerivativeOrdersToCancel` 字段描述发送者想要取消的特定衍生品订单。
* `SpotOrdersToCreate` 字段描述发送者想要创建的现货订单。
* `DerivativeOrdersToCreate` 字段描述发送者想要创建的衍生品订单。

## Msg/AuthorizeStakeGrants

`MsgAuthorizeStakeGrants` 是用于向另一个地址授予质押的 BIYA 余额以用于费用折扣目的的消息。如果授权金额设置为 0，也可以用于撤销/删除授权。

```go
type MsgAuthorizeStakeGrants struct {
	Sender  string 
	Grants  []*GrantAuthorization 
}
```

**字段描述**

* `Sender` 描述此消息的创建者。
* `Grants` 描述被授权人地址和授权金额列表。

## Msg/ActivateStakeGrant

`MsgActivateStakeGrant` is a message used to select/activate a stake grant for fee discount purposes.

```go
type MsgActivateStakeGrant struct {
	Sender  string 
	Granter string 
}
```

**Fields description**

* `Sender` describes the creator of this msg.
* `Granter` describes the address of the granter.
