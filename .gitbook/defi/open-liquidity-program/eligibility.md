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

* 示例：地址 `biya1a` 在第 21 周期开始时没有 OLP 奖励资格。`biya1a` 在第 21 周期的第 1、2、3 天分别占[合格市场](./eligible-markets.md)每日交易所做市总交易量的 1%、0.1% 和 0.2%。在第 4、5、6 天，`biya1a` 每天占适用交易量的 0.5%。`biya1a` 在第 7 天获得资格。为了保持第 22 周期的资格/预资格认定，`biya1a` 必须从第 21 周期的第 7 天到第 28 天占累计适用做市交易量的至少 0.25%。如果[合格市场](./eligible-markets.md)在此期间（第 7 天至第 28 天）的累计做市交易量为 $100M，那么 `biya1a` 必须在同一期间在这些市场中占 $250,000 的累计做市交易量。

如果地址通过前一周期的预资格认定在整个周期内都有资格，则该地址必须占整个周期内[合格市场](./eligible-markets.md)做市交易量的至少 0.25%。&#x20;

* 示例：地址 `biya1a` 通过保持第 21 周期的资格而预获得第 22 周期的资格。假设第 22 周期内[合格市场](./eligible-markets.md)的累计做市交易量总计 $200M。那么 `biya1a` 必须在第 22 周期结束前在[合格市场](./eligible-markets.md)中贡献至少 $500,000 的 $200M 交易量，以保持第 23 周期的自动资格。

## 取消资格

**任何在周期内未能占适用做市交易量至少 0.25% 的地址将在下一周期开始时被取消 OLP 资格**。如果地址希望重新加入计划，地址必须再次通过[全新资格认定过程](eligibility.md#clean-slate-qualification)（尽管地址不必再次退出 T\&E）。请注意，地址在不符合资格的日子里贡献的任何流动性在地址重新获得资格后不会追溯奖励。

{% hint style="info" %}
取消资格发生在每个周期结束时，这意味着地址在周期内继续累积奖励，无论下一周期的资格如何。
{% endhint %}

