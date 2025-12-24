# Biya Chain 名称服务

在本节中，我们将了解如何查询 Biya Chain 名称服务合约。

## 抽象服务（已弃用）

~~您可以使用我们的 `BiyaNameService` 抽象通过单个方法调用来查询智能合约。在此示例下方，您还可以找到如何查询智能合约的原始实现，以防您需要更多灵活性。~~

<pre class="language-typescript"><code class="lang-typescript">import { getNetworkEndpoints, Network } from '@biya-coin/network'
import { BiyaNameService } from '@biya-coin/sdk-ui-ts'

const biyaNameService = new BiyaNameService(Network.Testnet)
<strong>const name = 'nbiyaa.biya'
</strong>
// Fetch the address for the particular name
const addressForName = await biyaNameService.fetchBiyaAddress(name)

// Fetch the name for the particular address
const nameFromAddress = await biyaNameService.fetchBiyaName(addressForName)
</code></pre>

## 原始智能合约查询

解析 .biya 域名的示例代码片段。

## 域名解析

* 获取解析器地址

```ts
import {
  Network,
  getNetworkEndpoints,
  getBiyaNameRegistryContractForNetwork,
} from '@biya-coin/networks'
import {
  ChainGrpcWasmApi,
  QueryResolverAddress,
  BiyaNameServiceQueryTransformer,
} from '@biya-coin/sdk-ts'

const endpoints = getNetworkEndpoints(Network.Testnet)
const chainGrpcWasmApi = new ChainGrpcWasmApi(endpoints.grpc)

const registryContractAddress = getBiyaNameRegistryContractForNetwork(
  Network.Testnet,
)

const node = ''

const query = new QueryResolverAddress({ node }).toPayload()

const response = await chainGrpcWasmApi.fetchSmartContractState(
  registryContractAddress,
  query,
)

const resolverAddress =
  BiyaNameServiceQueryTransformer.resolverAddressResponseToResolverAddress(
    response,
  )

console.log(resolverAddress)
```

* 获取 .biya 域名的地址。

```ts
import {
  Network,
  getNetworkEndpoints,
  getBiyaNameReverseResolverContractForNetwork,
} from '@biya-coin/networks'
import {
  ChainGrpcWasmApi,
  QueryBiyachainAddress,
  BiyaNameServiceQueryTransformer,
} from '@biya-coin/sdk-ts'
import { nameToNode, normalizeName } from '@biya-coin/sdk-ts'

const endpoints = getNetworkEndpoints(Network.Testnet)
const chainGrpcWasmApi = new ChainGrpcWasmApi(endpoints.grpc)

const reverseResolverContractAddress =
  getBiyaNameReverseResolverContractForNetwork(Network.Testnet)

const name = 'allen.biya'

const normalizedName = normalizeName(name)
const node = nameToNode(normalizedName)

const query = new QueryBiyachainAddress({ node }).toPayload()

const response = await chainGrpcWasmApi.fetchSmartContractState(
  reverseResolverContractAddress,
  query,
)

const biyachainAddress =
  BiyaNameServiceQueryTransformer.biyachainAddressResponseToBiyachainAddress(
    response,
  )

if (!biyachainAddress) {
  throw new Error(`address not found for ${name}`)
}

console.log(biyachainAddress)
```

## 反向解析

* 获取 biyachain 地址的主要名称。

```ts
import {
  QueryBiyaName,
  ChainGrpcWasmApi,
  BiyaNameServiceQueryTransformer
} from '@biya-coin/sdk-ts'
  import {
  Network,
  getNetworkEndpoints,
  getBiyaNameReverseResolverContractForNetwork
} from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const chainGrpcWasmApi = new ChainGrpcWasmApi(endpoints.grpc)

const reverseResolverContractAddress =
  getBiyaNameReverseResolverContractForNetwork(Network.Testnet)
const biyachainAddress = ''

const query = new QueryBiyaName({ address: biyachainAddress }).toPayload()

const response = await chainGrpcWasmApi.fetchSmartContractState(
  reverseResolverContractAddress,
  query,
)

const name = BiyaNameServiceQueryTransformer.biyachainNameResponseToBiyachainName(response)

if (!name) {
  throw new Error(`.biya not found for ${biyachainAddress}`)
}

const addressForName = /** fetch as above example */

if (addressForName.toLowerCase() !== address.toLowerCase()) {
  throw new Error(`.biya not found for ${biyachainAddress}`)
}

console.log(name)
```
