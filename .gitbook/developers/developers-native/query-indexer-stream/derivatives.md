# 衍生品

从索引器查询衍生品模块相关数据的示例代码片段。

## 使用 gRPC 流

### 流式传输衍生品订单簿

```ts
import { IndexerGrpcDerivativesStream } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const indexerGrpcDerivativesStream = new IndexerGrpcDerivativesStream(
  endpoints.indexer,
)

const marketIds = ['0x...']

const streamFn = indexerGrpcDerivativesStream.streamDerivativeOrderbookV2.bind(
  indexerGrpcDerivativesStream,
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

### 流式传输衍生品订单

```ts
import { IndexerGrpcDerivativesStream } from '@biya-coin/sdk-ts'
import { OrderSide } from '@biya-coin/ts-types'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const indexerGrpcDerivativesStream = new IndexerGrpcDerivativesStream(
  endpoints.indexer,
)

const marketId = '0x...'
const subaccountId = '0x...' /* optional param */
const orderSide = OrderSide.Buy /* optional param */

const streamFn = indexerGrpcDerivativesStream.streamDerivativeOrders.bind(
  indexerGrpcDerivativesStream,
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

### 流式传输衍生品订单历史

```ts
import {
  TradeDirection,
  TradeExecutionType,
  IndexerGrpcDerivativesStream,
} from '@biya-coin/sdk-ts'
import { OrderSide } from '@biya-coin/ts-types'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const indexerGrpcDerivativesStream = new IndexerGrpcDerivativesStream(
  endpoints.indexer,
)

const marketId = '0x...' /* optional param */
const subaccountId = '0x...' /* optional param */
const orderTypes = [OrderSide.Buy] /* optional param */
const executionTypes = [TradeExecutionType.Market] /* optional param */
const direction = TradeDirection.Buy /* optional param*/

const streamFn = indexerGrpcDerivativesStream.streamDerivativeOrderHistory.bind(
  indexerGrpcDerivativesStream,
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

### 流式传输衍生品交易

```ts
import {
  PaginationOption,
  TradeDirection,
  IndexerGrpcDerivativesStream
} from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const indexerGrpcDerivativesStream = new IndexerGrpcDerivativesStream(endpoints.indexer)

const marketIds = ['0x...'] /* optional param */
const subaccountId = '0x...' /* optional param */
const direction = TradeDirection.Buy /* optional param */
const pagination = {...} as PaginationOption /* optional param */

const streamFn = indexerGrpcDerivativesStream.streamDerivativeTrades.bind(indexerGrpcDerivativesStream)

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

### 流式传输衍生品持仓

```ts
import { IndexerGrpcDerivativesStream } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const indexerGrpcDerivativesStream = new IndexerGrpcDerivativesStream(
  endpoints.indexer,
)

const marketId = '0x...' /* optional param */
const subaccountId = '0x...' /* optional param */

const streamFn = indexerGrpcDerivativesStream.streamDerivativePositions.bind(
  indexerGrpcDerivativesStream,
)

const callback = (positions) => {
  console.log(positions)
}

const streamFnArgs = {
  marketId,
  subaccountId,
  callback,
}

streamFn(streamFnArgs)
```

### 流式传输市场

```ts
import { IndexerGrpcDerivativesStream } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const indexerGrpcDerivativesStream = new IndexerGrpcDerivativesStream(
  endpoints.indexer,
)

const marketIds = ['0x...'] /* optional param */

const streamFn = indexerGrpcDerivativesStream.streamDerivativeMarket.bind(
  indexerGrpcDerivativesStream,
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
import { IndexerGrpcDerivativesStream } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const indexerGrpcDerivativesStream = new IndexerGrpcDerivativesStream(
  endpoints.indexer,
)

const marketIds = ['0x...']

const streamFn =
  indexerGrpcDerivativesStream.streamDerivativeOrderbookUpdate.bind(
    indexerGrpcDerivativesStream,
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
