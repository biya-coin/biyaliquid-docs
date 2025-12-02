# EndBlock

## **拍卖结算**

给定拍卖轮次的结算发生在 **blockTime ≥ EndingTimeStamp** 时。如果在此期间有非零的 BIYA 出价（即存在 **LastBid**），则会执行以下流程：

1. 获胜的 BIYA 出价金额将被销毁。
2. 拍卖模块持有的代币篮子将转移给获胜竞标者。
3. **LastAuctionResult** 会写入状态，并触发 **EventAuctionResult** 事件。
4. **LastBid** 被清除。
5. **AuctionRound** 递增 1，**EndingTimestamp** 递增 **AuctionPeriod**。
6. 累积的交易手续费将从交易模块转移到拍卖模块，为即将到来的新一轮拍卖做准备。
7. 如果该轮拍卖未有任何有效出价，现有的代币篮子将被转入下一轮拍卖，并与新的累积手续费篮子合并。

![img.png](https://content.gitbook.com/content/anhfn6E9s6UH5ZfZcrlA/blobs/N6LwXOobncYIecR4bySB/img.png)
