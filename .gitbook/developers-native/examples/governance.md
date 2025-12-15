# Governance

Biyachain is a community-run blockchain and users who have staked BIYA are able to participate in governance as it relates to the blockchain. Proposals can be submitted to make revisions to Biyachain programs, tech upgrades, or any other Biyachain related changes that impact the entire Biyachain ecosystem.

For every proposal you create, we require you to deposit at least 1 BIYA. This is to ensure that you are an active participant of the Biyachain community and you are eligible to make proposals and govern the protocol moving forward. For the proposal to pass to the voting stage, it must have 500 BIYA deposited. You can deposit the 500 BIYA yourself or collaborate with the community to deposit them collectively.

## Messages

Let's explore (and provide examples) the messages that the Governance module exports and we can use to interact with the Biyachain chain. For example, you can use these messages to propose new spot, perpetual, or futures markets.

### MsgGovDeposit

This message can be used to deposit towards an existing proposal.

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

/* broadcast transaction */
const txHash = await new MsgBroadcasterWithPk({
  privateKey,
  network: Network.Testnet
}).broadcast({
  msgs: message
});
```

### MsgVote

After the proposal is properly funded, voting can commence. You can vote "Yes", "No", "Abstain", or "No with Veto".

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

Propose any action on Biyachain. TextProposal defines a standard text proposal whose changes need to be manually updated in case of approval.

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
  title: "Title of Proposal",
  description: "Description of Proposal",
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

This message allows you to propose a new spot market. Ensure that the ticker is accurate and provide the base asset denom followed by the quote asset denom. Base denom refers to the asset you would like to trade and quote denom refers to the asset by which your base asset is denominated. For instance, in the BIYA/USDT market you would buy or sell BIYA using USDT.

```ts
import {
  TokenStaticFactory,
  MsgBroadcasterWithPk,
  MsgSubmitProposalSpotMarketLaunch,
} from "@biya-coin/sdk-ts";
import { toChainFormat, toHumanReadable } from "@biya-coin/utils";
import { getNetworkEndpoints, Network } from "@biya-coin/networks";
// refer to https://github.com/biya-coin/biyachain-lists
import { tokens } from "../data/tokens.json";

const tokenStaticFactory = new TokenStaticFactory(tokens as TokenStatic[]);

const denom = "biya";
const privateKey = "0x...";
const biyachainAddress = "biya...";
const amount = toChainFormat(1).toFixed();

const market = {
  baseDenom: "biya", // for example
  quoteDenom: "peggy0x...",
  makerFeeRate: "0.001",
  takerFeeRate: "0.002",
  title: "BIYA/USDT Spot Market Launch",
  description:
    "This proposal will launch the BIYA/USDT Spot Market with maker and taker fees 0.001% and 0.002% respectively",
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

This message allows you to propose a new perpetual market. perpetual futures contracts, or perps, are derivative futures contracts that allow users to buy or sell the value of an underlying base asset without actually owning it. This is the message you can use to create a perp market for a specified token pair.

```ts
import {
  TokenStaticFactory,
  MsgBroadcasterWithPk,
  MsgSubmitProposalPerpetualMarketLaunch,
} from "@biya-coin/sdk-ts";
import { toChainFormat } from "@biya-coin/utils";
import { getNetworkEndpoints, Network } from "@biya-coin/networks";
// refer to https://github.com/biya-coin/biyachain-lists
import { tokens } from "../data/tokens.json";

const tokenStaticFactory = new TokenStaticFactory(tokens as TokenStatic[]);

const denom = "biya";
const privateKey = "0x...";
const biyachainAddress = "biya...";
const amount = toChainFormat(1).toFixed();

const market = {
  title: "BIYA/USDT Perpetual Market Launch",
  description:
    "This proposal will launch the BIYA/USDT Spot Market with maker and taker fees 0.001% and 0.002% respectively",
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

An expiry futures contract is an agreement between two counterparties to buy and sell a specific amount of an underlying base asset at a specific future price, which is set to expire at a specified date in the future. This is the message you can use to create a futures market for a specified token pair.

```ts
import {
  TokenStaticFactory,
  MsgBroadcasterWithPk,
  MsgSubmitProposalExpiryFuturesMarketLaunch,
} from "@biya-coin/sdk-ts";
import { toChainFormat } from "@biya-coin/utils";
import { getNetworkEndpoints, Network } from "@biya-coin/networks";
// refer to https://github.com/biya-coin/biyachain-lists
import { tokens } from "../data/tokens.json";

const tokenStaticFactory = new TokenStaticFactory(tokens as TokenStatic[]);

const denom = "biya";
const biyachainAddress = "biya...";
const privateKey = "0x...";
const amount = toChainFormat(1).toFixed();

const market = {
  title: "BIYA/USDT Futures Market Launch",
  description:
    "This proposal will launch the BIYA/USDT Spot Market with maker and taker fees 0.001% and 0.002% respectively",
  ticker: "BIYA/USDT 24-MAR-2023",
  quoteDenom: "peggy0x...",
  oracleBase: "BIYA",
  oracleQuote: "USDT",
  expiry: 1000000, // when the market will expire, in ms
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

This message can be used to update the params of a spot market.

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
  title: "BIYA/USDT Spot Market Launch",
  description:
    "This proposal will launch the BIYA/USDT Spot Market with maker and taker fees 0.001% and 0.002% respectively",
  marketId: "0x...",
  makerFeeRate: "0.02",
  takerFeeRate: "0.03",
  relayerFeeShareRate: "0.4", // 40%, the percent of tsx fees that go to the relayers
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
