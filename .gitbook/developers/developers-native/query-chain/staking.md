# Staking

查询链上 staking 模块的示例代码片段

## 使用 gRPC

### 获取与 staking 模块相关的参数，如解绑时间或绑定面值

```ts
import { ChainGrpcStakingApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const chainGrpcStakingApi = new ChainGrpcStakingApi(endpoints.grpc)

const moduleParams = await chainGrpcStakingApi.fetchModuleParams()

console.log(moduleParams)
```

### 获取池的未绑定和已绑定代币

```ts
import { ChainGrpcStakingApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const chainGrpcStakingApi = new ChainGrpcStakingApi(endpoints.grpc)

const pool = await chainGrpcStakingApi.fetchPool()

console.log(pool)
```

### 获取验证者和相关元数据

```ts
import { ChainGrpcStakingApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const chainGrpcStakingApi = new ChainGrpcStakingApi(endpoints.grpc)

const validators = await chainGrpcStakingApi.fetchValidators()

console.log(validators)
```

### 从验证者地址获取验证者和相关元数据

```ts
import { ChainGrpcStakingApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const chainGrpcStakingApi = new ChainGrpcStakingApi(endpoints.grpc)

const validatorAddress = 'biyavaloper...'

const validator = await chainGrpcStakingApi.fetchValidator(validatorAddress)

console.log(validator)
```

### 获取与验证者关联的委托

```ts
import { PaginationOption, ChainGrpcStakingApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const chainGrpcStakingApi = new ChainGrpcStakingApi(endpoints.grpc)

const validatorAddress = 'biyavaloper...'
const pagination = {...} as PaginationOption

const delegations = await chainGrpcStakingApi.fetchValidatorDelegationsNoThrow({
  validatorAddress,
  pagination /* 可选的分页选项 */
})

console.log(delegations)
```

### 获取与验证者关联的解绑委托

```ts
import { PaginationOption, ChainGrpcStakingApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const chainGrpcStakingApi = new ChainGrpcStakingApi(endpoints.grpc)

const validatorAddress = 'biyavaloper...'
const pagination = {...} as PaginationOption

const unbondingDelegations = await chainGrpcStakingApi.fetchValidatorUnbondingDelegationsNoThrow({
  validatorAddress,
  pagination /* 可选的分页选项 */
})

console.log(unbondingDelegations)
```

### 获取 biyachain 地址对特定验证者的委托

```ts
import { ChainGrpcStakingApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const chainGrpcStakingApi = new ChainGrpcStakingApi(endpoints.grpc)

const biyachainAddress = 'biya...'
const validatorAddress = 'biyavaloper...'

const delegation = await chainGrpcStakingApi.fetchDelegation({
  biyachainAddress,
  validatorAddress,
})

console.log(delegation)
```

### 获取 biyachain 地址的委托

```ts
import { PaginationOption, ChainGrpcStakingApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const chainGrpcStakingApi = new ChainGrpcStakingApi(endpoints.grpc)

const biyachainAddress = 'biya...'
const pagination = {...} as PaginationOption

const delegations = await chainGrpcStakingApi.fetchDelegationsNoThrow({
  biyachainAddress,
  pagination /* 可选的分页选项 */
})

console.log(delegations)
```

### 获取验证者的委托人

```ts
import { PaginationOption, ChainGrpcStakingApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const chainGrpcStakingApi = new ChainGrpcStakingApi(endpoints.grpc)

const validatorAddress = 'biyavaloper...'
const pagination = {...} as PaginationOption

const delegators = await chainGrpcStakingApi.fetchDelegatorsNoThrow({
  validatorAddress,
  pagination /* 可选的分页选项 */
})

console.log(delegators)
```

### 获取 biyachain 地址的解绑委托

```ts
import { PaginationOption, ChainGrpcStakingApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const chainGrpcStakingApi = new ChainGrpcStakingApi(endpoints.grpc)

const biyachainAddress = 'biya...'
const pagination = {...} as PaginationOption

const unbondingDelegations = await chainGrpcStakingApi.fetchUnbondingDelegationsNoThrow({
  biyachainAddress,
  pagination /* 可选的分页选项 */
})

console.log(unbondingDelegations)
```

### 获取 biyachain 地址的重新委托

```ts
import { PaginationOption, ChainGrpcStakingApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const chainGrpcStakingApi = new ChainGrpcStakingApi(endpoints.grpc)

const biyachainAddress = 'biya...'
const pagination = {...} as PaginationOption

const unbondingDelegations = await chainGrpcStakingApi.fetchReDelegationsNoThrow({
  biyachainAddress,
  pagination /* 可选的分页选项 */
})

console.log(unbondingDelegations)
```
