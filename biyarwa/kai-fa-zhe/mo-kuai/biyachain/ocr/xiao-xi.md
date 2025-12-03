# 消息

在本节中，我们描述了 OCR 消息的处理过程及其对状态的相应更新。

## Msg/CreateFeed

MsgCreateFeed 是用于创建 Feed 配置的消息，它是一个受限制的消息，仅能由模块管理员执行。

```protobuf
message MsgCreateFeed {
  option (gogoproto.equal) = false;
  option (gogoproto.goproto_getters) = false;
  string sender = 1;
  FeedConfig config = 2;
}
```

步骤：

1. 确保发送者是模块管理员。
2. 确保 msg.Config.OnchainConfig.LinkDenom 与模块参数中的 LinkDenom 匹配。
3. 从 ctx.ChainID 设置 OnchainConfig.ChainId。
4. 确保相同 FeedId 的 FeedConfig 不存在。
5. 将最新的 EpochAndRound 设置为 (0, 0)。
6. 设置给定 FeedId 的 Feed 配置。
7. 将 Feed 传输计数和观测计数设置为 1。

## Msg/UpdateFeed

MsgCreateFeed 是用于更新 Feed 配置的消息，它是一个受限制的消息，仅能由 Feed 管理员或 Feed 计费管理员执行。

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

步骤：

1. 根据 FeedId 获取之前的 Feed 配置，并确保其存在。
2. 确保发送者是 Feed 管理员或 Feed 计费管理员。
3. 确保计费管理员未更改签名者、传输者和 Feed 管理员。
4. 处理之前的 Feed 配置的奖励支付。
5. 删除之前的 Feed 传输和观测计数。
6. 将最新的 EpochAndRound 设置为 (0, 0)。
7. 如果设置了，则更新签名者、传输者、LinkPerObservation、LinkPerTransmission、LinkDenom、FeedAdmin 和 BillingAdmin。

## Msg/Transmit

MsgTransmit 是用于传输特定 Feed 的报告的消息。在广播该消息时，必须有足够的观察者签名才能被接受。

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

步骤：

1. 获取 feedId 的 epoch 和 round。
2. 通过检查 msg.Epoch 和 msg.Round 确保报告不是过期的。
3. 从 feedId 获取 Feed 配置和配置信息。
4. 检查 msg.ConfigDigest 是否等于 Feed 配置信息的最新配置摘要。
5. 检查传输者是否是 FeedConfig 中配置的有效传输者。
6. 保存传输者的报告。
7. 触发传输事件。
8. 验证签名及签名数量。
9. 增加 Feed 的观测和传输计数。

## Msg/FundFeedRewardPool

MsgFundFeedRewardPool 是一条消息，用于向 Feed 奖励池中添加资金，这些资金将分配给传输者和观察者。

```protobuf
message MsgFundFeedRewardPool {
  option (gogoproto.equal) = false;
  option (gogoproto.goproto_getters) = false;

  string sender = 1;
  string feed_id = 2;
  cosmos.base.v1beta1.Coin amount = 3 [(gogoproto.nullable) = false];
}
```

步骤：

1. 获取 feedId 的之前奖励池金额。
2. 如果之前的金额为空，则将池金额初始化为零。
3. 确保之前的金额 denom 与存款 denom 相同（如果存在）。
4. 从账户向模块账户（OCR 模块）发送币。
5. 使用金额字段增加更新奖励池金额。
6. 如果设置了钩子，则调用 AfterFundFeedRewardPool 钩子。

## Msg/WithdrawFeedRewardPool

MsgFundFeedRewardPool 是一条消息，用于从 Feed 奖励池中提取资金，仅限 Feed 管理员或计费管理员执行。

```protobuf
message MsgWithdrawFeedRewardPool {
  option (gogoproto.equal) = false;
  option (gogoproto.goproto_getters) = false;

  string sender = 1;
  string feed_id = 2;
  cosmos.base.v1beta1.Coin amount = 3 [(gogoproto.nullable) = false];
}
```

步骤：

1. 获取 feedId 的 Feed 配置。
2. 确保 msg.Sender 是 Feed 管理员或计费管理员。
3. 为 Feed 处理奖励。
4. 从模块账户中提取指定金额 msg.Amount。

## Msg/SetPayees

MsgSetPayees 是一条消息，用于为传输者设置支付方，仅限 Feed 管理员执行。一旦设置，只有支付方才能更改。

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

步骤：

1. 获取 feedId 的 Feed 配置，并确保 Feed 配置存在。
2. 确保 msg.Sender 是 Feed 管理员。
3. 遍历 msg.Transmitters，
   1. 确保传输者已经设置了支付方。
   2. 为传输者设置支付方。

## Msg/TransferPayeeship

MsgTransferPayeeship 是一条消息，用于转移特定传输者的 Feed 支付权。在执行后，将创建一个待处理的支付权对象。

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

步骤：

1. 获取 feedId 的 Feed 配置，并确保 Feed 配置存在。
2. 确保 msg.Sender 是当前的支付方。
3. 检查之前的待处理支付权转移记录，确保之前的支付权转移不会冲突。
4. 设置支付权转移记录。

## Msg/AcceptPayeeship

MsgTransferPayeeship 是一条消息，用于接受特定传输者的 Feed 支付权。

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

步骤：

1. 获取 feedId 的 Feed 配置，并确保 Feed 配置存在。
2. 获取 msg.Transmitter 和 feedId 的待处理支付权转移记录。
3. 重置 feedId 和传输者的支付方。
