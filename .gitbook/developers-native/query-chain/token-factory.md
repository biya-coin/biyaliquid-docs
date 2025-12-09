# Token Factory

Example code snippets to query the chain for token factory module related data.

## Using gRPC

### Fetch all denoms created by _creator_

<pre class="language-ts"><code class="lang-ts"><strong>import { ChainGrpcTokenFactoryApi } from '@biya-coin/sdk-ts'
</strong>import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const chainGrpcTokenFactoryApi = new ChainGrpcTokenFactoryApi(endpoints.grpc)

const creator = 'biya...'
const denoms = await chainGrpcTokenFactoryApi.fetchDenomsFromCreator(creator)

console.log(denoms)
</code></pre>

### Fetch denom authority metadata (i.e fetch admin of a token)

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
