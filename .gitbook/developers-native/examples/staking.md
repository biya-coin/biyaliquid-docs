# Staking

The module enables Cosmos SDK-based blockchain to support an advanced Proof-of-Stake (PoS) system. In this system, holders of the native staking token of the chain can become validators and can delegate tokens to validators, ultimately determining the effective validator set for the system.

## Messages

Let's explore (and provide examples) the Messages that the Staking module exports and we can use to interact with the Biya Chain chain.

### MsgBeginRedelegate

This Message is used to Redelegate staked BIYA from one validator to another.

```ts
import {
  MsgBeginRedelegate,
  MsgBroadcasterWithPk,
} from "@biya-coin/sdk-ts";
import { toChainFormat } from "@biya-coin/utils";
import { Network } from "@biya-coin/networks";

const denom = "biya";
const privateKey = "0x...";
const amount = toChainFormat(5);
const biyachainAddress = "biya1...";
const sourceValidatorAddress = "biya1...";
const destinationValidatorAddress = "biya1...";

const msg = MsgBeginRedelegate.fromJSON({
  biyachainAddress,
  dstValidatorAddress: destinationValidatorAddress,
  srcValidatorAddress: sourceValidatorAddress,
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

### MsgDelegate

This Message is used to Delegate BIYA to a validator.

```ts
import { Network } from "@biya-coin/networks";
import { toChainFormat } from "@biya-coin/utils";
import { MsgDelegate, MsgBroadcasterWithPk } from "@biya-coin/sdk-ts";

const denom = "biya";
const privateKey = "0x...";
const biyachainAddress = "biya1...";
const validatorAddress = "biya1...";
const amount = toChainFormat(5).toFixed();

const msg = MsgDelegate.fromJSON({
  biyachainAddress,
  validatorAddress,
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

### MsgCancelUnbondingDelegation

This message is used to cancel unbonding from a validator, reset the bonding period, and delegate back to the previous validator.

```ts
import {
  MsgBroadcasterWithPk,
  MsgCancelUnbondingDelegation,
} from "@biya-coin/sdk-ts";
import { toChainFormat } from "@biya-coin/utils";
import { Network } from "@biya-coin/networks";

const denom = "biya";
const delegatorAddress = "biya1...";
const privateKey = "0x...";
const amount = toChainFormat(5).toFixed();
const validatorAddress = "biya1...";
const creationHeight = "123456"; // the height at which the unbonding was initiated

const msg = MsgCancelUnbondingDelegation.fromJSON({
  delegatorAddress,
  validatorAddress,
  amount: {
    denom,
    amount,
  },
  creationHeight,
});

const txHash = await new MsgBroadcasterWithPk({
  privateKey,
  network: Network.Testnet,
}).broadcast({
  msgs: msg,
});

console.log(txHash);
```
