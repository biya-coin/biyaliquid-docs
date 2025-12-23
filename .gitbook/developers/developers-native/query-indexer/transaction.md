# Web3 Gateway Transactions

查询索引器中 transaction 模块相关数据的示例代码片段。仅在与 [Web3Gateway](../transactions/web3-gateway.md) 交互时使用

## 使用 gRPC

### 获取准备交易的响应

```ts
import { Msgs, IndexerGrpcTransactionApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'
import { EvmChainId } from '@biya-coin/ts-types'

const endpoints = getNetworkEndpoints(Network.Testnet)
const indexerGrpcTransactionApi = new IndexerGrpcTransactionApi(endpoints.indexer)

const address = '0x...' // 以太坊地址
const chainId = EvmChainId.Sepolia
const message = { ... } as Msgs
const memo = '...'

const prepareTxResponse = await indexerGrpcTransactionApi.prepareTxRequest({
  address,
  chainId,
  message,
  memo
})

console.log(prepareTxResponse)
```

### 获取准备 cosmos 交易的响应

```ts
import { IndexerGrpcTransactionApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const indexerGrpcTransactionApi = new IndexerGrpcTransactionApi(endpoints.indexer)

const address = 'biya...'
const message = { ... }

const prepareCosmosTxResponse = await indexerGrpcTransactionApi.prepareCosmosTxRequest({
  address,
  message
})

console.log(prepareCosmosTxResponse)
```

### 获取使用 Web3Gateway 广播交易的响应

在 node/CLI 环境中使用 `MsgBroadcasterWithPk` 广播交易，可在 `@biya-coin/sdk-ts` 中找到。

在浏览器环境中使用 `@biya-coin/wallet-core` 的 `MsgBroadcaster` 类获取有关广播交易的更多详细信息。

```ts
import { ChainId, EvmChainId } from '@biya-coin/ts-types'
import { WalletStrategy } from '@biya-coin/wallet-strategy'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'
import { Msgs, IndexerGrpcTransactionApi } from '@biya-coin/sdk-ts'

const endpoints = getNetworkEndpoints(Network.Testnet)
const indexerGrpcTransactionApi = new IndexerGrpcTransactionApi(endpoints.indexer)

const chainId = ChainId.Testnet // Biya Chain 测试网链 ID
const evmChainId = EvmChainId.TestnetEvm // Biya Chain Evm 测试网链 ID

export const alchemyRpcEndpoint = `https://eth-goerli.alchemyapi.io/v2/${process.env.APP_ALCHEMY_SEPOLIA_KEY}`

const alchemyKey =  process.env.APP_ALCHEMY_SEPOLIA_KEY as string

const walletStrategy = new WalletStrategy({
  chainId,
  evmOptions: {
    evmChainId,
    rpcUrl: alchemyRpcEndpoint,
  },
})

const address = '0x...' // 以太坊地址
const message = { ... } as Msgs
const memo = '...'
const response = { ... } // 来自 prepareTxRequest 的响应
const signature = await walletStrategy.signEip712TypedData(
      response.getData(),
      address,
    ) /* 参见 biyachain-ts/wallet-ts 中 WalletStrategy 的实现。本质上，如果钱包支持签署以太坊交易，则使用钱包的 signEip712TypedData 方法 */

const broadcastTxResponse = await indexerGrpcTransactionApi.broadcastTxRequest({
  signature,
  chainId,
  message,
  txResponse: response
})

console.log(broadcastTxResponse)
```

### 获取广播 cosmos 交易的响应

```ts
import { IndexerGrpcTransactionApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'
import { TxRaw } from '@biya-coin/chain-api'

const endpoints = getNetworkEndpoints(Network.Testnet)
const indexerGrpcTransactionApi = new IndexerGrpcTransactionApi(endpoints.indexer)

const address = 'biya...' // 以太坊地址
const signature = '...' // base64
const txRaw = { ... } as TxRaw
const pubKey = {
  type: string,
  value: string // base64
}

const broadcastCosmosTxResponse = await indexerGrpcTransactionApi.broadcastCosmosTxRequest({
  address,
  signature,
  txRaw,
  pubKey
})

console.log(broadcastCosmosTxResponse)
```

### 获取 Web3Gateway 费用支付者

```ts
import { IndexerGrpcTransactionApi } from "@biya-coin/sdk-ts";
import { getNetworkEndpoints, Network } from "@biya-coin/networks";

const endpoints = getNetworkEndpoints(Network.Testnet);
const indexerGrpcTransactionApi = new IndexerGrpcTransactionApi(
  endpoints.indexer
);

const feePayer = await indexerGrpcTransactionApi.fetchFeePayer();

console.log(feePayer);
```
