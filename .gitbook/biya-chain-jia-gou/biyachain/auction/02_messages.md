---
sidebar_position: 2
title: Messages  
---

# 消息

在本节中，我们描述拍卖消息的处理以及相应的状态更新。

## Msg/Bid

通过使用 `Msg/Bid` 服务消息对给定轮次的拍卖篮子进行出价。

```protobuf
// Bid 定义了用于对拍卖进行出价的 SDK 消息
message MsgBid {
  option (gogoproto.equal) = false;
  option (gogoproto.goproto_getters) = false;
  string sender = 1;
  // 以 BIYA 代币计价的出价金额
  cosmos.base.v1beta1.Coin bid_amount = 2 [(gogoproto.nullable) = false];
  // 正在出价的当前拍卖轮次
  uint64 round = 3;
}
```

如果满足以下条件，此服务消息将失败：

- `Round` 不等于当前拍卖轮次
- `BidAmount` 没有超过之前最高出价金额至少 `min_next_increment_rate` 百分比。

此服务消息将 `BidAmount` 的 BIYA 从 `Sender` 转移到拍卖模块，存储出价，并退还最后出价者的出价金额。
