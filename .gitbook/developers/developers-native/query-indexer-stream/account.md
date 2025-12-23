# 账户

从索引器流式传输子账户相关数据的示例代码片段。

## 使用 gRPC 流

### 流式传输子账户余额

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
