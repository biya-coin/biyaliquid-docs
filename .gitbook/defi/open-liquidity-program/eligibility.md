---
description: 如何获得并保持 OLP 奖励资格
---

# 资格

## 全新资格认定

Biyaliquid 地址可以通过满足以下条件来获得 OLP 资格：

* **地址必须在资格认定过程开始之前退出交易与赚取 (T\&E) 计划**。地址在资格认定过程中不会获得 T\&E 奖励。有关以编程方式退出的示例，请参阅 [Python](https://github.com/biya-coin/sdk-python/blob/master/examples/chain_client/24_MsgRewardsOptOut.py)、[Go](https://github.com/biya-coin/sdk-go/blob/master/examples/chain/24_MsgRegisterAsDMM/example.go) 和 [TS](https://github.com/biya-coin/biyaliquid-ts/wiki/04CoreModulesExchange#msgrewardsoptout)。
  * 注意：资格认定过程的资格从退出完成后的第二天 00:00 UTC 开始。
* 地址的做市交易量必须**连续 3 天**在同一周期内占[**合格市场**](eligible-markets.md)的**每日交易所做市总交易量的至少 0.25%**。严格禁止自交易。

假设这两个要求都已满足，地址将在第 4 天 00:00 UTC 获得 OLP 奖励资格。一旦获得资格，地址将在周期的剩余时间内保持奖励资格，除非特殊情况（例如滥用系统、洗盘交易等）导致地址被移除。请注意，资格认定前的活动不会计入奖励。

{% hint style="warning" %}
将交易策略整合到单个地址以增加做市交易量可能是明智的。否则，做市交易量低于所需阈值的地址将没有资格获得奖励，即使多个地址之间的总交易量超过阈值。

有关从单个地址执行多个策略同时保留交易[费用折扣](https://helixapp.com/fee-discounts)的方法，请参阅 [Biyaliquid `authz` 模块文档](https://docs.biyaliquid.network/develop/modules/Core/authz/)。
{% endhint %}

## 保持下一周期资格/预资格认定

要在获得当前周期资格后自动获得下一周期资格，**地址必须从资格认定日期到周期最后一天占**[合格市场](eligible-markets.md)**（不包括 KAVA 奖励市场）的至少 0.25% 的交易所做市总交易量**。

* Example: Address `biya1a` enters epoch 21 ineligible for OLP rewards. `biya1a` accounts for 1%, 0.1%, and 0.2% of total daily exchange maker volume of [eligible markets](eligible-markets.md) on days 1, 2, and 3 of epoch 21, respectively. On days 4, 5, and 6, `biya1a` accounts for 0.5% of the applicable volume each day. `biya1a` qualifies on day 7 of the epoch. To maintain eligibility/qualification for epoch 22, `biya1a` must account for at least 0.25% of the cumulative applicable maker volume from day 7 through day 28 of epoch 21. If the cumulative maker volume of [eligible markets](eligible-markets.md) for this period (days 7 through 28) was $100M, then `biya1a` must account for $250,000 of cumulative maker volume in those markets within the same period.

If the address was eligible for the entire epoch through a previous epoch's pre-qualification, that address must account for at least 0.25% of the maker volume of [eligible markets](eligible-markets.md) in the entire epoch.

* Example: Address `biya1a` enters epoch 22 prequalified from maintaining eligibility in epoch 21. Suppose the cumulative maker volume of [eligible markets](eligible-markets.md) in epoch 22 totals $200M. Then `biya1a` must contribute at least $500,000 of the $200M in [eligible markets](eligible-markets.md) by the end of epoch 22 to maintain automatic eligibility for epoch 23.

## 取消资格

**任何在周期内未能占适用做市交易量至少 0.25% 的地址将在下一周期开始时被取消 OLP 资格**。如果地址希望重新加入计划，地址必须再次通过[全新资格认定过程](eligibility.md#clean-slate-qualification)（尽管地址不必再次退出 T\&E）。请注意，地址在不符合资格的日子里贡献的任何流动性在地址重新获得资格后不会追溯奖励。

{% hint style="info" %}
取消资格发生在每个周期结束时，这意味着地址在周期内继续累积奖励，无论下一周期的资格如何。
{% endhint %}

## 跟踪资格

可以使用 [OLP 仪表板](https://trading.biyaliquid.network/program/liquidity/eligibility)跟踪当前和未来周期的奖励资格。

{% embed url="https://trading.biyaliquid.network/program/liquidity/eligibility" %}
