# 消息

本节将介绍拍卖消息的处理流程及其对应的状态更新。

## Msg/Bid

拍卖轮次中的代币篮子可通过 **Msg/Bid** 服务消息进行竞标。

```protobuf
// Bid defines a SDK message for placing a bid for an auction
message MsgBid {
  option (gogoproto.equal) = false;
  option (gogoproto.goproto_getters) = false;
  string sender = 1;
  // amount of the bid in BIYA tokens
  cosmos.base.v1beta1.Coin bid_amount = 2 [(gogoproto.nullable) = false];
  // the current auction round being bid on
  uint64 round = 3;
}
```

如果满足以下条件，此服务消息预计会失败：

* 轮次与当前拍卖轮次不相等
* 出价金额未能超过之前最高出价金额至少 **min\_next\_increment\_rate** 百分比

此服务消息会将 **BidAmount** 的 BIYA 从发送方转移到拍卖模块，存储该出价，并退还给上一个竞标者的出价金额。
