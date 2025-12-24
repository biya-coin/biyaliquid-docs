---
sidebar_position: 4
title: State
---

# 状态

Genesis 状态定义了模块的初始状态，用于设置模块。

```go
// GenesisState defines the exchange module's genesis state.
type GenesisState struct {
	// params defines all the parameters of related to exchange.
	Params Params
	// accounts is an array containing the genesis trade pairs
	SpotMarkets []*SpotMarket
	// accounts is an array containing the genesis derivative markets
	DerivativeMarkets []*DerivativeMarket
	// spot_orderbook defines the spot exchange limit orderbook active at genesis.
	SpotOrderbook []SpotOrderBook
	// derivative_orderbook defines the derivative exchange limit orderbook active at genesis.
	DerivativeOrderbook []DerivativeOrderBook
	// balances defines the exchange users balances active at genesis.
	Balances []Balance
	// positions defines the exchange derivative positions at genesis
	Positions []DerivativePosition
	// subaccount_trade_nonces defines the subaccount trade nonces for the subaccounts at genesis
	SubaccountTradeNonces []SubaccountNonce
	// expiry_futures_market_info defines the market info for the expiry futures markets at genesis
	ExpiryFuturesMarketInfoState []ExpiryFuturesMarketInfoState
	// perpetual_market_info defines the market info for the perpetual derivative markets at genesis
	PerpetualMarketInfo []PerpetualMarketInfo
	// perpetual_market_funding_state defines the funding state for the perpetual derivative markets at genesis
	PerpetualMarketFundingState []PerpetualMarketFundingState
	// derivative_market_settlement_scheduled defines the scheduled markets for settlement at genesis
	DerivativeMarketSettlementScheduled []DerivativeMarketSettlementInfo
	// sets spot markets as enabled
	IsSpotExchangeEnabled               bool
	// sets derivative markets as enabled
	IsDerivativesExchangeEnabled        bool
	// the current trading reward campaign info
	TradingRewardCampaignInfo           *TradingRewardCampaignInfo
	// the current and upcoming trading reward campaign pools
	TradingRewardPoolCampaignSchedule   []*CampaignRewardPool
	// the current and upcoming trading reward account points
	TradingRewardCampaignAccountPoints  []*TradingRewardCampaignAccountPoints
	// the current and upcoming trading reward campaign pending pools
	PendingTradingRewardPoolCampaignSchedule []*CampaignRewardPool
	// the pending trading reward account points
	PendingTradingRewardCampaignAccountPoints []*TradingRewardCampaignAccountPendingPoints
	// the fee discount schedule
	FeeDiscountSchedule                 *FeeDiscountSchedule
	// the cached fee discount account tiers with TTL
	FeeDiscountAccountTierTtl           []*FeeDiscountAccountTierTTL
	// the fee discount paid by accounts in all buckets
	FeeDiscountBucketFeesPaidAccounts   []*FeeDiscountBucketFeesPaidAccounts
	// sets the first fee cycle as finished
	IsFirstFeeCycleFinished             bool
}
```

## 参数

`Params` 是模块范围的配置，存储系统参数并定义 exchange 模块的整体功能。\
此配置可通过治理使用 `gov` 模块原生支持的参数更新提案进行修改。

它定义了用于现货和衍生品市场的默认费用对象，以及衍生品市场的资金费率参数和即时上币费用。

Protobuf interface for the `exchange` module params store.

