---
sidebar_position: 10
title: 未来改进
---

# 未来改进

### 原生 Ethereum 签名

验证者在 peggo 编排器中运行必需的 `Eth Signer`，因为我们还不能在不显著修改 Tendermint 的情况下将这种简单的签名逻辑插入到基于 Cosmos SDK 的链中。未来可能通过[修改 Tendermint](https://github.com/tendermint/tendermint/issues/6066) 实现这一点。

应该注意的是，如果可以在共识代码内执行 Ethereum 签名，那么 [PEGGYSLASH-02](./05_slashing.md) 和 [PEGGYSLASH-03](./05_slashing.md) 都可以在不损失安全性的情况下消除。这是对 Tendermint 的一个相当有限的功能补充，将使 Peggy 更不容易受到惩罚。

### 改进验证者激励

目前 Peggy 中的验证者只有一个胡萝卜——由正常运行的桥接为链带来的额外活动。

另一方面，有很多负面激励（大棒）是验证者必须注意的。这些在[惩罚规范](./05_slashing.md)中概述。

一个不在惩罚范围内的负面激励是提交预言机提交和签名的成本。目前这些操作没有激励，但仍然需要验证者支付费用来提交。考虑到目前 Biya Chain 上相对便宜的交易费用，这不是一个严重的问题，但随着交易费用的上涨，这当然是一个需要考虑的重要因素。

应该考虑为正确参与桥接操作提供一些正面激励。除了消除强制性提交的费用。