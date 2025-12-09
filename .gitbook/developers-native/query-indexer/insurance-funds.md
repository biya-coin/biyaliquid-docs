# Insurance Funds

Example code snippets to query the indexer for insurance fund module related data.

## Using gRPC

### Fetch redemptions for an biyaliquid address

```ts
import { IndexerGrpcInsuranceFundApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const indexerGrpcInsuranceFundApi = new IndexerGrpcInsuranceFundApi(
  endpoints.indexer,
)

const biyaliquidAddress = 'biya...'

const redemptions = await indexerGrpcInsuranceFundApi.fetchRedemptions({
  biyaliquidAddress,
})

console.log(redemptions)
```

### Fetch insurance funds

```ts
import { IndexerGrpcInsuranceFundApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const indexerGrpcInsuranceFundApi = new IndexerGrpcInsuranceFundApi(
  endpoints.indexer,
)

const insuranceFunds = await indexerGrpcInsuranceFundApi.fetchInsuranceFunds()

console.log(insuranceFunds)
```