```go
type Params struct {
	// spot_market_instant_listing_fee defines the expedited fee in BIYA required to create a spot market by bypassing governance
	SpotMarketInstantListingFee types.Coin
	// derivative_market_instant_listing_fee defines the expedited fee in BIYA required to create a derivative market by bypassing governance
	DerivativeMarketInstantListingFee types.Coin
	// default_spot_maker_fee defines the default exchange trade fee for makers on a spot market
	DefaultSpotMakerFeeRate math.LegacyDec
	// default_spot_taker_fee_rate defines the default exchange trade fee rate for takers on a new spot market
	DefaultSpotTakerFeeRate math.LegacyDec
	// default_derivative_maker_fee defines the default exchange trade fee for makers on a new derivative market
	DefaultDerivativeMakerFeeRate math.LegacyDec
	// default_derivative_taker_fee defines the default exchange trade fee for takers on a new derivative market
	DefaultDerivativeTakerFeeRate math.LegacyDec
	// default_initial_margin_ratio defines the default initial margin ratio on a new derivative market
	DefaultInitialMarginRatio math.LegacyDec
	// default_maintenance_margin_ratio defines the default maintenance margin ratio on a new derivative market
	DefaultMaintenanceMarginRatio math.LegacyDec
	// default_funding_interval defines the default funding interval on a derivative market
	DefaultFundingInterval int64
	// funding_multiple defines the timestamp multiple that the funding timestamp should be a multiple of
	FundingMultiple int64
	// relayer_fee_share_rate defines the trade fee share percentage that goes to relayers
	RelayerFeeShareRate math.LegacyDec
	// default_hourly_funding_rate_cap defines the default maximum absolute value of the hourly funding rate
	DefaultHourlyFundingRateCap math.LegacyDec
	// hourly_interest_rate defines the hourly interest rate
	DefaultHourlyInterestRate math.LegacyDec
	// max_derivative_order_side_count defines the maximum number of derivative active orders a subaccount can have for a given orderbook side
	MaxDerivativeOrderSideCount uint32
	// biya_reward_staked_requirement_threshold defines the threshold on BIYA rewards after which one also needs staked BIYA to receive more
	BiyaRewardStakedRequirementThreshold github_com_cosmos_cosmos_sdk_types.Int
	// the trading_rewards_vesting_duration defines the vesting times for trading rewards
	TradingRewardsVestingDuration int64
}
```

## 余额

`Balance` 用于管理账户余额。模块将整个余额存储在模块账户中，而每个账户的余额仅作为记录进行管理。

`Balance` 对象通过 `subaccount_id` 和 `denom` 存储。

```go
message Balance {
	SubaccountId string
	Denom        string
	Deposits     *Deposit
}

// An subaccount's deposit for a given base currency
type Deposit struct {
	AvailableBalance math.LegacyDec
	TotalBalance     math.LegacyDec
}

type SubaccountDeposit {
	SubaccountId []byte
	Deposit      *Deposit
}
```

## SubaccountNonce

`SubaccountNonce` 用于表示唯一的订单哈希。

```go
type SubaccountNonce struct {
	SubaccountId         string
	SubaccountTradeNonce SubaccountTradeNonce
}
```

## 订单

有多个结构用于将订单存储到存储中。

```go
type OrderInfo struct {
	// bytes32 subaccount ID that created the order
	SubaccountId string
	// address fee_recipient address that will receive fees for the order
	FeeRecipient string
	// price of the order
	Price math.LegacyDec
	// quantity of the order
	Quantity math.LegacyDec
}

type SubaccountOrderbookMetadata struct {
	VanillaLimitOrderCount    uint32
	ReduceOnlyLimitOrderCount uint32
	// AggregateReduceOnlyQuantity is the aggregate fillable quantity of the subaccount's reduce-only limit orders in the given direction.
	AggregateReduceOnlyQuantity math.LegacyDec
	// AggregateVanillaQuantity is the aggregate fillable quantity of the subaccount's vanilla limit orders in the given direction.
	AggregateVanillaQuantity math.LegacyDec
}

type SubaccountOrder struct {
	// price of the order
	Price math.LegacyDec
	// the amount of the quantity remaining fillable
	Quantity     math.LegacyDec
	IsReduceOnly bool
    Cid          string
}

type MarketOrderIndicator struct {
	// market_id represents the unique ID of the market
	MarketId string
	IsBuy    bool
}
```

## SpotMarket

`SpotMarket` 是存储现货市场所有必需信息和状态的结构。\
现货市场通过市场的哈希值存储，以便高效查询市场。

