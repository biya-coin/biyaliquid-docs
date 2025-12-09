# Staking

Example code snippets to query the chain's staking module

## Using gRPC

### Fetch parameters related to the staking module such as the unbonding time or bond denom

```ts
import { ChainGrpcStakingApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const chainGrpcStakingApi = new ChainGrpcStakingApi(endpoints.grpc)

const moduleParams = await chainGrpcStakingApi.fetchModuleParams()

console.log(moduleParams)
```

### Fetch unbonded and bonded tokens for a pool

```ts
import { ChainGrpcStakingApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const chainGrpcStakingApi = new ChainGrpcStakingApi(endpoints.grpc)

const pool = await chainGrpcStakingApi.fetchPool()

console.log(pool)
```

### Fetch validators and associated metadata

```ts
import { ChainGrpcStakingApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const chainGrpcStakingApi = new ChainGrpcStakingApi(endpoints.grpc)

const validators = await chainGrpcStakingApi.fetchValidators()

console.log(validators)
```

### Fetch validator and associated metadata from a validator address

```ts
import { ChainGrpcStakingApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const chainGrpcStakingApi = new ChainGrpcStakingApi(endpoints.grpc)

const validatorAddress = 'biyavaloper...'

const validator = await chainGrpcStakingApi.fetchValidator(validatorAddress)

console.log(validator)
```

### Fetch delegations associated with a validator

```ts
import { PaginationOption, ChainGrpcStakingApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const chainGrpcStakingApi = new ChainGrpcStakingApi(endpoints.grpc)

const validatorAddress = 'biyavaloper...'
const pagination = {...} as PaginationOption

const delegations = await chainGrpcStakingApi.fetchValidatorDelegationsNoThrow({
  validatorAddress,
  pagination /* optional pagination options */
})

console.log(delegations)
```

### Fetch unbonding delegations associated with a validator

```ts
import { PaginationOption, ChainGrpcStakingApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const chainGrpcStakingApi = new ChainGrpcStakingApi(endpoints.grpc)

const validatorAddress = 'biyavaloper...'
const pagination = {...} as PaginationOption

const unbondingDelegations = await chainGrpcStakingApi.fetchValidatorUnbondingDelegationsNoThrow({
  validatorAddress,
  pagination /* optional pagination options */
})

console.log(unbondingDelegations)
```

### Fetch delegations associated with an biyaliquid address for a specific validator

```ts
import { ChainGrpcStakingApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const chainGrpcStakingApi = new ChainGrpcStakingApi(endpoints.grpc)

const biyaliquidAddress = 'biya...'
const validatorAddress = 'biyavaloper...'

const delegation = await chainGrpcStakingApi.fetchDelegation({
  biyaliquidAddress,
  validatorAddress,
})

console.log(delegation)
```

### Fetch delegations for an biyaliquid address

```ts
import { PaginationOption, ChainGrpcStakingApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const chainGrpcStakingApi = new ChainGrpcStakingApi(endpoints.grpc)

const biyaliquidAddress = 'biya...'
const pagination = {...} as PaginationOption

const delegations = await chainGrpcStakingApi.fetchDelegationsNoThrow({
  biyaliquidAddress,
  pagination /* optional pagination options */
})

console.log(delegations)
```

### Fetch delegators for a validator

```ts
import { PaginationOption, ChainGrpcStakingApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const chainGrpcStakingApi = new ChainGrpcStakingApi(endpoints.grpc)

const validatorAddress = 'biyavaloper...'
const pagination = {...} as PaginationOption

const delegators = await chainGrpcStakingApi.fetchDelegatorsNoThrow({
  validatorAddress,
  pagination /* optional pagination options */
})

console.log(delegators)
```

### Fetch unbonding delegations for an biyaliquid address

```ts
import { PaginationOption, ChainGrpcStakingApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const chainGrpcStakingApi = new ChainGrpcStakingApi(endpoints.grpc)

const biyaliquidAddress = 'biya...'
const pagination = {...} as PaginationOption

const unbondingDelegations = await chainGrpcStakingApi.fetchUnbondingDelegationsNoThrow({
  biyaliquidAddress,
  pagination /* optional pagination options */
})

console.log(unbondingDelegations)
```

### Fetch redelegations for an biyaliquid address

```ts
import { PaginationOption, ChainGrpcStakingApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const chainGrpcStakingApi = new ChainGrpcStakingApi(endpoints.grpc)

const biyaliquidAddress = 'biya...'
const pagination = {...} as PaginationOption

const unbondingDelegations = await chainGrpcStakingApi.fetchReDelegationsNoThrow({
  biyaliquidAddress,
  pagination /* optional pagination options */
})

console.log(unbondingDelegations)
```
