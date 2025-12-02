# BeginBlock

交易所的 [BeginBlocker](https://docs.cosmos.network/master/building-modules/beginblock-endblock.html) 在每个区块的开始运行，作为我们定义顺序中的最后一个模块。

## 1. 处理每小时资金支付

1. 检查第一个接收资金支付的市场。如果第一个市场尚未到期接收资金（资金时间戳尚未达到），则跳过所有资金支付。
2. 否则逐一检查每个市场：
   1. 如果资金时间戳尚未到期，跳过该市场。
   2. 计算资金，公式为 `twap + hourlyInterestRate，其中 $\mathrm{twap = \frac{cumulativePrice}{timeInterval * 24}}$`，其中 `$\mathrm{timeInterval = lastTimestamp - startingTimestamp}$`。cumulativePrice 是通过每笔交易计算的加权时间差：`$\mathrm{\frac{VWAP - markPrice}{markPrice} * timeElapsed}$。`
   3. 如果需要，将资金限制在 `HourlyFundingRateCap` 定义的最大值。
   4. 设置下一个资金时间戳。
   5. 发出 `EventPerpetualMarketFundingUpdate` 事件。

## 2. 处理计划结算的市场

对于待结算的每个市场：

1. 使用零结算费用和当前标记价格结算市场。
   1. 运行社会化损失。这将计算所有市场中缺少的资金总额，然后按比例减少每个盈利头寸的支付。例如，一个市场缺少100 USDT的资金，且有10个相同数量的盈利头寸，则每个头寸的支付将减少10 USDT。
   2. 所有头寸都将被强制平仓。
2. 从存储中删除。

## 3. 处理到期的期货市场

对于每个到期的期货市场，从第一个到期的市场开始迭代：

1. 如果市场是过早的，停止迭代。
2. 如果市场已禁用，从存储中删除市场并继续下一个市场。
3. 从预言机获取该市场的累积价格。
4. 如果市场开始成熟，存储该市场的 `startingCumulativePrice`。
5. 如果市场已成熟，计算结算价格为 `$\mathrm{twap = (currentCumulativePrice - startingCumulativePrice) / twapWindow}$`，并将其添加到待结算市场列表中。\
   使用定义的结算费用和结算价格结算所有成熟的市场。该过程与之前的结算过程相同（见上文）。注意，社会化损失是一个可选步骤。在常规情况下，市场不需要任何社会化损失。
6. 从存储中删除所有已结算的市场。

## 4. 处理交易奖励

1. 检查当前交易奖励活动是否已结束。
2. 如果活动已结束，向符合条件的交易员分发奖励代币。
   1. 计算每种奖励币种的可用奖励，公式为 `min(campaignRewardTokens, communityPoolRewardTokens)`。
   2. 根据交易份额计算每个交易员的奖励，公式为 `accountPoints * totalReward / totalTradingRewards`。
   3. 从社区池中向交易员发送奖励代币。
   4. 重置所有账户的交易奖励积分和总积分。
   5. 删除当前活动的结束时间戳。
3. 如果启动新活动，设置下一个当前活动结束时间戳为 `CurrentCampaignStartTimestamp + CampaignDurationSeconds`。
4. 如果没有进行中的活动，也没有启动新活动，从存储中删除活动信息、市场资格和市场倍数。

## 5. 处理费用折扣桶

* 如果最旧的桶的结束时间戳早于 `block.timestamp - bucketCount * bucketDuration`：
  * 修剪最旧的桶。
  * 遍历所有的 `bucketStartTimestamp + account → FeesPaidAmount`：
    * 从每个账户的 `totalPastBucketFeesPaidAmount` 中减去 `FeesPaidAmount。`
    * 删除账户的 `account → {tier, TTL timestamp}`。注意，技术上这对于正确性并不是必须的，因为我们会在 Endblocker 中检查 TTL 时间戳，但这是一种状态修剪策略。
  * 更新 `CurrBucketStartTimestamp ← CurrBucketStartTimestamp + BucketDuration`。

```
bucket count 5 and with 100 sec duration

120 220 320 420 520          220 320 420 520 620
 |   |   |   |   |   |  -->   |   |   |   |   |   |
   1   2   3   4   5            1   2   3   4   5

Current block.timestamp of 621:
621 - 5*100 = 121
120 is older than 121, so prune the last bucket and create a new bucket.
```
