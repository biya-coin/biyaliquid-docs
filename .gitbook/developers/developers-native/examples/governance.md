# Governance

Biya Chain 是一个社区运营的区块链，质押了 BIYA 的用户能够参与与区块链相关的治理。可以提交提案以修订 Biya Chain 程序、技术升级或影响整个 Biya Chain 生态系统的任何其他 Biya Chain 相关更改。

对于您创建的每个提案，我们要求您至少存入 1 BIYA。这是为了确保您是 Biya Chain 社区的积极参与者，并且有资格提出提案并管理协议的未来发展。要使提案进入投票阶段，必须存入 500 BIYA。您可以自己存入 500 BIYA，也可以与社区合作集体存入。

## 消息

让我们探索（并提供示例）Governance 模块导出的消息，我们可以使用这些消息与 Biya Chain 链交互。例如，您可以使用这些消息提议新的现货、永续或期货市场。

### MsgGovDeposit

此消息可用于向现有提案存款。

```ts
import {
  MsgGovDeposit
  MsgBroadcasterWithPk,
} from "@biya-coin/sdk-ts";
import { toChainFormat } from "@biya-coin/utils";
import { Network } from "@biya-coin/networks";

const denom = 'biya'
const proposalId = 12345
const privateKey = "0x...";
const biyachainAddress = "biya...";
const amount = toChainFormat(1).toFixed()

const message = MsgGovDeposit.fromJSON({
  amount: {
    denom,
    amount
  },
  proposalId,
  depositor: biyachainAddress
})

/* 广播交易 */
const txHash = await new MsgBroadcasterWithPk({
  privateKey,
  network: Network.Testnet
}).broadcast({
  msgs: message
});
```

### MsgVote

提案获得适当资金后，投票即可开始。您可以投"赞成"、"反对"、"弃权"或"否决"。

```ts
import { MsgVote, MsgBroadcasterWithPk } from "@biya-coin/sdk-ts";
import { Network } from "@biya-coin/networks";
import { VoteOption } from "@biya-coin/sdk-ts";

const proposalId = 12345;
const privateKey = "0x...";
const biyachainAddress = "biya...";
const vote = VoteOption.VOTE_OPTION_YES;

const message = MsgVote.fromJSON({
  vote,
  proposalId,
  voter: biyachainAddress,
});

const txHash = await new MsgBroadcasterWithPk({
  privateKey,
  network: Network.Testnet,
}).broadcast({
  msgs: message,
});
```

### MsgSubmitTextProposal

在 Biya Chain 上提议任何操作。TextProposal 定义了一个标准文本提案，其更改需要在批准的情况下手动更新。

```ts
import {
  MsgSubmitTextProposal,
  MsgBroadcasterWithPk,
} from "@biya-coin/sdk-ts";
import { Network } from "@biya-coin/networks";
import { toChainFormat } from "@biya-coin/utils";

const denom = "biya";
const privateKey = "0x...";
const biyachainAddress = "biya...";
const amount = toChainFormat(1).toFixed();

const message = MsgSubmitTextProposal.fromJSON({
  title: "提案标题",
  description: "提案描述",
  proposer: biyachainAddress,
  deposit: {
    denom,
    amount,
  },
});

const txHash = await new MsgBroadcasterWithPk({
  privateKey,
  network: Network.Testnet,
}).broadcast({
  msgs: message,
});
```

### MsgSubmitProposalSpotMarketLaunch

此消息允许您提议新的现货市场。确保代码准确，并提供基础资产面值，然后是报价资产面值。基础面值是指您想要交易的资产，报价面值是指您的基础资产以其计价的资产。例如，在 BIYA/USDT 市场中，您将使用 USDT 买卖 BIYA。

