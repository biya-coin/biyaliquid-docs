# AuthZ

`authz` 模块是 Cosmos SDK 模块的实现，根据 ADR 30，允许从一个账户（授予者）向另一个账户（被授予者）授予任意权限。

## 消息

### MsgGrant

使用 MsgGrant 消息创建授权。如果已经存在（授予者，被授予者，授权）三元组的授权，则新授权将覆盖之前的授权。要更新或扩展现有授权，应创建具有相同（授予者，被授予者，授权）三元组的新授权。

有用的消息类型列表：

```
"/biyachain.exchange.v1beta1.MsgCreateSpotLimitOrder",
"/biyachain.exchange.v1beta1.MsgCreateSpotMarketOrder",
"/biyachain.exchange.v1beta1.MsgCancelSpotOrder",
"/biyachain.exchange.v1beta1.MsgBatchUpdateOrders",
"/biyachain.exchange.v1beta1.MsgBatchCancelSpotOrders",
"/biyachain.exchange.v1beta1.MsgDeposit",
"/biyachain.exchange.v1beta1.MsgWithdraw",
"/biyachain.exchange.v1beta1.MsgCreateDerivativeLimitOrder",
"/biyachain.exchange.v1beta1.MsgCreateDerivativeMarketOrder",
"/biyachain.exchange.v1beta1.MsgCancelDerivativeOrder",
"/biyachain.exchange.v1beta1.MsgBatchUpdateOrders",
"/biyachain.exchange.v1beta1.MsgBatchCancelDerivativeOrders",
"/biyachain.exchange.v1beta1.MsgDeposit",
"/biyachain.exchange.v1beta1.MsgWithdraw",
```

根据 [cosmos sdk 文档](https://docs.cosmos.network/main/modules/authz)，"授权必须针对特定的 Msg 服务方法逐一授予"，因此以下代码片段必须针对您希望 `被授予者` 代表 `授予者` 拥有授权的每种消息类型重复执行。

```ts
import { MsgGrant, MsgBroadcasterWithPk } from '@biya-coin/sdk-ts'
import { Network } from '@biya-coin/networks'

const privateKeyOfGranter = '0x...'
const grantee = 'biya...'
const granter = 'biya...'
const messageType = '/biyachain.exchange.v1beta1.MsgCreateSpotLimitOrder' /* 示例消息类型 */

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

当被授予者想要代表授予者执行交易时，他们必须发送 MsgExec。在此示例中，我们将执行 MsgSend 以将资产从授予者的账户地址转移到另一个账户地址。

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
    srcBiyachainAddress: granter,
    dstBiyachainAddress: 'biya1...',
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

可以使用 MsgRevoke 消息删除授权。

```ts
import { MsgRevoke, MsgBroadcasterWithPk, getEthereumAddress } from '@biya-coin/sdk-ts'
import { Network } from '@biya-coin/networks'

const privateKeyOfGranter = '0x...'
const grantee = 'biya...'
const granter = 'biya...'
const messageType = '/biyachain.exchange.v1beta1.MsgCreateSpotLimitOrder' /* 示例消息类型 */

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
