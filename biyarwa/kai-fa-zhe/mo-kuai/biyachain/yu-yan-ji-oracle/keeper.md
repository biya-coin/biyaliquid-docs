# Keeper

oracle模块当前提供了三个不同的导出keeper接口，这些接口可以传递给需要读取价格源的其他模块。模块应使用最小权限的接口，以提供其所需的功能。

## Oracle模块 ViewKeeper

oracle模块的**ViewKeeper**提供了获取任何支持的oracle类型和oracle对的价格数据以及累计价格数据的功能。

```go
type ViewKeeper interface {
    GetPrice(ctx sdk.Context, oracletype types.OracleType, base string, quote string) *math.LegacyDec // Returns the price for a given pair for a given oracle type.
    GetCumulativePrice(ctx sdk.Context, oracleType types.OracleType, base string, quote string) *math.LegacyDec // Returns the cumulative price for a given pair for a given oracle type.
}
```

注意，**`GetPrice`** 对于Coinbase oracle返回的是5分钟的时间加权平均价格（TWAP）。

## Band

**BandKeeper** 提供了创建/修改/读取/删除BandPricefeed和BandRelayer的功能。

```go
type BandKeeper interface {
    GetBandPriceState(ctx sdk.Context, symbol string) *types.BandPriceState
    SetBandPriceState(ctx sdk.Context, symbol string, priceState types.BandPriceState)
    GetAllBandPriceStates(ctx sdk.Context) []types.BandPriceState
    GetBandReferencePrice(ctx sdk.Context, base string, quote string) *math.LegacyDec
    IsBandRelayer(ctx sdk.Context, relayer sdk.AccAddress) bool
    GetAllBandRelayers(ctx sdk.Context) []string
    SetBandRelayer(ctx sdk.Context, relayer sdk.AccAddress)
    DeleteBandRelayer(ctx sdk.Context, relayer sdk.AccAddress)
}
```

## Band IBC

**BandIBCKeeper** 提供了创建/修改/读取/删除BandIBCOracleRequest、BandIBCPriceState、BandIBCLatestClientID和BandIBCCallDataRecord的功能。

```go
type BandIBCKeeper interface {
	SetBandIBCOracleRequest(ctx sdk.Context, req types.BandOracleRequest)
	GetBandIBCOracleRequest(ctx sdk.Context) *types.BandOracleRequest
	DeleteBandIBCOracleRequest(ctx sdk.Context, requestID uint64)
	GetAllBandIBCOracleRequests(ctx sdk.Context) []*types.BandOracleRequest

	GetBandIBCPriceState(ctx sdk.Context, symbol string) *types.BandPriceState
	SetBandIBCPriceState(ctx sdk.Context, symbol string, priceState types.BandPriceState)
	GetAllBandIBCPriceStates(ctx sdk.Context) []types.BandPriceState
	GetBandIBCReferencePrice(ctx sdk.Context, base string, quote string) *math.LegacyDec

	GetBandIBCLatestClientID(ctx sdk.Context) uint64
	SetBandIBCLatestClientID(ctx sdk.Context, clientID uint64)
	SetBandIBCCallDataRecord(ctx sdk.Context, clientID uint64, bandIBCCallDataRecord []byte)
	GetBandIBCCallDataRecord(ctx sdk.Context, clientID uint64) *types.CalldataRecord
}
```

## Coinbase

`CoinbaseKeeper` 提供了创建、修改和读取CoinbasePricefeed数据的功能。

```go
type CoinbaseKeeper interface {
    GetCoinbasePrice(ctx sdk.Context, base string, quote string) *math.LegacyDec
    HasCoinbasePriceState(ctx sdk.Context, key string) bool
    GetCoinbasePriceState(ctx sdk.Context, key string) *types.CoinbasePriceState
    SetCoinbasePriceState(ctx sdk.Context, priceData *types.CoinbasePriceState) error
    GetAllCoinbasePriceStates(ctx sdk.Context) []*types.CoinbasePriceState
}
```

`GetCoinbasePrice` 返回基于Coinbase提供的`CoinbasePriceState.Timestamp`值的5分钟时间加权平均价格（TWAP）。

## PriceFeeder

**PriceFeederKeeper** 提供了创建/修改/读取/删除PriceFeedPrice和PriceFeedRelayer的功能。

```go
type PriceFeederKeeper interface {
    IsPriceFeedRelayer(ctx sdk.Context, oracleBase, oracleQuote string, relayer sdk.AccAddress) bool
    GetAllPriceFeedStates(ctx sdk.Context) []*types.PriceFeedState
    GetAllPriceFeedRelayers(ctx sdk.Context, baseQuoteHash common.Hash) []string
    SetPriceFeedRelayer(ctx sdk.Context, oracleBase, oracleQuote string, relayer sdk.AccAddress)
    SetPriceFeedRelayerFromBaseQuoteHash(ctx sdk.Context, baseQuoteHash common.Hash, relayer sdk.AccAddress)
    DeletePriceFeedRelayer(ctx sdk.Context, oracleBase, oracleQuote string, relayer sdk.AccAddress)
    HasPriceFeedInfo(ctx sdk.Context, priceFeedInfo *types.PriceFeedInfo) bool
    GetPriceFeedInfo(ctx sdk.Context, baseQuoteHash common.Hash) *types.PriceFeedInfo
    SetPriceFeedInfo(ctx sdk.Context, priceFeedInfo *types.PriceFeedInfo)
    GetPriceFeedPriceState(ctx sdk.Context, base string, quote string) *types.PriceState
    SetPriceFeedPriceState(ctx sdk.Context, oracleBase, oracleQuote string, priceState *types.PriceState)
    GetPriceFeedPrice(ctx sdk.Context, base string, quote string) *math.LegacyDec
}
```

## Stork

**StorkKeeper** 提供了创建/修改/读取StorkPricefeed和StorkPublishers数据的功能。

```go
type StorkKeeper interface {
	GetStorkPrice(ctx sdk.Context, base string, quote string) *math.LegacyDec
	IsStorkPublisher(ctx sdk.Context, address string) bool
	SetStorkPublisher(ctx sdk.Context, address string)
	DeleteStorkPublisher(ctx sdk.Context, address string)
	GetAllStorkPublishers(ctx sdk.Context) []string

	SetStorkPriceState(ctx sdk.Context, priceData *types.StorkPriceState)
	GetStorkPriceState(ctx sdk.Context, symbol string) types.StorkPriceState
	GetAllStorkPriceStates(ctx sdk.Context) []*types.StorkPriceState
}
```

`GetStorkPrice` 返回`StorkPriceState`的价格（`value`）。
