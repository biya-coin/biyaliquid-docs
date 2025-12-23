# Tendermint

查询链节点相关数据的示例代码片段。

## 使用 HTTP REST

### 获取最新区块信息

```ts
import { ChainRestTendermintApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const chainRestTendermintApi = new ChainRestTendermintApi(endpoints.rest)

const latestBlock = await chainRestTendermintApi.fetchLatestBlock()

console.log(latestBlock)
```

### 获取链节点信息

```ts
import { ChainRestTendermintApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const chainRestTendermintApi = new ChainRestTendermintApi(endpoints.rest)

const nodeInfo = await chainRestTendermintApi.fetchNodeInfo()

console.log(nodeInfo)
```
