# 代币工厂

Biya Chain 上的代币工厂模块允许用户和合约创建新的原生代币，并使用铸造 + 销毁模型将原生代币与 CW20 代币交换。这是链上的一个重要功能，因为将来自不同来源的资产表示为原生银行面额对于允许用户访问其他链上模块（如交易所、拍卖、保险基金等）至关重要。代币工厂面额采用以下格式 `factory/{creator address}/{subdenom}`。

结合充当创建者的 `CW20AdapterContract`，我们允许 CW20 资产在 Biya Chain 上作为代币工厂面额原生表示。其工作方式是 CW20 资产由 `CW20AdapterContract` 持有，并作为工厂面额为 biyachain 地址铸造，当我们想要将它们赎回为 CW20 时，它们从银行模块中销毁，并从 `CW20AdapterContract` 解锁回所有者地址。

## 如何将工厂面额赎回为 CW20 的示例

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

## 如何将 CW20 转换为工厂面额的示例

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
