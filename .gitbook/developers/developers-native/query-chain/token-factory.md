# Token Factory

查询链上 token factory 模块相关数据的示例代码片段。

## 使用 gRPC

### 获取由 _创建者_ 创建的所有面值

<pre class="language-ts"><code class="lang-ts"><strong>import { ChainGrpcTokenFactoryApi } from '@biya-coin/sdk-ts'
</strong>import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const chainGrpcTokenFactoryApi = new ChainGrpcTokenFactoryApi(endpoints.grpc)

const creator = 'biya...'
const denoms = await chainGrpcTokenFactoryApi.fetchDenomsFromCreator(creator)

console.log(denoms)
</code></pre>

### 获取面值权限元数据（即获取代币的管理员）

```ts
import { ChainGrpcTokenFactoryApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const chainGrpcTokenFactoryApi = new ChainGrpcTokenFactoryApi(endpoints.grpc)

const creator = 'biya...'
const subdenom = 'NBIYAA'
const metadata = await chainGrpcTokenFactoryApi.fetchDenomAuthorityMetadata(
  creator,
  subdenom,
)

console.log(metadata)
```
