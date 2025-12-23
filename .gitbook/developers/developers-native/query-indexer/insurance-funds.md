# Insurance Funds

查询索引器中 insurance fund 模块相关数据的示例代码片段。

## 使用 gRPC

### 获取 biyachain 地址的赎回

```ts
import { IndexerGrpcInsuranceFundApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const indexerGrpcInsuranceFundApi = new IndexerGrpcInsuranceFundApi(
  endpoints.indexer,
)

const biyachainAddress = 'biya...'

const redemptions = await indexerGrpcInsuranceFundApi.fetchRedemptions({
  biyachainAddress,
})

console.log(redemptions)
```

### 获取保险基金

```ts
import { IndexerGrpcInsuranceFundApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const indexerGrpcInsuranceFundApi = new IndexerGrpcInsuranceFundApi(
  endpoints.indexer,
)

const insuranceFunds = await indexerGrpcInsuranceFundApi.fetchInsuranceFunds()

console.log(insuranceFunds)
```
