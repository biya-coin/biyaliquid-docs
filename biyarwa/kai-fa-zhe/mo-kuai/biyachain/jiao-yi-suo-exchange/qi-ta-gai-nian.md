# 其他概念

## 并发友好的市场订单清算价格算法

我们应用[拆分-应用-合并](https://stackoverflow.com/tags/split-apply-combine/info)范式来利用并发进行高效的数据处理。

1. 在所有市场中并发匹配所有可匹配的订单（详细信息见订单匹配）。

* 中间结果是清算价格和已匹配订单的列表，包括它们的成交数量。
* 最终结果是所有新事件的临时缓存，以及所有位置、订单、子账户存款、交易奖励积分和已支付费用的更改。

2. 等待所有市场的执行并持久化所有数据。

注意：除了执行结算外，设计还必须考虑市场数据传播的需求，以供链下消费。

## 原子市场订单执行

一个常见的请求是，基于Cosmwasm构建的新应用程序希望在订单执行时收到通知。在常规的订单执行流程中，这是不可能的，因为频繁批量拍卖（FBA）是在EndBlocker内执行的。为了绕过FBA，介绍了一种新的原子市场订单类型。为了能够即时执行这种原子市场订单，需要额外的交易费用。计算原子市场订单费用时，市场的taker费用会乘以市场类型的AtomicMarketOrderFeeMultiplier。

* `SpotAtomicMarketOrderFeeMultiplier`
* `DerivativeAtomicMarketOrderFeeMultiplier`
* `BinaryOptionsAtomicMarketOrderFeeMultiplier`

这些乘数由全球交易所参数定义。此外，交易所参数还定义了AtomicMarketOrderAccessLevel，指定执行原子市场订单所需的最低访问级别。

```golang
const (
	AtomicMarketOrderAccessLevel_Nobody                         AtomicMarketOrderAccessLevel = 0
	AtomicMarketOrderAccessLevel_BeginBlockerSmartContractsOnly AtomicMarketOrderAccessLevel = 1
	AtomicMarketOrderAccessLevel_SmartContractsOnly             AtomicMarketOrderAccessLevel = 2
	AtomicMarketOrderAccessLevel_Everyone                       AtomicMarketOrderAccessLevel = 3
)
```

## 交易奖励

治理通过批准一个 **TradingRewardCampaignLaunchProposal** 提交，该提案指定：

* 第一个活动的开始时间戳
* TradingRewardCampaignInfo，其中指定：
  * 活动持续时间（秒）
  * 接受的交易手续费报价货币符号
  * 可选的市场特定的加成信息
  * 排除的市场ID，这些市场的交易将无法获得奖
* **CampaignRewardPools**，指定每个连续活动的最大时期奖励，这构成了每个活动的交易奖励池

在每个活动期间，交易所将记录每个交易者从所有合格市场获得的累计交易奖励积分（如果适用，加成会被应用），即报价货币匹配且不在排除列表中的市场。

在每个活动结束时，即`活动开始时间戳 + 活动持续时间`经过后，每个交易者将根据其在该活动时期的交易奖励积分，按比例获得交易奖励池的份额。

活动不会自动续期。如果在 CampaignRewardPools 中没有定义额外的活动，则交易奖励活动将结束。

## 费用折扣

治理通过批准一个 FeeDiscountProposal 提交，该提案定义了一个费用折扣计划，其中指定了折扣阶梯，每个阶梯都规定了如果交易者满足指定的最低 BIYA 持仓量，并且在指定的时间段内（`桶数 * 桶持续时间秒数，通常为 30 天`）完成了至少指定交易量（基于指定的报价货币符号），交易者将获得的做市商和吃单者折扣率。该计划还指定了一个排除的市场ID列表，这些市场的交易量将不计入交易量贡献。

* 在被接受的报价货币符号列表中的现货市场，基础资产和报价资产都属于该列表的市场将不会获得奖励（例如，USDC/USDT 现货市场）。
* 在具有负做市商费用的市场中，做市商的成交不会为交易者提供任何费用折扣。
* 如果费用折扣提案通过的时间少于 30 天，即提案创建以来还没有经过 BucketCount \* BucketDuration（30 天），那么费用交易量要求将被忽略，以避免对立即入驻的做市商进行不公平的惩罚。

内部的交易量存储在桶中，通常有 30 个桶，每个桶持续 24 小时。当某个桶超过 30 天时，它将被移除。此外，为了提高性能，会缓存一个账户的费用折扣阶梯，该缓存每 24 小时更新一次。
