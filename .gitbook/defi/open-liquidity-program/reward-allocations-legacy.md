---
description: OLP 奖励分配（至第 42 周期）
hidden: true
---

# 旧版奖励分配

## 市场奖励分配

奖励通过两种不同方法分配给[合格市场](eligible-markets.md)：

1. 静态分配
2. 具有动态成分的静态分配

### 静态市场奖励分配（预分配）

12.5% 的 BIYA 奖励将预分配给 BTC/USDT PERP 市场、ETH/USDT PERP 市场和 BIYA/USDT PERP 市场。1% 将预分配给每个剩余的合格市场作为最低分配：

| 市场                 | 总分配                                                                       |
| ---------------------- | -------------------------------------------------------------------------------------- |
| BTC/USDT Perp          | 12.5%                                                                                  |
| ETH/USDT Perp          | 12.5%                                                                                  |
| BIYA/USDT Perp          | 12.5%                                                                                  |
| 其他合格市场 | 每个 1% + 基于公式的分配，奖励上限基于公式（见下表） |

{% hint style="info" %}
随着更多市场添加到合格列表，静态分配可能会随时间变化
{% endhint %}

### 动态市场奖励分配

剩余奖励将根据以下公式分配给合格市场（不包括 BTC/ETH/BIYA 永续合约）：

$$
Rewards_{Market_i} = TAR * Preallocation_{Market_i} + TAR * (1- Preallocation_{Total}) *\newline \frac {\sum\limits_{MM} (LS_{MM,\  Market_i})^{0.7} * Volume_{MM,\  Market_i}} {\sum\limits_{Market}\sum\limits_{MM} (LS_{MM,\ Market})^{0.7}*Volume_{MM,\ Market}}
$$

$$
\text{其中} \quad Preallocation_{Total} = 0.125+0.125+0.125+Other\  Preallocations
$$

$$
\text{且} \quad TAR = Total\ Available\ Rewards
$$

{% hint style="info" %}
$$Other\ Preallocations$$ 指的是非 BTC、ETH 和 BIYA 永续合约市场的静态市场奖励分配。

有关每个周期 $$TAR$$ 的更多信息，请参阅[奖励池](rewards.md)页面。
{% endhint %}

对于每个合格市场，做市商[^1] 的 $$LS^{0.7}$$ 和 $$Volume$$ 的乘积在所有做市商中聚合。奖励根据所有适用市场的比例聚合乘积分配给每个市场。市场的预分配金额（1%）也会加入。

#### 周期中途添加的市场

对于在周期中途添加到合格列表的市场，1% 的预分配将按比例分配。例如，如果 ARB/USDT 在周期的第 15 天添加，则该市场将获得 0.5% 的预分配（28 天中还有 14 天。如果还有 17 天，则该市场将获得 $$\frac {17}{28} * 0.01$$）。

### 市场分配上限

对于具有动态奖励分配的每个市场，将根据以下公式应用硬上限，其中 $$n$$ 是排除 BTC、ETH 和 BIYA 永续合约的合格市场数量：

$$
Rewards_{max} = TAR\ *\ \frac{1 - 0.375}{n}*2
$$

任何超过上限的奖励分配将根据[动态分配公式](reward-allocations-legacy.md#dynamic-market-reward-allocations)在其他合格市场中重新分配。

<table><thead><tr><th width="417" align="center">排除 BTC/ETH/BIYA 永续合约的合格市场数量</th><th>奖励上限</th></tr></thead><tbody><tr><td align="center">6</td><td>总可用奖励的 20.83%</td></tr><tr><td align="center">7</td><td>总可用奖励的 17.86%</td></tr><tr><td align="center">8</td><td>总可用奖励的 15.63%</td></tr><tr><td align="center">9</td><td>总可用奖励的 13.89%</td></tr><tr><td align="center">10</td><td>总可用奖励的 12.50%</td></tr><tr><td align="center">11</td><td>总可用奖励的 11.36%</td></tr><tr><td align="center">12</td><td>总可用奖励的 10.42%</td></tr><tr><td align="center">...</td><td>...</td></tr></tbody></table>

## 做市商奖励分配

对个人做市商[^2] 的奖励将根据以下公式分配：

$$
Rewards_{MM_i} = \sum_{Market}\left(Rewards_{Market} * \frac {TS_{MM_i, \ Market}} {\sum_{MM} TS_{MM,\ Market}} \right)
$$

**每个**[**做市商**](#user-content-fn-1)[^1] **将根据**[**做市商**](#user-content-fn-1)[^1]**在市场中的比例**[ $$TS$$ ](scoring.md#total-score)**获得奖励，需经治理批准。**

{% hint style="info" %}
每个周期结束时总计 < 1 BIYA 的地址奖励将被忽略，以减少发放过程的开销。
{% endhint %}

[^1]: 做市商

[^2]: 做市商
