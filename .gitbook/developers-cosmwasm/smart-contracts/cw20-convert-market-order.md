# 在一笔交易中将 CW20 转换为 Bank 并下市价单

此示例帮助您创建消息，将 Biya Chain 区块链上的 CW20 代币转换为 bank 代币。当您拥有 CW20 代币并需要将其转换为等效的 bank 代币以执行诸如下市价单之类的操作时，这特别有用。请注意，此流程仅适用于 cw20 代币及其对应的[工厂代币](../../developers/concepts/)。

本指南将引导您完成：

* 获取用户的 CW20 代币余额。
* 使用 ConvertCw20ToBankService 创建将 CW20 代币转换为 bank 代币的消息
* 使用转换后的 bank 余额和现有 bank 余额执行市价单

## 获取用户的 CW20 余额

您可以使用[浏览器索引器查询](https://github.com/biya-coin/biyachain-docs/blob/master/.gitbook/developers-native/query-indexer/explorer.md#fetch-cw20-balances)执行此操作。

* 从结果集中找到您想要转换为 bank 工厂代币的 cw20 地址和余额

## 创建 CW20 到 Bank 的转换消息

* 使用[此处](../../developers/concepts/token-factory.md#example-on-how-to-convert-cw20-to-a-factory-denom)详细说明的步骤创建 `convertMsg`，以便将您的 CW20 代币转换为 bank 工厂代币。暂时无需提交交易。

## 创建 `MsgCreateSpotMarketOrder` 消息

* 使用 [MsgCreateSpotMarketOrder](https://github.com/biya-coin/biyachain-docs/blob/master/.gitbook/developers-native/examples/exchange.md#msgcreatespotmarketorder) 中详细说明的步骤创建 `msg`。暂时无需提交交易。
* 请注意，您创建的买单将可以访问您转换后的 cw20 余额 + 现有的 bank 余额。示例：

```ts
const order = {
  price: 1,
  quantity: 10,
}
```

* 如果您有 5 个 Cw20 代币和 5 个 bank 代币，每个价格为 $1，那么上面的订单将会通过，因为我们将在链执行此市价单之前将 cw20 转换为 bank。这将在下一步中更加清楚。

## 使用转换后的 CW20 余额和您现有的 bank 余额下市价单

现在您已经格式化了两条消息，您可以将 cw20 代币转换为 bank 工厂代币，然后使用组合余额下市价单，所有这些都在一笔交易中完成

```ts
import { MsgBroadcasterWithPk } from '@biya-coin/sdk-ts'
import { Network } from '@biya-coin/networks'

const privateKey = '0x...'
const biyachainAddress = 'biya1...'

const txHash = await new MsgBroadcasterWithPk({
  privateKey,
  network: Network.MainnetSentry,
}).broadcast({
  msgs: [convertMsg, msg], // the convert to bank message executes first, Then, you will have that additional balance to complete your market order in the following msg
})

console.log(txHash)
```
