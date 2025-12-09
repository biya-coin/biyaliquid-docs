# Distribution

Example code snippets to query data related to delegating to validators from the chain.

## Using gRPC

### Fetch parameters such as the base and bonus proposer reward

```ts
import { ChainGrpcDistributionApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const chainGrpcDistributionApi = new ChainGrpcDistributionApi(endpoints.grpc)

const moduleParams = await chainGrpcDistributionApi.fetchModuleParams()

console.log(moduleParams)
```

### Fetch the amount and denom of rewards for a delegator delagating to a specific validator

```ts
import { ChainGrpcDistributionApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const chainGrpcDistributionApi = new ChainGrpcDistributionApi(endpoints.grpc)

const delegatorAddress = 'biya...'
const validatorAddress = 'biyavaloper...'

const delegatorRewardsFromValidator =
  await chainGrpcDistributionApi.fetchDelegatorRewardsForValidatorNoThrow({
    delegatorAddress,
    validatorAddress,
  })

console.log(delegatorRewardsFromValidator)
```

### Fetch the amount and denom of all rewards for a delegator

```ts
import { ChainGrpcDistributionApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const chainGrpcDistributionApi = new ChainGrpcDistributionApi(endpoints.grpc)

const delegatorAddress = 'biya...'

const totalDelegatorRewards =
  await chainGrpcDistributionApi.fetchDelegatorRewardsNoThrow(delegatorAddress)

console.log(totalDelegatorRewards)
```
