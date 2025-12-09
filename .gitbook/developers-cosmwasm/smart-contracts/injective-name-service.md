# Biyaliquid Name Service

Within this section, we will look at how to query the Biyaliquid name service contracts.

## Abstraction Service (deprecated)

~~You can use our `BiyaNameService` abstraction to query the smart contracts with a single method call. Below this example, you can also find the raw implementation on how to query the smart contracts in case you need more flexibility.~~

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

## Raw Smart Contract Querying

Example code snippets to resolve .biya domain name.

## Domain Resolution

* Get resolver address

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

* Get address for .biya domain name.

```ts
import {
  Network,
  getNetworkEndpoints,
  getBiyaNameReverseResolverContractForNetwork,
} from '@biya-coin/networks'
import {
  ChainGrpcWasmApi,
  QueryBiyaliquidAddress,
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

const query = new QueryBiyaliquidAddress({ node }).toPayload()

const response = await chainGrpcWasmApi.fetchSmartContractState(
  reverseResolverContractAddress,
  query,
)

const biyaliquidAddress =
  BiyaNameServiceQueryTransformer.biyaliquidAddressResponseToBiyaliquidAddress(
    response,
  )

if (!biyaliquidAddress) {
  throw new Error(`address not found for ${name}`)
}

console.log(biyaliquidAddress)
```

## Reverse Resolution

* Get the primary name for biyaliquid address.

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
const biyaliquidAddress = ''

const query = new QueryBiyaName({ address: biyaliquidAddress }).toPayload()

const response = await chainGrpcWasmApi.fetchSmartContractState(
  reverseResolverContractAddress,
  query,
)

const name = BiyaNameServiceQueryTransformer.biyaliquidNameResponseToBiyaliquidName(response)

if (!name) {
  throw new Error(`.biya not found for ${biyaliquidAddress}`)
}

const addressForName = /** fetch as above example */

if (addressForName.toLowerCase() !== address.toLowerCase()) {
  throw new Error(`.biya not found for ${biyaliquidAddress}`)
}

console.log(name)
```
