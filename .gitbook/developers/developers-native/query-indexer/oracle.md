# Oracle

查询索引器中 oracle 模块相关数据的示例代码片段。

## 使用 gRPC

### 获取预言机列表

```ts
import { IndexerGrpcOracleApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const indexerGrpcOracleApi = new IndexerGrpcOracleApi(endpoints.indexer)

const oracleList = await indexerGrpcOracleApi.fetchOracleList()

console.log(oracleList)
```

### 从预言机获取价格

Base 和 Quote 预言机符号始终从市场本身获取。它们可能与普通符号的表示形式不同（例如，`pyth` 预言机的哈希值）。

```ts
import {
  IndexerGrpcOracleApi,
  IndexerGrpcDerivativeApi,
} from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const markets = new IndexerGrpcDerivativeApi(endpoints.indexer)
const indexerGrpcOracleApi = new IndexerGrpcOracleApi(endpoints.indexer)

const market = markets.find((market) => market.ticker === 'BIYA/USDT PERP')

// 这些值是从链上获取的市场对象的一部分
// 即 `oracle_base` 和 `oracle_quote`
const baseSymbol = market.oracle_base
const quoteSymbol = market.oracle_quote
const oracleType = market.oracle_type

const oraclePrice = await indexerGrpcOracleApi.fetchOraclePriceNoThrow({
  baseSymbol,
  quoteSymbol,
  oracleType,
})

console.log(oraclePrice)
```
