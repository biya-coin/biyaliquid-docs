# 提案

## Proposal/SpotMarketParamUpdate

`SpotMarketParamUpdateProposal` 定义了一条提议更新现货市场参数的 SDK 消息。

```go
type SpotMarketParamUpdateProposal struct {
	Title                string
	Description          string
	MarketId             string
	MakerFeeRate         *math.LegacyDec
	TakerFeeRate         *math.LegacyDec
	RelayerFeeShareRate  *math.LegacyDec
	MinPriceTickSize     *math.LegacyDec
	MinQuantityTickSize  *math.LegacyDec
    MinNotional          *math.LegacyDec
	Status               MarketStatus
}
```

字段描述

* `Title` 字段描述提案的标题。
* `Description` 字段描述提案的描述。
* `MarketId` 字段描述要更改参数的市场 ID。
* `MakerFeeRate` 字段描述做市商的目标费用率。
* `TakerFeeRate` 字段描述吃单者的目标费用率。
* `RelayerFeeShareRate` 字段描述中继商费用分成率。
* `MinPriceTickSize` 字段定义订单价格的最小刻度。
* `MinQuantityTickSize` 字段定义订单数量的最小刻度。
* `MinNotional` 定义订单的最小名义价值。
* `Status` 字段描述市场的目标状态。

## Proposal/ExchangeEnable

`ExchangeEnableProposal` 定义了一条提议启用特定交易类型的消息。

```go
type ExchangeEnableProposal struct {
	Title        string
	Description  string
	ExchangeType ExchangeType
}
```

字段描述

* `Title` 字段描述提案的标题。
* `Description` 字段描述提案的描述。
* `ExchangeType` 字段描述交易类型，现货或衍生品。

## Proposal/BatchExchangeModification

`BatchExchangeModificationProposal` 定义了一条在交易模块中批量处理多个提案的消息。

```go
type BatchExchangeModificationProposal struct {
	Title                                string
	Description                          string
	SpotMarketParamUpdateProposal        []*SpotMarketParamUpdateProposal
	DerivativeMarketParamUpdateProposal  []*DerivativeMarketParamUpdateProposal
	SpotMarketLaunchProposal             []*SpotMarketLaunchProposal
	PerpetualMarketLaunchProposal        []*PerpetualMarketLaunchProposal
	ExpiryFuturesMarketLaunchProposal    []*ExpiryFuturesMarketLaunchProposal
	TradingRewardCampaignUpdateProposal  *TradingRewardCampaignUpdateProposal
}
```

字段描述

* `Title` 字段描述提案的标题。
* `Description` 字段描述提案的描述。
* `SpotMarketParamUpdateProposal` 字段描述 SpotMarketParamUpdateProposal。
* `DerivativeMarketParamUpdateProposal` 字段描述 DerivativeMarketParamUpdateProposal。
* `SpotMarketLaunchProposal` 字段描述 SpotMarketLaunchProposal。
* `PerpetualMarketLaunchProposal` 字段描述 PerpetualMarketLaunchProposal。
* `ExpiryFuturesMarketLaunchProposal` 字段描述 ExpiryFuturesMarketLaunchProposal。
* `TradingRewardCampaignUpdateProposal` 字段描述 TradingRewardCampaignUpdateProposal。

## Proposal/SpotMarketLaunch

`SpotMarketLaunchProposal` 定义了一条通过治理提议新现货市场的 SDK 消息。

```go
type SpotMarketLaunchProposal struct {
	Title                string
	Description          string
	Ticker               string
	BaseDenom            string
	QuoteDenom           string
	MinPriceTickSize     math.LegacyDec
	MinQuantityTickSize  math.LegacyDec
    MinNotional          math.LegacyDec
	MakerFeeRate         math.LegacyDec
	TakerFeeRate         math.LegacyDec
}
```

字段描述

* `Title` 字段描述提案的标题。
* `Description`字段描述提案的描述。
* `Ticker` 字段描述现货市场的交易对符号。
* `BaseDenom` 字段指定用作基础货币的币种类型。
* `QuoteDenom` 字段指定用作报价货币的币种类型。
* `MinPriceTickSize` 字段定义订单价格的最小刻度。
* `MinQuantityTickSize` 字段定义订单数量的最小刻度。
* `MakerFeeRate` 字段描述衍生品市场上做市商的交易费用率。
* `TakerFeeRate` 字段描述衍生品市场上吃单者的交易费用率。

## Proposal/PerpetualMarketLaunch

`PerpetualMarketLaunchProposal` 定义了一条通过治理提议新永久期货市场的 SDK 消息。

```go
type PerpetualMarketLaunchProposal struct {
	Title                   string
	Description             string
	Ticker                  string
	QuoteDenom              string
	OracleBase              string
	OracleQuote             string
	OracleScaleFactor       uint32
	OracleType              types1.OracleType
	InitialMarginRatio      math.LegacyDec
	MaintenanceMarginRatio  math.LegacyDec
	MakerFeeRate            math.LegacyDec
	TakerFeeRate            math.LegacyDec
	MinPriceTickSize        math.LegacyDec
	MinQuantityTickSize     math.LegacyDec
}
```

