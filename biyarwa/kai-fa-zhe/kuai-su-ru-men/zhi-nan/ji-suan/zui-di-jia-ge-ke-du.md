# 最低价格刻度

## 最低市场订单价格刻度

最低市场订单价格刻度决定了订单价格可以增加或减少的最小增量。例如，如果市场的最低价格刻度为 0.001，则提交价格为 0.0011 的订单将被拒绝，因为它不符合允许的增量。

{% hint style="info" %}
**Note:** 计算价格刻度的公式在现货市场和衍生品市场之间有所不同。
{% endhint %}

### 现货市场

**从可读格式转换为链格式**

以 BIY&#x41;**/USDT** 市场为例，该市场具有 **18 位基础资产小数** 和 **6 位计价资产小数**，其转换为链格式的方式如下：

$$\text{chainFormat} = \text{value} \times 10^{(\text{quoteDecimals} - \text{baseDecimals})}$$

**从链格式转换为可读格式**

要转换回**可读格式**，请按照以下方式进行：

$$\text{humanReadableFormat} = \text{value} \times 10^{(\text{baseDecimals} - \text{quoteDecimals})}$$

### 衍生品市场

**从可读格式转换为链格式**

以**BIYA/USDT 永续合约市场**（具有 6 位报价小数）为例，转换为链上格式的方式如下：

$$\text{chainFormat} = \text{value} \times 10^{-\text{quoteDecimals}}$$

**从链格式转换为可读格式**

要转换回**可读格式**，请按照以下方式进行：

$$\text{humanReadableFormat} = \text{value} \times 10^{-\text{quoteDecimals}}$$

此外，请务必查看我们的 [TypeScript 文档](https://docs.ts.injective.network/getting-started/application-concepts/calculations/min-price-tick-size)。
