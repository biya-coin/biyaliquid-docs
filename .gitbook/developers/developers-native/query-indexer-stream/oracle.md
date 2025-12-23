# 预言机

从索引器查询预言机模块相关数据的示例代码片段。

## 使用 gRPC 流

### 流式传输预言机价格

```ts
import { IndexerGrpcOracleStream } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const indexerGrpcOracleStream = new IndexerGrpcOracleStream(endpoints.indexer)

const streamFn = indexerGrpcOracleStream.streamOraclePrices.bind(
  indexerGrpcOracleStream,
)

const callback = (oraclePrices) => {
  console.log(oraclePrices)
}

const streamFnArgs = {
  callback,
}

streamFn(streamFnArgs)
```

### 按市场流式传输预言机价格

```ts
import { IndexerGrpcOracleStream } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const indexerGrpcOracleStream = new IndexerGrpcOracleStream(endpoints.indexer)

const marketIds = ['0x...'] /* optional param */

const streamFn = indexerGrpcOracleStream.streamOraclePricesByMarkets.bind(
  indexerGrpcOracleStream,
)

const callback = (oraclePrices) => {
  console.log(oraclePrices)
}

const streamFnArgs = {
  marketIds,
  callback,
}

streamFn(streamFnArgs)
```