字段描述

* `Title` 字段描述提案的标题。
* `Description` 字段描述提案的描述。
* `Ticker` 字段描述衍生品市场的交易对符号。
* `QuoteDenom` 字段描述用作基础货币的币种类型。
* `OracleBase` 字段描述预言机的基础货币。
* `OracleQuote` 字段描述预言机的报价货币。
* `OracleScaleFactor` 字段描述预言机价格的缩放因子。
* `OracleType` 字段描述预言机的类型。
* `MakerFeeRate` 字段描述衍生品市场上做市商的交易费用率。
* `TakerFeeRate` 字段描述衍生品市场上吃单者的交易费用率。
* `InitialMarginRatio` 字段描述衍生品市场的初始保证金比例。
* `MaintenanceMarginRatio` 字段描述衍生品市场的维持保证金比例。
* `MinPriceTickSize` 字段描述订单价格和保证金的最小刻度。
* `MinQuantityTickSize` 字段描述订单数量的最小刻度。

## Expiry futures market launch proposal

```go
// ExpiryFuturesMarketLaunchProposal defines an SDK message for proposing a new expiry futures market through governance
type ExpiryFuturesMarketLaunchProposal struct {
	Title                      string
	Description                string
	// Ticker for the derivative market.
	Ticker                     string
	// type of coin to use as the quote currency
	QuoteDenom                 string
	// Oracle base currency
	OracleBase                 string
	// Oracle quote currency
	OracleQuote                string
	// Scale factor for oracle prices.
	OracleScaleFactor          uint32
	// Oracle type
	OracleType                 types1.OracleType
	// Expiration time of the market
	Expiry                     int64
	// initial_margin_ratio defines the initial margin ratio for the derivative market
	InitialMarginRatio         math.LegacyDec
	// maintenance_margin_ratio defines the maintenance margin ratio for the derivative market
	MaintenanceMarginRatio     math.LegacyDec
	// maker_fee_rate defines the exchange trade fee for makers for the derivative market
	MakerFeeRate               math.LegacyDec
	// taker_fee_rate defines the exchange trade fee for takers for the derivative market
	TakerFeeRate               math.LegacyDec
	// min_price_tick_size defines the minimum tick size of the order's price and margin
	MinPriceTickSize           math.LegacyDec
	// min_quantity_tick_size defines the minimum tick size of the order's quantity
	MinQuantityTickSize        math.LegacyDec
    // min_notional defines the minimum notional (in quote asset) required for orders in the market
    MinNotional                math.LegacyDec
}
```

字段描述

* `Title` 字段描述提案的标题。
* `Description` 字段描述提案的描述。
* `Ticker` 字段描述衍生品市场的交易对符号。
* `QuoteDenom` 字段描述用作报价货币的币种类型。
* `OracleBase` 字段描述预言机的基础货币。
* `OracleQuote` 字段描述预言机的报价货币。
* `OracleScaleFactor` 字段描述预言机价格的缩放因子。
* `OracleType` 字段描述预言机的类型。
* `Expiry` 字段描述市场的到期时间。
* `MakerFeeRate` 字段描述衍生品市场上做市商的交易费用率。
* `TakerFeeRate`字段描述衍生品市场上吃单者的交易费用率。
* `InitialMarginRatio` 字段描述衍生品市场的初始保证金比例。
* `MaintenanceMarginRatio` 字段描述衍生品市场的维持保证金比例。
* `MinPriceTickSize` 字段描述订单价格和保证金的最小刻度。
* `MinQuantityTickSize` 字段描述订单数量的最小刻度。

## Binary options market launch proposal

```go
type BinaryOptionsMarketLaunchProposal struct {
	Title       string
	Description string
	// Ticker for the derivative contract.
	Ticker string
	// Oracle symbol
	OracleSymbol string
	// Oracle Provider
	OracleProvider string
	// Oracle type
	OracleType types1.OracleType
	// Scale factor for oracle prices.
	OracleScaleFactor uint32
	// expiration timestamp
	ExpirationTimestamp int64
	// expiration timestamp
	SettlementTimestamp int64
	// admin of the market
	Admin string
	// Address of the quote currency denomination for the binary options contract
	QuoteDenom string
	// maker_fee_rate defines the maker fee rate of a binary options market
	MakerFeeRate math.LegacyDec
	// taker_fee_rate defines the taker fee rate of a derivative market
	TakerFeeRate math.LegacyDec
	// min_price_tick_size defines the minimum tick size that the price and margin required for orders in the market
	MinPriceTickSize math.LegacyDec
	// min_quantity_tick_size defines the minimum tick size of the quantity required for orders in the market
	MinQuantityTickSize math.LegacyDec
}
```

## Binary options market param update

