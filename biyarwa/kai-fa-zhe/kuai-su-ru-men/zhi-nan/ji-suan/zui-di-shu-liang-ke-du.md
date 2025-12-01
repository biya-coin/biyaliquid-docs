# 最低数量刻度

## 最低市场订单数量刻度

最小市场数量刻度（tick size）决定了订单数量可增加或减少的最小增量。例如，如果某个市场的最小数量刻度为 0.001，则提交数量为 0.0011 的订单将被拒绝，因为该数量未对齐到允许的增量。

{% hint style="info" %}
**Note:** 衍生品市场的最小数量刻度（`minQuantityTickSize`）在用户界面和链上使用相同的格式，因此不需要进行格式转换。
{% endhint %}

### 现货市场

**从可读格式转换为链格式**

以 **BIYA/USDT** 市场为例，该市场具有 **18 位基础资产小数** 和 **6 位计价资产小数**，其转换为链格式的方式如下：

$$\text{chainFormat} = \text{value} \times 10^{\text{baseDecimals}}$$

**从链格式转换为可读格式**

要转换回**可读格式**，请按照以下方式进行：

$$\text{humanReadableFormat} = \text{value} \times 10^{-\text{baseDecimals}}$$

此外，请务必查看我们的 [TypeScript 文档](https://docs.ts.injective.network/getting-started/application-concepts/calculations/min-price-tick-size)。
