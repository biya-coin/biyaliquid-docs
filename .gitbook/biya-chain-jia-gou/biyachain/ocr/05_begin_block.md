---
sidebar_position: 5
title: Begin-Block
---

# Begin-Block

在每个 BeginBlock 中，它检查是否到了支付间隔时间，如果是，则处理所有 feed 的支付。

**步骤**

- 确保这是支付间隔的开始区块
- 在遍历所有 feed 配置时，处理奖励支付