```go
type BinaryOptionsMarketParamUpdateProposal struct {
	Title       string
	Description string
	MarketId    string
	// maker_fee_rate defines the exchange trade fee for makers for the derivative market
	MakerFeeRate *math.LegacyDec
	// taker_fee_rate defines the exchange trade fee for takers for the derivative market
	TakerFeeRate *math.LegacyDec
	// relayer_fee_share_rate defines the relayer fee share rate for the derivative market
	RelayerFeeShareRate *math.LegacyDec
	// min_price_tick_size defines the minimum tick size of the order's price and margin
	MinPriceTickSize *math.LegacyDec
	// min_quantity_tick_size defines the minimum tick size of the order's quantity
	MinQuantityTickSize *math.LegacyDec
    // min_notional defines the minimum notional for orders
    MinNotional *math.LegacyDec
	// expiration timestamp
	ExpirationTimestamp int64
	// expiration timestamp
	SettlementTimestamp int64
	// new price at which market will be settled
	SettlementPrice *math.LegacyDec
	// admin of the market
	Admin        string
	Status       MarketStatus
	OracleParams *ProviderOracleParams
}
```

## Proposal/DerivativeMarketParamUpdate

```go
type OracleParams struct {
    // Oracle base currency
    OracleBase        string
    // Oracle quote currency
    OracleQuote       string
    // Scale factor for oracle prices.
    OracleScaleFactor uint32
    // Oracle type
    OracleType        types1.OracleType
}

type DerivativeMarketParamUpdateProposal struct {
	Title                  string
	Description            string
	MarketId               string
	InitialMarginRatio     *math.LegacyDec
	MaintenanceMarginRatio *math.LegacyDec
	MakerFeeRate           *math.LegacyDec
	TakerFeeRate           *math.LegacyDec
	RelayerFeeShareRate    *math.LegacyDec
	MinPriceTickSize       *math.LegacyDec
	MinQuantityTickSize    *math.LegacyDec
    MinNotional            *math.LegacyDec
	HourlyInterestRate     *math.LegacyDec
	HourlyFundingRateCap   *math.LegacyDec
	Status                 MarketStatus
	OracleParams           *OracleParams
}
```

字段描述

* `Title` 字段描述提案的标题。
* `Description` 字段描述提案的描述。
* `MarketId` 字段描述要更改参数的市场 ID。
* `InitialMarginRatio` 字段描述目标初始保证金比例。
* `MaintenanceMarginRatio` 字段描述目标维持保证金比例。
* `MakerFeeRate` 字段描述目标做市商费用率。
* `TakerFeeRate` 字段描述目标吃单者费用率。
* `RelayerFeeShareRate` 字段描述中继商费用分成率。
* `MinPriceTickSize`字段定义订单价格的最小刻度。
* `MinQuantityTickSize` 字段定义订单数量的最小刻度。
* `Status` 字段描述市场的目标状态。
* `OracleParams` 字段描述新的预言机参数。

## Proposal/TradingRewardCampaignLaunch

`TradingRewardCampaignLaunchProposal` 定义了一条提议启动新交易奖励活动的 SDK 消息。

```go
type TradingRewardCampaignLaunchProposal struct {
	Title               string
	Description         string
	CampaignInfo        *TradingRewardCampaignInfo
	CampaignRewardPools []*CampaignRewardPool
}
```

字段描述

* `Title` 字段描述提案的标题。
* `Description` 字段描述提案的描述。
* `CampaignInfo` 字段描述活动信息。
* `CampaignRewardPools` 字段描述奖励池信息。

## Proposal/TradingRewardCampaignUpdate

`TradingRewardCampaignUpdateProposal` 定义了一条提议更新现有交易奖励活动的 SDK 消息。

```go
type TradingRewardCampaignUpdateProposal struct {
	Title                        string
	Description                  string
	CampaignInfo                 *TradingRewardCampaignInfo
	CampaignRewardPoolsAdditions []*CampaignRewardPool
	CampaignRewardPoolsUpdates   []*CampaignRewardPool
}
```

字段描述

* `Title` 字段描述提案的标题。
* `Description` 字段描述提案的描述。
* `CampaignRewardPoolsAdditions` 字段描述奖励池新增信息。
* `CampaignRewardPoolsUpdates` 字段描述奖励池更新信息。

## Proposal/FeeDiscount

`FeeDiscountProposal` 定义了一条提议启动或更新费用折扣计划的 SDK 消息。

```go
type FeeDiscountProposal struct {
	Title          string
	Description    string
	Schedule       *FeeDiscountSchedule
}
```

字段描述

* `Title` 字段描述提案的标题。
* `Description` 字段描述提案的描述。
* `Schedule` 字段描述费用折扣计划。

## Proposal/TradingRewardPendingPointsUpdate

`TradingRewardPendingPointsUpdateProposal` 定义了一条在归属期间更新特定地址奖励积分的 SDK 消息。

```go
type TradingRewardPendingPointsUpdateProposal struct {
	Title                  string
	Description            string
	PendingPoolTimestamp   int64
	RewardPointUpdates     *[]RewardPointUpdate
}
```

字段描述

* `Title` 字段描述提案的标题。
* `Description` 字段描述提案的描述。
* `PendingPoolTimestamp` 字段描述待处理池的时间戳。
* `RewardPointUpdates` 描述 RewardPointUpdate.
