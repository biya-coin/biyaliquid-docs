# Markets

查询索引器中所有市场数据的示例代码片段

## 使用 HTTP REST

### 获取市场历史

```ts
import { IndexerRestMarketChronosApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const indexerRestMarketChronosApi = new IndexerRestMarketChronosApi(
  `${endpoints.chronos}/api/chronos/v1/market`,
)

const SelectList = {
  Hour: '60',
  Day: '1d',
  Week: '7d',
}
// const resolution = MARKETS_HISTORY_CHART_ONE_HOUR
// const countback = MARKETS_HISTORY_CHART_SEVEN_DAYS

const marketIds = ['0x']
const countback = 154 // 以小时为单位
const resolution = SelectList.Day

const marketsHistory = await indexerRestMarketChronosApi.fetchMarketsHistory({
  marketIds,
  resolution,
  countback,
})

console.log(marketsHistory)
```
