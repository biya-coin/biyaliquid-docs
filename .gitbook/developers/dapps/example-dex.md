# DEX

Within these short series we are going to showcase how easy it is to build a DEX on top of Biyaliquid. There is an open-sourced [DEX](https://github.com/biya-coin/biyaliquid-dex) which everyone can reference and use to build on top of Biyaliquid. For those who want to start from scratch, this is the right place to start.

The series will include:

- Setting up the API clients and environment,
- Connecting to the Chain and the Indexer API,
- Connect to a user wallet and get their address,
- Fetching Spot and Derivative markets and their orderbooks,
- Placing market orders on both spot and a derivative market,
- View all positions for an Biyaliquid address.

## Setup

First, configure your desired UI framework. You can find more details on the configuration here.

To get started with the dex, we need to setup the API clients and the environment. To build our DEX we are going to query data from both the Biyaliquid Chain and the Indexer API. In this example, we are going to use the existing **Testnet** environment.

Let's first setup some of the classes we need to query the data.

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

Then, we also need to setup a wallet connection to allow the user to connect to our DEX and start signing transactions. To make this happen we are going to use our `@biya-coin/wallet-strategy` package which allows users to connect with a various of different wallet providers and use them to sign transactions on Biyaliquid.

```ts
// filename: Wallet.ts
import { ChainId, EvmChainId } from "@biya-coin/ts-types";
import { WalletStrategy } from "@biya-coin/wallet-strategy";

const chainId = ChainId.Testnet; // The Biyaliquid Testnet Chain ID
const evmChainId = EvmChainId.TestnetEvm; // The Biyaliquid Evm Testnet Chain ID

export const alchemyRpcEndpoint = `https://eth-goerli.alchemyapi.io/v2/${process.env.APP_ALCHEMY_SEPOLIA_KEY}`;

export const walletStrategy = new WalletStrategy({
  chainId,
  evmOptions: {
    evmChainId,
    rpcUrl: alchemyRpcEndpoint,
  },
});
```

If we don't want to use Ethereum native wallets, just omit the `evmOptions` within the `WalletStrategy` constructor.

Finally, to do the whole transaction flow (prepare + sign + broadcast) on Biyaliquid we are going to use the MsgBroadcaster class.

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

## Connect to the user's wallet

Since we are using the `WalletStrategy` to handle the connection with the user's wallet, we can use its methods to handle some use cases like getting the user's addresses, sign/broadcast a transaction, etc. To find out more about the wallet strategy, you can explore the documentation interface and the method the `WalletStrategy` offers.

Note: We can switch between the "active" wallet within the `WalletStrategy` using the `setWallet` method.

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
  // If we are using Cosmos native wallets the 'addresses' are bech32 biyaliquid addresses,
  return addresses;
};
```

## Querying

After the initial setup is done, let's see how to query (and stream) markets from the IndexerAPI, as well as user's balances from the chain directly.

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

export const fetchPositions = async (biyaliquidAddress: string) => {
  const subaccountId = getDefaultSubaccountId(biyaliquidAddress)

  return await indexerDerivativesApi.fetchPositions({ subaccountId })
}

export const fetchSpotMarkets = async () => {
  return await indexerSpotsApi.fetchMarkets()
}

export const fetchBankBalances = async (biyaliquidAddress: string) => {
  return await chainBankApi.fetchBalances(biyaliquidAddress)
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

Once we have these functions we can call them anywhere in our application (usually the centralized state management services like Pinia in Nuxt, or Context providers in React, etc).

## Transactions

Finally, let's make some transactions. For this example, we are going to:

1. Send assets from one address to another,
2. Make a spot limit order,
3. Make a derivative market order.

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
    srcBiyaliquidAddress: sender,
    dstBiyaliquidAddress: recipient,
  })
}

// used to create a spot limit order
export const makeMsgCreateSpotLimitOrder = ({
  price, // human readable number
  quantity, // human readable number
  orderType, // OrderType enum
  biyaliquidAddress,
}) => {
  const subaccountId = getDefaultSubaccountId(biyaliquidAddress)
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
    biyaliquidAddress,
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
    feeRecipient: biyaliquidAddress,
  })
}

// used to create a derivative market order
export const makeMsgCreateDerivativeMarketOrder = ({
  price, // human readable number
  margin, // human readable number
  quantity, // human readable number
  orderType, // OrderType enum
  biyaliquidAddress,
}) => {
  const subaccountId = getDefaultSubaccountId(biyaliquidAddress)
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
    biyaliquidAddress,
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

After we have the Messages, you can use the `msgBroadcaster` client to broadcast these transactions:

```ts
const response = await msgBroadcaster({
  msgs: /** the message here */,
  biyaliquidAddress: signersBiyaliquidAddress,
})

console.log(response)
```

## Final Thoughts

What's left for you is to build a nice UI around the business logic explained above :)
