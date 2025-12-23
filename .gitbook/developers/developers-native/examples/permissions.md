# Permissions

Permissions 模块促进了 Biya Chain 生态系统中命名空间、角色和权限的管理。本文档概述了关键消息类型及其用于与权限相关数据交互的用法。

## 消息

让我们探索（并提供示例）Permissions 模块导出的消息，我们可以使用这些消息与 Biya Chain 链交互。

### `MsgClaimVoucher`

此消息用于领取与命名空间内特定地址绑定的凭证。

```ts
import {
  MsgClaimVoucher,
  MsgBroadcasterWithPk,
} from "@biya-coin/sdk-ts";
import { Network } from "@biya-coin/networks";

const biyachainAddress = "biya1...";
const privateKey = "0x...";
const denom = "biya";

const msg = MsgClaimVoucher.fromJSON({
  biyachainAddress,
  denom,
});

const txHash = await new MsgBroadcasterWithPk({
  privateKey,
  network: Network.Testnet
}).broadcast({
  msgs: msg
});

console.log(txHash);

```

### `MsgCreateNamespace`

此消息用于创建具有权限和角色的新命名空间。

```ts
import {
  MsgCreateNamespace,
  MsgBroadcasterWithPk,
} from "@biya-coin/sdk-ts";
import { Network } from "@biya-coin/networks";

const biyachainAddress = "biya1...";
const secondAddress = "biya2.....";
const privateKey = "0x...";
const denom = "biya";
const wasmHook = "biya3....";
const mintsPausedValue = false;
const sendsPausedValue = false;
const burnsPausedValue = false;
const role1 = "Everyone";
const permissions1 = 1;

const msg = MsgCreateNamespace.fromJSON({
  biyachainAddress,
  namespace: {
    denom,
    wasmHook,
    mintsPausedValue,
    sendsPausedValue,
    burnsPausedValue,
    rolePermissions: {
      role: role1,
      permissions: permissions1,
    },
    addressRoles: {
      address: biyachainAddress,
      roles: [role1],
    },
  },
})


const txHash = await new MsgBroadcasterWithPk({
  privateKey,
  network: Network.Testnet
}).broadcast({
  msgs: msg
});

console.log(txHash);

```

### `MsgDeleteNamespace`

此消息用于删除现有命名空间。

```ts
import {
  MsgDeleteNamespace,
  MsgBroadcasterWithPk,
} from "@biya-coin/sdk-ts";
import { Network } from "@biya-coin/networks";

const biyachainAddress = "biya1...";
const privateKey = "0x...";
const denom = "biya";

const msg = MsgDeleteNamespace.fromJSON({
  biyachainAddress,
  denom
});

const txHash = await new MsgBroadcasterWithPk({
  privateKey,
  network: Network.Testnet
}).broadcast({
  msgs: msg
});

console.log(txHash);

```

### `MsgRevokeNamespaceRoles`

此消息用于撤销命名空间中指定地址的角色。

```ts
import {
  MsgRevokeNamespaceRoles,
  MsgBroadcasterWithPk,
} from "@biya-coin/sdk-ts";
import { Network } from "@biya-coin/networks";

const biyachainAddress = "biya1...";
const privateKey = "0x...";
const denom = "biya";
const roles = ["role1","role2"];

const msg = MsgRevokeNamespaceRoles.fromJSON({
  biyachainAddress,
  denom,
  addressRolesToRevoke: {
    biyachainAddress,
    roles: roles,
  },
});

const txHash = await new MsgBroadcasterWithPk({
  privateKey,
  network: Network.Testnet
}).broadcast({
  msgs: msg
});

console.log(txHash);

```

### `MsgUpdateNamespace`

此消息用于更新命名空间属性，如铸造、发送和销毁。

```ts
import {
  MsgUpdateNamespace,
  MsgBroadcasterWithPk,
} from "@biya-coin/sdk-ts";
import { Network } from "@biya-coin/networks";

const biyachainAddress = "biya1..."
const privateKey = "0x...";
const denom = "biya";
const wasmHookValue = "biya2...";
const mintsPausedValue = false;
const sendsPausedValue = false;
const burnsPausedValue = true;

const msg = await new MsgUpdateNamespace.fromJSON({
  biyachainAddress,
  denom,
  wasmHook: {
    newValue: wasmHookValue
  },
  mintsPaused: {
    newValue: mintsPausedValue;
  },
  sendsPaused: {
    newValue: sendsPausedValue;
  },
  burnsPaused: {
    newValue: burnsPausedValue;
  },
});

const txHash = await new MsgBroadcasterWithPk({
  privateKey,
  network: Network.Testnet
}).broadcast({
  msgs: msg
});

console.log(txHash);

```

### `MsgUpdateNamespaceRoles`

此消息用于修改命名空间中地址的角色和权限。

```ts
import {
  MsgUpdateNamespaceRoles,
  MsgBroadcasterWithPk,
} from "@biya-coin/sdk-ts";
import { Network } from "@biya-coin/networks";

const biyachainAddress = "biya1...";
const privateKey = "0x...";
const denom = "biya";
const role = "role1";
const permissions = 4;

const msg = MsgUpdateNamespaceRoles.fromJSON({
  biyachainAddress,
  denom,
  rolePermissions: {
    role,
    permissions: permissions
  },
  addressRoles: {
    biyachainAddress,
    roles: [role],
  },
});

const txHash = await new MsgBroadcasterWithPk({
  privateKey,
  network: Network.Testnet
}).broadcast({
  msgs: msg
});

console.log(txHash);

```
