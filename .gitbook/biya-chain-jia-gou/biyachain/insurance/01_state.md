---
sidebar_position: 1
title: State
---

# 状态

## 参数

`Params` 是一个模块范围的配置结构，存储系统参数并定义保险模块的整体功能。

* Params: `Paramsspace("insurance") -> legacy_amino(params)`

```go

type Params struct {
	// default_redemption_notice_period_duration defines the default minimum notice period duration that must pass after an underwriter sends
	// a redemption request before the underwriter can claim his tokens
	DefaultRedemptionNoticePeriodDuration time.Duration 
}
```

## 保险类型

`InsuranceFund` 定义了按市场划分的 `Insurance Funds` 的所有信息。

```go

type InsuranceFund struct {
	// deposit denomination for the given insurance fund
	DepositDenom string 
	// insurance fund pool token denomination for the given insurance fund
	InsurancePoolTokenDenom string 
	// redemption_notice_period_duration defines the minimum notice period duration that must pass after an underwriter sends
	// a redemption request before the underwriter can claim his tokens
	RedemptionNoticePeriodDuration time.Duration 
	// balance of fund
	Balance math.Int 
	// total share tokens minted
	TotalShare math.Int 
	// marketID of the derivative market
	MarketId string 
	// ticker of the derivative market
	MarketTicker string 
	// Oracle base currency of the derivative market
	OracleBase string 
	// Oracle quote currency of the derivative market
	OracleQuote string 
	// Oracle type of the derivative market
	OracleType types.OracleType 
    // Expiration time of the derivative market. Should be -1 for perpetual markets.
	Expiry int64
}
```

`RedemptionSchedule` 定义用户的赎回计划 - 赎回不会立即执行，而是每个市场都指定了 `redemption_notice_period_duration`。

```go
type RedemptionSchedule struct {
	// id of redemption schedule
	Id uint64 
	// marketId of redemption schedule
	MarketId string
	// address of the redeemer
	Redeemer string
	// the time after which the redemption can be claimed
	ClaimableRedemptionTime time.Time 
  // the insurance_pool_token amount to redeem
	RedemptionAmount sdk.Coin
}
```

此外，我们引入 `next_share_denom_id` 和 `next_redemption_schedule_id` 来管理保险基金份额代币面额和来自不同用户的赎回计划。

```go
// GenesisState defines the insurance module's genesis state.
type GenesisState struct {
	// params defines all the parameters of related to insurance.
	Params                   Params               
	InsuranceFunds           []InsuranceFund      
	RedemptionSchedule       []RedemptionSchedule 
	NextShareDenomId         uint64               
	NextRedemptionScheduleId uint64               
}
```

## 待处理赎回

待处理赎回对象用于存储所有赎回请求的信息，并在期限过去时自动提取。
