# Bank

查询链上 bank 模块相关数据的示例代码片段。

## 使用 gRPC

### 获取 bank 模块参数

<pre class="language-ts"><code class="lang-ts"><strong>import { ChainGrpcBankApi } from '@biya-coin/sdk-ts'
</strong>import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const chainGrpcBankApi = new ChainGrpcBankApi(endpoints.grpc)

const moduleParams = await chainGrpcBankApi.fetchModuleParams()

console.log(moduleParams)
</code></pre>

### 获取 biyachain 地址的余额

```ts
import { ChainGrpcBankApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const chainGrpcBankApi = new ChainGrpcBankApi(endpoints.grpc)

const biyachainAddress = 'biya...'

const balances = await chainGrpcBankApi.fetchBalances(biyachainAddress)

console.log(balances)
```

### 按基础面值获取 cosmos 地址的余额

```ts
import { ChainGrpcBankApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const chainGrpcBankApi = new ChainGrpcBankApi(endpoints.grpc)

const biyachainAddress = 'biya1' /* 示例使用 Cosmos Hub */
const denom = 'biya'

const balance = await chainGrpcBankApi.fetchBalance({
  accountAddress: biyachainAddress,
  denom,
})

console.log(balance)
```

### 获取链上总供应量

```ts
import { PaginationOption, ChainGrpcBankApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const chainGrpcBankApi = new ChainGrpcBankApi(endpoints.grpc)

const pagination = {...} as PaginationOption

const totalSupply = await chainGrpcBankApi.fetchTotalSupply(
  pagination /* 可选的分页参数 */
)

console.log(totalSupply)
```

## 使用 HTTP REST

### 获取地址的余额

```ts
import { ChainRestBankApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const chainRestBankApi = new ChainRestBankApi(endpoints.rest)

const biyachainAddress = 'biya...'

const balances = await chainGrpcBankApi.fetchBalances(biyachainAddress)

console.log(balances)
```

### 按基础面值获取 cosmos 地址的余额

```ts
import { ChainRestBankApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const chainRestBankApi = new ChainRestBankApi(endpoints.rest)

const cosmosAddress = 'cosmos...' /* 示例使用 Cosmos Hub */
const denom = 'uatom'

const balance = await chainRestBankApi.fetchBalance(cosmosAddress, denom)

console.log(balance)
```
