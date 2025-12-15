# Insurance Funds

Example code snippets to query the indexer for insurance fund module related data.

## Using gRPC

### Fetch redemptions for an biyachain address

```ts
import { IndexerGrpcInsuranceFundApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const indexerGrpcInsuranceFundApi = new IndexerGrpcInsuranceFundApi(
  endpoints.indexer,
)

const biyachainAddress = 'biya...'

const redemptions = await indexerGrpcInsuranceFundApi.fetchRedemptions({
  biyachainAddress,
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
