# 消息

在本节中，我们描述了交易所消息的处理过程以及相应的状态更新。每个消息所创建/修改的状态对象都在[状态转换](zhuang-tai-zhuan-huan.md)部分进行了定义。

## Msg/Deposit

MsgDeposit 定义了一个 SDK 消息，用于将代币从发送者的银行余额转入子账户的交易所存款。

```go
type MsgDeposit struct {
	Sender        string
	// (Optional) bytes32 subaccount ID to deposit funds into. If empty, the coin will be deposited to the sender's default
	// subaccount address.
	SubaccountId string
	Amount       types.Coin
}
```

字段描述

* Sender 字段描述了进行存款的地址。
* SubaccountId 描述了接收存款的子账户 ID。
* Amount 指定了存款的金额。

## Msg/Withdraw

`MsgWithdraw` 定义了一个 SDK 消息，用于从子账户的存款中提取币到用户的银行余额。

```go
type MsgWithdraw struct {
	Sender       string
	// bytes32 subaccount ID to withdraw funds from
	SubaccountId string
	Amount       types.Coin
}
```

字段描述：

* **Sender**：描述发起提取操作的地址。
* **SubaccountId**：描述接收提取的子账户ID。
* **Amount**：指定提取的金额。

## Msg/InstantSpotMarketLaunch

`MsgInstantSpotMarketLaunch` 定义了一个 SDK 消息，用于通过支付上市费用在没有治理的情况下创建一个新的现货市场。费用将发送到社区支出池。

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

字段描述

* Sender 字段描述了此消息的创建者。
* Ticker 描述了现货市场的交易代码。
* BaseDenom 指定了用作基础货币的币种类型。
* QuoteDenom 指定了用作报价货币的币种类型。
* MinPriceTickSize 定义了订单价格的最小价格跳动。
* MinQuantityTickSize 定义了订单数量的最小数量跳动。

## Msg/InstantPerpetualMarketLaunch

`MsgInstantPerpetualMarketLaunch` 定义了一个 SDK 消息，用于通过支付上市费用来创建一个新的永久期货市场，无需治理。费用将发送到社区支出池。

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

字段描述

* **Sender** 字段描述了此消息的创建者。
* **Ticker** 字段描述了衍生品市场的交易代码。
* **QuoteDenom** 字段描述了用于基础货币的币种类型。
* **OracleBase** 字段描述了预言机的基础货币。
* **OracleQuote** 字段描述了预言机的报价货币。
* **OracleScaleFactor** 字段描述了预言机价格的缩放因子。
* **OracleType** 字段描述了预言机的类型。
* **MakerFeeRate** 字段描述了衍生品市场上做市商的交易费率。
* **TakerFeeRate** 字段描述了衍生品市场上吃单者的交易费率。
* **InitialMarginRatio** 字段描述了衍生品市场的初始保证金比例。
* **MaintenanceMarginRatio** 字段描述了衍生品市场的维持保证金比例。
* **MinPriceTickSize** 字段描述了订单价格和保证金的最小刻度。
* **MinQuantityTickSize** 字段描述了订单数量的最小刻度。

## Msg/InstantExpiryFuturesMarketLaunch

`MsgInstantExpiryFuturesMarketLaunch` 定义了一个 SDK 消息，用于通过支付上市费用创建一个新的到期期货市场，无需治理。费用将发送到社区支出池。

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

字段描述

* Sender：描述此消息的创建者。
* Ticker：描述衍生品市场的标记符。
* QuoteDenom：描述用作报价货币的币种类型。
* OracleBase：描述预言机基础货币。
* OracleQuote：描述预言机报价货币。
* OracleScaleFactor：描述预言机价格的缩放因子。
* OracleType：描述预言机类型。
* Expiry：描述市场的到期时间。
* MakerFeeRate：描述衍生品市场上做市商的交易费用率。
* TakerFeeRate：描述衍生品市场上交易者的交易费用率。
* InitialMarginRatio：描述衍生品市场的初始保证金比率。
* MaintenanceMarginRatio：描述衍生品市场的维持保证金比率。
* MinPriceTickSize：描述订单价格和保证金的最小刻度大小。

## Msg/CreateSpotLimitOrder

`MsgCreateSpotLimitOrder` 定义了一个 SDK 消息，用于创建一个新的现货限价订单。

```go
type MsgCreateSpotLimitOrder struct {
	Sender string
	Order  SpotOrder
}
```

字段描述

* Sender 字段描述了此消息的创建者。
* Order 字段描述了订单信息。

## Msg/BatchCreateSpotLimitOrders

MsgBatchCreateSpotLimitOrders 定义了一个 SDK 消息，用于创建一批新的现货限价订单。

```go
type MsgBatchCreateSpotLimitOrders struct {
	Sender string
	Orders []SpotOrder
}
```

字段描述

* Sender 字段描述了此消息的创建者。
* Order 字段描述了订单信息。

## Msg/CreateSpotMarketOrder

`MsgCreateSpotMarketOrder` 定义了一个 SDK 消息，用于创建一个新的现货市场订单。

```go
type MsgCreateSpotMarketOrder struct {
	Sender string
	Order  SpotOrder
}
```

字段描述

* Sender 字段描述了此消息的创建者。
* Order 字段描述了订单信息。

## Msg/CancelSpotOrder

`MsgCancelSpotOrder` 定义了一个消息，用于取消一个现货订单。

```go
type MsgCancelSpotOrder struct {
	Sender       string
	MarketId     string
	SubaccountId string
	OrderHash    string
    Cid          string
}
```

