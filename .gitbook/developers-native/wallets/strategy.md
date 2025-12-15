# Wallet Strategy

The main purpose of the `@biya-coin/wallet-strategy` is to offer developers a way to have different wallet implementations on Biyachain. All of these wallets implementations are exposing the same `ConcreteStrategy` interface which means that users can just use these methods without the need to know the underlying implementation for specific wallets as they are abstracted away.

To start, you have to make an instance of the `WalletStrategy` class which gives you the ability to use different wallets out of the box. You can switch the current wallet that is used by using the `setWallet` method on the `walletStrategy` instance.

Let's have a look at the methods that `WalletStrategy` strategy exposes and what they mean:

**Both Ethereum and Cosmos native wallets:**

- `getAddresses` gets the addresses from the connected wallet strategy. This method returns the Ethereum addresses for Ethereum native wallets (strategies) and Biyachain addresses for Cosmos native wallets (strategies).
- `signTransaction` signs a transaction using the corresponding wallet type method (`signCosmosTransaction` for Cosmos native wallets, `signEip712TypedData` for Ethereum native wallets)
- `sendTransaction` signs a transaction using the corresponding wallet type method (needs a `sentryEndpoint` passed to the options if we wanna use it on Ethereum native wallets - explanation can be found below)
- `getWalletDeviceType` returns the wallet connection type (mobile, browser, hardware),

**Cosmos native wallets:**

- `signCosmosTransaction` signs an Biyachain transaction using the connected wallet strategy,
- `getPublicKey` get the public key for the Cosmos native wallet strategies,

**Ethereum native wallets:**

- `getEthereumChainId` get the chain id for the Ethereum native wallet strategies,
- `signEip712TypedData` signs an EIP712 typed data using the connected wallet strategy,
- `sendEvmTransaction` sends an Ethereum Web3 transaction using the connected wallet strategy,
- `signEvmTransaction` signs an Ethereum Web3 transaction using the connected wallet strategy,
- `getEvmTransactionReceipt` get the transaction receipt for Ethereum native transactions for the wallet strategy,

### Arguments

The arguments passed to the WalletStrategy have the following interface:

```ts
export interface WalletStrategyEvmOptions {
  rpcUrl: string; // rpc url needed **ONLY** the Ethereum native methods on the strategies
  evmChainId: EvmChainId; // needed if you are signing EIP712 typed data using the Wallet Strategies
}

export interface EthereumWalletStrategyArgs {
  chainId: ChainId; // the Biyachain chain id
  evmOptions?: WalletStrategyEvmOptions; // optional, needed only if you are using Ethereum native wallets
  disabledWallets?: Wallet[]; // optional, needed if you wanna disable some wallets for being instantiated
  wallet?: Wallet; // optional, the initial wallet selected (defaults to Metamask if `evmOptions` are passed and Keplr if they are not)
}
```

_Note:_ When we wanna use the `sendTransaction` on Ethereum native wallets alongside the other options (chainId and address) we also need to pass a gRPC endpoint to a sentry to broadcast the transaction. This is needed because from Ethereum native wallets, we don't have access to a `broadcastTx` method as we have on Keplr or Leap to broadcast the transaction using the wallet's abstraction so we have to broadcast it on the client side directly to the chain.

### Example usage

```ts
import { TxRaw } from '@biya-coin/sdk-ts'
import { Web3Exception } from '@biya-coin/exceptions'
import { ChainId, EvmChainId } from '@biya-coin/ts-types'
import { WalletStrategy } from '@biya-coin/wallet-strategy'

const chainId = ChainId.Testnet // The Biyachain Testnet Chain ID
const evmChainId = EvmChainId.TestnetEvm // The Biyachain Evm Testnet Chain ID

export const alchemyRpcEndpoint = `https://eth-goerli.alchemyapi.io/v2/${process.env.APP_ALCHEMY_SEPOLIA_KEY}`

export const walletStrategy = new WalletStrategy({
  chainId,
  evmOptions: {
    evmChainId,
    rpcUrl: alchemyRpcEndpoint,
  },
})

// Get wallet's addresses
export const getAddresses = async (): Promise<string[]> => {
  const addresses = await walletStrategy.getAddresses()

  if (addresses.length === 0) {
    throw new Web3Exception(new Error('There are no addresses linked in this wallet.'))
  }

  return addresses
}

// Sign an Biyachain transaction
export const signTransaction = async (tx: TxRaw): Promise<string[]> => {
  const response = await walletStrategy.signCosmosTransaction(
    /*transaction:*/ { txRaw: tx, accountNumber: /* */, chainId: 'biyachain-1' },
    /*address: */ 'biya1...',
  )

  return response
}

// Send an Biyachain transaction
export const sendTransaction = async (tx: TxRaw): Promise<string[]> => {
  const response = await walletStrategy.sendTransaction(
    tx,
    // `sentryEndpoint` needed if Ethereum wallets are used
    {address: 'biya1...', chainId: 'biyachain-1', sentryEndpoint: 'https://grpc.biyachain.network' }
  )

  return response
}
```
