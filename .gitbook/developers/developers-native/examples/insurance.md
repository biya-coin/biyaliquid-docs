# Insurance

此模块为 Biya Chain 链的交易所模块中的衍生品市场提供保险基金，以支持更高杠杆的交易。在高层次上，每个衍生品市场的保险基金由一个无需许可的承保人组成，每个承保人对保险基金中的基础资产拥有比例索赔权（通过保险基金份额代币表示）。

## 消息

让我们探索（并提供示例）Insurance 模块导出的消息，我们可以使用这些消息与 Biya Chain 链交互。

### MsgCreateInsuranceFund

此消息用于创建保险基金

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
    amount: amount.toWei(6 /* 6 因为 USDT 有 6 位小数 */).toFixed(),
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

此消息用于请求赎回。

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
const denom = "share1"; // 保险基金面值 (share{id})
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

此消息用于向保险基金承保。

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
