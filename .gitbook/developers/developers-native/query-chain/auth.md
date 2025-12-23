# Auth

查询链上 auth 模块的示例代码片段。

## 使用 gRPC

### 获取参数，如最大备注字符数或交易签名限制

```ts
import { ChainGrpcAuthApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const chainGrpcAuthApi = new ChainGrpcAuthApi(endpoints.grpc)

const moduleParams = await chainGrpcAuthApi.fetchModuleParams()

console.log(moduleParams)
```

### 获取与 biyachain 地址关联的账户详情，如账户地址、序列号或公钥

```ts
import { ChainGrpcAuthApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const chainGrpcAuthApi = new ChainGrpcAuthApi(endpoints.grpc)
const biyachainAddress = 'biya...'

const accountDetailsResponse = await chainGrpcAuthApi.fetchAccount(
  biyachainAddress,
)

console.log(accountDetailsResponse)
```

### 获取链上账户列表

```ts
import { PaginationOption, ChainGrpcAuthApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const chainGrpcAuthApi = new ChainGrpcAuthApi(endpoints.grpc)
const biyachainAddress = 'biya...'
const pagination = {...} as PaginationOption

const accounts = await chainGrpcAuthApi.fetchAccounts(/* 可选的分页参数*/)

console.log(accounts)
```

## 使用 HTTP REST

### 获取与 biyachain 地址关联的账户详情，如账户地址、序列号或公钥

```ts
import { ChainRestAuthApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const chainRestAuthApi = new ChainRestAuthApi(endpoints.rest)
const biyachainAddress = 'biya...'

const accountDetailsResponse = await chainRestAuthApi.fetchAccount(
  biyachainAddress,
)

console.log(accountDetailsResponse)
```

#### 从 biyachain 地址获取 cosmos 地址

```ts
import { ChainRestAuthApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const chainRestAuthApi = new ChainRestAuthApi(endpoints.rest)
const biyachainAddress = 'biya...'

const cosmosAddress = await chainRestAuthApi.fetchCosmosAccount(
  biyachainAddress,
)

console.log(cosmosAddress)
```
