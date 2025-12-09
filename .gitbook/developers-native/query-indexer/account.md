# Account

Example code snippets to query the indexer for subaccount related data.

## Using gRPC

### Fetch user's portfolio details

This includes available balance, unrealized Pnl, and portfolio value. Note: **deprecated** -> use [Portfolio](../query-indexer/portfolio.md#using-grpc) instead

```ts
import { IndexerGrpcAccountApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const indexerGrpcAccountApi = new IndexerGrpcAccountApi(endpoints.indexer)

const biyaliquidAddress = 'biya...'

const portfolio = await indexerGrpcAccountApi.fetchPortfolio(biyaliquidAddress)

console.log(portfolio)
```

### Fetch user's trading rewards per epoch

```ts
import { IndexerGrpcAccountApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const indexerGrpcAccountApi = new IndexerGrpcAccountApi(endpoints.indexer)

const biyaliquidAddress = 'biya...'
const epoch = -1 // current epoch

const tradingRewards = await indexerGrpcAccountApi.fetchRewards({
  address: biyaliquidAddress,
  epoch,
})

console.log(tradingRewards)
```

### Fetch subaccounts associated with an biyaliquid address

```ts
import { IndexerGrpcAccountApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const indexerGrpcAccountApi = new IndexerGrpcAccountApi(endpoints.indexer)

const biyaliquidAddress = 'biya...'

const subaccountsList = await indexerGrpcAccountApi.fetchSubaccountsList(
  biyaliquidAddress,
)

console.log(subaccountsList)
```

### Fetch balance of a subaccount for a specific denom

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

### Fetch of balances for a subaccount

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

### Fetch subacount history

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
  pagination /* optional param */
})

console.log(subaccountHistory)
```

### Fetch a summary of a subaccount's orders

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

### Fetch states of spot or (and) derivatives orders

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
