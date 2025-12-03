# 提案

## SetConfigProposal

SetConfigProposal 是由治理设置 Feed 配置的提案。

```protobuf
message SetConfigProposal {
  option (gogoproto.equal) = false;
  option (gogoproto.goproto_getters) = false;

  string title = 1;
  string description = 2;
  FeedConfig config = 3;
}
```

步骤：

1. 验证提案的基本信息。
2. 确保模块的 LinkDenom 与提案中的 LinkDenom 相同。
3. 从 ctx.ChainID 设置 p.Config.OnchainConfig.ChainId。
4. 为 feedId 设置 Feed 配置。
5. 为 Config.Transmitters 设置 Feed 传输和观测计数。

## SetBatchConfigProposal

SetBatchConfigProposal 是由治理一次性设置多个 Feed 配置的提案。

```protobuf
message SetBatchConfigProposal {
  option (gogoproto.equal) = false;
  option (gogoproto.goproto_getters) = false;

  string title = 1;
  string description = 2;
  // signers ith element is address ith oracle uses to sign a report
  repeated string signers = 3;
  // transmitters ith element is address ith oracle uses to transmit a report via the transmit method
  repeated string transmitters = 4;
  // Native denom for LINK coin in the bank keeper
  string link_denom = 5;
  repeated FeedProperties feed_properties = 6;
}
```
