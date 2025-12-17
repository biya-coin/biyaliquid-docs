# Distribution

The `distribution` module is extended from the cosmos sdk [distribution module](https://github.com/biya-coin/cosmos-sdk/tree/master/x/distribution), where delegator can withdraw their staking rewards from the validator.

Distribution -> MsgWithdrawValidatorCommission

## MsgWithdrawDelegatorReward

This message is used to withdraw all available delegator staking rewards from the validator.

```ts
import {
  MsgBroadcasterWithPk,
  MsgWithdrawDelegatorReward,
} from "@biya-coin/sdk-ts";
import {  Network } from "@biya-coin/networks";

const biyachainAddress = "biya1...";
const validatorAddress = "biya1...";

/* create message in proto format */
const msg = MsgWithdrawDelegatorReward.fromJSON({
  validatorAddress,
  delegatorAddress: biyachainAddress,
});

const privateKey = "0x...";

/* broadcast transaction */
const txHash = await new MsgBroadcasterWithPk({
  privateKey,
  network: Network.Mainnet
}).broadcast({
  msgs: msg
});

console.log(txHash);
```

## MsgWithdrawValidatorCommission

This message is used by the validator to withdraw the commission earned.

```ts
import {
  MsgBroadcasterWithPk,
  MsgWithdrawValidatorCommission,
} from "@biya-coin/sdk-ts";
import { Network } from "@biya-coin/networks";

const biyachainAddress = "biya1...";
const validatorAddress = "biya1...";

/* create message in proto format */
const msg = MsgWithdrawValidatorCommission.fromJSON({
  validatorAddress,
});

const privateKey = "0x...";

/* broadcast transaction */
const txHash = await new MsgBroadcasterWithPk({
  privateKey,
  network: Network.Testnet
}).broadcast({
  msgs: msg
});

console.log(txHash);
```
