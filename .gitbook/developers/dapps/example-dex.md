# DEX

在这个简短的系列中，我们将展示在 Biya Chain 上构建 DEX 是多么容易。有一个开源的 [DEX](https://github.com/biya-coin/biyachain-dex)，每个人都可以参考并使用它在 Biya Chain 上构建。对于那些想从头开始的人来说，这是正确的起点。

该系列将包括：

- 设置 API 客户端和环境，
- 连接到链和索引器 API，
- 连接到用户钱包并获取其地址，
- 获取现货和衍生品市场及其订单簿，
- 在现货和衍生品市场上下市场订单，
- 查看 Biya Chain 地址的所有持仓。

## 设置

首先，配置您所需的 UI 框架。您可以在此处找到有关配置的更多详细信息。

要开始使用 dex，我们需要设置 API 客户端和环境。为了构建我们的 DEX，我们将从 Biya Chain 链和索引器 API 查询数据。在此示例中，我们将使用现有的 **Testnet** 环境。

让我们首先设置一些我们需要查询数据的类。

```ts
// filename: Services.ts
import {
  ChainGrpcBankApi,
  IndexerGrpcSpotApi,
  IndexerGrpcDerivativesApi,
} from "@biya-coin/sdk-ts";
import { getNetworkEndpoints, Network } from "@biya-coin/networks";

// Getting the pre-defined endpoints for the Testnet environment
// (using TestnetK8s here because we want to use the Kubernetes infra)
export const NETWORK = Network.Testnet;
export const ENDPOINTS = getNetworkEndpoints(NETWORK);

export const chainBankApi = new ChainGrpcBankApi(ENDPOINTS.grpc);
export const indexerSpotApi = new IndexerGrpcSpotApi(ENDPOINTS.indexer);
export const indexerDerivativesApi = new IndexerGrpcDerivativesApi(
  ENDPOINTS.indexer
);

export const indexerSpotStream = new IndexerGrpcDerivativeStream(
  ENDPOINTS.indexer
);
export const indexerDerivativeStream = new IndexerGrpcDerivativeStream(
  ENDPOINTS.indexer
);
```

然后，我们还需要设置钱包连接，以允许用户连接到我们的 DEX 并开始签署交易。为了实现这一点，我们将使用我们的 `@biya-coin/wallet-strategy` 包，该包允许用户连接各种不同的钱包提供商，并使用它们在 Biya Chain 上签署交易。

```ts
// filename: Wallet.ts
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

```ts
// filename: MsgBroadcaster.ts
import { Wallet } from "@biya-coin/wallet-base";
import { EvmWalletStrategy } from "@biya-coin/wallet-evm";
import { BaseWalletStrategy, MsgBroadcaster } from "@biya-coin/wallet-core";

const strategyArgs: WalletStrategyArguments = {}; /** define the args */
const strategyEthArgs: ConcreteEthereumWalletStrategyArgs =
  {}; /** if the wallet is an Ethereum wallet */
const strategies = {
  [Wallet.Metamask]: new EvmWalletStrategy(strategyEthArgs),
};

export const walletStrategy = new BaseWalletStrategy({
  ...strategyArgs,
  strategies,
});

const broadcasterArgs: MsgBroadcasterOptions =
  {}; /** define the broadcaster args */
export const msgBroadcaster = new MsgBroadcaster({
  ...broadcasterArgs,
  walletStrategy,
});
```

## 连接到用户的钱包

由于我们使用 `WalletStrategy` 来处理与用户钱包的连接，我们可以使用其方法来处理一些用例，如获取用户的地址、签名/广播交易等。要了解更多关于钱包策略的信息，您可以探索文档接口和 `WalletStrategy` 提供的方法。

注意：我们可以使用 `setWallet` 方法在 `WalletStrategy` 中的"活动"钱包之间切换。

```ts
// filename: WalletConnection.ts
import {
  ErrorType,
  WalletException,
  UnspecifiedErrorCode,
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

初始设置完成后，让我们看看如何从 IndexerAPI 查询（和流式传输）市场，以及直接从链查询用户的余额。

```ts
// filename: Query.ts
import  { getDefaultSubaccountId, OrderbookWithSequence } from '@biya-coin/sdk-ts'
import {
  chainBankApi,
  indexerSpotApi,
  indexerSpotStream,
  indexerDerivativesApi
  indexerDerivativesStream,
} from './Services.ts'

export const fetchDerivativeMarkets = async () => {
  return await indexerDerivativesApi.fetchMarkets()
}

export const fetchPositions = async (biyachainAddress: string) => {
  const subaccountId = getDefaultSubaccountId(biyachainAddress)

  return await indexerDerivativesApi.fetchPositions({ subaccountId })
}

export const fetchSpotMarkets = async () => {
  return await indexerSpotsApi.fetchMarkets()
}

export const fetchBankBalances = async (biyachainAddress: string) => {
  return await chainBankApi.fetchBalances(biyachainAddress)
}

export const streamDerivativeMarketOrderbook = async (
  marketId: string,
  ) => {
  const streamOrderbookUpdates = indexerDerivativesStream.streamDerivativeOrderbookUpdate.bind(indexerDerivativesStream)
  const callback = (orderbookUpdate) => {
    console.log(orderbookUpdate)
  }

  streamOrderbookUpdates({
    marketIds,
    callback
  })
}

export const streamSpotMarketOrderbook = async (
  marketId: string,
  ) => {
  const streamOrderbookUpdates = indexerSpotsStream.streamSpotOrderbookUpdate.bind(indexerSpotsStream)
  const callback = (orderbookUpdate) => {
    console.log(orderbookUpdate)
  }

  streamOrderbookUpdates({
    marketIds,
    callback
  })
}
```

一旦我们有了这些函数，我们就可以在应用程序的任何地方调用它们（通常是集中式状态管理服务，如 Nuxt 中的 Pinia，或 React 中的 Context providers 等）。

## 交易

最后，让我们进行一些交易。在此示例中，我们将：

1. 从一个地址向另一个地址发送资产，
2. 下现货限价订单，
3. 下衍生品市场订单。

```ts
// filename: Transactions.ts
import { toChainFormat } from '@biya-coin/utils'
import {
  MsgSend,
  MsgCreateSpotLimitOrder,
  spotPriceToChainPriceToFixed,
  MsgCreateDerivativeMarketOrder,
  spotQuantityToChainQuantityToFixed
} from '@biya-coin/sdk-ts'

// used to send assets from one address to another
export const makeMsgSend = ({
  sender: string,
  recipient: string,
  amount: string, // human readable amount
  denom: string
}) => {
  const amount = {
    denom,
    amount: toChainFormat(amount)
  }

  return MsgSend.fromJSON({
    amount,
    srcBiyachainAddress: sender,
    dstBiyachainAddress: recipient,
  })
}

// used to create a spot limit order
export const makeMsgCreateSpotLimitOrder = ({
  price, // human readable number
  quantity, // human readable number
  orderType, // OrderType enum
  biyachainAddress,
}) => {
  const subaccountId = getDefaultSubaccountId(biyachainAddress)
  const market = {
    marketId: '0x...',
    baseDecimals: 18,
    quoteDecimals: 6,
    minPriceTickSize: '', /* fetched from the chain */
    minQuantityTickSize: '', /* fetched from the chain */
    priceTensMultiplier: '', /** can be fetched from getDerivativeMarketTensMultiplier */
    quantityTensMultiplier: '', /** can be fetched from getDerivativeMarketTensMultiplier */
  }

  return MsgCreateSpotLimitOrder.fromJSON({
    subaccountId,
    biyachainAddress,
    orderType: orderType,
    price: spotPriceToChainPriceToFixed({
      value: price,
      tensMultiplier: market.priceTensMultiplier,
      baseDecimals: market.baseDecimals,
      quoteDecimals: market.quoteDecimals
    }),
    quantity: spotQuantityToChainQuantityToFixed({
      value: quantity,
      tensMultiplier: market.quantityTensMultiplier,
      baseDecimals: market.baseDecimals
    }),
    marketId: market.marketId,
    feeRecipient: biyachainAddress,
  })
}

// used to create a derivative market order
export const makeMsgCreateDerivativeMarketOrder = ({
  price, // human readable number
  margin, // human readable number
  quantity, // human readable number
  orderType, // OrderType enum
  biyachainAddress,
}) => {
  const subaccountId = getDefaultSubaccountId(biyachainAddress)
  const market = {
    marketId: '0x...',
    baseDecimals: 18,
    quoteDecimals: 6,
    minPriceTickSize: '', /* fetched from the chain */
    minQuantityTickSize: '', /* fetched from the chain */
    priceTensMultiplier: '', /** can be fetched from getDerivativeMarketTensMultiplier */
    quantityTensMultiplier: '', /** can be fetched from getDerivativeMarketTensMultiplier */
  }

  return MsgCreateDerivativeMarketOrder.fromJSON(
    orderType: orderPrice,
    triggerPrice: '0',
    biyachainAddress,
    price: derivativePriceToChainPriceToFixed({
      value: order.price,
      tensMultiplier: market.priceTensMultiplier,
      quoteDecimals: market.quoteDecimals
    }),
    quantity: derivativeQuantityToChainQuantityToFixed({
      value: order.quantity,
      tensMultiplier: market.quantityTensMultiplier,
    }),
    margin: derivativeMarginToChainMarginToFixed({
      value: order.margin,
      quoteDecimals: market.quoteDecimals,
      tensMultiplier: priceTensMultiplier,
    }),
    marketId: market.marketId,
    feeRecipient: feeRecipient,
    subaccountId: subaccountI
  })

}
```

有了消息后，您可以使用 `msgBroadcaster` 客户端广播这些交易：

```ts
const response = await msgBroadcaster({
  msgs: /** the message here */,
  biyachainAddress: signersBiyachainAddress,
})

console.log(response)
```

## 最后的想法

剩下要做的就是围绕上面解释的业务逻辑构建一个漂亮的 UI :)
