# Token Factory

`tokenfactory` 模块允许任何账户创建名为 `factory/{创建者地址}/{子面值}` 的新代币。由于代币按创建者地址命名空间，这使得代币铸造无需许可，因为不需要解决名称冲突。

_注意：如果您希望您的面值在 Helix、Hub、Explorer 等产品上可见，重要的是使用下面解释的 `MsgSetDenomMetadata` 消息添加代币元数据信息。_

_注意 #2：建议将您的管理员更改为零地址以确保安全并防止供应操纵。_

## 消息

让我们探索（并提供示例）TokenFactory 模块导出的消息，我们可以使用这些消息与 Biya Chain 链交互。

### MsgCreateDenom

给定面值创建者地址和子面值，创建 `factory/{创建者地址}/{子面值}` 的面值。子面值可以包含 \[a-zA-Z0-9./]。请记住，创建新代币时需要支付 `创建费用`。

请记住，代币的 `管理员` 可以更改供应量（铸造或销毁新代币）。建议使用 `MsgChangeAdmin` 取消设置 `管理员`，如下所述。

```ts
import { Network } from "@biya-coin/networks";
import { MsgCreateDenom } from "@biya-coin/sdk-ts";

const biyachainAddress = "biya1...";
const privateKey = "0x...";
const subdenom = "biya-test";

const msg = MsgCreateDenom.fromJSON({
  subdenom,
  symbol: "BiyaTest",
  name: "Biya Testing",
  sender: biyachainAddress,
});

const txHash = await new MsgBroadcasterWithPk({
  privateKey,
  network: Network.Testnet,
}).broadcast({
  msgs: msg,
});

console.log(txHash);
```

### MsgMint

只有当前管理员才能铸造特定面值。请注意，当前管理员默认为面值的创建者。

```ts
import { MsgMint } from "@biya-coin/sdk-ts";
import { Network } from "@biya-coin/networks";

const biyachainAddress = "biya1...";
const privateKey = "0x...";
const subdenom = "biya-test";
const amountToMint = 1_000_000_000;

const msg = MsgMint.fromJSON({
  sender: biyachainAddress,
  amount: {
    denom: `factory/${biyachainAddress}/${subdenom}`,
    amount: amountToMint,
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

### MsgBurn

管理员可以销毁代币工厂的供应量。其他人只能使用此消息销毁自己的资金。

```ts
import { MsgBurn } from "@biya-coin/sdk-ts";
import { Network } from "@biya-coin/networks";

const biyachainAddress = "biya1...";
const privateKey = "0x...";
const subdenom = "biya-test";
const amountToBurn = 1_000_000_000;

const msg = MsgBurn.fromJSON({
  sender: biyachainAddress,
  amount: {
    denom: `factory/${biyachainAddress}/${subdenom}`,
    amount: amountToBurn,
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

### MsgSetDenomMetadata

只有面值的管理员才能设置特定面值的元数据。它允许覆盖 bank 模块中的面值元数据。

```ts
import {
  MsgSetDenomMetadata,
} from "@biya-coin/sdk-ts";
import { Network } from "@biya-coin/networks";

const biyachainAddress = "biya1...";
const privateKey = "0x...";
const subdenom = 'biya-test'
const denom = `factory/${biyachainAddress}/${subdenom}`;

const denomUnitsIfTokenHas0Decimals = [
  {
    denom: denom,
    exponent: 0,
    aliases: [subdenom]
  },
]
const denomUnitsIfTokenHas6Decimals = [
  {
    denom: denom, /** 我们在这里使用完整的面值 */
    exponent: 0,
    aliases: [subdenom]
  },
  {
    denom: subdenom,
    exponent: 6, /** 我们在这里只使用子面值（如果您希望代币有 6 位小数）*/
    aliases: []
  },
]

const msg = MsgSetDenomMetadata.fromJSON({
  sender: biyachainAddress,
  metadata: {
    base: denom, /** 基础面值 */
    description: '', /** 您的代币描述 */
    display: subdenom, /** 您的代币在 UI 上的显示别名（它是具有最高小数位数的单位的面值）*/
    name: '', /** 您的代币名称 */
    symbol: '', /** 您的代币符号 */
    uri: '' /** 您的代币徽标，应托管在 IPFS 上，应该是小型 webp 图像 */
    denomUnits: denomUnitsIfTokenHas6Decimals  /** 选择您希望代币有 6 位还是 0 位小数 */,
    decimals: 6 /** 选择您希望代币有 6 位还是 0 位小数 */
  }
});

const txHash = await new MsgBroadcasterWithPk({
  privateKey,
  network: Network.Testnet
}).broadcast({
  msgs: msg
});

console.log(txHash);
```

### MsgChangeAdmin

面值的管理员可以铸造新供应或销毁现有供应。建议将管理员更改为零地址，以不允许更改代币的供应量。

```ts
import { Network } from "@biya-coin/networks";
import { MsgChangeAdmin } from "@biya-coin/sdk-ts";

const biyachainAddress = "biya1...";
const privateKey = "0x...";
const subdenom = "biya-test";
const denom = `factory/${biyachainAddress}/${subdenom}`;

const msg = MsgChangeAdmin.fromJSON({
  denom,
  sender: biyachainAddress,
  newAdmin:
    "biya1qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqe2hm49" /** 设置为零地址 */,
});

const txHash = await new MsgBroadcasterWithPk({
  privateKey,
  network: Network.Testnet,
}).broadcast({
  msgs: msg,
});

console.log(txHash);
```

## 完整示例

以下是如何在 Biya Chain 上创建新代币、铸造新代币和设置代币元数据的完整示例。

```ts
import {
  MsgSetDenomMetadata,
} from "@biya-coin/sdk-ts";
import { Network } from "@biya-coin/networks";

const biyachainAddress = "biya1...";
const privateKey = "0x...";
const subdenom = 'biya-test'
const denom = `factory/${biyachainAddress}/${subdenom}`;
const amount = 1_000_000_000

const msgCreateDenom = MsgCreateDenom.fromJSON({
  subdenom,
  sender: biyachainAddress,
});
const msgMint = MsgMint.fromJSON({
  sender: biyachainAddress,
  amount: {
    denom: `factory/${biyachainAddress}/${subdenom}`,
    amount: amount
  }
});
const msgChangeAdmin = MsgChangeAdmin.fromJSON({
  denom: `factory/${biyachainAddress}/${subdenom}`,
  sender: biyachainAddress,
  newAdmin: 'biya1qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqe2hm49' /** 设置为零地址 */
});
const msgSetDenomMetadata = MsgSetDenomMetadata.fromJSON({
  sender: biyachainAddress,
  metadata: {
    base: denom, /** 基础面值 */
    description: '', /** 您的代币描述 */
    display: '', /** 您的代币在 UI 上的显示名称 */,
    name: '', /** 您的代币名称 */,
    symbol: '' /** 您的代币符号 */,
    uri: '' /** 您的代币徽标，应托管在 IPFS 上，应该是小型 webp 图像 */
    denomUnits: [
      {
        denom: denom,
        exponent: 0,
        aliases: [subdenom]
      },
      {
        denom: subdenom,
        exponent: 6, /** 如果您希望代币有 6 位小数 */
        aliases: []
      },
    ]
  }
});

const txHash = await new MsgBroadcasterWithPk({
  privateKey,
  network: Network.Testnet
}).broadcast({
  msgs: [msgCreateDenom, msgMint, msgSetDenomMetadata, msgChangeAdmin]
});

console.log(txHash);
```
