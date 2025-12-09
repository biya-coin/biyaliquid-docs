# Web3 Gateway Transactions

Example code snippets to query the indexer for transaction module related data. Used only when interacting with the [Web3Gateway](../transactions/web3-gateway.md)

## Using gRPC

### Fetch response for preparing a transaction

```ts
import { Msgs, IndexerGrpcTransactionApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'
import { EvmChainId } from '@biya-coin/ts-types'

const endpoints = getNetworkEndpoints(Network.Testnet)
const indexerGrpcTransactionApi = new IndexerGrpcTransactionApi(endpoints.indexer)

const address = '0x...' // ethereum address
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

### Fetch response for preparing a cosmos transaction

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

### Fetch response for broadcasting transactions using the Web3Gateway

Use `MsgBroadcasterWithPk` to broadcast transactions within a node/CLI environment, which can be found in `@biya-coin/sdk-ts`.

Use `@biya-coin/wallet-core`'s `MsgBroadcaster` class for more details on broadcasting a transactions in a browser environment.

```ts
import { ChainId, EvmChainId } from '@biya-coin/ts-types'
import { WalletStrategy } from '@biya-coin/wallet-strategy'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'
import { Msgs, IndexerGrpcTransactionApi } from '@biya-coin/sdk-ts'

const endpoints = getNetworkEndpoints(Network.Testnet)
const indexerGrpcTransactionApi = new IndexerGrpcTransactionApi(endpoints.indexer)

const chainId = ChainId.Testnet // The Biyaliquid Testnet Chain ID
const evmChainId = EvmChainId.TestnetEvm // The Biyaliquid Evm Testnet Chain ID

export const alchemyRpcEndpoint = `https://eth-goerli.alchemyapi.io/v2/${process.env.APP_ALCHEMY_SEPOLIA_KEY}`

const alchemyKey =  process.env.APP_ALCHEMY_SEPOLIA_KEY as string

const walletStrategy = new WalletStrategy({
  chainId,
  evmOptions: {
    evmChainId,
    rpcUrl: alchemyRpcEndpoint,
  },
})

const address = '0x...' // ethereum address
const message = { ... } as Msgs
const memo = '...'
const response = { ... } // response from  prepareTxRequest
const signature = await walletStrategy.signEip712TypedData(
      response.getData(),
      address,
    ) /* see biyaliquid-ts/wallet-ts implementation of WalletStrategy. Essentially, you use the signEip712TypedData method of the wallet, if the wallet supports signing ethereum transactions */

const broadcastTxResponse = await indexerGrpcTransactionApi.broadcastTxRequest({
  signature,
  chainId,
  message,
  txResponse: response
})

console.log(broadcastTxResponse)
```

### Fetch response for broadcasting a cosmos transactions.

```ts
import { IndexerGrpcTransactionApi } from '@biya-coin/sdk-ts'
import { getNetworkEndpoints, Network } from '@biya-coin/networks'
import { TxRaw } from '@biya-coin/chain-api'

const endpoints = getNetworkEndpoints(Network.Testnet)
const indexerGrpcTransactionApi = new IndexerGrpcTransactionApi(endpoints.indexer)

const address = 'biya...' // ethereum address
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

### Fetch Web3Gateway Fee Payer

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
