# Account

查询索引器中子账户相关数据的示例代码片段。

## 使用 gRPC

### 获取用户的投资组合详情

这包括可用余额、未实现盈亏和投资组合价值。注意：**已弃用** -> 请改用 [Portfolio](../query-indexer/portfolio.md#using-grpc)

```ts
import { IndexerGrpcAccountApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const indexerGrpcAccountApi = new IndexerGrpcAccountApi(endpoints.indexer)

const biyachainAddress = 'biya...'

const portfolio = await indexerGrpcAccountApi.fetchPortfolio(biyachainAddress)

console.log(portfolio)
```

### 获取用户每个 epoch 的交易奖励

```ts
import { IndexerGrpcAccountApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const indexerGrpcAccountApi = new IndexerGrpcAccountApi(endpoints.indexer)

const biyachainAddress = 'biya...'
const epoch = -1 // 当前 epoch

const tradingRewards = await indexerGrpcAccountApi.fetchRewards({
  address: biyachainAddress,
  epoch,
})

console.log(tradingRewards)
```

### 获取与 biyachain 地址关联的子账户

```ts
import { IndexerGrpcAccountApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const indexerGrpcAccountApi = new IndexerGrpcAccountApi(endpoints.indexer)

const biyachainAddress = 'biya...'

const subaccountsList = await indexerGrpcAccountApi.fetchSubaccountsList(
  biyachainAddress,
)

console.log(subaccountsList)
```

### 获取子账户特定面值的余额

```ts
import { IndexerGrpcAccountApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const indexerGrpcAccountApi = new IndexerGrpcAccountApi(endpoints.indexer)

const subaccountId = '0x...'
const denom = 'biya'

const subaccountBalance = await indexerGrpcAccountApi.fetchSubaccountBalance(
  subaccountId,
  denom,
)

console.log(subaccountBalance)
```

### 获取子账户的余额列表

```ts
import { IndexerGrpcAccountApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const indexerGrpcAccountApi = new IndexerGrpcAccountApi(endpoints.indexer)

const subaccountId = '0x...'

const subaccountBalanceList =
  await indexerGrpcAccountApi.fetchSubaccountBalancesList(subaccountId)

console.log(subaccountBalanceList)
```

### 获取子账户历史

```ts
import { PaginationOption, IndexerGrpcAccountApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const indexerGrpcAccountApi = new IndexerGrpcAccountApi(endpoints.indexer)

const subaccountId = '0x...'
const denom = 'biya'
const pagination = {...} as PaginationOption

const subaccountHistory = await indexerGrpcAccountApi.fetchSubaccountHistory({
  subaccountId,
  denom,
  pagination /* 可选参数 */
})

console.log(subaccountHistory)
```

### 获取子账户订单摘要

```ts
import { IndexerGrpcAccountApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const indexerGrpcAccountApi = new IndexerGrpcAccountApi(endpoints.indexer)

const subaccountId = '0x...'
const marketId = '0x'
const orderDirection = 'buy'

const orderSummary = await indexerGrpcAccountApi.fetchSubaccountOrderSummary({
  subaccountId,
  marketId,
  orderDirection,
})

console.log(orderSummary)
```

### 获取现货或（和）衍生品订单状态

```ts
import { IndexerGrpcAccountApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const indexerGrpcAccountApi = new IndexerGrpcAccountApi(endpoints.indexer)

const spotOrderHashes = ['0x...']
const derivativeOrderHashes = ['0x...']

const orderStates = await indexerGrpcAccountApi.fetchOrderStates({
  spotOrderHashes,
  derivativeOrderHashes,
})

console.log(orderStates)
```
