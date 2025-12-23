# WasmX

查询链上 wasmX 模块的示例代码片段

## 使用 gRPC

### 获取与 wasmX 模块相关的参数

```ts
import { ChainGrpcWasmXApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const chainGrpcWasmXApi = new ChainGrpcWasmXApi(endpoints.grpc)

const moduleParams = await chainGrpcWasmXApi.fetchModuleParams()

console.log(moduleParams)
```

### 获取 wasmX 模块状态

```ts
import { ChainGrpcWasmXApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const chainGrpcWasmXApi = new ChainGrpcWasmXApi(endpoints.grpc)

const moduleState = await chainGrpcWasmXApi.fetchModuleState()

console.log(moduleState)
```
