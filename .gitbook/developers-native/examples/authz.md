# AuthZ

The `authz` module is an implementation of a Cosmos SDK module, per ADR 30, that allows granting arbitrary privileges from one account (the granter) to another account (the grantee).

## Messages

### MsgGrant

An authorization grant is created using the MsgGrant message. If there is already a grant for the (granter, grantee, Authorization) triple, then the new grant will overwrite the previous one. To update or extend an existing grant, a new grant with the same (granter, grantee, Authorization) triple should be created.

List of useful message types:

```
"/biyaliquid.exchange.v1beta1.MsgCreateSpotLimitOrder",
"/biyaliquid.exchange.v1beta1.MsgCreateSpotMarketOrder",
"/biyaliquid.exchange.v1beta1.MsgCancelSpotOrder",
"/biyaliquid.exchange.v1beta1.MsgBatchUpdateOrders",
"/biyaliquid.exchange.v1beta1.MsgBatchCancelSpotOrders",
"/biyaliquid.exchange.v1beta1.MsgDeposit",
"/biyaliquid.exchange.v1beta1.MsgWithdraw",
"/biyaliquid.exchange.v1beta1.MsgCreateDerivativeLimitOrder",
"/biyaliquid.exchange.v1beta1.MsgCreateDerivativeMarketOrder",
"/biyaliquid.exchange.v1beta1.MsgCancelDerivativeOrder",
"/biyaliquid.exchange.v1beta1.MsgBatchUpdateOrders",
"/biyaliquid.exchange.v1beta1.MsgBatchCancelDerivativeOrders",
"/biyaliquid.exchange.v1beta1.MsgDeposit",
"/biyaliquid.exchange.v1beta1.MsgWithdraw",
```

Per [cosmos sdk docs](https://docs.cosmos.network/main/modules/authz), "Authorizations must be granted for a particular Msg service method one by one", so the following code snipped must be repeated for each message type that you would like for the `grantee` to have authorization on behalf of a `granter`.

```ts
import { MsgGrant, MsgBroadcasterWithPk } from '@biya-coin/sdk-ts'
import { Network } from '@biya-coin/networks'

const privateKeyOfGranter = '0x...'
const grantee = 'biya...'
const granter = 'biya...'
const messageType = '/biyaliquid.exchange.v1beta1.MsgCreateSpotLimitOrder' /* example message type */

const msg = MsgGrant.fromJSON({
   messageType,
    grantee,
    granter
});

const txHash = await new MsgBroadcasterWithPk({
  privateKey: privateKeyOfGranter,
  network: Network.Testnet
}).broadcast({
  msgs: msg
})

console.log(txHash)
```

### MsgExec

When a grantee wants to execute a transaction on behalf of a granter, they must send MsgExec. In this example, we'll do a MsgSend to transfer assets from the granter's account address to another account address.

```ts
import { Network } from '@biya-coin/networks'
import { toChainFormat } from '@biya-coin/utils'
import { MsgExec, MsgSend, MsgBroadcasterWithPk } from '@biya-coin/sdk-ts'

const privateKeyOfGrantee = '0x...'
const grantee = 'biya...'
const granter = 'biya...'

const msgs = MsgSend.fromJSON({
    amount: {
        denom: 'biya',
        amount: toChainFormat(0.01).toFixed()
    },
    srcBiyaliquidAddress: granter,
    dstBiyaliquidAddress: 'biya1...',
  });

const msg = MsgExec.fromJSON({
    msgs,
    grantee,
});

const txHash = await new MsgBroadcasterWithPk({
  privateKey: privateKeyOfGrantee,
  network: Network.Testnet
}).broadcast({
  msgs: msg
})

console.log(txHash)
```

### MsgRevoke

A grant can be removed with the MsgRevoke message.

```ts
import { MsgRevoke, MsgBroadcasterWithPk, getEthereumAddress } from '@biya-coin/sdk-ts'
import { Network } from '@biya-coin/networks'

const privateKeyOfGranter = '0x...'
const grantee = 'biya...'
const granter = 'biya...'
const messageType = '/biyaliquid.exchange.v1beta1.MsgCreateSpotLimitOrder' /* example message type */

const msg = MsgRevoke.fromJSON({
   messageType,
    grantee,
    granter
});

const txHash = await new MsgBroadcasterWithPk({
  privateKey: privateKeyOfGranter,
  network: Network.Testnet
}).broadcast({
  msgs: msg
})

console.log(txHash)
```
