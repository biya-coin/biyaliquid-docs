# Insurance Funds

Example code snippets to query data related to the insurance fund on chain.

## Using gRPC

### Fetch default redemption notice period duration

```ts
import { ChainGrpcInsuranceFundApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const chainGrpcInsuranceFundApi = new ChainGrpcInsuranceFundApi(endpoints.grpc)

const moduleParams = await chainGrpcInsuranceFundApi.fetchModuleParams()

console.log(moduleParams)
```

### Fetch insurance funds and associated metadata

```ts
import { ChainGrpcInsuranceFundApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const chainGrpcInsuranceFundApi = new ChainGrpcInsuranceFundApi(endpoints.grpc)

const insuranceFunds = await chainGrpcInsuranceFundApi.fetchInsuranceFunds()

console.log(insuranceFunds)
```

### Fetch insurance fund and associated metadata based on the market ID

```ts
import { ChainGrpcInsuranceFundApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const chainGrpcInsuranceFundApi = new ChainGrpcInsuranceFundApi(endpoints.grpc)

const marketId = '0x...'
const insuranceFund = await chainGrpcInsuranceFundApi.fetchInsuranceFund(
  marketId,
)

console.log(insuranceFund)
```

### Fetch estimated redemptions for a given biyachain address for a market

```ts
import { ChainGrpcInsuranceFundApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const chainGrpcInsuranceFundApi = new ChainGrpcInsuranceFundApi(endpoints.grpc)

const marketId = '0x...'
const biyachainAddress = 'biya...'

const estimatedRedemptions =
  await chainGrpcInsuranceFundApi.fetchEstimatedRedemptions({
    marketId,
    address: biyachainAddress,
  })

console.log(estimatedRedemptions)
```

### Fetch pending redemptions for a given biyachain address for a market

```ts
import { ChainGrpcInsuranceFundApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const chainGrpcInsuranceFundApi = new ChainGrpcInsuranceFundApi(endpoints.grpc)

const marketId = '0x...'
const biyachainAddress = 'biya...'

const pendingRedemptions =
  await chainGrpcInsuranceFundApi.fetchPendingRedemptions({
    marketId,
    address: biyachainAddress,
  })

console.log(pendingRedemptions)
```
