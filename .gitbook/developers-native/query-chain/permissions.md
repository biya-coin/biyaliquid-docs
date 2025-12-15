# Permissions

Example code snippets to query data related to the permissions module on chain.

## Using gRPC

### Fetch all namespaces

```ts
import { ChainGrpcPermissionsApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const chainGrpcPermissionsApi = new ChainGrpcPermissionsApi(endpoints.grpc)

const allNamespaces = await chainGrpcPermissionsApi.fetchAllNamespaces()

console.log(allNamespaces)
```

### Fetch a namespace based on the denom

```ts
import { ChainGrpcPermissionsApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const chainGrpcPermissionsApi = new ChainGrpcPermissionsApi(endpoints.grpc)

const subdenom = 'NBIYAA'
const includeRoles = true

const namespace = await chainGrpcPermissionsApi.fetchNamespaceByDenom({
  subdenom,
  includeRoles: includeRoles,
})

console.log(namespace)
```

### Fetch all roles that are associated to an address based on the denom

```ts
import { ChainGrpcPermissionsApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const chainGrpcPermissionsApi = new ChainGrpcPermissionsApi(endpoints.grpc)

const biyachainAddress = 'biya...'
const subdenom = 'NBIYAA'

const addressRoles = await chainGrpcPermissionsApi.fetchAddressRoles({
  biyachainAddress,
  denom: subdenom,
})

console.log(addressRoles)
```

### Fetch all addresses that are associated to a given role for a denom

```ts
import { ChainGrpcPermissionsApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const chainGrpcPermissionsApi = new ChainGrpcPermissionsApi(endpoints.grpc)

const subdenom = 'NBIYAA'
const role = 'role'


const addressesByRole = await chainGrpcPermissionsApi.fetchAddressesByRole({
    subdenom,
    role: role,
})

console.log(addressesByRole)
```

### Fetch vouchers for a given biyachain address

```ts
import { ChainGrpcPermissionsApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const chainGrpcPermissionsApi = new ChainGrpcPermissionsApi(endpoints.grpc)

const biyachainAddress = 'biya...'

const vouchers = await chainGrpcPermissionsApi.fetchVouchersForAddress(
    biyachainAddress,
)

console.log(vouchers)
```
