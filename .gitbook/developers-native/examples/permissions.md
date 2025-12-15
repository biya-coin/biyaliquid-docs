# Permissions

The Permissions Module facilitates the management of namespaces, roles, and permissions within the Biyachain ecosystem. This documentation outlines the key message types and their usage for interacting with permissions-related data.

## Messages

Let's explore (and provide examples) the Messages that the Permissions module exports and we can use to interact with the Biyachain chain.

### `MsgClaimVoucher`

This message is used to claim a voucher tied to a specific address within a namespace.

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

This message is used to creates a new namespace with permissions and roles.

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

This message is used to delete an existing namespace.

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

This message is used to revoke roles from specified addresses in a namespace.

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

This message is used to update namespace properties like mints, sends, and burns.

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

This message is used to modify the roles and permissions for addresses in a namespace.

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
