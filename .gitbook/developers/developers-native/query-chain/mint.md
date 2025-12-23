# Mint

查询链上 mint 模块的示例代码片段。

## 使用 gRPC

### 获取与 mint 模块相关的参数

```ts
import { ChainGrpcMintApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const chainGrpcMintApi = new ChainGrpcMintApi(endpoints.grpc)

const moduleParams = await chainGrpcMintApi.fetchModuleParams()

console.log(moduleParams)
```

### 获取通胀率

```ts
import { ChainGrpcMintApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const chainGrpcMintApi = new ChainGrpcMintApi(endpoints.grpc)

const inflation = await chainGrpcMintApi.fetchInflation()

console.log(inflation)
```

### 获取年度供应量

```ts
import { ChainGrpcMintApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const chainGrpcMintApi = new ChainGrpcMintApi(endpoints.grpc)

const annualProvisions = await chainGrpcMintApi.fetchAnnualProvisions()

console.log(annualProvisions)
```
