---
sidebar_position: 3
title: Other Concepts
---

# 其他概念

## 并发友好的市价单清算价格算法

我们应用[拆分-应用-合并](https://stackoverflow.com/tags/split-apply-combine/info)范式来利用\
并发进行高效的数据处理。

1. 在所有市场中并发匹配所有可匹配的订单（有关订单匹配的详细信息，请参见订单匹配）。

* 中间结果是清算价格和匹配订单列表及其成交数量。
* 最终结果是所有新事件的临时缓存以及对持仓、订单、子账户存款、\
  交易奖励积分和已支付费用的所有更改。

2. 等待所有市场的执行并持久化所有数据。

注意：除了执行结算之外，设计还必须考虑链下消费的市场数据传播要求。

## 原子市价单执行

基于 Cosmwasm 构建的新应用程序的一个常见需求是能够在订单执行时收到通知。\
在常规订单执行流程中，这是不可能的，因为频繁批量拍卖（FBA）在 EndBlocker 内部执行。\
为了绕过 FBA，引入了新型原子市价单。为了立即执行此类原子市价单的特权，\
需要支付额外的交易费用。要计算原子市价单的费用，市场的吃单费用乘以市场类型的 `AtomicMarketOrderFeeMultiplier`。

* `SpotAtomicMarketOrderFeeMultiplier`
* `DerivativeAtomicMarketOrderFeeMultiplier`
* `BinaryOptionsAtomicMarketOrderFeeMultiplier`

这些乘数在全局交易所参数中定义。此外，交易所参数还定义 `AtomicMarketOrderAccessLevel`，\
它指定执行原子市价单所需的最低访问级别。

```golang
const (
	AtomicMarketOrderAccessLevel_Nobody                         AtomicMarketOrderAccessLevel = 0
	AtomicMarketOrderAccessLevel_BeginBlockerSmartContractsOnly AtomicMarketOrderAccessLevel = 1
	AtomicMarketOrderAccessLevel_SmartContractsOnly             AtomicMarketOrderAccessLevel = 2
	AtomicMarketOrderAccessLevel_Everyone                       AtomicMarketOrderAccessLevel = 3
)
```

## 交易奖励

治理批准 **TradingRewardCampaignLaunchProposal**，它指定：

* 第一个活动的开始时间戳
* **TradingRewardCampaignInfo**，它指定
  * 活动持续时间（秒）
  * 接受的交易费用报价货币 denoms
  * 可选的特定市场**提升**信息
  * 不符合条件的市场 ID，在这些市场中的交易不会获得奖励
* **CampaignRewardPools**，它指定构成每个连续活动的交易奖励池的最大周期奖励

在给定活动期间，交易所将记录每个交易者从所有符合条件的市场（即具有匹配报价货币且不在不符合条件列表中的市场）\
的交易量（如果适用，应用提升）获得的累计交易奖励积分。

在每个活动结束时，即在 `活动开始时间戳 + 活动持续时间` 过去之后，\
每个交易者将根据他们在该活动周期中的交易奖励积分，按比例获得交易奖励池的百分比。

活动不会自动滚动。如果 **CampaignRewardPools** 中没有定义其他活动，交易奖励活动将结束。

## 费用折扣

治理批准 **FeeDiscountProposal**，它定义费用折扣**计划**，该计划指定费用折扣**层级**，\
每个层级指定如果交易者满足指定的最低 BIYA 质押数量并且在指定时间段内（`桶数量 * 桶持续时间秒`，\
应等于 30 天）至少具有指定的交易量（基于指定的**报价 denoms**），交易者将获得的做市商和吃单折扣率。\
该计划还指定不符合条件的市场 ID 列表，这些市场的交易量不会计入交易量贡献。

* 基础资产和报价资产都在接受的报价货币列表中的现货市场将不会获得奖励（例如 USDC/USDT 现货市场）。
* 具有负做市商费用的市场中的做市商成交不会给交易者任何费用折扣。
* 如果费用折扣提案在不到 30 天前通过，即自提案创建以来 `BucketCount * BucketDuration` 尚未过去，\
  则忽略费用交易量要求，这样我们就不会不公平地惩罚立即上线的做市商。

内部交易量存储在桶中，通常 30 个桶，每个持续 24 小时。当桶超过 30 天时，它会被删除。\
此外，出于性能原因，有一个用于检索账户费用折扣层级的缓存。此缓存每 24 小时更新一次。

### 质押委托/授权

费用折扣层级的质押 BIYA 要求可以通过已质押其 BIYA 的其他地址的授权来满足。\
用于费用折扣计算的质押 BIYA 总值为 `OwnStake + StakeGrantedFromGranter - TotalStakeGrantedToOthers`。\
请注意，虽然可以向单个地址进行多次授权，但**一次只能激活一个授权**。\
但是，单个地址可以同时向其他地址进行多次授权。\
请注意，只有与 25 个验证者质押的 BIYA 用于计算 `OwnStake` 以用于质押授权目的。\
为确保所有质押的 BIYA 都可以用于授权，请与 25 个或更少的验证者质押。已授权的质押不能重新授权。
