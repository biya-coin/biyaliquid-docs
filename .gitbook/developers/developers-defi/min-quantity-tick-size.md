# 最小数量变动单位计算

## 最小市场数量变动单位

最小市场数量变动单位规定了订单数量可以增加或减少的最小增量。例如，如果市场的最小数量变动单位为 **0.001**，则提交数量为 **0.0011** 的订单将被拒绝，因为它不符合允许的增量。

{% hint style="info" %}
**注意：** 衍生品市场在用户界面和链上对 `minQuantityTickSize` 使用相同的格式，因此不需要格式转换。
{% endhint %}

### 现货市场

#### 从人类可读格式转换为链上格式

以 BIYA/USDT 市场为例，该市场有 **18 个基础代币小数位**和 **6 个报价代币小数位**，转换为链上格式如下：

$$\text{chainFormat} = \text{value} \times 10^{\text{baseDecimals}}$$

#### 从链上格式转换为人类可读格式

要转换回人类可读格式：

$$\text{humanReadableFormat} = \text{value} \times 10^{-\text{baseDecimals}}$$

另外，请务必查看我们的[概念说明](../concepts/calculation-min-price-tick-size.md)。
