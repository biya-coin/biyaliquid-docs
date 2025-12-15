# Insurance

This module provides insurance funds for derivative markets in the exchange module of the Biyachain Chain to use in order to support higher leverage trading. On a high level, insurance funds for each derivative market are funded by a permissionless group of underwriters who each own a proportional claim (represented through insurance fund share tokens) over the underlying assets in the insurance fund.

## Messages

Let's explore (and provide examples) the Messages that the Insurance module exports and we can use to interact with the Biyachain chain.

### MsgCreateInsuranceFund

This Message is used to create an Insurance Fund

```ts
import {
  MsgCreateInsuranceFund,
  MsgBroadcasterWithPk,
} from "@biya-coin/sdk-ts";
import { toBigNumber } from "@biya-coin/utils";
import { Network } from "@biya-coin/networks";

const biyachainAddress = "biya1...";
const privateKey = "0x...";
const amount = toBigNumber(5);
const fund = {
  ticker: "BTC/USDT",
  quoteDenom: "peggy0x...",
  oracleBase: "BTC",
  oracleQuote: "USDT",
  oracleType: 10, // BANDIBC
};

const msg = MsgCreateInsuranceFund.fromJSON({
  fund,
  biyachainAddress,
  deposit: {
    denom: fund.quoteDenom,
    amount: amount.toWei(6 /* 6 because USDT has 6 decimals */).toFixed(),
  },
});

const txHash = await new MsgBroadcasterWithPk({
  privateKey,
  network: Network.Testnet,
}).broadcast({
  msgs: msg,
});

console.log(txHash);
```

### MsgRequestRedemption

This Message is used to request redemption.

```ts
import {
  MsgRequestRedemption,
  MsgBroadcasterWithPk,
} from "@biya-coin/sdk-ts";
import { toChainFormat } from "@biya-coin/utils";
import { Network } from "@biya-coin/networks";

const marketId = "0x....";
const privateKey = "0x...";
const biyachainAddress = "biya1...";
const denom = "share1"; // the insurance fund denom (share{id})
const amount = toChainFormat(5).toFixed();

const msg = MsgRequestRedemption.fromJSON({
  marketId,
  biyachainAddress,
  amount: {
    denom,
    amount,
  },
});

const txHash = await new MsgBroadcasterWithPk({
  privateKey,
  network: Network.Testnet,
}).broadcast({
  msgs: msg,
});

console.log(txHash);
```

### MsgUnderwrite

This Message is used to underwrite to an insurance fund.

```ts
import { Network } from "@biya-coin/networks";
import { toChainFormat } from "@biya-coin/utils";
import { MsgUnderwrite, MsgBroadcasterWithPk } from "@biya-coin/sdk-ts";

const usdtDecimals = 6;
const marketId = "0x...";
const privateKey = "0x...";
const denom = "peggy0x...";
const biyachainAddress = "biya1...";
const amount = toChainFormat(5, usdtDecimals).toFixed();

const msg = MsgUnderwrite.fromJSON({
  marketId,
  biyachainAddress,
  amount: {
    denom,
    amount,
  },
});

const txHash = await new MsgBroadcasterWithPk({
  privateKey,
  network: Network.Testnet,
}).broadcast({
  msgs: msg,
});

console.log(txHash);
```
