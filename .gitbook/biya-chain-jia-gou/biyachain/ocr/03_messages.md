---
sidebar_position: 3
title: 消息
---

# 消息

在本节中，我们描述 ocr 消息的处理以及相应的状态更新。

## Msg/CreateFeed

`MsgCreateFeed` 是创建 feed 配置的消息，它是受限消息，只能由模块管理员执行。

```protobuf
message MsgCreateFeed {
  option (gogoproto.equal) = false;
  option (gogoproto.goproto_getters) = false;
  string sender = 1;
  FeedConfig config = 2;
}
```

**步骤**

- 确保 `Sender` 是模块管理员
- 确保 `msg.Config.OnchainConfig.LinkDenom` 是模块参数的 `LinkDenom`
- 从 `ctx.ChainID` 设置 `OnchainConfig.ChainId`
- 确保不存在相同 `FeedId` 的 `FeedConfig`
- 将最新的 `EpochAndRound` 设置为 `(0, 0)`
- 为 `feedId` 设置 feed 配置
- 将 feed 传输计数和观察计数设置为 1

## Msg/UpdateFeed

`MsgUpdateFeed` 是更新 feed 配置的消息，它是受限消息，只能由 feed 管理员或 feed 计费管理员执行。

```protobuf
message MsgUpdateFeed {
  option (gogoproto.equal) = false;
  option (gogoproto.goproto_getters) = false;
  string sender = 1;
  // feed_id is an unique ID for the target of this config
  string feed_id = 2;
  // signers ith element is address ith oracle uses to sign a report
  repeated string signers = 3;
  // transmitters ith element is address ith oracle uses to transmit a report via the transmit method
  repeated string transmitters = 4;
  // Fixed LINK reward for each observer
  string link_per_observation = 5[
    (gogoproto.customtype) = "cosmossdk.io/math.Int",
    (gogoproto.nullable) = true
  ];
  // Fixed LINK reward for transmitter
  string link_per_transmission = 6[
    (gogoproto.customtype) = "cosmossdk.io/math.Int",
    (gogoproto.nullable) = true
  ];
  // Native denom for LINK coin in the bank keeper
  string link_denom = 7;
  // feed administrator
  string feed_admin = 8;
  // feed billing administrator
  string billing_admin = 9;
}
```

**步骤**

- 通过 `feedId` 获取之前的 feed 配置并确保其存在
- 确保 `Sender` 是 feed 管理员或 feed 计费管理员
- 确保计费管理员不更改 Signers、Transmitters 和 feed 管理员
- 处理之前 feed 配置的奖励支付
- 删除之前的 feed 传输和观察计数
- 将最新的 `EpochAndRound` 设置为 `(0, 0)`
- 如果设置了，则更新 signers、transmitters、`LinkPerObservation`、`LinkPerTransmission`、`LinkDenom`、`FeedAdmin`、`BillingAdmin`。

## Msg/Transmit

`MsgTransmit` 是传输特定 feed 报告的消息。广播消息时，应该有足够数量的观察者签名才能被接受。

```protobuf
message MsgTransmit {
  option (gogoproto.equal) = false;
  option (gogoproto.goproto_getters) = false;
  // Address of the transmitter
  string transmitter = 1;
  bytes config_digest = 2;
  string feed_id = 3;
  uint64 epoch = 4;
  uint64 round = 5;
  bytes extra_hash = 6;
  Report report = 7;
  repeated bytes signatures = 8;
}
```

**步骤**

- 获取 `feedId` 的纪元和轮次
- 通过检查 `msg.Epoch` 和 `msg.Round` 确保报告不是过期的
- 从 `feedId` 获取 feed 配置和配置信息
- 检查 msg.ConfigDigest 是否等于 feed 配置信息的最新配置摘要
- 检查传输者是否是 `feedConfig` 中配置的有效传输者
- 保存传输者报告
- 发出传输事件
- 验证签名和签名数量
- 增加 feed 观察和传输计数

