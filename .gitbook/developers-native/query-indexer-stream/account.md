# Account

Example code snippets to stream from the indexer for subaccount related data.

## Using gRPC stream

### Stream subaccount balance

```ts
import { IndexerGrpcAccountStream } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const indexerGrpcAccountStream = new IndexerGrpcAccountStream(endpoints.indexer)

const subaccountId = '0x...'

const streamFn = indexerGrpcAccountStream.streamSubaccountBalance.bind(
  indexerGrpcAccountStream,
)

const callback = (subaccountBalance) => {
  console.log(subaccountBalance)
}

const streamFnArgs = {
  subaccountId,
  callback,
}

streamFn(streamFnArgs)
```
