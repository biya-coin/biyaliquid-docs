# State

## Params

**Params** 是一个模块级的配置结构，用于存储系统参数，并定义 **拍卖模块** 的整体运行方式。

* Params: `Paramsspace("auction") -> legacy_amino(params)`

```go
type Params struct {
	// auction_period_duration defines the auction period duration
	AuctionPeriod int64 
	// min_next_bid_increment_rate defines the minimum increment rate for new bids
	MinNextBidIncrementRate math.LegacyDec
}
```

### **LastBid**

用于跟踪当前最高出价。

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

该值会与当前区块时间进行比较，以决定拍卖轮次的结算时间。当导出的链再次导入时，**EndingTimeStamp** 将更新为未来的下一个时间点。

* `EndingTimeStamp`: `0x04 -> BigEndian(EndingTimestamp)`

### **LastAuctionResult**

用于跟踪最近一次拍卖的结果。

* LastAuctionResult: `0x05 -> ProtocolBuffer(LastAuctionResult)`

```go
type LastAuctionResult struct {
    Winner string 
    Amount sdk.Coin 
    Round uint64 
}
```
