# 智能合约

在这个简短的系列中，我们将展示在 Biya Chain 上构建 dApp 是多么容易。有一个开源的 [dApp](https://github.com/biya-coin/biyachain-simple-sc-counter-ui)，每个人都可以参考并使用它在 Biya Chain 上构建。有 Next、Nuxt 和 Vanilla Js 的示例。对于那些想从头开始的人来说，这是正确的起点。

在此示例中，我们将使用 biyachain-ts 模块实现连接并与部署在 Biya Chain 链上的示例智能合约交互。

该系列将包括：

- 设置 API 客户端和环境，
- 连接到链和索引器 API，
- 连接到用户钱包并获取其地址，
- 查询智能合约（在本例中获取智能合约的当前计数），
- 修改合约状态（在本例中将计数增加 1，或将其设置为特定值），

## 设置

首先，配置您所需的 UI 框架。您可以在此处找到有关配置的更多详细信息。

要开始使用 dex，我们需要设置 API 客户端和环境。为了构建我们的 DEX，我们将从 Biya Chain 链和索引器 API 查询数据。在此示例中，我们将使用现有的 **Testnet** 环境。

让我们首先设置一些我们需要查询数据的类。

为了与智能合约交互，我们将使用 `@biya-coin/sdk-ts` 中的 `ChainGrpcWasmApi`。我们还需要我们要使用的网络端点（主网或测试网），我们可以在 `@biya-coin/networks` 中找到它们。

示例：

```js
//filename: services.ts
import { ChainGrpcWasmApi } from "@biya-coin/sdk-ts";
import { Network, getNetworkEndpoints } from "@biya-coin/networks";

export const NETWORK = Network.Testnet;
export const ENDPOINTS = getNetworkEndpoints(NETWORK);

export const chainGrpcWasmApi = new ChainGrpcWasmApi(ENDPOINTS.grpc);
```

然后，我们还需要设置钱包连接，以允许用户连接到我们的 DEX 并开始签署交易。为了实现这一点，我们将使用我们的 `@biya-coin/wallet-strategy` 包，该包允许用户连接各种不同的钱包提供商，并使用它们在 Biya Chain 上签署交易。

`@biya-coin/wallet-strategy` 的主要目的是为开发者提供一种在 Biya Chain 上拥有不同钱包实现的方法。所有这些钱包实现都公开相同的 `ConcreteStrategy` 接口，这意味着用户可以直接使用这些方法，而无需了解特定钱包的底层实现，因为它们已被抽象化。

首先，您必须创建 WalletStrategy 类的实例，这使您能够开箱即用地使用不同的钱包。您可以通过在 walletStrategy 实例上使用 `setWallet` 方法来切换当前使用的钱包。默认值为 `Metamask`。

```ts
// filename: wallet.ts
import { ChainId, EvmChainId } from "@biya-coin/ts-types";
import { WalletStrategy } from "@biya-coin/wallet-strategy";

const chainId = ChainId.Testnet; // The Biya Chain Testnet Chain ID
const evmChainId = EvmChainId.TestnetEvm; // The Biya Chain Evm Testnet Chain ID

export const alchemyRpcEndpoint = `https://eth-goerli.alchemyapi.io/v2/${process.env.APP_ALCHEMY_SEPOLIA_KEY}`;

export const walletStrategy = new WalletStrategy({
  chainId,
  evmOptions: {
    evmChainId,
    rpcUrl: alchemyRpcEndpoint,
  },
});
```

如果我们不想使用以太坊原生钱包，只需在 `WalletStrategy` 构造函数中省略 `evmOptions`。

最后，为了在 Biya Chain 上完成整个交易流程（准备 + 签名 + 广播），我们将使用 MsgBroadcaster 类。

```js
import { Network } from "@biya-coin/networks";
export const NETWORK = Network.Testnet;

export const msgBroadcastClient = new MsgBroadcaster({
  walletStrategy,
  network: NETWORK,
});
```

## 连接到用户的钱包

由于我们使用 `WalletStrategy` 来处理与用户钱包的连接，我们可以使用其方法来处理一些用例，如获取用户的地址、签名/广播交易等。要了解更多关于钱包策略的信息，您可以探索文档接口和 `WalletStrategy` 提供的方法。

注意：我们可以使用 `setWallet` 方法在 `WalletStrategy` 中的"活动"钱包之间切换。

```ts
// filename: WalletConnection.ts
import {
  WalletException,
  UnspecifiedErrorCode,
  ErrorType,
} from "@biya-coin/exceptions";
import { Wallet } from "@biya-coin/wallet-base";
import { walletStrategy } from "./Wallet.ts";

export const getAddresses = async (wallet: Wallet): Promise<string[]> => {
  walletStrategy.setWallet(wallet);

  const addresses = await walletStrategy.getAddresses();

  if (addresses.length === 0) {
    throw new WalletException(
      new Error("There are no addresses linked in this wallet."),
      {
        code: UnspecifiedErrorCode,
        type: ErrorType.WalletError,
      }
    );
  }

  if (!addresses.every((address) => !!address)) {
    throw new WalletException(
      new Error("There are no addresses linked in this wallet."),
      {
        code: UnspecifiedErrorCode,
        type: ErrorType.WalletError,
      }
    );
  }

  // If we are using Ethereum native wallets the 'addresses' are the hex addresses
  // If we are using Cosmos native wallets the 'addresses' are bech32 biyachain addresses,
  return addresses;
};
```

## 查询

初始设置完成后，让我们看看如何使用我们之前创建的 chainGrpcWasmApi 服务查询智能合约以获取当前计数，并在智能合约上调用 get_count。

```ts
function getCount() {
  const response = (await chainGrpcWasmApi.fetchSmartContractState(
    COUNTER_CONTRACT_ADDRESS, // The address of the contract
    toBase64({ get_count: {} }) // We need to convert our query to Base64
  )) as { data: string };

  const { count } = fromBase64(response.data) as { count: number }; // we need to convert the response from Base64

  return count; // return the current counter value.
}
```

一旦我们有了这些函数（`getCount` 或我们创建的其他函数），我们就可以在应用程序的任何地方调用它们（通常是集中式状态管理服务，如 Nuxt 中的 Pinia，或 React 中的 Context providers 等）。

## 修改状态

接下来我们将修改 `count` 状态。我们可以通过使用我们之前创建的 `Broadcast Client` 和 `@biya-coin/sdk-ts` 中的 `MsgExecuteContractCompat` 向链发送消息来实现。

我们在此示例中使用的智能合约有 2 种方法来更改状态：

- `increment`
- `reset`

`increment` 将计数增加 1，`reset` 将计数设置为给定值。请注意，只有当您是智能合约的创建者时才能调用 `reset`。

当我们调用这些函数时，我们的钱包会打开以签署消息/交易并广播它。

让我们首先看看如何增加计数。

```js
// Preparing the message

const msg = MsgExecuteContractCompat.fromJSON({
  contractAddress: COUNTER_CONTRACT_ADDRESS,
  sender: biyachainAddress,
  msg: {
    increment: {}, // we pass an empty object if the method doesn't have parameters
  },
});

// Signing and broadcasting the message

const response = await msgBroadcastClient.broadcast({
  msgs: msg, // we can pass multiple messages here using an array. ex: [msg1,msg2]
  biyachainAddress: biyachainAddress,
});

console.log(response);
```

现在，让我们看一个如何将计数器设置为特定值的示例。请注意，在此智能合约中，只有智能合约的创建者才能将计数设置为特定值。

```js
// Preparing the message

const msg = MsgExecuteContractCompat.fromJSON({
  contractAddress: COUNTER_CONTRACT_ADDRESS,
  sender: biyachainAddress,
  msg: {
    reset: {
      count: parseInt(number, 10), // we are parsing the number variable here because usually it comes from an input which always gives a string, and we need to pass a number instead.
    },
  },
});

// Signing and broadcasting the message

const response = await msgBroadcastClient.broadcast({
  msgs: msg,
  biyachainAddress: biyachainAddress,
});

console.log(response);
```

### 完整示例

现在让我们看一个 Vanilla JS 中的完整示例（您可以在[这里](https://github.com/biya-coin/biyachain-simple-sc-counter-ui)找到特定框架如 Nuxt 和 Next 的示例）

```js
import { Web3Exception } from "@biya-coin/exceptions"
import { WalletStrategy } from "@biya-coin/wallet-strategy"
import { Network, getNetworkEndpoints } from "@biya-coin/networks"
import { ChainGrpcWasmApi, getBiyachainAddress } from "@biya-coin/sdk-ts"

const chainId = ChainId.Testnet // The Biya Chain Testnet Chain ID
const evmChainId = EvmChainId.TestnetEvm // The Biya Chain Evm Testnet Chain ID

export const alchemyRpcEndpoint = `https://eth-goerli.alchemyapi.io/v2/${process.env.APP_ALCHEMY_SEPOLIA_KEY}`

const NETWORK = Network.Testnet
const ENDPOINTS = getNetworkEndpoints(NETWORK)

const chainGrpcWasmApi = new ChainGrpcWasmApi(ENDPOINTS.grpc)

export const walletStrategy = new WalletStrategy({
  chainId,
  evmOptions: {
    evmChainId,
    rpcUrl: alchemyRpcEndpoint,
  },
})

export const getAddresses = async (): Promise<string[]> => {
  const addresses = await walletStrategy.getAddresses()

  if (addresses.length === 0) {
    throw new Web3Exception(
      new Error("There are no addresses linked in this wallet.")
    )
  }

  return addresses
}

const msgBroadcastClient = new MsgBroadcaster({
  walletStrategy,
  network: NETWORK,
})

const [address] = await getAddresses()
const biyachainAddress = getBiyachainAddress(getBiyachainAddress)

async function fetchCount() {
  const response = (await chainGrpcWasmApi.fetchSmartContractState(
    COUNTER_CONTRACT_ADDRESS, // The address of the contract
      toBase64({ get_count: {} }) // We need to convert our query to Base64
    )) as { data: string }

  const { count } = fromBase64(response.data) as { count: number } // we need to convert the response from Base64

  console.log(count)
}

async function increment(){
    const msg = MsgExecuteContractCompat.fromJSON({
    contractAddress: COUNTER_CONTRACT_ADDRESS,
    sender: biyachainAddress,
    msg: {
        increment: {},
        },
    })

    // Signing and broadcasting the message

    await msgBroadcastClient.broadcast({
        msgs: msg,
        biyachainAddress: biyachainAddress,
    })
}

async function main() {
    await fetchCount() // this will log: {count: 5}
    await increment() // this opens up your wallet to sign the transaction and broadcast it
    await fetchCount() // the count now is 6. log: {count: 6}
}

main()

```

## 最后的想法

剩下要做的就是围绕上面解释的业务逻辑构建一个漂亮的 UI :)
