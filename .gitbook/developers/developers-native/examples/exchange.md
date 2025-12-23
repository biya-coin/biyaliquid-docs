# Exchange

`exchange` 模块是 Biya Chain 链的核心，它实现了完全去中心化的现货和衍生品交易所。它是链的必不可少的模块，与 `auction`、`insurance`、`oracle` 和 `peggy` 模块紧密集成。

交易所协议使交易者能够创建和交易任意现货和衍生品市场。订单簿管理、交易执行、订单匹配和结算的整个过程都通过交易所模块编码的逻辑在链上进行。

## 消息

让我们探索（并提供示例）Exchange 模块导出的消息,我们可以使用这些消息与 Biya Chain 链交互。

### MsgDeposit

此消息用于将代币从 Bank 模块发送到钱包的子账户

```ts
import { Network } from "@biya-coin/networks";
import { toChainFormat } from "@biya-coin/utils";
import {
  MsgDeposit,
  MsgBroadcasterWithPk,
  getEthereumAddress,
} from "@biya-coin/sdk-ts";

const privateKey = "0x...";
const biyachainAddress = "biya1...";

const amount = {
  denom: "biya",
  amount: toChainFormat(1),
};

const ethereumAddress = getEthereumAddress(biyachainAddress);
const subaccountIndex = 0;
const suffix = "0".repeat(23) + subaccountIndex;
const subaccountId = ethereumAddress + suffix;

const msg = MsgDeposit.fromJSON({
  amount,
  subaccountId,
  biyachainAddress,
});

const txHash = await new MsgBroadcasterWithPk({
  privateKey,
  network: Network.Testnet,
}).broadcast({
  msgs: msg,
});

console.log(txHash);
```

### MsgWithdraw

此消息用于将代币从钱包的子账户发送回用户的 Bank 资金

```ts
import {
  MsgWithdraw,
  MsgBroadcasterWithPk,
  getEthereumAddress,
} from "@biya-coin/sdk-ts";
import { toChainFormat } from "@biya-coin/utils";
import { Network } from "@biya-coin/networks";

const privateKey = "0x...";
const biyachainAddress = "biya1...";

const amount = {
  denom: "biya",
  amount: toChainFormat(1).toFixed(),
};

const ethereumAddress = getEthereumAddress(biyachainAddress);
const subaccountIndex = 0;
const suffix = "0".repeat(23) + subaccountIndex;
const subaccountId = ethereumAddress + suffix;

const msg = MsgWithdraw.fromJSON({
  amount,
  subaccountId,
  biyachainAddress,
});

const txHash = await new MsgBroadcasterWithPk({
  privateKey,
  network: Network.Testnet,
}).broadcast({
  msgs: msg,
});

console.log(txHash);
```

### MsgCreateSpotLimitOrder

此消息用于创建现货限价订单

```ts
import {
  getEthereumAddress,
  MsgBroadcasterWithPk,
  MsgCreateSpotLimitOrder,
  getSpotMarketTensMultiplier,
} from "@biya-coin/sdk-ts";
import { Network } from "@biya-coin/networks";
import {
  spotPriceToChainPriceToFixed,
  spotQuantityToChainQuantityToFixed,
} from "@biya-coin/utils";

const privateKey = "0x...";
const biyachainAddress = "biya1...";
const feeRecipient = "biya1...";
const market = {
  marketId: "0x...",
  baseDecimals: 18,
  quoteDecimals: 6,
  minPriceTickSize: "" /* 从链上获取 */,
  minQuantityTickSize: "" /* 从链上获取 */,
  priceTensMultiplier:
    "" /** 可以从 getSpotMarketTensMultiplier 获取 */,
  quantityTensMultiplier:
    "" /** 可以从 getSpotMarketTensMultiplier 获取 */,
};

const order = {
  price: 1,
  quantity: 1,
};

const ethereumAddress = getEthereumAddress(biyachainAddress);
const subaccountIndex = 0;
const suffix = "0".repeat(23) + subaccountIndex;
const subaccountId = ethereumAddress + suffix;

const msg = MsgCreateSpotLimitOrder.fromJSON({
  subaccountId,
  biyachainAddress,
  orderType: 1 /* 买入 */,
  price: spotPriceToChainPriceToFixed({
    value: order.price,
    tensMultiplier: market.priceTensMultiplier,
    baseDecimals: market.baseDecimals,
    quoteDecimals: market.quoteDecimals,
  }),
  quantity: spotQuantityToChainQuantityToFixed({
    value: order.quantity,
    tensMultiplier: market.quantityTensMultiplier,
    baseDecimals: market.baseDecimals,
  }),
  marketId: market.marketId,
  feeRecipient: feeRecipient,
});

const txHash = await new MsgBroadcasterWithPk({
  privateKey,
  network: Network.Testnet,
}).broadcast({
  msgs: msg,
});

console.log(txHash);
```

