# Fee Grant

`feegrant` 模块允许账户（授予者）向其他账户（被授予者）授予费用津贴。这允许被授予者使用授予者的资金支付交易费用。

## 消息

### MsgGrantAllowance

使用 `MsgGrantAllowance` 消息创建费用津贴授权。如果已经存在（授予者，被授予者）对的授权，则新授权将覆盖之前的授权。

```ts
import { MsgGrantAllowance, MsgBroadcasterWithPk } from '@biya-coin/sdk-ts'
import { Network } from '@biya-coin/networks'


const privateKeyOfGranter = '0x...'

const date = new Date('2023-10-02T00:00:00Z')
const expiration = date.getTime() / 1000
const granter = 'biya...'
const grantee = 'biya...'
const allowance = {
  spendLimit: [
    {
      denom: 'biya',
      amount: '10000',
    },
  ],
  expiration
}

const msg = MsgGrantAllowance.fromJSON({
  granter,
  grantee,
  allowance,
})

const txHash = await new MsgBroadcasterWithPk({
privateKey: privateKeyOfGranter,
network: Network.Testnet,
}).broadcast({
msgs: msg,
})

console.log(txHash)

```

### MsgRevokeAllowance
可以使用 MsgRevokeAllowance 消息删除授权。被授予者将不再能够使用授予者的资金支付交易费用。

```ts
import { MsgRevokeAllowance, MsgBroadcasterWithPk } from '@biya-coin/sdk-ts'
import { Network } from '@biya-coin/networks'

const privateKey= "0x..."
const granteeAddress = 'biya...'
const granterAddress = 'biya...'

const params = {
grantee: granteeAddress,
granter: granterAddress,
}

const msg = MsgRevokeAllowance.fromJSON(params);

const txHash = await new MsgBroadcasterWithPk({
privateKey,
network: Network.Testnet,
}).broadcast({
msgs: msg,
})

console.log(txHash)
```
