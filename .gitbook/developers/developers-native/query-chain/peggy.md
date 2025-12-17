# Peggy

Example code snippets to query the chain via the peggy api.

## Using gRPC

### Fetch parameters related to peggy

```ts
import { ChainGrpcPeggyApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const chainGrpcPeggyApi = new ChainGrpcPeggyApi(endpoints.grpc)

const moduleParams = await chainGrpcPeggyApi.fetchModuleParams()

console.log(moduleParams)
```
