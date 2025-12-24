---
sidebar_position: 8
title: BeginBlocker
---

# BeginBlock

交易所 BeginBlocker 在每个区块开始时运行，在我们的定义顺序中作为最后一个模块。

### 1. 处理每小时资金费率

1. 检查第一个接收资金费率支付的市场。如果第一个市场尚未到期接收资金费率（资金费率时间戳未到达），则跳过所有资金费率。
2. 否则逐个遍历每个市场：
   1. 如果资金费率时间戳尚未到达，则跳过市场。
   2. 计算资金费率为 `twap + hourlyInterestRate`，其中 $$twap = \frac{cumulativePrice}{timeInterval * 24}$$，其中 _timeInterval = lastTimestamp - startingTimestamp_。`cumulativePrice` 之前通过每笔交易计算，作为 VWAP 和标记价格之间的时间加权差：$${\frac{VWAP - markPrice}{markPrice} * timeElapsed}$$。
   3. 如果需要，将资金费率限制为 `HourlyFundingRateCap` 定义的最大值。
   4. 设置下一个资金费率时间戳。
   5. 发出 `EventPerpetualMarketFundingUpdate`。

### 2. 处理计划结算的市场

对于要结算的市场列表中的每个市场：

1. 以零平仓费用和当前标记价格结算市场。
   1. 运行社会化损失。这将计算市场中所有缺失资金的总金额，然后按比例减少每个盈利持仓的支付。例如，一个市场总共缺失 100 USDT 资金，有 10 个数量相同的盈利持仓，每个持仓的支付将减少 10 USDT。
   2. 所有持仓被强制平仓。
2. 从存储中删除。

### 3. 处理交易奖励

1. 检查当前交易奖励活动是否已完成。
2. 如果活动已完成，向符合条件的交易者分发奖励代币。
   1. 将每个奖励 denom 的可用奖励计算为 `min(campaignRewardTokens, communityPoolRewardTokens)`
   2. 根据各自交易者的交易份额获取交易者奖励，计算为 `accountPoints * totalReward / totalTradingRewards`。
   3. 从社区池向交易者发送奖励代币。
   4. 重置总额和所有账户交易奖励积分。
   5. 删除当前活动结束时间戳。
3. 如果启动了新活动，将下一个当前活动结束时间戳设置为 `CurrentCampaignStartTimestamp + CampaignDurationSeconds`。
4. 如果没有正在进行的当前活动且没有启动新活动，则从存储中删除活动信息、市场资格和市场乘数。

### 4. 处理费用折扣桶

* 如果最旧的桶的结束时间戳早于 `block.timestamp - bucketCount * bucketDuration`：
  * 修剪最旧的桶
  * 遍历所有 `bucketStartTimestamp + account → FeesPaidAmount`：
    * 从每个账户的 `totalPastBucketFeesPaidAmount` 中减去 `FeesPaidAmount`
    * 删除账户的 `account → {tier, TTL timestamp}`。请注意，这在技术上对于正确性不是必需的，因为我们在 Endblocker 中检查 TTL 时间戳，但这是一个状态修剪策略。
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
