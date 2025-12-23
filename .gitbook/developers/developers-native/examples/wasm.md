# Wasm

`wasm` 模块是与部署在 biyachain 链上的 wasm 智能合约交互的核心，在这里您可以找到部署在 Biya Chain 链上的[智能合约](https://biyascan.com/smart-contracts/)列表。

{% hint style="info" %}
以太坊（例如：Metamask）钱包不支持 `MsgUpdateCode` 和 `MsgStoreCode`。
{% endhint %}

## 消息

### MsgExecuteContract (Transfer)

此消息用于执行合约函数，下面我们将使用 [CW20 规范](https://github.com/CosmWasm/cw-plus/blob/main/packages/cw20/README.md)转账消息作为示例。

```ts
import { Network } from '@biya-coin/networks'
import { MsgExecuteContract, MsgBroadcasterWithPk } from '@biya-coin/sdk-ts'

const biyachainAddress = 'biya1...'
const recipientAddress = 'biya2...'
const contractAddress = 'cw...'

const msg = MsgExecuteContract.fromJSON({
  contractAddress,
  sender: biyachainAddress,
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

### MsgExecuteContract (funds 示例)

在某些情况下，根据智能合约的功能，我们必须将代币转移到智能合约，遵循 cosmwasm 约定，我们使用 funds 字段将代币从用户的 bank 模块转移到智能合约。

以下是如何使用 `test` 合约函数发送 `MsgExecuteContract` 的示例。

```ts
import { Network } from '@biya-coin/networks'
import { toChainFormat } from '@biya-coin/utils'
import { MsgExecuteContract, MsgBroadcasterWithPk } from '@biya-coin/sdk-ts'

const biyachainAddress = 'biya1...'
const contractAddress = 'cw...'

const msg = MsgExecuteContract.fromJSON({
  contractAddress,
  sender: biyachainAddress,
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

在前面的示例中，使用 EIP712 解析 `funds` 数组和 `msgs` 对象存在一些兼容性问题。由于 `MsgExecuteContract` 无法正确转换为 EIP712 然后由以太坊钱包签名，我们引入了 `MsgExecuteContractCompat`，它与 EIP712 完全兼容。

_**注意：**_ _`MsgExecuteContract` 和 `MsgExecuteContractCompat` 底层消息相同。`MsgExecuteContractCompat` 只是与 EIP712 兼容。_

以下是如何使用 `test` 合约函数发送 `MsgExecuteContractCompact` 的示例。

```ts
import {
  MsgBroadcasterWithPk,
  MsgExecuteContractCompat,
} from '@biya-coin/sdk-ts'
import { Network } from '@biya-coin/networks'
import { toChainFormat } from '@biya-coin/utils'

const biyachainAddress = 'biya1...'
const contractAddress = 'cw...'

const msg = MsgExecuteContractCompat.fromJSON({
  contractAddress,
  sender: biyachainAddress,
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
