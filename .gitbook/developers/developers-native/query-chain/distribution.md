# Distribution

从链上查询与委托给验证者相关数据的示例代码片段。

## 使用 gRPC

### 获取参数，如基础和奖励提议者奖励

```ts
import { ChainGrpcDistributionApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const chainGrpcDistributionApi = new ChainGrpcDistributionApi(endpoints.grpc)

const moduleParams = await chainGrpcDistributionApi.fetchModuleParams()

console.log(moduleParams)
```

### 获取委托人从特定验证者获得的奖励金额和面值

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

### 获取委托人所有奖励的金额和面值

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
