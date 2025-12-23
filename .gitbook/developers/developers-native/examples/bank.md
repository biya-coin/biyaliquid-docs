# Bank

bank 模块负责处理账户之间的多资产代币转账，并跟踪必须与特定类型账户（特别是归属账户的委托/取消委托）不同工作的特殊情况伪转账。它公开了几个具有不同功能的接口，用于与必须更改用户余额的其他模块进行安全交互。

此外，bank 模块跟踪并提供应用程序中使用的所有资产总供应量的查询支持。

## 消息

让我们探索（并提供示例）Bank 模块导出的消息，我们可以使用这些消息与 Biya Chain 链交互。

### MsgSend

此消息用于将代币从一个地址发送到另一个地址。这里可以使用任何 TokenFactory 代币和 Peggy 代币。要转移 CW20 代币，请参阅 [wasm 模块示例](../../developers-native/examples/wasm.md#msgexecutecontract-transfer)中的 `MsgExecuteContract` 部分。

```ts
import { MsgSend, MsgBroadcasterWithPk } from "@biya-coin/sdk-ts";
import { toChainFormat } from "@biya-coin/utils";
import { Network } from "@biya-coin/networks";

const privateKey = "0x...";
const biyachainAddress = "biya1...";
const amount = {
  denom: "biya",
  amount: toChainFormat(1).toFixed(),
};
const msg = MsgSend.fromJSON({
  amount,
  srcBiyachainAddress: biyachainAddress,
  dstBiyachainAddress: biyachainAddress,
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

此消息用于从多个发送者发送到多个接收者。

```typescript
import { Network } from "@biya-coin/networks";
import { toChainFormat } from "@biya-coin/utils";
import { MsgMultiSend, MsgBroadcasterWithPk } from "@biya-coin/sdk-ts";

const privateKey = "0x...";
const biyachainAddress = "biya1...";
const denom = "biya";
const decimals = 18;
const records = [
  /** 在此添加记录 */
] as {
  address: string;
  amount: string /* 以人类可读的数字表示 */;
}[];
const totalToSend = records.reduce((acc, record) => {
  return acc.plus(toChainFormat(record.amount, decimals));
}, toChainFormat(0));

const msg = MsgMultiSend.fromJSON({
  inputs: [
    {
      address: biyachainAddress,
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
