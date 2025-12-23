# 使用 GraphQL 查询以太坊

从以太坊查询数据的示例代码片段。

## 使用 GraphQL

### 获取用户在以太坊链上的存款

```ts
import { ApolloConsumer } from '@biya-coin/sdk-ts'
import {
  Network,
  getNetworkEndpoints,
  getPeggyGraphQlEndpointForNetwork,
} from '@biya-coin/networks'

const apolloConsumer = new ApolloConsumer(
  getPeggyGraphQlEndpointForNetwork(Network.Testnet),
)

const ethereumAddress = '0x...'

const userDeposits = apolloConsumer.fetchUserDeposits(ethereumAddress)

console.log(userDeposits)
```

### 获取用户在特定时间在以太坊链上的存款

```ts
import { ApolloConsumer } from '@biya-coin/sdk-ts'
import {
  Network,
  getNetworkEndpoints,
  getPeggyGraphQlEndpointForNetwork,
} from '@biya-coin/networks'

const apolloConsumer = new ApolloConsumer(
  getPeggyGraphQlEndpointForNetwork(Network.Testnet),
)

const ethereumAddress = '0x...'
const timestamp = 13434333

const userDeposits = apolloConsumer.fetchUserBridgeDeposits(
  ethereumAddress,
  timestamp,
)

console.log(userDeposits)
```
