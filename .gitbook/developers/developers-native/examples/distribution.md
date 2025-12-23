# Distribution

`distribution` 模块是从 cosmos sdk [distribution 模块](https://github.com/biya-coin/cosmos-sdk/tree/master/x/distribution)扩展而来的，委托人可以从验证者那里提取他们的质押奖励。

Distribution -> MsgWithdrawValidatorCommission

## MsgWithdrawDelegatorReward

此消息用于从验证者那里提取所有可用的委托人质押奖励。

```ts
import {
  MsgBroadcasterWithPk,
  MsgWithdrawDelegatorReward,
} from "@biya-coin/sdk-ts";
import {  Network } from "@biya-coin/networks";

const biyachainAddress = "biya1...";
const validatorAddress = "biya1...";

/* 以 proto 格式创建消息 */
const msg = MsgWithdrawDelegatorReward.fromJSON({
  validatorAddress,
  delegatorAddress: biyachainAddress,
});

const privateKey = "0x...";

/* 广播交易 */
const txHash = await new MsgBroadcasterWithPk({
  privateKey,
  network: Network.Mainnet
}).broadcast({
  msgs: msg
});

console.log(txHash);
```

## MsgWithdrawValidatorCommission

此消息由验证者用于提取赚取的佣金。

```ts
import {
  MsgBroadcasterWithPk,
  MsgWithdrawValidatorCommission,
} from "@biya-coin/sdk-ts";
import { Network } from "@biya-coin/networks";

const biyachainAddress = "biya1...";
const validatorAddress = "biya1...";

/* 以 proto 格式创建消息 */
const msg = MsgWithdrawValidatorCommission.fromJSON({
  validatorAddress,
});

const privateKey = "0x...";

/* 广播交易 */
const txHash = await new MsgBroadcasterWithPk({
  privateKey,
  network: Network.Testnet
}).broadcast({
  msgs: msg
});

console.log(txHash);
```
