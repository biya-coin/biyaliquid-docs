# 钩子(Hooks)

其他模块可以注册操作，以便在ocr模块内发生特定事件时执行。以下钩子可以在ocr中注册：

* `AfterSetFeedConfig(ctx sdk.Context, feedConfig *FeedConfig)`
  * 在feed配置创建或更新后调用
* `AfterTransmit(ctx sdk.Context, feedId string, answer math.LegacyDec, timestamp int64)`
  * 在信息传输时调用
* `AfterFundFeedRewardPool`(`ctx sdk.Context, feedId string, newPoolAmount sdk.Coin`)
  * 在feed奖励池更新时调用

注意：`oracle`模块接受`AfterTransmit`钩子，用于在传输时存储累计价格。
