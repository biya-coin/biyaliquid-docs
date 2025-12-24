---
sidebar_position: 7
title: Governance Proposals
---

# 治理提案

## Proposal/SpotMarketParamUpdate

`SpotMarketParamUpdateProposal` 定义了一个 SDK 消息，用于提议更新现货市场参数。

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

**字段描述**

- `Title` 描述提案的标题。
- `Description` 描述提案的描述。
- `MarketId` 描述要更改参数的市场 ID。
- `MakerFeeRate` 描述做市商的目标费率。
- `TakerFeeRate` 描述吃单者的目标费率。
- `RelayerFeeShareRate` 描述中继者费用分享率。
- `MinPriceTickSize` 定义订单价格的最小变动单位。
- `MinQuantityTickSize` 定义订单数量的最小变动单位。
- `Status` 描述市场的目标状态。

## Proposal/ExchangeEnable

`ExchangeEnableProposal` defines a message to propose enable of specific exchange type.

```go
type ExchangeEnableProposal struct {
	Title        string
	Description  string
	ExchangeType ExchangeType
}
```

**Fields description**

- `Title` describes the title of the proposal.
- `Description` describes the description of the proposal.
- `ExchangeType` describes the type of exchange, spot or derivatives.


## Proposal/BatchExchangeModification

`BatchExchangeModificationProposal` defines a message to batch multiple proposals in the exchange module.

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

**Fields description**

- `Title` describes the title of the proposal.
- `Description` describes the description of the proposal.
- `SpotMarketParamUpdateProposal` describes the SpotMarketParamUpdateProposal.
- `DerivativeMarketParamUpdateProposal` describes the DerivativeMarketParamUpdateProposal.
- `SpotMarketLaunchProposal` describes the SpotMarketLaunchProposal.
- `PerpetualMarketLaunchProposal` describes the PerpetualMarketLaunchProposal.
- `ExpiryFuturesMarketLaunchProposal` describes the ExpiryFuturesMarketLaunchProposal.
- `TradingRewardCampaignUpdateProposal` describes the TradingRewardCampaignUpdateProposal.


## Proposal/SpotMarketLaunch

`SpotMarketLaunchProposal` defines an SDK message for proposing a new spot market through governance.

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

**Fields description**

- `Title` describes the title of the proposal.
- `Description` describes the description of the proposal.
- `Ticker` describes the ticker for the spot market.
- `BaseDenom` specifies the type of coin to use as the base currency.
- `QuoteDenom` specifies the type of coin to use as the quote currency.
- `MinPriceTickSize` defines the minimum tick size of the order's price.
- `MinQuantityTickSize` defines the minimum tick size of the order's quantity.
- `MakerFeeRate` field describes the trade fee rate for makers on the derivative market.
- `TakerFeeRate` field describes the trade fee rate for takers on the derivative market.

## Proposal/PerpetualMarketLaunch

`PerpetualMarketLaunchProposal` defines an SDK message for proposing a new perpetual futures market through governance.

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

**Fields description**

- `Title` describes the title of the proposal.
- `Description` describes the description of the proposal.
- `Ticker` field describes the ticker for the derivative market.
- `QuoteDenom` field describes the type of coin to use as the base currency.
- `OracleBase` field describes the oracle base currency.
- `OracleQuote` field describes the oracle quote currency.
- `OracleScaleFactor` field describes the scale factor for oracle prices.
- `OracleType` field describes the oracle type.
- `MakerFeeRate` field describes the trade fee rate for makers on the derivative market.
- `TakerFeeRate` field describes the trade fee rate for takers on the derivative market.
- `InitialMarginRatio` field describes the initial margin ratio for the derivative market.
- `MaintenanceMarginRatio` field describes the maintenance margin ratio for the derivative market.
- `MinPriceTickSize` field describes the minimum tick size of the order's price and margin.
- `MinQuantityTickSize` field describes the minimum tick size of the order's quantity.

## 二元期权市场启动提案

```go
type BinaryOptionsMarketLaunchProposal struct {
	Title       string
	Description string
	// 衍生品合约的交易代码
	Ticker string
	// 预言机符号
	OracleSymbol string
	// 预言机提供者
	OracleProvider string
	// 预言机类型
	OracleType types1.OracleType
	// 预言机价格的缩放因子
	OracleScaleFactor uint32
	// 到期时间戳
	ExpirationTimestamp int64
	// 结算时间戳
	SettlementTimestamp int64
	// 市场管理员
	Admin string
	// 二元期权合约的报价货币面额地址
	QuoteDenom string
	// maker_fee_rate 定义二元期权市场的做市商费率
	MakerFeeRate math.LegacyDec
	// taker_fee_rate 定义衍生品市场的吃单者费率
	TakerFeeRate math.LegacyDec
	// min_price_tick_size 定义市场中订单所需价格和保证金的最小变动单位
	MinPriceTickSize math.LegacyDec
	// min_quantity_tick_size 定义市场中订单所需数量的最小变动单位
	MinQuantityTickSize math.LegacyDec
}
```