```ts
import {
  TokenStaticFactory,
  MsgBroadcasterWithPk,
  MsgSubmitProposalSpotMarketLaunch,
} from "@biya-coin/sdk-ts";
import { toChainFormat, toHumanReadable } from "@biya-coin/utils";
import { getNetworkEndpoints, Network } from "@biya-coin/networks";
// 参考 https://github.com/biya-coin/biyachain-lists
import { tokens } from "../data/tokens.json";

const tokenStaticFactory = new TokenStaticFactory(tokens as TokenStatic[]);

const denom = "biya";
const privateKey = "0x...";
const biyachainAddress = "biya...";
const amount = toChainFormat(1).toFixed();

const market = {
  baseDenom: "biya", // 例如
  quoteDenom: "peggy0x...",
  makerFeeRate: "0.001",
  takerFeeRate: "0.002",
  title: "BIYA/USDT 现货市场启动",
  description:
    "此提案将启动 BIYA/USDT 现货市场，做市商和接受者费用分别为 0.001% 和 0.002%",
  ticker: "BIYA/USDT",
  minPriceTickSize: "0.001",
  minQuantityTickSize: "0.001",
};

const baseDenom = tokenStaticFactory.toToken(market.baseDenom);
const quoteDenom = tokenStaticFactory.toToken(market.quoteDenom);
const marketWithDecimals: SpotMarketLaunchProposal = {
  ...market,
  baseTokenDecimals: baseDenom ? baseDenom.decimals : 18,
  quoteTokenDecimals: quoteDenom ? quoteDenom.decimals : 6,
};

const marketWithTickSizes = {
  ...market,
  minPriceTickSize: toHumanReadable(
    marketWithDecimals.minPriceTickSize,
    marketWithDecimals.baseTokenDecimals - marketWithDecimals.quoteTokenDecimals
  ).toFixed(),
  minQuantityTickSize: toChainFormat(
    marketWithDecimals.minQuantityTickSize,
    marketWithDecimals.baseTokenDecimals
  ).toFixed(),
};

const message = MsgSubmitProposalSpotMarketLaunch.fromJSON({
  market: marketWithTickSizes,
  proposer: biyachainAddress,
  deposit: {
    denom,
    amount,
  },
});

const txHash = await new MsgBroadcasterWithPk({
  privateKey,
  network: Network.Testnet,
}).broadcast({
  msgs: message,
});
```

### MsgSubmitProposalPerpetualMarketLaunch

此消息允许您提议新的永续市场。永续期货合约（或 perps）是衍生期货合约，允许用户买卖基础资产的价值而无需实际拥有它。这是您可以用来为指定代币对创建永续市场的消息。

```ts
import {
  TokenStaticFactory,
  MsgBroadcasterWithPk,
  MsgSubmitProposalPerpetualMarketLaunch,
} from "@biya-coin/sdk-ts";
import { toChainFormat } from "@biya-coin/utils";
import { getNetworkEndpoints, Network } from "@biya-coin/networks";
// 参考 https://github.com/biya-coin/biyachain-lists
import { tokens } from "../data/tokens.json";

const tokenStaticFactory = new TokenStaticFactory(tokens as TokenStatic[]);

const denom = "biya";
const privateKey = "0x...";
const biyachainAddress = "biya...";
const amount = toChainFormat(1).toFixed();

const market = {
  title: "BIYA/USDT 永续市场启动",
  description:
    "此提案将启动 BIYA/USDT 现货市场，做市商和接受者费用分别为 0.001% 和 0.002%",
  ticker: "BIYA/USDT PERP",
  quoteDenom: "peggy0x...",
  oracleBase: "BIYA",
  oracleQuote: "USDT",
  oracleScaleFactor: 6,
  oracleType: 10, // BAND IBC
  initialMarginRatio: "0.05",
  maintenanceMarginRatio: "0.02",
  makerFeeRate: "0.01",
  takerFeeRate: "0.02",
  minPriceTickSize: "0.01",
  minQuantityTickSize: "0.01",
};

const quoteDenom = await tokenStaticFactory.toToken(market.quoteDenom);
const marketWithDecimals = {
  ...market,
  quoteTokenDecimals: quoteDenom ? quoteDenom.decimals : 6,
};

const marketWithTickSizes = {
  ...market,
  minPriceTickSize: toChainFormat(
    marketWithDecimals.minPriceTickSize,
    marketWithDecimals.quoteTokenDecimals
  ).toFixed(),
};

const message = MsgSubmitProposalPerpetualMarketLaunch.fromJSON({
  market: marketWithTickSizes,
  proposer: biyachainAddress,
  deposit: {
    denom,
    amount,
  },
});

const txHash = await new MsgBroadcasterWithPk({
  privateKey,
  network: Network.Testnet,
}).broadcast({
  msgs: message,
});
```

