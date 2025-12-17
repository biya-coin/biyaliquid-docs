---
sidebar_position: 5
title: 参数
---

# 参数

tokenfactory 模块包含以下参数：

```protobuf
// Params defines the parameters for the tokenfactory module.
message Params {
  repeated cosmos.base.v1beta1.Coin denom_creation_fee = 1 [
    (gogoproto.castrepeated) = "github.com/cosmos/cosmos-sdk/types.Coins",
    (gogoproto.moretags) = "yaml:\"denom_creation_fee\"",
    (gogoproto.nullable) = false
  ];
}
```