### MsgCreateSpotMarketOrder

此消息用于创建现货市价订单

```ts
import {
  MsgCreateSpotMarketOrder,
  MsgBroadcasterWithPk,
  getEthereumAddress,
  getSpotMarketTensMultiplier,
} from "@biya-coin/sdk-ts";
import {
  spotPriceToChainPriceToFixed,
  spotQuantityToChainQuantityToFixed,
} from "@biya-coin/utils";
import { Network } from "@biya-coin/networks";

const privateKey = "0x...";
const biyachainAddress = "biya1...";
const feeRecipient = "biya1...";
const market = {
  marketId: "0x...",
  baseDecimals: 18,
  quoteDecimals: 6,
  minPriceTickSize: "" /* 从链上获取 */,
  minQuantityTickSize: "" /* 从链上获取 */,
  priceTensMultiplier:
    "" /** 可以从 getSpotMarketTensMultiplier 获取 */,
  quantityTensMultiplier:
    "" /** 可以从 getSpotMarketTensMultiplier 获取 */,
};
const order = {
  price: 10,
  quantity: 1,
};

const ethereumAddress = getEthereumAddress(biyachainAddress);
const subaccountIndex = 0;
const suffix = "0".repeat(23) + subaccountIndex;
const subaccountId = ethereumAddress + suffix;

const msg = MsgCreateSpotMarketOrder.fromJSON({
  subaccountId,
  biyachainAddress,
  orderType: 1 /* 买入 */,
  price: spotPriceToChainPriceToFixed({
    value: order.price,
    tensMultiplier: market.priceTensMultiplier,
    baseDecimals: market.baseDecimals,
    quoteDecimals: market.quoteDecimals,
  }),
  quantity: spotQuantityToChainQuantityToFixed({
    value: order.quantity,
    tensMultiplier: market.quantityTensMultiplier,
    baseDecimals: market.baseDecimals,
  }),
  marketId: market.marketId,
  feeRecipient: feeRecipient,
});

const txHash = await new MsgBroadcasterWithPk({
  privateKey,
  network: Network.Testnet,
}).broadcast({
  msgs: msg,
});

console.log(txHash);
```

### MsgCreateDerivativeLimitOrder

此消息用于创建衍生品限价订单

