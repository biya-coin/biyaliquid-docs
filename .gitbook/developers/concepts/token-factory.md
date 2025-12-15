# Token Factory

The Token Factory module on Biya Chain which allows users and contracts to create new native tokens and swap native tokens with CW20 tokens using the Mint + Burn model. This is an important feature to have on chain because representing assets from different sources to a native bank denom is crucial to allow users to access the rest of the on-chain modules like exchange, auction, insurance funds, etc. The token factory denoms are in the following format `factory/{creator address}/{subdenom}`.

Combined with the `CW20AdapterContract` which acts as a creator, we allow CW20 assets to be natively represented on Biya Chain as Token Factory denoms. The way it works is that CW20 assets are held by the `CW20AdapterContract` and minted as a factory denom for the biyachain address and when we want to redeem them back to CW20, they are burned from the bank module and unlocked from the `CW20AdapterContract` back to the owner address.

## Example on how to redeem a factory denom to CW20

```ts
import {
  MsgExecuteContractCompat,
  ExecArgCW20AdapterRedeemAndTransfer,
} from '@biya-coin/sdk-ts'

const CW20_ADAPTER_CONTRACT = 'biya...'
const contractCw20Address = 'biya...'
const biyachainAddress = 'biya...'

const message = MsgExecuteContractCompat.fromJSON({
  sender: biyachainAddress,
  contractAddress: CW20_ADAPTER_CONTRACT,
  funds: {
    denom: `factory/${CW20_ADAPTER_CONTRACT}/${contractCw20Address}`,
    amount: actualAmount.toFixed(),
  },
  execArgs: ExecArgCW20AdapterRedeemAndTransfer.fromJSON({
    recipient: biyachainAddress,
  }),
})

// Then pack the message in a transaction, sign it and broadcast to the chain
```

## Example on how to convert CW20 to a factory denom

```ts
import {
  ExecArgCW20Send,
  MsgExecuteContractCompat,
} from '@biya-coin/sdk-ts'

const CW20_ADAPTER_CONTRACT = 'biya...'
const contractCw20Address = 'biya...'
const biyachainAddress = 'biya...'
const amount = '1000000' // 1 USDT represented as on the chain as it has 6 decimals

const message = MsgExecuteContractCompat.fromJSON({
  contractAddress: contractCw20Address,
  sender: biyachainAddress,
  execArgs: ExecArgCW20Send.fromJSON({
    amount,
    contractAddress: CW20_ADAPTER_CONTRACT,
  }),
})

// Then pack the message in a transaction, sign it and broadcast to the chain
```
