# 拍卖

从索引器流式传输拍卖模块相关数据的示例代码片段。

## 使用 gRPC 流

### 流式传输拍卖出价

```ts
import { IndexerGrpcAuctionStream } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const indexerGrpcAuctionStream = new IndexerGrpcAuctionStream(endpoints.indexer)

const streamFn = indexerGrpcAuctionStream.streamBids.bind(
  indexerGrpcAuctionStream,
)

const callback = (bids) => {
  console.log(bids)
}

const streamFnArgs = {
  callback,
}

streamFn(streamFnArgs)
```