```go
// An object describing trade pair of two assets.
type SpotMarket struct {
	// A name of the pair in format AAA/BBB, where AAA is base asset, BBB is quote asset.
	Ticker string
	// Coin denom used for the base asset
	BaseDenom string
	// Coin used for the quote asset
	QuoteDenom string
	// maker_fee_rate defines the fee percentage makers pay when trading
	MakerFeeRate math.LegacyDec
	// taker_fee_rate defines the fee percentage takers pay when trading
	TakerFeeRate math.LegacyDec
	// relayer_fee_share_rate defines the percentage of the transaction fee shared with the relayer in a derivative market
	RelayerFeeShareRate math.LegacyDec
	// Unique market ID.
	MarketId string
	// Status of the market
	Status MarketStatus
	// min_price_tick_size defines the minimum tick size that the price required for orders in the market
	MinPriceTickSize math.LegacyDec
	// min_quantity_tick_size defines the minimum tick size of the quantity required for orders in the market
	MinQuantityTickSize math.LegacyDec
}
```

## SpotOrderBook

`SpotOrderBook` 是存储特定市场的现货限价单的结构。\
创建两个对象，一个用于买单，一个用于卖单。

```go
// Spot Exchange Limit Orderbook
type SpotOrderBook struct {
	MarketId  string
	IsBuySide bool
	Orders    []*SpotLimitOrder
}

type SpotOrder struct {
	// market_id represents the unique ID of the market
	MarketId string
	// order_info contains the information of the order
	OrderInfo OrderInfo
	// order types
	OrderType OrderType
	// trigger_price is the trigger price used by stop/take orders
	TriggerPrice *math.LegacyDec
}

// A valid Spot limit order with Metadata.
type SpotLimitOrder struct {
	// order_info contains the information of the order
	OrderInfo OrderInfo
	// order types
	OrderType OrderType
	// the amount of the quantity remaining fillable
	Fillable math.LegacyDec
	// trigger_price is the trigger price used by stop/take orders
	TriggerPrice *math.LegacyDec
	OrderHash    []byte
}

// A valid Spot market order with Metadata.
type SpotMarketOrder struct {
	// order_info contains the information of the order
	OrderInfo   OrderInfo
	BalanceHold math.LegacyDec
	OrderHash   []byte
}
```

## DerivativeMarket

`DerivativeMarket` 是存储衍生品市场所有必需信息和状态的结构。\
衍生品市场通过市场的哈希值存储，以便高效查询市场。

```go
// An object describing a derivative market in the Biya Chain Futures Protocol.
type DerivativeMarket struct {
	// Ticker for the derivative contract.
	Ticker string
	// Oracle base currency
	OracleBase string
	// Oracle quote currency
	OracleQuote string
	// Oracle type
	OracleType types1.OracleType
	// Scale factor for oracle prices.
	OracleScaleFactor uint32
	// Address of the quote currency denomination for the derivative contract
	QuoteDenom string
	// Unique market ID.
	MarketId string
	// initial_margin_ratio defines the initial margin ratio of a derivative market
	InitialMarginRatio math.LegacyDec
	// maintenance_margin_ratio defines the maintenance margin ratio of a derivative market
	MaintenanceMarginRatio math.LegacyDec
	// maker_fee_rate defines the maker fee rate of a derivative market
	MakerFeeRate math.LegacyDec
	// taker_fee_rate defines the taker fee rate of a derivative market
	TakerFeeRate math.LegacyDec
	// relayer_fee_share_rate defines the percentage of the transaction fee shared with the relayer in a derivative market
	RelayerFeeShareRate math.LegacyDec
	// true if the market is a perpetual market. false if the market is an expiry futures market
	IsPerpetual bool
	// Status of the market
	Status MarketStatus
	// min_price_tick_size defines the minimum tick size that the price and margin required for orders in the market
	MinPriceTickSize math.LegacyDec
	// min_quantity_tick_size defines the minimum tick size of the quantity required for orders in the market
	MinQuantityTickSize math.LegacyDec
}
```

## DerivativeOrderBook

`DerivativeOrderBook` 是存储特定市场的衍生品限价单的结构。\
创建两个对象，一个用于买单，一个用于卖单。

