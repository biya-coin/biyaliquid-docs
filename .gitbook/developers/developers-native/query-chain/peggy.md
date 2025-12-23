# Peggy

通过 peggy api 查询链的示例代码片段。

## 使用 gRPC

### 获取与 peggy 相关的参数

```ts
import { ChainGrpcPeggyApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const chainGrpcPeggyApi = new ChainGrpcPeggyApi(endpoints.grpc)

const moduleParams = await chainGrpcPeggyApi.fetchModuleParams()

console.log(moduleParams)
```
