# Wasm

The `wasm` module is the heart of interacting with the wasm smart contracts deployed on the biyaliquid chain, here you can find a list of [smart contracts](https://biyascan.com/smart-contracts/) that are deployed on the Biyaliquid chain.

{% hint style="info" %}
`MsgUpdateCode` and `MsgStoreCode` are not supported by Ethereum (ex: Metamask) wallets.
{% endhint %}

## Messages

### MsgExecuteContract (Transfer)

This message is used to execute contract function, below we will use the [CW20 spec](https://github.com/CosmWasm/cw-plus/blob/main/packages/cw20/README.md) transfer message as an example.

```ts
import { Network } from '@biya-coin/networks'
import { MsgExecuteContract, MsgBroadcasterWithPk } from '@biya-coin/sdk-ts'

const biyaliquidAddress = 'biya1...'
const recipientAddress = 'biya2...'
const contractAddress = 'cw...'

const msg = MsgExecuteContract.fromJSON({
  contractAddress,
  sender: biyaliquidAddress,
  exec: {
    action: 'transfer',
    msg: {
      recipient: recipientAddress,
      amount: 100000,
    },
  },
})

const txHash = await new MsgBroadcasterWithPk({
  privateKey,
  network: Network.Mainnet,
}).broadcast({
  msgs: msg,
})

console.log(txHash)
```

### MsgExecuteContract (funds example)

In some scenarios, depending on the smart contract's function we have to transfer tokens to the smart contract, following cosmwasm convention, we use the funds field to transfer tokens to the smart contract from the user's bank module.

Below is an example of how we can send the `MsgExecuteContract` using an `test` contract function.

```ts
import { Network } from '@biya-coin/networks'
import { toChainFormat } from '@biya-coin/utils'
import { MsgExecuteContract, MsgBroadcasterWithPk } from '@biya-coin/sdk-ts'

const biyaliquidAddress = 'biya1...'
const contractAddress = 'cw...'

const msg = MsgExecuteContract.fromJSON({
  contractAddress,
  sender: biyaliquidAddress,
  exec: {
    action: 'test',
    funds: [
      {
        denom: 'biya',
        amount: toChainFormat(1).toFixed(),
      },
    ],
  },
})

const txHash = await new MsgBroadcasterWithPk({
  privateKey,
  network: Network.Mainnet,
}).broadcast({
  msgs: msg,
})

console.log(txHash)
```

### MsgExecuteContractCompat

There are some compatibility issues parsing the `funds` array and `msgs` object in the previous example with EIP712. Since `MsgExecuteContract` can't be properly converted to EIP712 and then signed by Ethereum wallets, we introduced `MsgExecuteContractCompat` which is fully compatible with EIP712.

_**Note:**_ _`MsgExecuteContract` and `MsgExecuteContractCompat` underlying messages are the same. `MsgExecuteContractCompat` is just EIP712 compatible._

Below is an example of how we can send the `MsgExecuteContractCompact` using an `test` contract function.

```ts
import {
  MsgBroadcasterWithPk,
  MsgExecuteContractCompat,
} from '@biya-coin/sdk-ts'
import { Network } from '@biya-coin/networks'
import { toChainFormat } from '@biya-coin/utils'

const biyaliquidAddress = 'biya1...'
const contractAddress = 'cw...'

const msg = MsgExecuteContractCompat.fromJSON({
  contractAddress,
  sender: biyaliquidAddress,
  exec: {
    action: 'test',
    funds: [
      {
        denom: 'biya',
        amount: toChainFormat(1).toFixed(),
      },
    ],
  },
})

const txHash = await new MsgBroadcasterWithPk({
  privateKey,
  network: Network.Mainnet,
}).broadcast({
  msgs: msg,
})

console.log(txHash)
```