### MsgSubmitProposalExpiryFuturesMarketLaunch

到期期货合约是两个交易对手之间的协议，以特定的未来价格买卖特定数量的基础资产，该价格将在未来的指定日期到期。这是您可以用来为指定代币对创建期货市场的消息。

```ts
import {
  TokenStaticFactory,
  MsgBroadcasterWithPk,
  MsgSubmitProposalExpiryFuturesMarketLaunch,
} from "@biya-coin/sdk-ts";
import { toChainFormat } from "@biya-coin/utils";
import { getNetworkEndpoints, Network } from "@biya-coin/networks";
// 参考 https://github.com/biya-coin/biyachain-lists
import { tokens } from "../data/tokens.json";

const tokenStaticFactory = new TokenStaticFactory(tokens as TokenStatic[]);

const denom = "biya";
const biyachainAddress = "biya...";
const privateKey = "0x...";
const amount = toChainFormat(1).toFixed();

const market = {
  title: "BIYA/USDT 期货市场启动",
  description:
    "此提案将启动 BIYA/USDT 现货市场，做市商和接受者费用分别为 0.001% 和 0.002%",
  ticker: "BIYA/USDT 24-MAR-2023",
  quoteDenom: "peggy0x...",
  oracleBase: "BIYA",
  oracleQuote: "USDT",
  expiry: 1000000, // 市场到期时间，以毫秒为单位
  oracleScaleFactor: 6,
  oracleType: 10, // BAND IBC
  initialMarginRatio: "0.05",
  maintenanceMarginRatio: "0.02",
  makerFeeRate: "0.01",
  takerFeeRate: "0.02",
  minPriceTickSize: "0.01",
  minQuantityTickSize: "0.01",
};

const quoteDenom = await tokenStaticFactory.toToken(market.quoteDenom);

const marketWithDecimals = {
  ...market,
  quoteTokenDecimals: quoteDenom ? quoteDenom.decimals : 6,
};

const marketWithTickSizes = {
  ...market,
  minPriceTickSize: toChainFormat(
    marketWithDecimals.minPriceTickSize,
    marketWithDecimals.quoteTokenDecimals
  ).toFixed(),
};

const message = MsgSubmitProposalExpiryFuturesMarketLaunch.fromJSON({
  market: marketWithTickSizes,
  proposer: biyachainAddress,
  deposit: {
    denom,
    amount,
  },
});

const txHash = await new MsgBroadcasterWithPk({
  privateKey,
  network: Network.Testnet,
}).broadcast({
  msgs: message,
});
```

### MsgSubmitProposalSpotMarketParamUpdate

此消息可用于更新现货市场的参数。

```ts
import {
  MsgBroadcasterWithPk,
  MsgSubmitProposalSpotMarketParamUpdate,
} from "@biya-coin/sdk-ts";
import { toChainFormat } from "@biya-coin/utils";
import { Network } from "@biya-coin/networks";
import { MarketStatusMap } from "@biya-coin/chain-api";

const denom = "biya";
const privateKey = "0x...";
const biyachainAddress = "biya...";
const amount = toChainFormat(1).toFixed();

const market = {
  title: "BIYA/USDT 现货市场启动",
  description:
    "此提案将启动 BIYA/USDT 现货市场，做市商和接受者费用分别为 0.001% 和 0.002%",
  marketId: "0x...",
  makerFeeRate: "0.02",
  takerFeeRate: "0.03",
  relayerFeeShareRate: "0.4", // 40%，交易费用中分配给中继者的百分比
  minPriceTickSize: "0.002",
  minQuantityTickSize: "0.002",
  status: MarketStatusMap.Active,
};

const message = MsgSubmitProposalSpotMarketParamUpdate.fromJSON({
  market,
  proposer: biyachainAddress,
  deposit: {
    denom,
    amount,
  },
});

const txHash = await new MsgBroadcasterWithPk({
  privateKey,
  network: Network.Testnet,
}).broadcast({
  msgs: message,
});
```
