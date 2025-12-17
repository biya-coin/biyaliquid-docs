---
sidebar_position: 4
title: 治理提案
---

# 治理提案

## SetConfigProposal

`SetConfigProposal` 是通过治理设置 feed 配置的提案。

```protobuf
message SetConfigProposal {
  option (gogoproto.equal) = false;
  option (gogoproto.goproto_getters) = false;

  string title = 1;
  string description = 2;
  FeedConfig config = 3;
}
```

**步骤**

- 验证提案的基本信息
- 确保模块的 `LinkDenom` 与提案的 `LinkDenom` 相同
- 从 `ctx.ChainID` 设置 `p.Config.OnchainConfig.ChainId`
- 为 `feedId` 设置 feed 配置
- 为 `Config.Transmitters` 设置 feed 传输和观察计数

## SetBatchConfigProposal

`SetBatchConfigProposal` 是通过治理一次性设置多个 feed 配置的提案。

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
