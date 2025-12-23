# Wasm

查询链上 wasm 模块的示例代码片段

## 使用 gRPC

### 获取合约的账户余额 注意可以传递分页参数以获取其他账户。

```ts
import { ChainGrpcWasmApi, PaginationOption } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const chainGrpcWasmApi = new ChainGrpcWasmApi(endpoints.grpc)

const contractAddress = 'biya...'
const pagination = {...} as PaginationOption

const contractAccountsBalance = await chainGrpcWasmApi.fetchContractAccountsBalance({
    contractAddress,
    pagination /* 可选的分页选项 */
})

console.log(contractAccountsBalance)
```

### 获取与合约相关的信息

```ts
import { ChainGrpcWasmApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const chainGrpcWasmApi = new ChainGrpcWasmApi(endpoints.grpc)

const contractAddress = 'biya...'

const contractInfo = await chainGrpcWasmApi.fetchContractInfo(contractAddress)

console.log(contractInfo)
```

### 获取合约历史

```ts
import { ChainGrpcWasmApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const chainGrpcWasmApi = new ChainGrpcWasmApi(endpoints.grpc)

const contractAddress = 'biya...'

const contractHistory = await chainGrpcWasmApi.fetchContractHistory(
  contractAddress,
)

console.log(contractHistory)
```

### 获取智能合约的状态

```ts
import { ChainGrpcWasmApi, toBase64 } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const chainGrpcWasmApi = new ChainGrpcWasmApi(endpoints.grpc)

const contractAddress = 'biya...'
const query = '...'
const queryFromObject = toBase64({ get_coin: {} })

const contractState = await chainGrpcWasmApi.fetchSmartContractState({
  contractAddress,
  query /* 可选的字符串查询 - 必须是 base64 格式或使用 queryFromObject */,
})

console.log(contractState)
```

### 获取智能合约的原始状态

```ts
import { ChainGrpcWasmApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const chainGrpcWasmApi = new ChainGrpcWasmApi(endpoints.grpc)

const contractAddress = 'biya...'
const query = '...'
const queryFromObject = toBase64({ get_coin: {} })

const rawContractState = await chainGrpcWasmApi.fetchRawContractState({
  contractAddress,
  query /* 可选的字符串查询 - 必须是 base64 格式或使用 queryFromObject */,
})

console.log(rawContractState)
```

### 获取与合约关联的代码

```ts
import { PaginationOption, ChainGrpcWasmApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const chainGrpcWasmApi = new ChainGrpcWasmApi(endpoints.grpc)

const pagination = {...} as PaginationOption


const rawContractState = await chainGrpcWasmApi.fetchRawContractState(
pagination /* 可选的分页选项 */
)

console.log(rawContractState)
```

### 获取与合约代码关联的信息

```ts
import { ChainGrpcWasmApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const chainGrpcWasmApi = new ChainGrpcWasmApi(endpoints.grpc)

const codeId = 1

const codeDetails = await chainGrpcWasmApi.fetchContractCode(codeId)

console.log(codeDetails)
```

### 获取与代码关联的合约

```ts
import { PaginationOption, ChainGrpcWasmApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const chainGrpcWasmApi = new ChainGrpcWasmApi(endpoints.grpc)

const codeId = 1
const pagination = {...} as PaginationOption

const contracts = await chainGrpcWasmApi.fetchContractCodeContracts({
  codeId,
  pagination /* 可选的分页选项 */
})

console.log(contracts)
```
