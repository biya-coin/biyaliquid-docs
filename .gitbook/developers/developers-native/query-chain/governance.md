# Governance

查询链上 governance 模块的示例代码片段。

## 使用 gRPC

### 获取参数，如投票期、最大存款期或计票详情

```ts
import { ChainGrpcGovApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const chainGrpcGovApi = new ChainGrpcGovApi(endpoints.grpc)

const moduleParams = await chainGrpcGovApi.fetchModuleParams()

console.log(moduleParams)
```

### 根据状态获取提案

```ts
import { PaginationOption, ChainGrpcGovApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'
import { ProposalStatusMap } from '@biya-coin/chain-api'

const endpoints = getNetworkEndpoints(Network.Testnet)
const chainGrpcGovApi = new ChainGrpcGovApi(endpoints.grpc)

const status = 3 as ProposalStatusMap[keyof ProposalStatusMap]
const pagination = {...} as PaginationOption

const proposals = await chainGrpcGovApi.fetchProposals({
  status,
  pagination /* 可选的分页参数 */
})

console.log(proposals)
```

### 根据提案 ID 获取提案详情

```ts
import { ChainGrpcGovApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const chainGrpcGovApi = new ChainGrpcGovApi(endpoints.grpc)

const proposalId = 123

const proposalDetails = await chainGrpcGovApi.fetchProposal(proposalId)

console.log(proposalDetails)
```

### 根据提案 ID 获取提案存款

```ts
import { PaginationOption, ChainGrpcGovApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const chainGrpcGovApi = new ChainGrpcGovApi(endpoints.grpc)

const proposalId = 123
const pagination = {...} as PaginationOption

const proposalDeposits = await chainGrpcGovApi.fetchProposalDeposits({
  proposalId,
  pagination /* 可选的分页参数 */
})

console.log(proposalDeposits)
```

### 根据提案 ID 获取提案详情

```ts
import { ChainGrpcGovApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const chainGrpcGovApi = new ChainGrpcGovApi(endpoints.grpc)

const proposalId = 123

const proposalDetails = await chainGrpcGovApi.fetchProposal(proposalId)

console.log(proposalDetails)
```

### 根据提案 ID 获取提案存款

```ts
import { PaginationOption, ChainGrpcGovApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const chainGrpcGovApi = new ChainGrpcGovApi(endpoints.grpc)

const proposalId = 123
const pagination = {...} as PaginationOption

const proposalDeposits = await chainGrpcGovApi.fetchProposalDeposits({
  proposalId,
  pagination /* 可选的分页参数 */
})

console.log(proposalDeposits)
```

### 根据提案 ID 获取提案投票

```ts
import { PaginationOption, ChainGrpcGovApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const chainGrpcGovApi = new ChainGrpcGovApi(endpoints.grpc)

const proposalId = 123

const proposalVotes = await chainGrpcGovApi.fetchProposalVotes({
  proposalId,
  pagination: /* 可选的分页选项 */
})

console.log(proposalVotes)
```

### 根据提案 ID 获取提案计票

```ts
import { PaginationOption, ChainGrpcGovApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const chainGrpcGovApi = new ChainGrpcGovApi(endpoints.grpc)

const proposalId = 123
const pagination = {...} as PaginationOption

const proposalTally = await chainGrpcGovApi.fetchProposalTally({
  proposalId,
  pagination /* 可选的分页选项 */
})

console.log(proposalTally)
```
