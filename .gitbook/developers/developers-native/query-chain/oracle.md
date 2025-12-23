# Oracle

通过 oracle api 查询链的示例代码片段。

## 使用 gRPC

### 获取与 oracle 相关的参数

```ts
import { ChainGrpcOracleApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const chainGrpcOracleApi = new ChainGrpcOracleApi(endpoints.grpc)

const moduleParams = await chainGrpcOracleApi.fetchModuleParams()

console.log(moduleParams)
```
