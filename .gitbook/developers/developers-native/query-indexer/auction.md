# Auction

查询索引器中 auction 模块相关数据的示例代码片段。

## 使用 gRPC

### 根据轮次获取拍卖

```ts
import { IndexerGrpcAuctionApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const indexerGrpcAuctionApi = new IndexerGrpcAuctionApi(endpoints.indexer)

const round = 1

const auction = await indexerGrpcAuctionApi.fetchAuction(round)

console.log(auction)
```

### 获取拍卖列表

```ts
import { IndexerGrpcAuctionApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const indexerGrpcAuctionApi = new IndexerGrpcAuctionApi(endpoints.indexer)

const auction = await indexerGrpcAuctionApi.fetchAuctions()

console.log(auction)
```