```ts
import {
  MsgCreateDerivativeLimitOrder,
  MsgBroadcasterWithPk,
  getEthereumAddress,
  getDerivativeMarketTensMultiplier
} from '@biya-coin/sdk-ts'
import {
  derivativePriceToChainPriceToFixed,
  derivativeQuantityToChainQuantityToFixed,
  derivativeMarginToChainMarginToFixed
} from '@biya-coin/utils'
import { Network } from '@biya-coin/networks'

const privateKey = '0x...'
const biyachainAddress = 'biya1...'
const feeRecipient = 'biya1...'
const market = {
  marketId: '0x...',
  baseDecimals: 18,
  quoteDecimals: 6,
  minPriceTickSize: '', /* 从链上获取 */
  minQuantityTickSize: '', /* 从链上获取 */
  priceTensMultiplier: '', /** 可以从 getDerivativeMarketTensMultiplier 获取 */
  quantityTensMultiplier: '', /** 可以从 getDerivativeMarketTensMultiplier 获取 */
}
const order = {
  price: 10,
  quantity: 1,
  margin: 10
}

const ethereumAddress = getEthereumAddress(biyachainAddress)
const subaccountIndex = 0
const suffix = '0'.repeat(23) + subaccountIndex
const subaccountId = ethereumAddress + suffix

const msg = MsgCreateDerivativeLimitOrder.fromJSON(
  orderType: 1 /* 买入 */,
  triggerPrice: '0',
  biyachainAddress,
  price: derivativePriceToChainPriceToFixed({
    value: order.price,
    quoteDecimals: market.quoteDecimals
  }),
  quantity: derivativeQuantityToChainQuantityToFixed({ value: order.quantity }),
  margin: derivativeMarginToChainMarginToFixed({
    value: order.margin,
    quoteDecimals: market.quoteDecimals
  }),
  marketId: market.marketId,
  feeRecipient: feeRecipient,
  subaccountId: subaccountI
})

const txHash = await new MsgBroadcasterWithPk({
  privateKey,
  network: Network.Testnet
}).broadcast({
  msgs: msg
})

console.log(txHash)
```

### MsgCreateDerivativeMarketOrder

此消息用于创建衍生品市价订单

```ts
import {
  MsgCreateDerivativeMarketOrder,
  MsgBroadcasterWithPk,
  getEthereumAddress,
  getDerivativeMarketTensMultiplier
} from '@biya-coin/sdk-ts'
import {
  derivativePriceToChainPriceToFixed,
  derivativeQuantityToChainQuantityToFixed,
  derivativeMarginToChainMarginToFixed
} from '@biya-coin/utils'
import { Network } from '@biya-coin/networks'

const privateKey = '0x...'
const biyachainAddress = 'biya1...'
const feeRecipient = 'biya1...'
const market = {
  marketId: '0x...',
  baseDecimals: 18,
  quoteDecimals: 6,
  minPriceTickSize: '', /* 从链上获取 */
  minQuantityTickSize: '', /* 从链上获取 */
  priceTensMultiplier: '', /** 可以从 getDerivativeMarketTensMultiplier 获取 */
  quantityTensMultiplier: '', /** 可以从 getDerivativeMarketTensMultiplier 获取 */
}
const order = {
  price: 10,
  quantity: 1,
  margin: 10
}

const ethereumAddress = getEthereumAddress(biyachainAddress)
const subaccountIndex = 0
const suffix = '0'.repeat(23) + subaccountIndex
const subaccountId = ethereumAddress + suffix

const msg = MsgCreateDerivativeMarketOrder.fromJSON(
  orderType: 1 /* 买入 */,
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

const txHash = await new MsgBroadcasterWithPk({
  privateKey,
  network: Network.Testnet
}).broadcast({
  msgs: msg
})

console.log(txHash)
```

### MsgBatchUpdateOrders

此消息用于在链上批量更新订单

