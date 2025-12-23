# Auction

查询链上 auction 模块的示例代码片段。

## 使用 gRPC

### 获取模块参数，如拍卖周期

```ts
import { ChainGrpcBankApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const chainGrpcAuctionApi = new ChainGrpcAuctionApi(endpoints.grpc)

const moduleParams = await chainGrpcAuctionApi.fetchModuleParams()

console.log(moduleParams)
```

### 获取当前拍卖的状态，如最新轮次

```ts
import { ChainGrpcBankApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const chainGrpcAuctionApi = new ChainGrpcAuctionApi(endpoints.grpc)

const latestAuctionModuleState = await auctionApi.fetchModuleState()

console.log(latestAuctionModuleState)
```

### 获取当前拍卖篮子并获取信息，如最高出价者和金额

```ts
import { ChainGrpcBankApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const chainGrpcAuctionApi = new ChainGrpcAuctionApi(endpoints.grpc)

const currentBasket = await chainGrpcAuctionApi.fetchCurrentBasket()

console.log(currentBasket)
```
