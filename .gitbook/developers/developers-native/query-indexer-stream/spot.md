# 现货

从索引器流式传输现货市场模块相关数据的示例代码片段。

## 使用 gRPC 流

### 流式传输现货订单簿

```ts
import { IndexerGrpcSpotStream } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const indexerGrpcSpotStream = new IndexerGrpcSpotStream(endpoints.indexer)

const marketIds = ['0x...']

const streamFn = indexerGrpcSpotStream.streamSpotOrderbookV2.bind(
  indexerGrpcSpotStream,
)

const callback = (orderbooks) => {
  console.log(orderbooks)
}

const streamFnArgs = {
  marketIds,
  callback,
}

streamFn(streamFnArgs)
```

### 流式传输现货订单

```ts
import { IndexerGrpcSpotsStream } from '@biya-coin/sdk-ts'
import { OrderSide } from '@biya-coin/ts-types'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const indexerGrpcSpotStream = new IndexerGrpcSpotsStream(endpoints.indexer)

const marketId = '0x...'
const subaccountId = '0x...' /* optional param */
const orderSide = OrderSide.Buy /* optional param */

const streamFn = indexerGrpcSpotStream.streamSpotOrders.bind(
  indexerGrpcSpotStream,
)

const callback = (orders) => {
  console.log(orders)
}

const streamFnArgs = {
  marketId,
  subaccountId,
  orderside,
  callback,
}

streamFn(streamFnArgs)
```

### 流式传输现货订单历史

```ts
import {
  TradeDirection,
  TradeExecutionType,
  IndexerGrpcSpotStream,
} from '@biya-coin/sdk-ts'
import { OrderSide } from '@biya-coin/ts-types'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const indexerGrpcSpotStream = new IndexerGrpcSpotStream(endpoints.indexer)

const marketId = '0x...' /* optional param */
const subaccountId = '0x...' /* optional param */
const orderTypes = [OrderSide.Buy] /* optional param */
const executionTypes = [TradeExecutionType.Market] /* optional param */
const direction = TradeDirection.Buy /* optional param*/

const streamFn = indexerGrpcSpotStream.streamSpotOrderHistory.bind(
  indexerGrpcSpotStream,
)

const callback = (orderHistory) => {
  console.log(orderHistory)
}

const streamFnArgs = {
  marketId,
  subaccountId,
  orderTypes,
  executionTypes,
  direction,
  callback,
}

streamFn(streamFnArgs)
```

### 流式传输现货交易

```ts
import {
  PaginationOption,
  TradeDirection,
  IndexerGrpcSpotStream
} from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const indexerGrpcSpotStream = new IndexerGrpcSpotStream(endpoints.indexer)

const marketIds = ['0x...'] /* optional param */
const subaccountId = '0x...' /* optional param */
const direction = TradeDirection.Buy /* optional param */
const pagination = {...} as PaginationOption /* optional param */

const streamFn = indexerGrpcSpotStream.streamSpotTrades.bind(indexerGrpcSpotStream)

const callback = (trades) => {
  console.log(trades)
}

const streamFnArgs = {
  marketIds,
  subaccountId,
  orderTypes,
  direction,
  pagination,
  callback
}

streamFn(streamFnArgs)
```

### 流式传输市场

```ts
import { IndexerGrpcSpotStream } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const indexerGrpcSpotStream = new IndexerGrpcSpotStream(endpoints.indexer)

const marketIds = ['0x...'] /* optional param */

const streamFn = indexerGrpcSpotStream.streamSpotMarket.bind(
  indexerGrpcSpotStream,
)

const callback = (markets) => {
  console.log(markets)
}

const streamFnArgs = {
  marketIds,
  callback,
}

streamFn(streamFnArgs)
```

### 流式传输订单簿更新

```ts
import { IndexerGrpcSpotStream } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const indexerGrpcSpotStream = new IndexerGrpcSpotStream(endpoints.indexer)

const marketIds = ['0x...']

const streamFn = indexerGrpcSpotStream.streamDerivativeOrderbookUpdate.bind(
  indexerGrpcSpotStream,
)

const callback = (orderbookUpdates) => {
  console.log(orderbookUpdates)
}

const streamFnArgs = {
  marketIds,
  callback,
}

streamFn(streamFnArgs)
```
