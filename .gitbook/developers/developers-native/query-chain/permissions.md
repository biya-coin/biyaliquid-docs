# Permissions

查询链上 permissions 模块相关数据的示例代码片段。

## 使用 gRPC

### 获取所有命名空间

```ts
import { ChainGrpcPermissionsApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const chainGrpcPermissionsApi = new ChainGrpcPermissionsApi(endpoints.grpc)

const allNamespaces = await chainGrpcPermissionsApi.fetchAllNamespaces()

console.log(allNamespaces)
```

### 根据面值获取命名空间

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

### 根据面值获取与地址关联的所有角色

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

### 获取面值的给定角色关联的所有地址

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

### 获取给定 biyachain 地址的凭证

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