```ts
import {
  MsgBatchUpdateOrders,
  MsgBroadcasterWithPk,
  getEthereumAddress,
  getDerivativeMarketTensMultiplier,
} from "@biya-coin/sdk-ts";
import {
  derivativePriceToChainPriceToFixed,
  derivativeQuantityToChainQuantityToFixed,
  derivativeMarginToChainMarginToFixed,
} from "@biya-coin/utils";
import { Network } from "@biya-coin/networks";

const privateKey = "0x...";
const biyachainAddress = "biya1...";
const feeRecipient = "biya1...";
const derivativeMarket = {
  marketId: "0x...",
  baseDecimals: 18,
  quoteDecimals: 6,
  minPriceTickSize: "" /* 从链上获取 */,
  minQuantityTickSize: "" /* 从链上获取 */,
  priceTensMultiplier:
    "" /** 可以从 getDerivativeMarketTensMultiplier 获取 */,
  quantityTensMultiplier:
    "" /** 可以从 getDerivativeMarketTensMultiplier 获取 */,
};
const derivativeOrder = {
  price: 10,
  quantity: 1,
  margin: 10,
};
const spotMarket = {
  marketId: "0x...",
  baseDecimals: 18,
  quoteDecimals: 6,
  minPriceTickSize: "" /* 从链上获取 */,
  minQuantityTickSize: "" /* 从链上获取 */,
  priceTensMultiplier:
    "" /** 可以从 getDerivativeMarketTensMultiplier 获取 */,
  quantityTensMultiplier:
    "" /** 可以从 getDerivativeMarketTensMultiplier 获取 */,
};
const spotOrder = {
  price: 10,
  quantity: 1,
  margin: 10,
};

const ethereumAddress = getEthereumAddress(biyachainAddress);
const subaccountIndex = 0;
const suffix = "0".repeat(23) + subaccountIndex;
const subaccountId = ethereumAddress + suffix;

const msg = MsgBatchUpdateOrders.fromJSON({
  biyachainAddress,
  subaccountId: subaccountId,
  derivativeOrdersToCreate: [
    {
      orderType: derivativeOrder.orderType as GrpcOrderType,
      price: derivativePriceToChainPriceToFixed({
        value: derivativeOrder.price,
        quoteDecimals: 6 /* USDT 有 6 位小数 */,
      }),
      quantity: derivativeQuantityToChainQuantityToFixed({
        value: derivativeOrder.quantity,
      }),
      margin: derivativeMarginToChainMarginToFixed({
        value: margin,
        quoteDecimals: 6 /* USDT 有 6 位小数 */,
      }),
      marketId: derivativeMarket.marketId,
      feeRecipient: biyachainAddress,
    },
  ],
  spotOrdersToCreate: [
    {
      orderType: spotOrder.orderType as GrpcOrderType,
      price: spotPriceToChainPriceToFixed({
        value: spotOrder.price,
        baseDecimals: 18 /* BIYA 有 18 位小数 */,
        quoteDecimals: 6 /* USDT 有 6 位小数 */,
      }),
      quantity: spotQuantityToChainQuantityToFixed({
        value: spotOrder.quantity,
        baseDecimals: 18 /* BIYA 有 18 位小数 */,
      }),
      marketId: spotMarket.marketId,
      feeRecipient: biyachainAddress,
    },
  ],
});

const txHash = await new MsgBroadcasterWithPk({
  privateKey,
  network: Network.Testnet,
}).broadcast({
  msgs: msg,
});

console.log(txHash);
```

### MsgBatchCancelSpotOrders

此消息用于在链上批量取消现货订单

```ts
import {
  MsgBatchCancelSpotOrders,
  MsgBroadcasterWithPk,
} from "@biya-coin/sdk-ts";
import { Network } from "@biya-coin/networks";

const privateKey = "0x...";
const biyachainAddress = "biya1...";
const orders = [
  {
    marketId: "0x...",
    subaccountId: "0x...",
    orderHash: "0x...",
  },
  {
    marketId: "0x...",
    subaccountId: "0x...",
    orderHash: "0x...",
  },
];

const messages = orders.map((order) =>
  MsgBatchCancelSpotOrders.fromJSON({
    biyachainAddress,
    orders: [
      {
        marketId: order.marketId,
        subaccountId: order.subaccountId,
        orderHash: order.orderHash,
      },
    ],
  })
);

const txHash = await new MsgBroadcasterWithPk({
  privateKey,
  network: Network.Testnet,
}).broadcast({
  msgs: messages,
});

console.log(txHash);
```

此消息用于在链上批量取消现货订单

### MsgBatchCancelDerivativeOrders

