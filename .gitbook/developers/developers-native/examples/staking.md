# Staking

该模块使基于 Cosmos SDK 的区块链能够支持先进的权益证明（PoS）系统。在此系统中，链的原生质押代币的持有者可以成为验证者，并可以将代币委托给验证者，最终确定系统的有效验证者集。

## 消息

让我们探索（并提供示例）Staking 模块导出的消息，我们可以使用这些消息与 Biya Chain 链交互。

### MsgBeginRedelegate

此消息用于将质押的 BIYA 从一个验证者重新委托到另一个验证者。

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

此消息用于将 BIYA 委托给验证者。

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

此消息用于取消从验证者的解绑，重置绑定期，并重新委托回之前的验证者。

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
const creationHeight = "123456"; // 启动解绑的高度

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
