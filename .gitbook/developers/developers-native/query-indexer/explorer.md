# Explorer

查询索引器中 explorer 模块相关数据的示例代码片段。

## 使用 gRPC

### 通过哈希获取交易

```ts
import { IndexerGrpcExplorerApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const indexerGrpcExplorerApi = new IndexerGrpcExplorerApi(endpoints.explorer)

const txsHash = '...'

const transaction = await indexerGrpcExplorerApi.fetchTxByHash(txsHash)

console.log(transaction)
```

### 通过地址获取账户交易

```ts
import { IndexerGrpcExplorerApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const indexerGrpcExplorerApi = new IndexerGrpcExplorerApi(endpoints.explorer)

const biyachainAddress = 'biya...'

const account = await indexerGrpcExplorerApi.fetchAccountTx({
  biyachainAddress,
})

console.log(account)
```

### 通过地址获取验证者

```ts
import { IndexerGrpcExplorerApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const indexerGrpcExplorerApi = new IndexerGrpcExplorerApi(endpoints.explorer)

const validatorAddress = 'biyavaloper...'

const validator = await indexerGrpcExplorerApi.fetchValidator(validatorAddress)

console.log(validator)
```

### 通过地址获取验证者正常运行时间

```ts
import { IndexerGrpcExplorerApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const indexerGrpcExplorerApi = new IndexerGrpcExplorerApi(endpoints.explorer)

const validatorAddress = 'biyavaloper...'

const validatorUptime = await indexerGrpcExplorerApi.fetchValidatorUptime(
  validatorAddress,
)

console.log(validatorUptime)
```

### 通过地址获取验证者正常运行时间

```ts
import { IndexerGrpcExplorerApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const indexerGrpcExplorerApi = new IndexerGrpcExplorerApi(endpoints.explorer)

const validatorAddress = 'biyavaloper...'

const validatorUptime = await indexerGrpcExplorerApi.fetchValidatorUptime(
  validatorAddress,
)

console.log(validatorUptime)
```

### 从以太坊获取 Peggy 存款交易

```ts
import { IndexerGrpcExplorerApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const indexerGrpcExplorerApi = new IndexerGrpcExplorerApi(endpoints.explorer)

const sender = '0x...' /* 可选参数 */
const receiver = 'biya...' /* 可选参数 */
const limit = 100 /* 可选分页参数 */
const skip = 20 /* 可选分页参数 */

const peggyDeposits = await indexerGrpcExplorerApi.fetchPeggyDepositTxs({
  sender,
  receiver,
  limit,
  skip,
})

console.log(peggyDeposits)
```

### 获取到以太坊的 Peggy 提款交易

```ts
import { IndexerGrpcExplorerApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const indexerGrpcExplorerApi = new IndexerGrpcExplorerApi(endpoints.explorer)

const receiver = '0x...' /* 可选参数 */
const sender = 'biya...' /* 可选参数 */
const limit = 100 /* 可选分页参数 */
const skip = 20 /* 可选分页参数 */

const peggyWithdrawals = await indexerGrpcExplorerApi.fetchPeggyWithdrawalTxs({
  sender,
  receiver,
  limit,
  skip,
})

console.log(peggyWithdrawals)
```

### 获取区块

```ts
import { IndexerGrpcExplorerApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const indexerGrpcExplorerApi = new IndexerGrpcExplorerApi(endpoints.explorer)

const after = 30 /* 可选分页参数 */
const limit = 100 /* 可选分页参数 */

const blocks = await indexerGrpcExplorerApi.fetchBlocks({
  after,
  limit,
})

console.log(blocks)
```

### 通过高度获取区块

```ts
import { IndexerGrpcExplorerApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const indexerGrpcExplorerApi = new IndexerGrpcExplorerApi(endpoints.explorer)

const height = 123456
const block = await indexerGrpcExplorerApi.fetchBlock(height)

console.log(block)
```

### 获取交易

```ts
import { IndexerGrpcExplorerApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const indexerGrpcExplorerApi = new IndexerGrpcExplorerApi(endpoints.explorer)

const after = 20 /* 可选分页参数 */
const limit = 100 /* 可选分页参数 */

const transactions = await indexerGrpcExplorerApi.fetchTxs({
  after,
  limit,
})

console.log(transactions)
```

### 获取 IBC 转账交易

```ts
import { IndexerGrpcExplorerApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const indexerGrpcExplorerApi = new IndexerGrpcExplorerApi(endpoints.explorer)

const sender = 'osmo...'
const receiver = 'biya...'

const ibcTransactions = await indexerGrpcExplorerApi.fetchIBCTransferTxs({
  sender,
  receiver,
})

console.log(ibcTransactions)
```

## 使用 HTTP REST

### 获取区块和详情

```ts
import { IndexerRestExplorerApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const indexerRestExplorerApi = new IndexerRestExplorerApi(
  `${endpoints.explorer}/api/explorer/v1`,
)

const blockHashHeight = 1

const block = await indexerRestExplorerApi.fetchBlock(blockHashHeight)

console.log(block)
```

### 获取区块和详情

```ts
import { IndexerRestExplorerApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const indexerRestExplorerApi = new IndexerRestExplorerApi(
  `${endpoints.explorer}/api/explorer/v1`,
)

const before = 200 /* 可选分页参数 */
const limit = 100 /* 可选分页参数 */

const blocks = await indexerRestExplorerApi.fetchBlocks({
  before,
  limit,
})

console.log(blocks)
```