```ts
import {
  MsgBatchCancelDerivativeOrders,
  MsgBroadcasterWithPk,
} from "@biya-coin/sdk-ts";
import { Network } from "@biya-coin/networks";

const privateKey = "0x...";
const biyachainAddress = "biya1...";
const orders = [
  {
    marketId: "0x...",
    subaccountId: "0x...",
    orderHash: "0x...",
  },
  {
    marketId: "0x...",
    subaccountId: "0x...",
    orderHash: "0x...",
  },
];

const messages = orders.map((order) =>
  MsgBatchCancelDerivativeOrders.fromJSON({
    biyachainAddress,
    orders: [
      {
        marketId: order.marketId,
        subaccountId: order.subaccountId,
        orderHash: order.orderHash,
      },
    ],
  })
);

const txHash = await new MsgBroadcasterWithPk({
  privateKey,
  network: Network.Testnet,
}).broadcast({
  msgs: messages,
});

console.log(txHash);
```

### MsgRewardsOptOut

此消息用于退出交易赚取计划。

```ts
import { MsgRewardsOptOut, MsgBroadcasterWithPk } from "@biya-coin/sdk-ts";
import { Network } from "@biya-coin/networks";

const privateKey = "0x...";
const biyachainAddress = "biya...";

const msg = MsgRewardsOptOut.fromJSON({ sender: biyachainAddress });

const txHash = await new MsgBroadcasterWithPk({
  privateKey,
  network: Network.Testnet,
}).broadcast({
  msgs: msg,
});

console.log(txHash);
```

### MsgExternalTransfer

此消息用于将余额从一个子账户转移到另一个子账户。

注意：

- 您不能从默认的 subaccountId 转账，因为该余额现在与 bank 模块中的 Biya Chain 地址相关联。因此，为了使 `MsgExternalTransfer` 工作，您需要从非默认的 subaccountId 转账。

如何找到您将要转账的 subaccountId：

- 您可以通过[账户投资组合 api](../query-indexer/portfolio.md) 查询您现有的 subaccountIds。

如何使用当前与 bank 模块中 Biya Chain 地址关联的资金：

- 如果您有现有的非默认子账户，您需要对您现有的非默认 subaccountIds 之一执行 [MsgDeposit](exchange.md#MsgDeposit)，并使用该 subaccountId 作为下面的 `srcSubaccountId`。
- 如果您没有现有的非默认子账户，您可以对新的默认 subaccountId 执行 [MsgDeposit](exchange.md#MsgDeposit)，这将通过从 `sdk-ts` 导入 `getSubaccountId` 并将 [MsgDeposit](exchange.md#MsgDeposit) 中的 `subaccountId` 字段设置为 `getSubaccountId(biyachainAddress, 1)` 来完成。

```ts
import {
  DenomClient,
  MsgExternalTransfer,
  MsgBroadcasterWithPk,
} from "@biya-coin/sdk-ts";
import { toChainFormat } from "@biya-coin/utils";
import { Network } from "@biya-coin/networks";

const denomClient = new DenomClient(Network.Testnet);

const biyachainAddress = "biya...";
const srcSubaccountId = "0x...";
const dstSubaccountId = `0x...`;
const BIYA_TOKEN_SYMBOL = "BIYA";
const tokenMeta = denomClient.getTokenMetaDataBySymbol(BIYA_TOKEN_SYMBOL);
const tokenDenom = `biya`;

/* 格式化要添加到销毁拍卖池的金额 */
const amount = {
  denom: tokenDenom,
  amount: toChainFormat(1, tokenMeta.decimals).toFixed(),
};

/* 以 proto 格式创建消息 */
const msg = MsgExternalTransfer.fromJSON({
  amount,
  dstSubaccountId,
  srcSubaccountId,
  biyachainAddress,
});

const privateKey = "0x...";

/* 广播交易 */
const txHash = await new MsgBroadcasterWithPk({
  network: Network.Testnet,
  privateKey,
}).broadcast({
  msgs: msg,
});

console.log(txHash);
```
