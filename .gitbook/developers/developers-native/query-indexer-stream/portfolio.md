# 投资组合

从索引器流式传输投资组合模块相关数据的示例代码片段。

## 使用 gRPC 流

### 流式传输账户的投资组合

```ts
import { IndexerGrpcAccountPortfolioStream } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const indexerGrpcAccountPortfolioStream = new IndexerGrpcAccountPortfolioStream(
  endpoints.indexer,
)

const accountAddress = 'biya...'

const streamFn = indexerGrpcAccountPortfolioStream.streamAccountPortfolio.bind(
  indexerGrpcAccountPortfolioStream,
)

const callback = (portfolioResults) => {
  console.log(portfolioResults)
}

const streamFnArgs = {
  accountAddress,
  callback,
}

streamFn(streamFnArgs)
```