字段描述

* Sender 字段描述了此消息的创建者。
* MarketId 字段描述了订单所在市场的 ID。
* SubaccountId 字段描述了下单的子账户 ID。
* OrderHash 字段描述了订单的哈希值。

## Msg/BatchCancelSpotOrders

`MsgBatchCancelSpotOrders` 定义了批量取消现货订单的消息。

```go
type MsgBatchCancelSpotOrders struct {
	Sender string
	Data   []OrderData
}
```

字段描述

* Sender 字段描述了该消息的创建者。
* Data 字段描述了要取消的订单。

## Msg/CreateDerivativeLimitOrder

`MsgCreateDerivativeLimitOrder` 定义了创建衍生品限价订单的消息。

```go
type MsgCreateDerivativeLimitOrder struct {
	Sender string
	Order  DerivativeOrder
}
```

字段描述

* Sender 字段描述了消息的创建者。
* Order 字段描述了订单的详细信息。

## Batch creation of derivative limit orders

`MsgBatchCreateDerivativeLimitOrders` 描述了批量创建衍生品限价订单的消息。

```go
type MsgBatchCreateDerivativeLimitOrders struct {
	Sender string
	Orders []DerivativeOrder
}
```

字段描述

* Sender 字段描述了消息的创建者。
* Order 字段描述了订单的详细信息。

## Msg/CreateDerivativeMarketOrder

`MsgCreateDerivativeMarketOrder` 是用于创建衍生品市场订单的消息。

```go
// A Cosmos-SDK MsgCreateDerivativeMarketOrder
type MsgCreateDerivativeMarketOrder struct {
	Sender string
	Order  DerivativeOrder
}
```

字段描述

* Sender 字段描述了消息的创建者。
* Order 字段描述了订单的详细信息。

## Msg/CancelDerivativeOrder

`MsgCancelDerivativeOrder` 是用于取消衍生品订单的消息。

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

字段描述

* Sender 字段描述此消息的创建者。
* MarketId 字段描述订单所在市场的 ID。
* SubaccountId 字段描述下单的子账户 ID。
* OrderHash 字段描述订单的哈希值。

## Msg/BatchCancelDerivativeOrders

`MsgBatchCancelDerivativeOrders` 是一个批量取消衍生品订单的消息。

```go
type MsgBatchCancelDerivativeOrders struct {
	Sender string
	Data   []OrderData
}
```

字段描述

* Sender 字段描述此消息的创建者。
* Data 字段描述要取消的订单。

## Msg/SubaccountTransfer

`MsgSubaccountTransfer` 是一条用于在子账户之间转移余额的消息。

```go
type MsgSubaccountTransfer struct {
	Sender                  string
	SourceSubaccountId      string
	DestinationSubaccountId string
	Amount                  types.Coin
}
```

字段描述

* Sender 字段描述消息的创建者。
* SourceSubaccountId 字段描述发送币的源子账户。
* DestinationSubaccountId 字段描述接收币的目标子账户。
* Amount 字段描述要发送的币的数量。

## Msg/ExternalTransfer

`MsgExternalTransfer` 是一条将余额从源账户转移到外部子账户的消息。

```go
type MsgExternalTransfer struct {
	Sender                  string
	SourceSubaccountId      string
	DestinationSubaccountId string
	Amount                  types.Coin
}
```

字段描述

* Sender 字段描述消息的创建者。
* SourceSubaccountId 字段描述发送币的源子账户。
* DestinationSubaccountId 字段描述接收币的目标子账户。
* Amount 字段描述要发送的币的数量。

## Msg/LiquidatePosition

`MsgLiquidatePosition` 描述了一条清算账户持仓的消息。

```go
type MsgLiquidatePosition struct {
	Sender       string
	SubaccountId string
	MarketId     string
	// optional order to provide for liquidation
	Order        *DerivativeOrder
}
```

字段描述

* Sender 字段描述消息的创建者。
* SubaccountId 字段描述接收清算金额的子账户。
* MarketId 字段描述持仓所在的市场。
* Order 字段描述订单信息。

## Msg/IncreasePositionMargin

`MsgIncreasePositionMargin` 描述了一条增加账户保证金的消息。

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

字段描述

* Sender 字段描述消息的创建者。
* SourceSubaccountId 字段描述发送余额的源子账户。
* DestinationSubaccountId 字段描述接收余额的目标子账户。
* MarketId 字段描述持仓所在的市场。
* Amount 字段描述增加的金额。

## Msg/BatchUpdateOrders

`MsgBatchUpdateOrders` 允许原子级别地取消和创建现货及衍生品限价订单，并引入了一种新的订单取消模式。执行时，首先进行订单取消（如果有），然后进行订单创建（如果有）。

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

字段描述

* Sender 字段描述消息的创建者。
* SubaccountId 字段描述发送者的子账户 ID。
* SpotMarketIdsToCancelAll 字段描述发送者希望取消所有未结订单的现货市场 ID 列表。
* DerivativeMarketIdsToCancelAll 字段描述发送者希望取消所有未结订单的衍生品市场 ID 列表。
* SpotOrdersToCancel 字段描述发送者希望取消的具体现货订单。
* DerivativeOrdersToCancel 字段描述发送者希望取消的具体衍生品订单。
* SpotOrdersToCreate 字段描述发送者希望创建的现货订单。
* DerivativeOrdersToCreate 字段描述发送者希望创建的衍生品订单。
