---
description: 评估做市商在单个市场中的周期表现
---

# 评分公式/方法论

## 总分

对于任何给定市场，流动性提供者在周期中的 $$TS$$（总分）计算如下：

$$
TS_{Market} = (LS_{Epoch})^a \cdot (Uptime_{Epoch})^b \cdot (Volume_{epoch})^c
$$

其中 $$LS_{epoch}$$ 是流动性提供者在周期中市场中的[流动性分数](scoring.md#liquidity-score)，$$Uptime_{Epoch}$$ 是流动性提供者在周期中市场中的[正常运行时间分数](scoring.md#uptime-score)，$$Volume_{epoch}$$ 是流动性提供者在周期中市场中的总交易量（做市和吃单）。

{% hint style="info" %}
$$a$$、$$b$$ 和 $$c$$ 是加权公式不同组成部分的指数[参数](formula-parameters.md)。
{% endhint %}

## 流动性分数

$$
LS_{Epoch} =  \sum \limits_{N=1}^{40,320}  \min(LS_{N_{Bid}}, LS_{N_{Ask}})
$$

流动性提供者在周期中市场的流动性分数 $$LS_{Epoch}$$ 是周期中相关市场所有订单簿快照中买卖流动性分数（见下文）之间的最小值之和，乘以每个市场的定制波动性参数（用 Θ 表示）。这促进了双边流动性，因为单边流动性在 $$\min()$$ 函数下将获得 0 的流动性分数。

订单簿快照每 10-100 个区块随机拍摄一次。平均大约每分钟一次，这意味着一个周期中大约有 40,320 个快照 $$(60 \cdot 24 \cdot 28 = 40,320)$$。实际上，求和的上限会根据周期中快照的实际数量而变化。为了本指南的目的，我们假设周期中恰好有 40,320 个快照。

$$
LS_{N_{Bid}} = \frac{BidDepth_1}{Spread_1} \cdot \Theta_{vol} + \frac{BidDepth_2}{Spread_2} \cdot \Theta_{vol} + \ldots
 \newline  \forall \ BidDepth_i \geq MinDepth \text{ and } Spread_i \leq MaxSpread
$$

$$
LS_{N_{Ask}} = \frac{AskDepth_1}{Spread_1} \cdot \Theta_{vol} + \frac{AskDepth_2}{Spread_2} \cdot \Theta_{vol} + \ldots \newline  \forall \ AskDepth_i \geq MinDepth \text{ and } Spread_i \leq MaxSpread
$$

$$LS_{N_{Bid}}$$ 是流动性提供者在快照 $$N$$ 中放置的所有限价订单的买单深度除以订单价差的总和，乘以该快照的波动性参数，这些订单的大小超过 $$MinDepth$$ 且在 $$MaxSpread$$ 范围内。

$$LS_{N_{Ask}}$$ 遵循与 $$LS_{N_{Bid}}$$ 相同的逻辑，但在订单簿的卖单侧。

波动性参数计算如下：

$$
\Theta_{\text{vol}}(S_b)\;=\;
\min\!\bigl(\,\Theta_{\max},\;
           \max\!\{\,1,\;
                    e^{\alpha\,\sigma_b\,|\frac{S_b-\mu_b}{S_b}|}\}\bigr)
$$

其中 $$\mu_b$$ 是 $$N$$ 个区块（1000 个区块，或大约 10 分钟）的预言机价格移动平均，$$S_b$$ 表示当前区块的预言机价格，$$\sigma_b$$ 表示 $$N$$ 个区块的实现波动率。该函数有一个钳位，如果当前预言机价格偏离移动平均，或者在过去 $$N$$ 个区块中出现波动率峰值，它会很好地缩放。$$\Theta_{\text{vol}} \in [1, \Theta_{\text{max}}]$$ 的范围——因此我们将其限制在有限域内。我们引入了两个新参数 $$(\alpha, \Theta_{\text{max}})$$，用于监控对波动率的敏感性和钳位。因为 $$\Theta_{\text{max}}$$ 应该在 10 分钟内 3% 的价格变动时趋向于上限 10，所以 $$\alpha$$ 目前设置为 2,500。更高的 $$\alpha$$ 值意味着 $$\Theta$$ 更快地趋向于 $$\Theta_{\text{max}}$$，但由于 $$\Theta_{\text{max}}$$ 目前每个市场设置为 10（并且可以按市场修改），更高的 $$\alpha$$ 不会绕过该最大值。

$$Spread$$ 从中间价计算（距中间价的距离除以中间价）。

{% hint style="info" %}
有关 $$MinDepth$$ 和 $$MaxSpread$$ 的当前值，请参阅[公式参数页面](formula-parameters.md)。
{% endhint %}

## 正常运行时间分数

$$
Uptime_{Epoch} = \sum \limits_{N=1}^{40,320} \begin{cases}1&\text{if } \min(LS_{N_{Bid}}, LS_{N_{Ask}}) > 0\\ 0&\text{otherwise} \\\end{cases}
$$

$$Uptime_{Epoch}$$ 是周期中流动性提供者在相关市场中具有[正买单流动性分数 _**和**_ 正卖单流动性分数](scoring.md#liquidity-score)的订单簿快照数量。这意味着流动性提供者在订单簿的两侧报价，订单大小大于或等于 $$MinDepth$$，价差小于或等于 $$MaxSpread$$。

对于在周期中途首次获得 OLP 奖励资格的流动性提供者，$$Uptime_{Epoch}$$ 根据从资格认定时刻到周期结束的快照总数进行缩放。

例如，假设一个周期中恰好有 40,320 个快照，流动性提供者首次获得资格时恰好剩余 20,000 个快照。还假设流动性提供者在周期的剩余时间内根据上述评分公式的 $$Uptime_{Epoch}$$ 为 18,000。在这种情况下，$$Uptime_{Epoch}$$ 将缩放到 $$\frac{18000}{20000}*40320 = 36288$$。

{% hint style="warning" %}
对于在周期中途获得资格但过去曾获得过资格（地址在某个时候未能保持资格）的地址，$$Uptime_{Epoch}$$ 不会被缩放。这是为了阻止地址周期性地失去资格。
{% endhint %}

## 交易量

$$Volume$$ 是流动性提供者在周期中市场中的累计合格做市和吃单交易量。

## 完全展开的公式

The fully expanded formula is:

$$TS_{Market} =$$

$$
\left(\sum \limits_{N=1}^{40,320}  \min(LS_{N_{Bid}}, LS_{N_{Ask}})\right)^a \cdot \left(\sum \limits_{N=1}^{40,320} \begin{cases}1&\text{if } \min(LS_{N_{Bid}}, LS_{N_{Ask}}) > 0\\ 0&\text{otherwise} \\\end{cases} \right)^b \cdot Volume^c
$$

$$
\text {where}
$$

$$
LS_{N_{Bid}} = \frac{BidDepth_1}{Spread_1} \cdot \Theta_{vol} + \frac{BidDepth_2}{Spread_2} \cdot \Theta_{vol} + \ldots
 \newline  \forall \ BidDepth_i \geq MinDepth \text{ and } Spread_i \leq MaxSpread
$$

$$
LS_{N_{Ask}} = \frac{AskDepth_1}{Spread_1} \cdot \Theta_{vol} + \frac{AskDepth_2}{Spread_2} \cdot \Theta_{vol} + \ldots \newline  \forall \ AskDepth_i \geq MinDepth \text{ and } Spread_i \leq MaxSpread
$$

{% hint style="info" %}
有关每个周期个人奖励计算的信息，请参阅[奖励分配页面](reward-allocations.md)。
{% endhint %}
