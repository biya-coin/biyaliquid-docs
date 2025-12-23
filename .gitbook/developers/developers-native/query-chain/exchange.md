# Exchange

查询链上 exchange 模块的示例代码片段。

## 使用 gRPC

### 获取参数，如默认现货和衍生品费用/交易奖励

```ts
import { ChainGrpcExchangeApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const chainGrpcExchangeApi = new ChainGrpcExchangeApi(endpoints.grpc)

const moduleParams = await chainGrpcExchangeApi.fetchModuleParams()

console.log(moduleParams)
```

### 获取费用折扣计划

```ts
import { ChainGrpcExchangeApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const chainGrpcExchangeApi = new ChainGrpcExchangeApi(endpoints.grpc)

const feeDiscountSchedule =
  await chainGrpcExchangeApi.fetchFeeDiscountSchedule()

console.log(feeDiscountSchedule)
```

### 获取与 biyachain 地址关联的费用折扣

```ts
import { ChainGrpcExchangeApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const chainGrpcExchangeApi = new ChainGrpcExchangeApi(endpoints.grpc)

const biyachainAddress = 'biya...'

const feeDiscountAccountInfo =
  await chainGrpcExchangeApi.fetchFeeDiscountAccountInfo(biyachainAddress)

console.log(feeDiscountAccountInfo)
```

### 获取有关交易奖励活动的详情，如总奖励积分

```ts
import { ChainGrpcExchangeApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const chainGrpcExchangeApi = new ChainGrpcExchangeApi(endpoints.grpc)

const tradingRewardsCampaign =
  await chainGrpcExchangeApi.fetchTradingRewardsCampaign()

console.log(tradingRewardsCampaign)
```

### 获取 biyachain 地址的交易奖励积分

```ts
import { ChainGrpcExchangeApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const chainGrpcExchangeApi = new ChainGrpcExchangeApi(endpoints.grpc)

const biyachainAddress = 'biya...'

const tradeRewardsPoints = await chainGrpcExchangeApi.fetchTradeRewardsPoints(
  biyachainAddress,
)

console.log(tradeRewardsPoints)
```

### 获取 biyachain 地址的待处理交易奖励积分

```ts
import { ChainGrpcExchangeApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const chainGrpcExchangeApi = new ChainGrpcExchangeApi(endpoints.grpc)

const biyachainAddresses = ['biya...']

const pendingTradeRewardsPoints =
  await chainGrpcExchangeApi.fetchPendingTradeRewardPoints(biyachainAddresses)

console.log(pendingTradeRewardsPoints)
```

#### 获取当前持仓，如 subaccountId、marketId 和持仓

```ts
import { ChainGrpcExchangeApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const chainGrpcExchangeApi = new ChainGrpcExchangeApi(endpoints.grpc)

const positions = await chainGrpcExchangeApi.fetchPositions(biyachainAddresses)

console.log(positions)
```

### 获取子账户交易随机数

```ts
import { ChainGrpcExchangeApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const chainGrpcExchangeApi = new ChainGrpcExchangeApi(endpoints.grpc)

const subaccountId = '0x...'

const subaccountTradeNonce =
  await chainGrpcExchangeApi.fetchSubaccountTradeNonce(subaccountId)

console.log(subaccountTradeNonce)
```
