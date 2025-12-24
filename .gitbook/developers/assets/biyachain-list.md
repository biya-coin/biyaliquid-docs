# Biya Chain 列表

我们已将链上 denoms 代币元数据移至 [biyachain-list](https://github.com/biya-coin/biyachain-lists) 存储库。此存储库将聚合来自多个来源的数据，并生成全面的代币元数据主列表。

以下是如何将 biyachain-list 与 TokenFactoryStatic 类集成的示例：

1. 从 GitHub 下载 [Biya Chain 列表 JSON 文件](https://github.com/biya-coin/biyachain-lists?tab=readme-ov-file#-usage)

2. 使用 `sdk-ts` 包中的 `TokenStaticFactory` 类

```ts
import { TokenType, TokenStatic, TokenStaticFactory } from '@biya-coin/sdk-ts'
import { tokens } from '../data/tokens.json' // json file downloaded from step 1

export const tokenStaticFactory = new TokenStaticFactory(tokens as TokenStatic[])

// After instantiating, we can start using it in our dApp
const denom = 'peggy0x...'
const token = tokenStaticFactory.toToken(denom)

console.log(token)
```

使用 `TokenFactory` 时需要考虑几个边缘情况：

- 如果您尝试查询[代币列表](https://github.com/biya-coin/biyachain-lists)中不存在的 denom 的代币元数据，`TokenFactory` 将返回 undefined。如果是这样，您应该遵循我们的[贡献指南](https://github.com/biya-coin/biyachain-lists/blob/master/CONTRIBUTING.md)在包中添加代币元数据信息。
