# 通过 Keplr 钱包使用 Ledger 交易

在本页面上，我们将了解当您的用户通过 Keplr 钱包使用 Ledger 设备时 Biya Chain 的实现。

如前所述，Biya Chain 使用与其他 Cosmos 链不同的派生曲线，这意味着用户必须使用以太坊应用（目前）与 Biya Chain 交互。

覆盖所有边缘情况并为 Biya Chain 上所有支持的钱包提供完整的开箱即用解决方案的最简单方法是，我建议您查看 [MsgBroadcaster + WalletStrategy](./msgbroadcaster.md#msgbroadcaster-+-wallet-strategy) 抽象。如果您想进行自己的实现，让我们一起看看代码示例。

## 概述

Keplr 公开了一个 `experimentalSignEIP712CosmosTx_v0` 方法，可用于签署 EIP712 类型数据（通过将 Cosmos StdSignDoc 传递给上述方法在 Keplr 端自动生成），并允许 EVM 兼容链在通过 Keplr 连接 Ledger 设备时获得正确的签名。

以下是函数的签名：

```typescript
/**
 * 使用 ethermint 的 EIP-712 格式签署签名文档。
 * 与 signEthereum(..., EthSignType.EIP712) 的区别在于，此 api 返回由用户的费用设置更改的新签名文档以及该签名文档的签名。
 * 将 tx 编码为 EIP-712 格式应该在使用此 api 的一侧完成。
 * 与 cosmjs 不兼容。
 * 返回的签名是以太坊中使用的 (r | s | v) 格式。
 * v 应该是 27 或 28，无论链如何，都在以太坊主网中使用。
 * @param chainId
 * @param signer
 * @param eip712
 * @param signDoc
 * @param signOptions
 */
experimentalSignEIP712CosmosTx_v0(chainId: string, signer: string, eip712: {
    types: Record<string, {
        name: string;
        type: string;
    }[] | undefined>;
    domain: Record<string, any>;
    primaryType: string;
}, signDoc: StdSignDoc, signOptions?: KeplrSignOptions): Promise<AminoSignResponse>;


```

我们现在需要做的是生成 `eip712` 和 `signDoc`，将它们传递给此函数，Keplr 将要求用户使用其 Ledger 设备上的以太坊应用签署交易。

## 示例实现

基于上述概述，现在让我们展示如何使用 Ledger + Keplr 在 Biya Chain 上实现签署交易的完整示例。请记住，下面的示例考虑到您正在使用从 `@biya-coin/sdk-ts` 包导出的 [Msgs](https://github.com/biya-coin/biyachain-ts/blob/master/packages/sdk-ts/src/core/modules/msgs.ts#L60) 接口。

````typescript
import {
 TxGrpcApi,
 SIGN_AMINO,
 BaseAccount,
 ChainRestAuthApi,
 createTransaction,
 createTxRawEIP712,
 getEip712TypedData
 createWeb3Extension,
 ChainRestTendermintApi,
 getGasPriceBasedOnMessage,
} from '@biya-coin/sdk-ts'
import { EvmChainId, ChainId } from '@biya-coin/ts-types'
import { getNetworkEndpoints, NetworkEndpoints, Network } from '@biya-coin/networks'
import { GeneralException, TransactionException } from '@biya-coin/exceptions'
import { toBigNumber, getStdFee } from '@biya-coin/utils'

export interface Options {
  evmChainId: EvmChainId /* Evm 链 id */
  chainId: ChainId; /* Biya Chain 链 id */
  endpoints: NetworkEndpoints /* 可以根据网络从 @biya-coin/networks 获取 */
}

export interface Transaction {
  memo?: string
  biyachainAddress?: string
  msgs: Msgs | Msgs[]

  // 如果我们想手动设置 gas 选项
  gas?: {
    gasPrice?: string
    gas?: number /** gas 限制 */
    feePayer?: string
    granter?: string
  }
}

/** 将 EIP712 交易详情转换为 Cosmos Std Sign Doc */
export const createEip712StdSignDoc = ({
  memo,
  chainId,
  accountNumber,
  timeoutHeight,
  sequence,
  gas,
  msgs,
}: {
  memo?: string
  chainId: ChainId
  timeoutHeight?: string
  accountNumber: number
  sequence: number
  gas?: string
  msgs: Msgs[]
}) => ({
  chain_id: chainId,
  timeout_height: timeoutHeight || '',
  account_number: accountNumber.toString(),
  sequence: sequence.toString(),
  fee: getStdFee({ gas }),
  msgs: msgs.map((m) => m.toEip712()),
  memo: memo || '',
})

```

/**
 * 我们仅在想要使用 Keplr 上的 Ledger 为 Biya Chain 广播交易时使用此方法
 *
 * 注意：Gas 估算不可用
 * @param tx 需要广播的交易
 */
export const experimentalBroadcastKeplrWithLedger = async (
  tx: Transaction,
  options: Options
) => {
  const { endpoints, chainId, evmChainId } = options
  const msgs = Array.isArray(tx.msgs) ? tx.msgs : [tx.msgs]
  const DEFAULT_BLOCK_TIMEOUT_HEIGHT = 60

  /**
   * 您可以选择执行检查
   * 用户是否确实使用 Ledger + Keplr 连接
   */
  if (/* 您的条件在这里 */) {
    throw new GeneralException(
        new Error(
          '此方法只能在 Keplr 与 Ledger 连接时使用',
        ),
      )
  }

  /** 账户详情 * */
  const chainRestAuthApi = new ChainRestAuthApi(endpoints.rest)
  const accountDetailsResponse = await chainRestAuthApi.fetchAccount(
    tx.biyachainAddress,
  )
  const baseAccount = BaseAccount.fromRestApi(accountDetailsResponse)
  const accountDetails = baseAccount.toAccountDetails()

  /** 区块详情 */
  const chainRestTendermintApi = new ChainRestTendermintApi(endpoints.rest)
  const latestBlock = await chainRestTendermintApi.fetchLatestBlock()
  const latestHeight = latestBlock.header.height
  const timeoutHeight = toBigNumber(latestHeight).plus(
    DEFAULT_BLOCK_TIMEOUT_HEIGHT,
  )

  const key = await window.keplr.getKey(chainId)
  const pubKey = Buffer.from(key.pubKey).toString('base64')
  const gas = (tx.gas?.gas || getGasPriceBasedOnMessage(msgs)).toString()

  /** 用于在以太坊钱包上签名的 EIP712 */
  const eip712TypedData = getEip712TypedData({
    msgs,
    fee: getStdFee({ ...tx.gas, gas }),
    tx: {
      memo: tx.memo,
      accountNumber: accountDetails.accountNumber.toString(),
      sequence: accountDetails.sequence.toString(),
      timeoutHeight: timeoutHeight.toFixed(),
      chainId,
    },
    evmChainId,
  })

  const aminoSignResponse = await window.keplr.experimentalSignEIP712CosmosTx_v0(
    chainId,
    tx.biyachainAddress,
    eip712TypedData,
    createEip712StdSignDoc({
      ...tx,
      ...baseAccount,
      msgs,
      chainId,
      gas: gas || tx.gas?.gas?.toString(),
      timeoutHeight: timeoutHeight.toFixed(),
    }
  )

  /**
   * 从我们作为响应获得的已签名交易创建 TxRaw
   * 以防用户在 Keplr 弹出窗口上更改了费用/备注
   */
  const { txRaw } = createTransaction({
    pubKey,
    message: msgs,
    memo: aminoSignResponse.signed.memo,
    signMode: SIGN_AMINO,
    fee: aminoSignResponse.signed.fee,
    sequence: parseInt(aminoSignResponse.signed.sequence, 10),
    timeoutHeight: parseInt(
      (aminoSignResponse.signed as any).timeout_height,
      10,
    ),
    accountNumber: parseInt(aminoSignResponse.signed.account_number, 10),
    chainId,
  })

  /** 准备用于客户端广播的交易 */
  const web3Extension = createWeb3Extension({
    evmChainId,
  })
  const txRawEip712 = createTxRawEIP712(txRaw, web3Extension)

  /** 附加签名 */
  const signatureBuff = Buffer.from(
    aminoSignResponse.signature.signature,
    'base64',
  )
  txRawEip712.signatures = [signatureBuff]

  /** 广播交易 */
  const response = await new TxGrpcApi(endpoints.grpc).broadcast(txRawEip712)

  if (response.code !== 0) {
    throw new TransactionException(new Error(response.rawLog), {
      code: UnspecifiedErrorCode,
      contextCode: response.code,
      contextModule: response.codespace,
    })
  }

  return response
}
````
