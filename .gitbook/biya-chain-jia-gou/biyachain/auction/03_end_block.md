---
sidebar_position: 3
title: End-Block
---

# EndBlock

### 拍卖结算

当 `blockTime ≥ EndingTimeStamp` 时，给定拍卖轮次的结算发生。如果在此期间放置了非零 BIYA 出价（即存在 `LastBid`），将执行以下程序：

* 获胜的 BIYA 出价金额被销毁。
* 拍卖模块持有的代币篮子转移给获胜的出价者。
* `LastAuctionResult` 被写入状态，并发出 `EventAuctionResult` 事件。
* `LastBid` 被清除。
* AuctionRound 增加 1，EndingTimestamp 增加 `AuctionPeriod`。
* 累积的交易所费用从 `exchange` 模块转移到 `auction` 模块，用于即将到来的新拍卖。

如果该轮次在没有成功出价的情况下结束，现有的代币篮子将滚动到下一次拍卖，并与新累积的费用篮子合并。

![img.png](/broken/files/8DUHqFLCrQlNRUQRXTbJ)
