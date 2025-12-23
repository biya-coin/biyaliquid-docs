# Insurance Funds

查询链上保险基金相关数据的示例代码片段。

## 使用 gRPC

### 获取默认赎回通知期限

```ts
import { ChainGrpcInsuranceFundApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const chainGrpcInsuranceFundApi = new ChainGrpcInsuranceFundApi(endpoints.grpc)

const moduleParams = await chainGrpcInsuranceFundApi.fetchModuleParams()

console.log(moduleParams)
```

### 获取保险基金和相关元数据

```ts
import { ChainGrpcInsuranceFundApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const chainGrpcInsuranceFundApi = new ChainGrpcInsuranceFundApi(endpoints.grpc)

const insuranceFunds = await chainGrpcInsuranceFundApi.fetchInsuranceFunds()

console.log(insuranceFunds)
```

### 根据市场 ID 获取保险基金和相关元数据

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

### 获取给定 biyachain 地址在市场中的估计赎回

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

### 获取给定 biyachain 地址在市场中的待处理赎回

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
