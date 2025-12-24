# 市场最小价格变动单位

订单价格的最小市场价格变动单位 - 如果市场的 minPriceTickSize 为 `0.001`，则价格为 `0.0011` 的订单提交将被拒绝。

请注意，计算现货和报价市场价格变动单位的公式是不同的。

### 现货市场

1.  UI 人类可读格式到链上格式：
    以具有 18 个基础代币小数位和 6 个报价代币小数位的 BIYA/USDT 市场为例，以下是我们如何将值转换为链上格式：

```ts
import { toChainFormat } from "@biya-coin/utils";

const value = toChainFormat(value, quoteDecimals - baseDecimals).toFixed();
```

2. 链上格式到 UI 人类可读格式：
   以具有 18 个基础代币小数位和 6 个报价代币小数位的 BIYA/USDT 市场为例，以下是我们如何将值转换为 UI 人类可读格式：

```ts
import { toHumanReadable } from "@biya-coin/utils";

const value = toHumanReadable(value, quoteDecimals - baseDecimals).toFixed();
```

### 衍生品市场

1.  UI 人类可读格式到链上格式：
    以具有 6 个报价代币小数位的 BIYA/USDT 永续市场为例，以下是我们如何将值转换为链上格式：

```ts
import { toChainFormat } from "@biya-coin/utils";

const value = toChainFormat(value, -quoteDecimals).toFixed();
```

2. 链上格式到 UI 人类可读格式：
   以具有 6 个报价代币小数位的 BIYA/USDT 永续市场为例，以下是我们如何将值转换为 UI 人类可读格式：

```ts
import { toHumanReadable } from "@biya-coin/utils";

const value = toHumanReadable(value, quoteDecimals).toFixed();
```
