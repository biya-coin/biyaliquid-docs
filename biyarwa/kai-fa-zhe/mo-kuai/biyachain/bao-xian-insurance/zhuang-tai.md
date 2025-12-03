# 状态

## Params

Params 是一个模块级的配置结构，用于存储系统参数并定义保险模块的整体功能。

* `Params: Paramsspace("insurance") -> legacy_amino(params)`

```go

type Params struct {
	// default_redemption_notice_period_duration defines the default minimum notice period duration that must pass after an underwriter sends
	// a redemption request before the underwriter can claim his tokens
	DefaultRedemptionNoticePeriodDuration time.Duration 
}
```

## Insurance Types

`InsuranceFund` 定义了按市场划分的所有保险基金信息。

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

`RedemptionSchedule` 定义了用户的赎回计划——赎回不会立即执行，而是每个市场都有一个指定的赎回通知期持续时间(`redemption_notice_period_duration`)。

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

此外，我们引入了 `next_share_denom_id` 和 `next_redemption_schedule_id` 来管理来自不同用户的保险基金份额代币的 denom 和赎回计划。

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

## Pending Redemptions

待处理赎回对象用于存储有关赎回请求的所有信息，并在期限过后自动进行赎回。
