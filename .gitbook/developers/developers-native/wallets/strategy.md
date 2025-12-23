# 钱包策略

`@biya-coin/wallet-strategy` 的主要目的是为开发者提供一种在 Biya Chain 上使用不同钱包实现的方法。所有这些钱包实现都公开相同的 `ConcreteStrategy` 接口，这意味着用户可以直接使用这些方法，而无需了解特定钱包的底层实现，因为它们被抽象掉了。

首先，您必须创建 `WalletStrategy` 类的实例，这使您能够开箱即用地使用不同的钱包。您可以通过在 `walletStrategy` 实例上使用 `setWallet` 方法来切换当前使用的钱包。

让我们看看 `WalletStrategy` 策略公开的方法及其含义：

**以太坊和 Cosmos 原生钱包都支持：**

- `getAddresses` 从连接的钱包策略获取地址。此方法为以太坊原生钱包（策略）返回以太坊地址，为 Cosmos 原生钱包（策略）返回 Biya Chain 地址。
- `signTransaction` 使用相应的钱包类型方法签署交易（对于 Cosmos 原生钱包使用 `signCosmosTransaction`，对于以太坊原生钱包使用 `signEip712TypedData`）
- `sendTransaction` 使用相应的钱包类型方法签署交易（如果我们想在以太坊原生钱包上使用它，需要将 `sentryEndpoint` 传递给选项 - 下面可以找到解释）
- `getWalletDeviceType` 返回钱包连接类型（移动端、浏览器、硬件），

**Cosmos 原生钱包：**

- `signCosmosTransaction` 使用连接的钱包策略签署 Biya Chain 交易，
- `getPublicKey` 获取 Cosmos 原生钱包策略的公钥，

**以太坊原生钱包：**

- `getEthereumChainId` 获取以太坊原生钱包策略的链 ID，
- `signEip712TypedData` 使用连接的钱包策略签署 EIP712 类型数据，
- `sendEvmTransaction` 使用连接的钱包策略发送以太坊 Web3 交易，
- `signEvmTransaction` 使用连接的钱包策略签署以太坊 Web3 交易，
- `getEvmTransactionReceipt` 获取钱包策略的以太坊原生交易的交易收据，

### 参数

传递给 WalletStrategy 的参数具有以下接口：

```ts
export interface WalletStrategyEvmOptions {
  rpcUrl: string; // rpc url **仅**在策略上的以太坊原生方法需要
  evmChainId: EvmChainId; // 如果您使用钱包策略签署 EIP712 类型数据，则需要
}

export interface EthereumWalletStrategyArgs {
  chainId: ChainId; // Biya Chain 链 ID
  evmOptions?: WalletStrategyEvmOptions; // 可选，仅在使用以太坊原生钱包时需要
  disabledWallets?: Wallet[]; // 可选，如果您想禁用某些钱包被实例化，则需要
  wallet?: Wallet; // 可选，选择的初始钱包（如果传递了 `evmOptions` 则默认为 Metamask，如果没有则默认为 Keplr）
}
```

_注意：_ 当我们想在以太坊原生钱包上使用 `sendTransaction` 以及其他选项（chainId 和 address）时，我们还需要将 gRPC 端点传递给 sentry 以广播交易。这是必需的，因为从以太坊原生钱包，我们无法访问 `broadcastTx` 方法，就像我们在 Keplr 或 Leap 上那样使用钱包的抽象来广播交易，所以我们必须在客户端直接向链广播它。

### 示例用法

```ts
import { TxRaw } from '@biya-coin/sdk-ts'
import { Web3Exception } from '@biya-coin/exceptions'
import { ChainId, EvmChainId } from '@biya-coin/ts-types'
import { WalletStrategy } from '@biya-coin/wallet-strategy'

const chainId = ChainId.Testnet // Biya Chain 测试网链 ID
const evmChainId = EvmChainId.TestnetEvm // Biya Chain Evm 测试网链 ID

export const alchemyRpcEndpoint = `https://eth-goerli.alchemyapi.io/v2/${process.env.APP_ALCHEMY_SEPOLIA_KEY}`

export const walletStrategy = new WalletStrategy({
  chainId,
  evmOptions: {
    evmChainId,
    rpcUrl: alchemyRpcEndpoint,
  },
})

// 获取钱包的地址
export const getAddresses = async (): Promise<string[]> => {
  const addresses = await walletStrategy.getAddresses()

  if (addresses.length === 0) {
    throw new Web3Exception(new Error('此钱包中没有链接的地址。'))
  }

  return addresses
}

// 签署 Biya Chain 交易
export const signTransaction = async (tx: TxRaw): Promise<string[]> => {
  const response = await walletStrategy.signCosmosTransaction(
    /*transaction:*/ { txRaw: tx, accountNumber: /* */, chainId: 'biyachain-1' },
    /*address: */ 'biya1...',
  )

  return response
}

// 发送 Biya Chain 交易
export const sendTransaction = async (tx: TxRaw): Promise<string[]> => {
  const response = await walletStrategy.sendTransaction(
    tx,
    // 如果使用以太坊钱包，则需要 `sentryEndpoint`
    {address: 'biya1...', chainId: 'biyachain-1', sentryEndpoint: 'https://grpc.biyachain.network' }
  )

  return response
}
```
