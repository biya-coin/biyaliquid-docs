# 市场最小数量变动单位计算

订单价格的最小市场数量变动单位 - 如果市场的 minQuantityTickSize 为 `0.001`，则数量为 `0.0011` 的订单提交将被拒绝。

请注意，衍生品市场在 UI 和链之间对 minQuantityTickSize 使用相同的格式，因此不需要格式转换。

## 现货市场

1.  UI 人类可读格式到链上格式：
    以具有 18 个基础代币小数位和 6 个报价代币小数位的 BIYA/USDT 市场为例，以下是我们如何将值转换为链上格式：

```ts
import { toChainFormat } from "@biya-coin/utils";

const chainFormat = toChainFormat(value, baseDecimals);
```

2. 链上格式到 UI 人类可读格式：
   以具有 18 个基础代币小数位和 6 个报价代币小数位的 BIYA/USDT 市场为例，以下是我们如何将值转换为 UI 人类可读格式：

```ts
import { toHumanReadable } from "@biya-coin/utils";

const humanReadableFormat = toHumanReadable(
  minQuantityTickSize,
  baseDecimals
).toFixed();
```
