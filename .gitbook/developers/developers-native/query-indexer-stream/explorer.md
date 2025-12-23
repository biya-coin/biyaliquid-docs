# 浏览器

从索引器流式传输浏览器模块相关数据的示例代码片段。

## 使用 gRPC 流

### 流式传输区块

```ts
import { IndexerGrpcExplorerStream } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const indexerGrpcExplorerStream = new IndexerGrpcExplorerStream(
  endpoints.indexer,
)

const streamFn = indexerGrpcExplorerStream.blocks.bind(
  indexerGrpcExplorerStream,
)

const callback = (blocks) => {
  console.log(blocks)
}

const streamFnArgs = {
  callback,
}

streamFn(streamFnArgs)
```

### 流式传输包含交易的区块

```ts
import { IndexerGrpcExplorerStream } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const indexerGrpcExplorerStream = new IndexerGrpcExplorerStream(
  endpoints.indexer,
)

const streamFn = indexerGrpcExplorerStream.blocksWithTxs.bind(
  indexerGrpcExplorerStream,
)

const callback = (blocksWithTransactions) => {
  console.log(blocksWithTransactions)
}

const streamFnArgs = {
  callback,
}

streamFn(streamFnArgs)
```

### 流式传输交易

```ts
import { IndexerGrpcExplorerStream } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const indexerGrpcExplorerStream = new IndexerGrpcExplorerStream(
  endpoints.indexer,
)

const streamFn = indexerGrpcExplorerStream.streamTransactions.bind(
  indexerGrpcExplorerStream,
)

const callback = (transactions) => {
  console.log(transactions)
}

const streamFnArgs = {
  callback,
}

streamFn(streamFnArgs)
```
