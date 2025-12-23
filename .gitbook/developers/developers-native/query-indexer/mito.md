# Mito

查询索引器中 Mito vault 模块相关数据的示例代码片段。

{% hint style="info" %}
Mito 文档已移至此处，请访问 [Mito's Docs](https://docs.mito.fi/)。
{% endhint %}

## (已过时) 使用 gRPC

### 根据合约地址获取金库，如金库的 tvl 或利润

```ts
import { IndexerGrpcNinjaApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const indexerGrpcNinjaApi = new IndexerGrpcNinjaApi(endpoints.ninjaApi)

const contractAddress = '0x...' /* 可选参数 */
const slug = 'derivative-vault' /* 可选参数 */

const vault = await indexerGrpcNinjaApi.fetchVault({
  contractAddress,
  slug,
})

console.log(vault)
```

### 获取金库和相关详情

```ts
import { IndexerGrpcNinjaApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const indexerGrpcNinjaApi = new IndexerGrpcNinjaApi(endpoints.ninjaApi)

const vault = await indexerGrpcNinjaApi.fetchVaults()

console.log(vault)
```

### 根据金库地址获取 lp 代币价格图表

```ts
import { IndexerGrpcNinjaApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const indexerGrpcNinjaApi = new IndexerGrpcNinjaApi(endpoints.ninjaApi)

const vaultAddress = 'biya...'
const from = 50 /* 可选分页参数 */
const to = 150 /* 可选分页参数 */

const lpTokenPriceChart = await indexerGrpcNinjaApi.fetchLpTokenPriceChart({
  vaultAddress,
  from,
  to,
})

console.log(lpTokenPriceChart)
```

### 根据金库地址获取 tvl 代币图表

```ts
import { IndexerGrpcNinjaApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const indexerGrpcNinjaApi = new IndexerGrpcNinjaApi(endpoints.ninjaApi)

const vaultAddress = 'biya...'
const from = 50 /* 可选分页参数 */
const to = 150 /* 可选分页参数 */

const tvlChart = await indexerGrpcNinjaApi.fetchTVLChartRequest({
  vaultAddress,
  from,
  to,
})

console.log(tvlChart)
```

### 获取与 lp 代币持有者关联的金库

```ts
import { IndexerGrpcNinjaApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const indexerGrpcNinjaApi = new IndexerGrpcNinjaApi(endpoints.ninjaApi)

const holderAddress = 'biya...'

const vaults = await indexerGrpcNinjaApi.fetchVaultsByHolderAddress({
  holderAddress,
})

console.log(vaults)
```

### 从金库地址获取 lp 代币持有者

```ts
import { IndexerGrpcNinjaApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const indexerGrpcNinjaApi = new IndexerGrpcNinjaApi(endpoints.ninjaApi)

const vaultAddress = 'biya...'

const holders = await indexerGrpcNinjaApi.fetchLPHolders({
  vaultAddress,
})

console.log(holders)
```

### 获取 lp 持有者的投资组合

```ts
import { IndexerGrpcNinjaApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const indexerGrpcNinjaApi = new IndexerGrpcNinjaApi(endpoints.ninjaApi)

const holderAddress = 'biya...'

const portfolio = await indexerGrpcNinjaApi.fetchHolderPortfolio(holderAddress)

console.log(portfolio)
```

### 获取排行榜以查看盈亏排名

```ts
import { IndexerGrpcNinjaApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const indexerGrpcNinjaApi = new IndexerGrpcNinjaApi(endpoints.ninjaApi)

const leaderboard = await indexerGrpcNinjaApi.fetchLeaderboard()

console.log(leaderboard)
```
