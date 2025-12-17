# Portfolio

Example code snippets to stream from the indexer for portfolio module related data.

## Using gRPC Stream

### Stream an account's portfolio

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