## Msg/FundFeedRewardPool

`MsgFundFeedRewardPool` 是向 feed 奖励池添加资金的消息，用于支付给传输者和观察者。

```protobuf
message MsgFundFeedRewardPool {
  option (gogoproto.equal) = false;
  option (gogoproto.goproto_getters) = false;

  string sender = 1;
  string feed_id = 2;
  cosmos.base.v1beta1.Coin amount = 3 [(gogoproto.nullable) = false];
}
```

**步骤**

- 从 `feedId` 获取之前的奖励池金额
- 如果之前的金额为空，则用零整数初始化池金额
- 如果存在，确保之前的金额面额与存款面额不同
- 将代币从账户发送到模块账户（`ocr` 模块）
- 通过添加 `amount` 字段更新奖励池金额
- 如果设置了钩子，则调用 `AfterFundFeedRewardPool` 钩子

## Msg/WithdrawFeedRewardPool

`MsgWithdrawFeedRewardPool` 是从 feed 奖励池提取资金的消息，仅限于 feed 管理员或计费管理员。

```protobuf
message MsgWithdrawFeedRewardPool {
  option (gogoproto.equal) = false;
  option (gogoproto.goproto_getters) = false;

  string sender = 1;
  string feed_id = 2;
  cosmos.base.v1beta1.Coin amount = 3 [(gogoproto.nullable) = false];
}
```

**步骤**

- 从 `feedId` 获取 feed 配置
- 确保 `msg.Sender` 是 `feedAdmin` 或 `billingAdmin`
- 处理 feed 的奖励
- 从模块账户提取指定金额 `msg.Amount`

## Msg/SetPayees

`MsgSetPayees` 是为传输者设置收款人的消息——它仅限于 feed 管理员。一旦设置，只能由收款人更改。

```protobuf
message MsgSetPayees {
  option (gogoproto.equal) = false;
  option (gogoproto.goproto_getters) = false;

  string sender = 1;
  string feed_id = 2;
  // addresses oracles use to transmit the reports
  repeated string transmitters = 3;
  // addresses of payees corresponding to list of transmitters
  repeated string payees = 4;
}
```

**步骤**

- 从 `feedId` 获取 feed 配置并确保 feed 配置存在
- 确保 `msg.Sender` 是 feed 管理员
- 遍历 `msg.Transmitters`，
- 1. 确保已为传输者设置收款人
- 2. 为传输者设置收款人

## Msg/TransferPayeeship

`MsgTransferPayeeship` 是转移 feed 特定传输者收款权的消息。执行后，将创建待处理的收款权对象。

```protobuf
message MsgTransferPayeeship {
  option (gogoproto.equal) = false;
  option (gogoproto.goproto_getters) = false;

  // transmitter address of oracle whose payee is changing
  string sender = 1;
  string transmitter = 2;
  string feed_id = 3;
  // new payee address
  string proposed = 4;
}
```

**步骤**

- 从 `feedId` 获取 feed 配置并确保 feed 配置存在
- 确保 msg.Sender 是当前收款人
- 检查之前的待处理收款权转移记录，确保之前的收款权转移不冲突
- 设置收款权转移记录

## Msg/AcceptPayeeship

`MsgAcceptPayeeship` 是接受 feed 特定传输者收款权的消息。

```protobuf
message MsgAcceptPayeeship {
  option (gogoproto.equal) = false;
  option (gogoproto.goproto_getters) = false;
  // new payee address
  string payee = 1;
  // transmitter address of oracle whose payee is changing
  string transmitter = 2;
  string feed_id = 3;
}
```

**步骤**

- 从 `feedId` 获取 feed 配置并确保 feed 配置存在
- 获取 `msg.Transmitter` 和 `feedId` 的待处理收款权转移记录
- 重置 `feedId` 和 `transmitter` 的收款人
- 删除 `feedId` 的 `transmitter` 的待处理收款权转移
