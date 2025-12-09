# Auth

Example code snippets to query the auth module on the chain.

## Using gRPC

### Fetch parameters such as max memo characters or tsx signature limit

```ts
import { ChainGrpcAuthApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const chainGrpcAuthApi = new ChainGrpcAuthApi(endpoints.grpc)

const moduleParams = await chainGrpcAuthApi.fetchModuleParams()

console.log(moduleParams)
```

### Fetch ccount details associated with an biyaliquid address such as the account's address, sequence, or pub\_key

```ts
import { ChainGrpcAuthApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const chainGrpcAuthApi = new ChainGrpcAuthApi(endpoints.grpc)
const biyaliquidAddress = 'biya...'

const accountDetailsResponse = await chainGrpcAuthApi.fetchAccount(
  biyaliquidAddress,
)

console.log(accountDetailsResponse)
```

### Fetch list of accounts on chain

```ts
import { PaginationOption, ChainGrpcAuthApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const chainGrpcAuthApi = new ChainGrpcAuthApi(endpoints.grpc)
const biyaliquidAddress = 'biya...'
const pagination = {...} as PaginationOption

const accounts = await chainGrpcAuthApi.fetchAccounts(/* optional pagination params*/)

console.log(accounts)
```

## Using HTTP REST

### Fetch account details associated with an biyaliquid address such as the account's address, sequence, or pub\_key

```ts
import { ChainRestAuthApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const chainRestAuthApi = new ChainRestAuthApi(endpoints.rest)
const biyaliquidAddress = 'biya...'

const accountDetailsResponse = await chainRestAuthApi.fetchAccount(
  biyaliquidAddress,
)

console.log(accountDetailsResponse)
```

#### Fetch cosmos address from an biyaliquid address

```ts
import { ChainRestAuthApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const chainRestAuthApi = new ChainRestAuthApi(endpoints.rest)
const biyaliquidAddress = 'biya...'

const cosmosAddress = await chainRestAuthApi.fetchCosmosAccount(
  biyaliquidAddress,
)

console.log(cosmosAddress)
```
