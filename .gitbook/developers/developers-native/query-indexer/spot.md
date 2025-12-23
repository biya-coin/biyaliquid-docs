# Spot

查询索引器中现货市场模块相关数据的示例代码片段。

## 使用 gRPC

### 获取市场

```ts
import { IndexerGrpcSpotApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const indexerGrpcSpotApi = new IndexerGrpcSpotApi(endpoints.indexer)

const markets = await indexerGrpcSpotApi.fetchMarkets()

console.log(markets)
```

### 根据市场 ID 获取市场

```ts
import { IndexerGrpcSpotApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const indexerGrpcSpotApi = new IndexerGrpcSpotApi(endpoints.indexer)

const marketId = '0x...'

const market = await indexerGrpcSpotApi.fetchMarket(marketId)

console.log(market)
```

### 获取市场订单

```ts
import { PaginationOption, IndexerGrpcSpotApi } from '@biya-coin/sdk-ts'
import { OrderSide } from '@biya-coin/ts-types'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const indexerGrpcSpotApi = new IndexerGrpcSpotApi(endpoints.indexer)

const marketId = '0x...' /* 可选参数 */
const orderSide = OrderSide.Buy /* 可选参数 */
const subaccountId = '0x...' /* 可选参数 */
const pagination = {...} as PaginationOption /* 可选参数 */

const orders = await indexerGrpcSpotApi.fetchOrders({
  marketId,
  orderSide,
  subaccountId,
  pagination
})

console.log(orders)
```

### 获取市场订单历史

```ts
import {
  TradeDirection,
  PaginationOption,
  TradeExecutionType,
  IndexerGrpcSpotApi
} from '@biya-coin/sdk-ts'
import { OrderSide } from '@biya-coin/ts-types'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const indexerGrpcSpotApi = new IndexerGrpcSpotApi(endpoints.indexer)

const marketIds = ['0x...'] /* 可选参数 */
const executionTypes = [TradeExecutionType.Market] /* 可选参数 */
const orderTypes = OrderSide.Buy /* 可选参数 */
const direction = TradeDirection.Buy /* 可选参数 */
const subaccountId = '0x...' /* 可选参数 */
const pagination = {...} as PaginationOption /* 可选参数 */

const orderHistory = await indexerGrpcSpotApi.fetchOrderHistory({
  marketIds,
  executionTypes,
  orderTypes,
  direction,
  subaccountId,
  pagination
})

console.log(orderHistory)
```

### 获取市场交易

```ts
import {
  TradeDirection,
  PaginationOption,
  TradeExecutionType,
  IndexerGrpcSpotApi
} from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const indexerGrpcSpotApi = new IndexerGrpcSpotApi(endpoints.indexer)

const marketId = '0x...' /* 可选参数 */
const executionTypes = [TradeExecutionType.Market] /* 可选参数 */
const direction = TradeDirection.Buy /* 可选参数 */
const subaccountId = '0x...'/* 可选参数 */
const pagination = {...} as PaginationOption /* 可选参数 */

const trades = await indexerGrpcSpotApi.fetchTrades({
  marketId,
  executionTypes,
  direction,
  subaccountId,
  pagination
})

console.log(trades)
```

### 获取子账户订单列表

```ts
import {
  PaginationOption,
  IndexerGrpcSpotApi
} from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const indexerGrpcSpotApi = new IndexerGrpcSpotApi(endpoints.indexer)

const marketId = '0x...' /* 可选参数 */
const subaccountId = '0x...' /* 可选参数 */
const pagination = {...} as PaginationOption /* 可选参数 */

const subaccountOrders = await indexerGrpcSpotApi.fetchSubaccountOrdersList({
  marketId,
  subaccountId,
  pagination
})

console.log(subaccountOrders)
```

### 获取子账户交易列表

```ts
import {
  TradeDirection,
  TradeExecutionType,
  PaginationOption,
  IndexerGrpcSpotApi
} from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const indexerGrpcSpotApi = new IndexerGrpcSpotApi(endpoints.indexer)

const marketId = '0x...' /* 可选参数 */
const subaccountId = '0x...' /* 可选参数 */
const executionType = TradeExecutionType.LimitFill /* 可选参数 */
const direction = TradeDirection.Sell /* 可选参数 */
const pagination = {...} as PaginationOption /* 可选参数 */

const subaccountTrades = await indexerGrpcSpotApi.fetchSubaccountTradesList({
  marketId,
  subaccountId,
  executionType,
  direction,
  pagination
})

console.log(subaccountTrades)
```

### 获取多个市场的订单簿

```ts
import { IndexerGrpcSpotApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const indexerGrpcSpotApi = new IndexerGrpcSpotApi(endpoints.indexer)

const marketIds = ['0x...']

const orderbooks = await indexerGrpcSpotApi.fetchOrderbooksV2(marketIds)

console.log(orderbooks)
```

### 获取市场的订单簿

```ts
import { IndexerGrpcSpotApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const indexerGrpcSpotApi = new IndexerGrpcSpotApi(endpoints.indexer)

const marketId = '0x...'

const orderbook = await indexerGrpcSpotApi.fetchOrderbookV2(marketId)

console.log(orderbook)
```

## 使用 HTTP REST

### 获取市场摘要，如价格历史和 24 小时交易量

```ts
import { IndexerRestSpotChronosApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const indexerRestSpotChronosApi = new IndexerRestSpotChronosApi(
  `${endpoints.chronos}/api/chronos/v1/spot`,
)

const marketId = '0x...'

const marketSummary = await indexerRestSpotChronosApi.fetchMarketSummary(
  marketId,
)

console.log(marketSummary)
```

### 获取所有市场摘要，如价格历史和 24 小时交易量

```ts
import { IndexerRestSpotChronosApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const indexerRestSpotChronosApi = new IndexerRestSpotChronosApi(
  `${endpoints.chronos}/api/chronos/v1/spot`,
)

const marketSummaries = await indexerRestSpotChronosApi.fetchMarketsSummary(
  marketId,
)

console.log(marketSummaries)
```
