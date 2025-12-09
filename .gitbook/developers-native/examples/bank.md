# Bank

The bank module is responsible for handling multi-asset coin transfers between accounts and tracking special-case pseudo-transfers which must work differently with particular kinds of accounts (notably delegating/undelegating for vesting accounts). It exposes several interfaces with varying capabilities for secure interaction with other modules which must alter user balances.

In addition, the bank module tracks and provides query support for the total supply of all assets used in the application.

## Messages

Let's explore (and provide examples) the messages that the Bank module exports and we can use to interact with the Biyaliquid chain.

### MsgSend

This message is used to send coins from one address to another. Any TokenFactory token and Peggy token can be used here. To transfer CW20 tokens, see the `MsgExecuteContract` section in [wasm module examples](../../developers-native/examples/wasm.md#msgexecutecontract-transfer).

```ts
import { MsgSend, MsgBroadcasterWithPk } from "@biya-coin/sdk-ts";
import { toChainFormat } from "@biya-coin/utils";
import { Network } from "@biya-coin/networks";

const privateKey = "0x...";
const biyaliquidAddress = "biya1...";
const amount = {
  denom: "biya",
  amount: toChainFormat(1).toFixed(),
};
const msg = MsgSend.fromJSON({
  amount,
  srcBiyaliquidAddress: biyaliquidAddress,
  dstBiyaliquidAddress: biyaliquidAddress,
});

const txHash = await new MsgBroadcasterWithPk({
  privateKey,
  network: Network.Testnet,
}).broadcast({
  msgs: msg,
});

console.log(txHash);
```

### MsgMultiSend

This message is used to send to multiple recipients from multiple senders.

```typescript
import { Network } from "@biya-coin/networks";
import { toChainFormat } from "@biya-coin/utils";
import { MsgMultiSend, MsgBroadcasterWithPk } from "@biya-coin/sdk-ts";

const privateKey = "0x...";
const biyaliquidAddress = "biya1...";
const denom = "biya";
const decimals = 18;
const records = [
  /** add records here */
] as {
  address: string;
  amount: string /* in a human readable number */;
}[];
const totalToSend = records.reduce((acc, record) => {
  return acc.plus(toChainFormat(record.amount, decimals));
}, toChainFormat(0));

const msg = MsgMultiSend.fromJSON({
  inputs: [
    {
      address: biyaliquidAddress,
      coins: [
        {
          denom,
          amount: totalToSend.toFixed(),
        },
      ],
    },
  ],
  outputs: records.map((record) => {
    return {
      address: record.address,
      coins: [
        {
          amount: toChainFormat(record.amount, decimals).toFixed(),
          denom,
        },
      ],
    };
  }),
});

const txHash = await new MsgBroadcasterWithPk({
  privateKey,
  network: Network.Testnet,
}).broadcast({
  msgs: msg,
});

console.log(txHash);
```
