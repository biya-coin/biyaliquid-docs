---
sidebar_position: 2
title: Keepers
---

# Keeper

oracle 模块目前提供三种不同的导出 keeper 接口，可以传递给需要读取价格源的其他模块。模块应使用提供其所需功能的最小权限接口。

## Oracle Module ViewKeeper

oracle 模块 ViewKeeper 提供获取任何支持的 oracle 类型和 oracle 对的价格数据以及累积价格数据的能力。

```go
type ViewKeeper interface {
    GetPrice(ctx sdk.Context, oracletype types.OracleType, base string, quote string) *math.LegacyDec // Returns the price for a given pair for a given oracle type.
    GetCumulativePrice(ctx sdk.Context, oracleType types.OracleType, base string, quote string) *math.LegacyDec // Returns the cumulative price for a given pair for a given oracle type.
}
```

请注意，Coinbase oracle 的 `GetPrice` 返回 5 分钟 TWAP 价格。

## Band

BandKeeper 提供创建/修改/读取/删除 BandPricefeed 和 BandRelayer 的能力。

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

BandIBCKeeper 提供创建/修改/读取/删除 BandIBCOracleRequest、BandIBCPriceState、BandIBCLatestClientID 和 BandIBCCallDataRecord 的能力。

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

CoinbaseKeeper 提供创建、修改和读取 CoinbasePricefeed 数据的能力。

```go
type CoinbaseKeeper interface {
    GetCoinbasePrice(ctx sdk.Context, base string, quote string) *math.LegacyDec
    HasCoinbasePriceState(ctx sdk.Context, key string) bool
    GetCoinbasePriceState(ctx sdk.Context, key string) *types.CoinbasePriceState
    SetCoinbasePriceState(ctx sdk.Context, priceData *types.CoinbasePriceState) error
    GetAllCoinbasePriceStates(ctx sdk.Context) []*types.CoinbasePriceState
}
```

`GetCoinbasePrice` 基于 Coinbase 提供的 `CoinbasePriceState.Timestamp` 值返回 CoinbasePriceState 的 5 分钟 TWAP 价格。

## PriceFeeder

PriceFeederKeeper 提供创建/修改/读取/删除 PriceFeedPrice 和 PriceFeedRelayer 的能力。

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

StorkKeeper 提供创建/修改/读取 StorkPricefeed 和 StorkPublishers 数据的能力。

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

GetStorkPrice 返回 StorkPriceState 的价格（`value`）。