```go
// Spot Exchange Limit Orderbook
type DerivativeOrderBook struct {
	MarketId  string
	IsBuySide bool
	Orders    []*DerivativeLimitOrder
}

type DerivativeOrder struct {
	// market_id represents the unique ID of the market
	MarketId string
	// order_info contains the information of the order
	OrderInfo OrderInfo
	// order types
	OrderType OrderType
	// margin is the margin used by the limit order
	Margin math.LegacyDec
	// trigger_price is the trigger price used by stop/take orders
	TriggerPrice *math.LegacyDec
}

// A valid Derivative limit order with Metadata.
type DerivativeLimitOrder struct {
	// order_info contains the information of the order
	OrderInfo OrderInfo
	// order types
	OrderType OrderType
	// margin is the margin used by the limit order
	Margin math.LegacyDec
	// the amount of the quantity remaining fillable
	Fillable math.LegacyDec
	// trigger_price is the trigger price used by stop/take orders
	TriggerPrice *math.LegacyDec
	OrderHash    []byte
}

// A valid Derivative market order with Metadata.
type DerivativeMarketOrder struct {
	// order_info contains the information of the order
	OrderInfo OrderInfo
	// order types
	OrderType  OrderType
	Margin     math.LegacyDec
	MarginHold math.LegacyDec
	// trigger_price is the trigger price used by stop/take orders
	TriggerPrice *math.LegacyDec
	OrderHash    []byte
}

type DerivativeMarketOrderCancel struct {
	MarketOrder    *DerivativeMarketOrder
	CancelQuantity math.LegacyDec
}
```

## DerivativePosition

`DerivativePosition` 是存储子账户在特定市场上的衍生品持仓的结构。

**注意：** 衍生品订单表示意图，而持仓表示拥有。

```go
type Position struct {
	IsLong                 bool
	Quantity               math.LegacyDec
	EntryPrice             math.LegacyDec
	Margin                 math.LegacyDec
	CumulativeFundingEntry math.LegacyDec
}

type PositionDelta struct {
	IsLong            bool
	ExecutionQuantity math.LegacyDec
	ExecutionMargin   math.LegacyDec
	ExecutionPrice    math.LegacyDec
}

type DerivativePosition struct {
	SubaccountId string
	MarketId     string
	Position     *Position
}

type SubaccountPosition struct {
	Position     *Position
	SubaccountId []byte
}
```

## PerpetualMarketInfo

`PerpetualMarketInfo` 是用于保存永续市场信息的结构。

```go
type PerpetualMarketInfo struct {
	// market ID.
	MarketId string
	// hourly_funding_rate_cap defines the maximum absolute value of the hourly funding rate
	HourlyFundingRateCap math.LegacyDec
	// hourly_interest_rate defines the hourly interest rate
	HourlyInterestRate math.LegacyDec
	// next_funding_timestamp defines the next funding timestamp in seconds of a perpetual market
	NextFundingTimestamp int64
	// funding_interval defines the next funding interval in seconds of a perpetual market.
	FundingInterval int64
}
```

## PerpetualMarketFunding

`PerpetualMarketFunding` 是用于管理永续市场资金费率信息的结构。

```go
type PerpetualMarketFunding struct {
	// cumulative_funding defines the cumulative funding of a perpetual market.
	CumulativeFunding math.LegacyDec
	// cumulative_price defines the cumulative price for the current hour up to the last timestamp
	CumulativePrice math.LegacyDec
	LastTimestamp   int64
}
```

## Trading Rewards

### CampaignRewardPool

`CampaignRewardPool` 是用于获取即将到来的交易奖励池的结构。

```go
type CampaignRewardPool struct {
	StartTimestamp int64
	// max_campaign_rewards are the maximum reward amounts to be disbursed at the end of the campaign
	MaxCampaignRewards sdk.Coins
}
```

### TradingRewardCampaignInfo

`TradingRewardCampaignInfo` 是用于获取交易奖励活动信息的结构。

```go
type TradingRewardCampaignInfo struct {
	// number of seconds of the duration of each campaign
	CampaignDurationSeconds int64
	// the trading fee quote denoms which will be counted for the rewards
	QuoteDenoms []string
	// the optional boost info for markets
	TradingRewardBoostInfo *TradingRewardCampaignBoostInfo
	// the marketIDs which are disqualified from being rewarded
	DisqualifiedMarketIds []string
}

type TradingRewardCampaignBoostInfo struct {
	BoostedSpotMarketIds        []string
	SpotMarketMultipliers       []PointsMultiplier
	BoostedDerivativeMarketIds  []string
	DerivativeMarketMultipliers []PointsMultiplier
}

type PointsMultiplier struct {
	MakerPointsMultiplier math.LegacyDec
	TakerPointsMultiplier math.LegacyDec
}
```

