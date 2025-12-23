# Leaderboard

查询索引器中 leaderboard 模块相关数据的示例代码片段。

## 使用 HTTP REST

### 获取排行榜

```ts
import { IndexerRestLeaderboardChronosApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const indexerGrpcExplorerApi = new IndexerRestLeaderboardChronosApi(
  `${endpoints.chronos}/api/chronos/v1/leaderboard`,
)

const SelectList = {
  Day: '1d',
  Week: '7d',
}

const resolution = SelectList.Day

const leaderboard = await indexerGrpcExplorerApi.fetchLeaderboard(resolution)

console.log(leaderboard)
```
