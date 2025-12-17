---
sidebar_position: 4
title: Events
---

# 事件

erc20 模块发出以下事件：

```protobuf 
message EventCreateTokenPair {
  string bank_denom = 1;
  string erc20_address = 2;
}

message EventDeleteTokenPair {
  string bank_denom = 1;
}
```