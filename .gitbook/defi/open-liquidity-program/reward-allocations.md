---
description: OLP 奖励分配（第 43 周期起）
---

# 奖励分配

## 市场奖励分配

奖励通过三种不同方法分配给[合格市场](eligible-markets.md)：

1. 静态分配
2. 具有动态成分的最低分配
3. 灵活奖励分配

### 静态市场奖励分配（预分配）

12.5% 的 BIYA 奖励将预分配给 BTC/USDT PERP 市场、ETH/USDT PERP 市场和 BIYA/USDT PERP 市场。周期的剩余 BIYA 将分配给每个剩余的合格市场，最低分配为 100 BIYA。

<table><thead><tr><th width="165.875">市场</th><th>分配（至第 51 周期）</th><th>分配（从第 52 周期起）</th></tr></thead><tbody><tr><td>BTC/USDT Perp</td><td>12.5%</td><td>13.33%</td></tr><tr><td>ETH/USDT Perp</td><td>12.5%</td><td>13.33%</td></tr><tr><td>BIYA/USDT Perp</td><td>12.5%</td><td>13.33%</td></tr><tr><td>BIYA/USDT Spot</td><td>5%</td><td>5%</td></tr><tr><td>其他合格市场</td><td>基于公式的分配（见下文）</td><td></td></tr></tbody></table>

{% hint style="info" %}
随着更多市场添加到合格列表，静态分配可能会随时间变化
{% endhint %}

### 动态市场奖励分配

剩余奖励根据以下方案分配给合格市场（不包括 BTC/ETH/BIYA 永续合约）。

首先，每个周期都是全新的，这样每个交易对都有平等的机会获得该周期的最大可用总奖励，无论前一周期的交易量和流动性如何。每个交易对在周期的第 1 天开始时都有一个可能性范围，从周期最低 100 BIYA 开始。

在此更改之前，最低奖励为 400 BIYA，最高奖励约为 900 BIYA，低交易量交易对和交易量明显更多的交易对之间的奖励累积变化不足。通过此更改，流动性提供者因在热门市场中的交易量而获得奖励。

每个市场的奖励范围将在整个周期内推进，在周期的最后一天收敛到该市场的真实奖励。范围 $$[Rewards_{min};Rewards_{max}]$$ 将按市场定义如下：

$$
MinVolume=Min(Market\ traded\ volume\ since\ beginning\ of\ epoch) \\
MaxVolume=Max(Market\ traded\ volume\ since\ beginning\ of\ epoch)
$$

其中

$$
Rewards_{min_{market\ i}}=100+\frac{Volume_{market_{i}}-MinVolume}{MaxVolume-MinVolume}(Rewards_{max}-100)
$$

$$Rewards_{max}$$ 仍按本页底部的计算方式计算。因此，交易量最高的市场将获得 $$Rewards_{max}$$，交易量最低的市场将获得最低 100 BIYA 的奖励。

必须注意的是，$$Rewards_{min}$$ 只是奖励范围的下限，它永远不会等于奖励，除非是交易量最高的市场，其范围将是平凡的 $$[Rewards_{max};Rewards_{max}]$$，在这种情况下奖励将等于 $$Rewards_{max}$$。这是一个从 100 BIYA 到 $$Rewards_{max}$$ 的线性函数。

定义此范围后，计算市场奖励的步骤是：

1\) 从 $$Rewards_{Market_{i}}=Rewards_{min_{market\ i}}$$ 开始

2\) 分配剩余奖励 _RR_，其中 $$RR=TAR-\sum_{i}Rewards_{min_{market\ i}}$$，使用上述公式。

3\) 对于任何超过 $$Rewards_{max}$$ 的计算奖励，按照上述公式在所有市场中重新分配。

4\) 迭代直到没有剩余奖励。

**周期中途添加的市场**

对于在周期中途添加到合格列表的市场，预分配将按比例分配。例如，如果 ARB/USDT 在周期的第 15 天添加，则该市场将获得周期奖励的一半（因为 28 天中还有 14 个完整天）。

### 市场分配上限

对于具有动态奖励分配的每个市场，将根据以下公式应用硬上限，其中 $$n$$ 是排除 BTC、ETH 和 BIYA 永续合约的合格市场数量：

$$
Rewards_{max} = TAR\ *\ \frac{1 - TPR}{n}*2
$$

其中 _TPR_ 等于总预分配奖励的百分比（以小数表示，目前为 0.375），_n_ 是非预分配交易对的数量。

任何超过上限的奖励分配将根据[动态分配公式](reward-allocations.md#dynamic-market-reward-allocations)在其他合格市场中重新分配。

## 奖励分配

对个人机构流动性提供者的奖励将根据以下公式分配：

$$
Rewards_{MM_i} = \sum_{Market}\left(Rewards_{Market} * \frac {TS_{MM_i, \ Market}} {\sum_{MM} TS_{MM,\ Market}} \right)
$$

**每个机构流动性提供者将根据其在市场中的比例**[ $$TS$$ ](scoring.md#total-score)**获得奖励，需经治理批准。**

{% hint style="info" %}
每个周期结束时总计 < 1 BIYA 的地址奖励将被忽略，以减少发放过程的开销。
{% endhint %}