## 二元期权市场参数更新

```go
type BinaryOptionsMarketParamUpdateProposal struct {
	Title       string
	Description string
	MarketId    string
	// maker_fee_rate 定义衍生品市场上做市商的交易所交易费率
	MakerFeeRate *math.LegacyDec
	// taker_fee_rate 定义衍生品市场上吃单者的交易所交易费率
	TakerFeeRate *math.LegacyDec
	// relayer_fee_share_rate 定义衍生品市场的中继者费用分享率
	RelayerFeeShareRate *math.LegacyDec
	// min_price_tick_size 定义订单价格和保证金的最小变动单位
	MinPriceTickSize *math.LegacyDec
	// min_quantity_tick_size 定义订单数量的最小变动单位
	MinQuantityTickSize *math.LegacyDec
    // min_notional 定义订单的最小名义价值
    MinNotional *math.LegacyDec
	// 到期时间戳
	ExpirationTimestamp int64
	// 结算时间戳
	SettlementTimestamp int64
	// 市场将以此价格结算的新价格
	SettlementPrice *math.LegacyDec
	// 市场管理员
	Admin        string
	Status       MarketStatus
	OracleParams *ProviderOracleParams
}
```

## Proposal/DerivativeMarketParamUpdate

```go
type OracleParams struct {
    // 预言机基础货币
    OracleBase        string
    // 预言机报价货币
    OracleQuote       string
    // 预言机价格的缩放因子
    OracleScaleFactor uint32
    // 预言机类型
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

**字段描述**

- `Title` 描述提案的标题。
- `Description` 描述提案的描述。
- `MarketId` 描述要更改参数的市场 ID。
- `InitialMarginRatio` 描述目标初始保证金比率。
- `MaintenanceMarginRatio` 描述目标维持保证金比率。
- `MakerFeeRate` 描述做市商的目标费率。
- `TakerFeeRate` 描述吃单者的目标费率。
- `RelayerFeeShareRate` 描述中继者费用分享率。
- `MinPriceTickSize` 定义订单价格的最小变动单位。
- `MinQuantityTickSize` 定义订单数量的最小变动单位。
- `Status` 描述市场的目标状态。
- `OracleParams` 描述新的预言机参数。

## Proposal/TradingRewardCampaignLaunch

`TradingRewardCampaignLaunchProposal` defines an SDK message for proposing to launch a new trading reward campaign.

```go
type TradingRewardCampaignLaunchProposal struct {
	Title               string
	Description         string
	CampaignInfo        *TradingRewardCampaignInfo
	CampaignRewardPools []*CampaignRewardPool
}
```

**Fields description**

- `Title` describes the title of the proposal.
- `Description` describes the description of the proposal.
- `CampaignInfo` describes the CampaignInfo.
- `CampaignRewardPools` describes the CampaignRewardPools.

## Proposal/TradingRewardCampaignUpdate

`TradingRewardCampaignUpdateProposal` defines an SDK message for proposing to update an existing trading reward campaign.

```go
type TradingRewardCampaignUpdateProposal struct {
	Title                        string
	Description                  string
	CampaignInfo                 *TradingRewardCampaignInfo
	CampaignRewardPoolsAdditions []*CampaignRewardPool
	CampaignRewardPoolsUpdates   []*CampaignRewardPool
}
```

- `Title` describes the title of the proposal.
- `Description` describes the description of the proposal.
- `CampaignRewardPoolsAdditions` describes the CampaignRewardPoolsAdditions.
- `CampaignRewardPoolsUpdates` describes the CampaignRewardPoolsUpdates.

## Proposal/FeeDiscount

`FeeDiscountProposal` defines an SDK message for proposing to launch or update a fee discount schedule.

```go
type FeeDiscountProposal struct {
	Title          string
	Description    string
	Schedule       *FeeDiscountSchedule
}
```

- `Title` describes the title of the proposal.
- `Description` describes the description of the proposal.
- `Schedule` describes the Fee discount schedule.

## Proposal/TradingRewardPendingPointsUpdate

`TradingRewardPendingPointsUpdateProposal` defines an SDK message to update reward points for certain addresses during the vesting period.

```go
type TradingRewardPendingPointsUpdateProposal struct {
	Title                  string
	Description            string
	PendingPoolTimestamp   int64
	RewardPointUpdates     *[]RewardPointUpdate
}
```

**Fields description**

- `Title` describes the title of the proposal.
- `Description` describes the description of the proposal.
- `PendingPoolTimestamp` describes timestamp of the pending pool.
- `RewardPointUpdates` describes the RewardPointUpdate.