### 获取带有交易详情的区块

```ts
import { IndexerRestExplorerApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const indexerRestExplorerApi = new IndexerRestExplorerApi(
  `${endpoints.explorer}/api/explorer/v1`,
)

const before = 200 /* 可选分页参数 */
const limit = 100 /* 可选分页参数 */

const blocks = await indexerRestExplorerApi.fetchBlocksWithTx({
  before,
  limit,
})

console.log(blocks)
```

### 获取交易

```ts
import { IndexerRestExplorerApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const indexerRestExplorerApi = new IndexerRestExplorerApi(
  `${endpoints.explorer}/api/explorer/v1`,
)

const after = 200 /* 可选分页参数 */
const limit = 100 /* 可选分页参数 */
const fromNumber = 1 /* 可选参数 */
const toNumber = 100 /* 可选参数 */

const transactions = await indexerRestExplorerApi.fetchTransactions({
  after,
  limit,
  fromNumber,
  toNumber,
})

console.log(transactions)
```

### 获取地址的交易

```ts
import { IndexerRestExplorerApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const indexerRestExplorerApi = new IndexerRestExplorerApi(
  `${endpoints.explorer}/api/explorer/v1`,
)

const account = 'biya...'
const after = 200 /* 可选分页参数 */
const limit = 100 /* 可选分页参数 */
const fromNumber = 1 /* 可选参数 */
const toNumber = 100 /* 可选参数 */

const accountTransactions =
  await indexerRestExplorerApi.fetchAccountTransactions({
    account,
    params: {
      account,
      after,
      limit,
      fromNumber,
      toNumber,
    },
  })

console.log(accountTransactions)
```

### 使用交易哈希获取交易

```ts
import { IndexerRestExplorerApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const indexerRestExplorerApi = new IndexerRestExplorerApi(
  `${endpoints.explorer}/api/explorer/v1`,
)

const txsHash = '...'

const transaction = await indexerRestExplorerApi.fetchTransaction(txsHash)

console.log(transaction)
```

### 获取验证者

```ts
import { IndexerRestExplorerApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const indexerRestExplorerApi = new IndexerRestExplorerApi(
  `${endpoints.explorer}/api/explorer/v1`,
)

const validators = await indexerRestExplorerApi.fetchValidators()

console.log(validators)
```

### 获取验证者正常运行时间

```ts
import { IndexerRestExplorerApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const indexerRestExplorerApi = new IndexerRestExplorerApi(
  `${endpoints.explorer}/api/explorer/v1`,
)

const validatorAddress = 'biyavalcons'

const validatorUptime = await indexerRestExplorerApi.fetchValidatorUptime(
  validatorAddress,
)

console.log(validatorUptime)
```

### 通过合约地址获取合约

```ts
import { IndexerRestExplorerApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const indexerRestExplorerApi = new IndexerRestExplorerApi(
  `${endpoints.explorer}/api/explorer/v1`,
)

const contractAddress = 'biya...'

const contract = await indexerRestExplorerApi.fetchContract(contractAddress)

console.log(contract)
```

### 获取合约

```ts
import { IndexerRestExplorerApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const indexerRestExplorerApi = new IndexerRestExplorerApi(
  `${endpoints.explorer}/api/explorer/v1`,
)

const limit = 100 /* 可选分页参数 */
const skip = 50 /* 可选分页参数 */

const contracts = await indexerRestExplorerApi.fetchContracts({
  limit,
  skip,
})

console.log(contracts)
```

### 获取合约交易

```ts
import { IndexerRestExplorerApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const indexerRestExplorerApi = new IndexerRestExplorerApi(
  `${endpoints.explorer}/api/explorer/v1`,
)

const contractAddress = 'biya...'
const limit = 100 /* 可选分页参数 */
const skip = 50 /* 可选分页参数 */

const transactions = await indexerRestExplorerApi.fetchContractTransactions({
  contractAddress,
  params: {
    limit,
    skip,
  },
})

console.log(transactions)
```

### 获取 cosmwasm 代码详情

```ts
import { IndexerRestExplorerApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const indexerRestExplorerApi = new IndexerRestExplorerApi(
  `${endpoints.explorer}/api/explorer/v1`,
)

const codeId = 1

const codeDetails = await indexerRestExplorerApi.fetchWasmCode(codeId)

console.log(codeDetails)
```

### 获取 wasm 代码和详情

```ts
import { IndexerRestExplorerApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const indexerRestExplorerApi = new IndexerRestExplorerApi(
  `${endpoints.explorer}/api/explorer/v1`,
)

const limit = 100 /* 可选分页参数 */
const fromNumber = 50 /* 可选分页参数 */
const toNumber = 150 /* 可选分页参数 */

const codes = await indexerRestExplorerApi.fetchWasmCodes({
  limit,
  fromNumber,
  toNumber,
})

console.log(codes)
```

### 获取 cw20 余额

```ts
import { IndexerRestExplorerApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const indexerRestExplorerApi = new IndexerRestExplorerApi(
  `${endpoints.explorer}/api/explorer/v1`,
)

const address = 'biya...'

const cw20Balances = await indexerRestExplorerApi.fetchCW20BalancesNoThrow(
  address,
)

console.log(cw20Balances)
```
