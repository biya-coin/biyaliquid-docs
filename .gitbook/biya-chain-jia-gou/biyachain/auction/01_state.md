---
sidebar_position: 1
title: State  
---

# 状态

## 参数

Params 是一个模块范围的配置结构，用于存储系统参数并定义拍卖模块的整体功能。

- Params: `Paramsspace("auction") -> legacy_amino(params)`

```go
type Params struct {
	// auction_period_duration 定义拍卖周期持续时间
	AuctionPeriod int64 
	// min_next_bid_increment_rate 定义新出价的最小递增率
	MinNextBidIncrementRate math.LegacyDec
}
```

### **LastBid**

跟踪当前最高出价

* LastBid: `0x01 -> ProtocolBuffer(Bid)`

```go
type Bid struct {
	Bidder string                                  
	Amount sdk.Coin 
}
```

### **AuctionRound**

当前拍卖轮次。

* AuctionRound: `0x03 -> BigEndian(AuctionRound)`

### **EndingTimeStamp**

此值与当前区块时间进行比较，以决定拍卖轮次的结算。当导出的链再次导入时，EndingTimeStamp 将更新为未来的下一个值。

* `EndingTimeStamp`: `0x04 -> BigEndian(EndingTimestamp)`

### **LastAuctionResult**

跟踪最后一次拍卖的结果。

* LastAuctionResult: `0x05 -> ProtocolBuffer(LastAuctionResult)`

```go
type LastAuctionResult struct {
    Winner string 
    Amount sdk.Coin 
    Round uint64 
}
```
