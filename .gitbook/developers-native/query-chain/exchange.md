# Exchange

Example code snippets to query the exchange module on the chain.

## Using gRPC

### Fetch parameters such as the default spot and derivatives fees/trading rewards

```ts
import { ChainGrpcExchangeApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const chainGrpcExchangeApi = new ChainGrpcExchangeApi(endpoints.grpc)

const moduleParams = await chainGrpcExchangeApi.fetchModuleParams()

console.log(moduleParams)
```

### Fetch the fee discount schedules

```ts
import { ChainGrpcExchangeApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const chainGrpcExchangeApi = new ChainGrpcExchangeApi(endpoints.grpc)

const feeDiscountSchedule =
  await chainGrpcExchangeApi.fetchFeeDiscountSchedule()

console.log(feeDiscountSchedule)
```

### Fetch the fee discounts associated with an biyaliquid address

```ts
import { ChainGrpcExchangeApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const chainGrpcExchangeApi = new ChainGrpcExchangeApi(endpoints.grpc)

const biyaliquidAddress = 'biya...'

const feeDiscountAccountInfo =
  await chainGrpcExchangeApi.fetchFeeDiscountAccountInfo(biyaliquidAddress)

console.log(feeDiscountAccountInfo)
```

### Fetch the details regarding the trading reward campaign, such as the total reward points

```ts
import { ChainGrpcExchangeApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const chainGrpcExchangeApi = new ChainGrpcExchangeApi(endpoints.grpc)

const tradingRewardsCampaign =
  await chainGrpcExchangeApi.fetchTradingRewardsCampaign()

console.log(tradingRewardsCampaign)
```

### Fetch the trading rewards points for an biyaliquid address

```ts
import { ChainGrpcExchangeApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const chainGrpcExchangeApi = new ChainGrpcExchangeApi(endpoints.grpc)

const biyaliquidAddress = 'biya...'

const tradeRewardsPoints = await chainGrpcExchangeApi.fetchTradeRewardsPoints(
  biyaliquidAddress,
)

console.log(tradeRewardsPoints)
```

### Fetch the pending trading rewards points for biyaliquid addresses

```ts
import { ChainGrpcExchangeApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const chainGrpcExchangeApi = new ChainGrpcExchangeApi(endpoints.grpc)

const biyaliquidAddresses = ['biya...']

const pendingTradeRewardsPoints =
  await chainGrpcExchangeApi.fetchPendingTradeRewardPoints(biyaliquidAddresses)

console.log(pendingTradeRewardsPoints)
```

#### Fetch the current positions, such as subaccountId, marketId, and position

```ts
import { ChainGrpcExchangeApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const chainGrpcExchangeApi = new ChainGrpcExchangeApi(endpoints.grpc)

const positions = await chainGrpcExchangeApi.fetchPositions(biyaliquidAddresses)

console.log(positions)
```

### Fetch the subaccount trade nonce

```ts
import { ChainGrpcExchangeApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const chainGrpcExchangeApi = new ChainGrpcExchangeApi(endpoints.grpc)

const subaccountId = '0x...'

const subaccountTradeNonce =
  await chainGrpcExchangeApi.fetchSubaccountTradeNonce(subaccountId)

console.log(subaccountTradeNonce)
```
