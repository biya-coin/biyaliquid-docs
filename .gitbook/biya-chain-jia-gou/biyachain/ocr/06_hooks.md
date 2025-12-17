---
sidebar_position: 6
---

# 钩子

其他模块可以注册操作，以便在 ocr 模块内发生某些事件时执行。以下钩子可以在 ocr 中注册：

* `AfterSetFeedConfig(ctx sdk.Context, feedConfig *FeedConfig)`
  * 在创建或更新 feed 配置后调用
* `AfterTransmit(ctx sdk.Context, feedId string, answer math.LegacyDec, timestamp int64)`
  * 在传输信息时调用
* `AfterFundFeedRewardPool(ctx sdk.Context, feedId string, newPoolAmount sdk.Coin)`
  * 在更新 feed 奖励池时调用

注意：`oracle` 模块接受 `AfterTransmit` 钩子，以便在传输时存储累积价格。