## FeeDiscountProposal

`FeeDiscountProposal` 是用于提议新的费用折扣计划和持续时间的结构。

```go
type FeeDiscountSchedule struct {
	// the bucket count, e.g., 30
	BucketCount    uint64
	// the bucket duration, e.g., 1 day
	BucketDuration int64
	// the trading fee quote denoms which will be counted for the fee paid contribution
	QuoteDenoms []string
	// the fee discount tiers
	TierInfos []*FeeDiscountTierInfo
	// the marketIDs which are disqualified from contributing to the fee paid amount
	DisqualifiedMarketIds []string
}

type FeeDiscountTierInfo struct {
  MakerDiscountRate math.LegacyDec
  TakerDiscountRate math.LegacyDec
  StakedAmount      math.Int
  FeePaidAmount     math.LegacyDec
}
```

## DerivativeMarketSettlementInfo

`DerivativeMarketSettlementInfo` 是用于计划结算市场的结构。

```go
type DerivativeMarketSettlementInfo struct {
	// market ID.
	MarketId string
	// settlement_price defines the settlement price
	SettlementPrice math.LegacyDec
	// starting_deficit defines starting deficit
	StartingDeficit math.LegacyDec
}
```

## TradeLog

交易日志在事件中发出，用于跟踪交易历史。

```go
type TradeLog struct {
	Quantity math.LegacyDec
	Price    math.LegacyDec
	// bytes32 subaccount ID that executed the trade
	SubaccountId []byte
	Fee          math.LegacyDec
	OrderHash    []byte
}

type DerivativeTradeLog struct {
	SubaccountId  []byte
	PositionDelta *PositionDelta
	Payout        math.LegacyDec
	Fee           math.LegacyDec
	OrderHash     []byte
}
```

## Enums

枚举用于描述订单类型、执行类型和市场状态。

```protobuf
enum OrderType {
  UNSPECIFIED = 0 [(gogoproto.enumvalue_customname) = "UNSPECIFIED"];
  BUY = 1 [(gogoproto.enumvalue_customname) = "BUY"];
  SELL = 2 [(gogoproto.enumvalue_customname) = "SELL"];
  STOP_BUY = 3 [(gogoproto.enumvalue_customname) = "STOP_BUY"];
  STOP_SELL = 4 [(gogoproto.enumvalue_customname) = "STOP_SELL"];
  TAKE_BUY = 5 [(gogoproto.enumvalue_customname) = "TAKE_BUY"];
  TAKE_SELL = 6 [(gogoproto.enumvalue_customname) = "TAKE_SELL"];
  BUY_PO = 7 [(gogoproto.enumvalue_customname) = "BUY_PO"];
  SELL_PO = 8 [(gogoproto.enumvalue_customname) = "SELL_PO"];
  BUY_ATOMIC = 9 [ (gogoproto.enumvalue_customname) = "BUY_ATOMIC" ];
  SELL_ATOMIC = 10 [ (gogoproto.enumvalue_customname) = "SELL_ATOMIC" ];
}

enum MarketStatus {
  Unspecified = 0;
  Active = 1;
  Paused = 2;
  Suspended = 3;
  Demolished = 4;
  Expired = 5;
}

enum ExecutionType {
  UnspecifiedExecutionType = 0;
  Market = 1;
  LimitFill = 2;
  LimitMatchRestingOrder = 3;
  LimitMatchNewOrder = 4;
}
```

## GrantAuthorization

`GrantAuthorization` 用于跟踪被授权人的地址和授权人授权的质押金额，用于交易费用折扣。

```protobuf
type GrantAuthorization struct {
  Grantee string             
  Amount  math.Int
}

```

## ActiveGrant

`ActiveGrant` 用于跟踪授权人的地址和授权中已被被授权人激活的质押金额（用于交易费用折扣）。

```protobuf
type ActiveGrant struct {
  Granter string             
  Amount  math.Int
}

```

## EffectiveGrant

`EffectiveGrant` 用于跟踪授权人在质押授权中为交易费用折扣授权的质押总额。

```protobuf
type EffectiveGrant struct {
  Granter         string               
  NetGrantedStake math.Int 
  IsValid         bool                  
}
```
