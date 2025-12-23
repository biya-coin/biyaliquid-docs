# 以太坊 Ledger 交易

## 使用 Ledger 在 Biya Chain 上签署交易

本文档的目标是解释如何使用 Ledger 在 Biya Chain 上签署交易并将其广播到链。该实现与 Cosmos SDK 原生链的默认方法不同，因为 Biya Chain 定义了自己的自定义账户类型，该类型使用以太坊的 ECDSA secp256k1 曲线作为密钥。

## 实现

要了解我们应该如何进行实现，让我们先了解一些概念，这样更容易理解我们将要采取的方法。

### 背景

派生路径是一段数据，它告诉分层确定性（HD）钱包如何在密钥树中派生特定密钥。派生路径被用作标准，并作为 BIP32 的一部分与 HD 钱包一起引入。分层确定性钱包是用于描述使用种子派生许多公钥和私钥的钱包的术语。

派生路径看起来像这样

`m/purpose'/coin_type'/account'/change/address_index`

序列中的每个部分都起作用，每个部分都会改变私钥、公钥和地址。我们不会深入探讨 HD 路径每个部分的确切细节，相反，我们只是简要解释 `coin_type`。每个区块链都有一个代表它的数字，即 `coin_type`。比特币是 `0`，以太坊是 `60`，Cosmos 是 `118`。

### Biya Chain 特定上下文

Biya Chain 使用与以太坊相同的 `coin_type`，即 `60`。这意味着要使用 Ledger 在 Biya Chain 上签署交易，**我们必须使用 Ledger 上的以太坊应用**。

Ledger 限制为一个 `coin_type` 只能安装一个应用程序。由于我们必须使用以太坊应用在 Biya Chain 上签署交易，我们必须探索可用的选项来获得有效的签名。可用选项之一是用于散列和签署类型化结构数据的 `EIP712` 过程。Ledger 公开了我们将要使用的 `signEIP712HashedMessage`。

一旦我们签署了 `EIP712` 类型数据，我们将使用正常的 Cosmos-SDK 方法打包和广播交易。有一些细微的差异，其中之一是使用 `SIGN_MODE_LEGACY_AMINO_JSON` 模式并将 `Web3Extension` 附加到 Cosmos 交易，我们将在本文档中解释它们。

### EIP712 类型数据

EIP 712 是用于散列和签署类型化结构数据的标准。对于每个 EIP712 类型数据，用户传递的每个值（需要签署）都有一个类型代表，它解释了该特定值的确切类型。除了用户想要签署的值及其类型（EIP712 typedData 的 `PrimaryType`）之外，每个 EIP712 类型数据都应包含一个 `EIP712Domain`，它提供有关交易来源的上下文。

## 交易流程

实现本身包括几个步骤，即：

1. 准备要使用 Ledger 上的以太坊应用签署的交易，
2. 在 Ledger 上准备和签署交易，
3. 准备要广播的交易，
4. 广播交易。

我们将深入研究每个步骤，并详细说明我们需要采取的行动来签署交易并将其广播到链。

### 准备交易（用于签名）

如上所述，交易需要使用 Ledger 上的以太坊应用签署。这意味着一旦用户到达签名阶段，就必须提示用户切换（或打开）Ledger 上的以太坊应用。

我们知道每个 Cosmos 交易都由消息组成，这些消息表示用户想要在链上执行的指令。如果我们想从一个地址向另一个地址发送资金，我们将把 `MsgSend` 消息打包到交易中并将其广播到链。

了解这一点后，Biya Chain 团队对这些消息进行了[抽象](https://github.com/biya-coin/biyachain-ts/blob/master/packages/sdk-ts/src/core/modules/MsgBase.ts)，以简化它们打包到交易中的方式。这些消息中的每一个都接受实例化消息所需的特定参数集。完成此操作后，抽象会公开几个方便的方法，我们可以根据选择使用的签名/广播方法使用这些方法。例如，消息公开了 `toDirectSign` 方法，该方法返回消息的类型和 proto 表示，然后可以使用默认的 Cosmos 方法打包交易，使用 privateKey 签署并将其广播到链。

对于这个特定的实现，对我们来说重要的是 `toEip712Types` 和 `toEip712` 方法。在消息实例上调用第一个方法会给出 EIP712 类型数据的消息类型，第二个方法会给出 EIP712 数据的消息值。当我们结合这两种方法时，我们可以生成有效的 EIP712 类型数据，可以传递给签名过程。

那么，让我们看一个快速的代码片段，了解这些方法的使用以及我们如何从消息生成 EIP712 typedData：

```ts
import {
  getEip712TypedDataV2,
  Eip712ConvertTxArgs,
  Eip712ConvertFeeArgs,
} from "@biya-coin/sdk-ts/dist/core/eip712";
import { EvmChainId } from "@biya-coin/ts-types";
import { toChainFormat } from "@biya-coin/utils";
import { MsgSend, getDefaultStdFee } from "@biya-coin/sdk-ts";

/** 稍后将详细介绍这两个接口 */
const txArgs: Eip712ConvertTxArgs = {
  accountNumber: accountDetails.accountNumber.toString(),
  sequence: accountDetails.sequence.toString(),
  timeoutHeight: timeoutHeight.toFixed(),
  chainId: chainId,
};
const txFeeArgs: Eip712ConvertFeeArgs = getDefaultStdFee();
const biyachainAddress = "biya14au322k9munkmx5wrchz9q30juf5wjgz2cfqku";
const amount = {
  denom: "biya",
  amount: toChainFormat(0.01).toFixed(),
};
const evmChainId = EvmChainId.Mainnet;

const msg = MsgSend.fromJSON({
  amount,
  srcBiyachainAddress: biyachainAddress,
  dstBiyachainAddress: biyachainAddress,
});

/** 可用于签名的 EIP712 类型数据 **/
const eip712TypedData = getEip712TypedDataV2({
  msgs: msg,
  tx: txArgs,
  evmChainId,
  fee: txFeeArgs,
});

return eip712TypedData;
```

### 在 Ledger 上准备签名过程

现在我们有了 `eip712TypedData`，我们需要使用 Ledger 签署它。首先，我们需要根据用户在浏览器上的支持获取 Ledger 的传输，并使用 `@ledgerhq/hw-app-eth` 创建一个 Ledger 实例，该实例将使用 Ledger 设备上的以太坊应用来执行用户的操作（确认交易）。从步骤 1 获得 `eip712TypedData` 后，我们可以在 `EthereumApp` 上使用 `signEIP712HashedMessage` 来签署此 typedData 并返回签名。

```ts
import { TypedDataUtils } from 'eth-sig-util'
import { bufferToHex, addHexPrefix } from 'ethereumjs-util'
import EthereumApp from '@ledgerhq/hw-app-eth'

const domainHash = (message: any) =>
  TypedDataUtils.hashStruct('EIP712Domain', message.domain, message.types, true)

const messageHash = (message: any) =>
  TypedDataUtils.hashStruct(
    message.primaryType,
    message.message,
    message.types,
    true,
  )

const transport = /* 从 Ledger 获取传输 */
const ledger = new EthereumApp(transport)
const derivationPath = /* 获取地址的派生路径 */

/* 来自步骤 1 的 eip712TypedData */
const object = JSON.parse(eip712TypedData)

const result = await ledger.signEIP712HashedMessage(
  derivationPath,
  bufferToHex(domainHash(object)),
  bufferToHex(messageHash(object)),
)
const combined = `${result.r}${result.s}${result.v.toString(16)}`
const signature = combined.startsWith('0x') ? combined : `0x${combined}`

return signature;
```

### 准备要广播的交易

现在我们有了签名，我们可以使用默认的 cosmos 方法准备交易。

```ts
import {
  SIGN_AMINO,
  BaseAccount,
  getDefaultStdFee,
  ChainRestAuthApi,
  createTransaction,
  createTxRawEIP712,
  createWeb3Extension,
  ChainRestTendermintApi,
} from "@biya-coin/sdk-ts";
import { ChainId, EvmChainId } from "@biya-coin/ts-types";
import {
  toBigNumber,
  DEFAULT_BLOCK_TIMEOUT_HEIGHT,
} from "@biya-coin/utils";

const msg: MsgSend; /* 来自步骤 1 */

const chainId = ChainId.Mainnet;
const evmChainId = EvmChainId.Mainnet;

/** 账户详情 **/
const chainRestAuthApi = new ChainRestAuthApi(lcdEndpoint);
const accountDetailsResponse = await chainRestAuthApi.fetchAccount(
  biyachainAddress
);
const baseAccount = BaseAccount.fromRestApi(accountDetailsResponse);
const accountDetails = baseAccount.toAccountDetails();

/** 区块详情 */
const chainRestTendermintApi = new ChainRestTendermintApi(lcdEndpoint);
const latestBlock = await chainRestTendermintApi.fetchLatestBlock();
const latestHeight = latestBlock.header.height;
const timeoutHeight = toBigNumber(latestHeight).plus(
  DEFAULT_BLOCK_TIMEOUT_HEIGHT
);

const { txRaw } = createTransaction({
  message: msgs,
  memo: "",
  signMode: SIGN_AMINO,
  fee: getDefaultStdFee(),
  pubKey: publicKeyBase64,
  sequence: baseAccount.sequence,
  timeoutHeight: timeoutHeight.toNumber(),
  accountNumber: baseAccount.accountNumber,
  chainId,
});
const web3Extension = createWeb3Extension({
  evmChainId,
});
const txRawEip712 = createTxRawEIP712(txRaw, web3Extension);

/** 附加签名 */
const signatureBuff = Buffer.from(signature.replace("0x", ""), "hex");
txRawEip712.signatures = [signatureBuff];

return txRawEip712;
```

### 广播交易

现在我们已经将交易打包到 `TxRaw` 中，我们可以使用默认的 cosmos 方法将其广播到节点。

## 代码库

让我们看一个包含上述所有步骤的示例代码库

```ts
import {
  TxRestApi,
  SIGN_AMINO
  BaseAccount,
  getDefaultStdFee
  ChainRestAuthApi,
  createTransaction,
  createTxRawEIP712,
  createWeb3Extension,
  ChainRestTendermintApi,
} from '@biya-coin/sdk-ts'
import {
   getEip712TypedDataV2,
   Eip712ConvertTxArgs,
   Eip712ConvertFeeArgs
} from '@biya-coin/sdk-ts/dist/core/eip712'
import { TypedDataUtils } from 'eth-sig-util'
import EthereumApp from '@ledgerhq/hw-app-eth'
import { bufferToHex, addHexPrefix } from 'ethereumjs-util'
import { EvmChainId, ChainId } from '@biya-coin/ts-types'
import { toChainFormat, DEFAULT_BLOCK_TIMEOUT_HEIGHT } from '@biya-coin/utils'

const domainHash = (message: any) =>
TypedDataUtils.hashStruct('EIP712Domain', message.domain, message.types, true)

const messageHash = (message: any) =>
  TypedDataUtils.hashStruct(
    message.primaryType,
    message.message,
    message.types,
    true,
  )

const signTransaction = async (eip712TypedData: any) => {
  const transport = /* 从 Ledger 获取传输 */
  const ledger = new EthereumApp(transport)
  const derivationPath = /* 获取地址的派生路径 */

  /* 来自步骤 1 的 eip712TypedData */
  const result = await ledger.signEIP712HashedMessage(
    derivationPath,
    bufferToHex(domainHash(eip712TypedData)),
    bufferToHex(messageHash(eip712TypedData)),
  )
  const combined = `${result.r}${result.s}${result.v.toString(16)}`
  const signature = combined.startsWith('0x') ? combined : `0x${combined}`

  return signature;
}

const getAccountDetails = (address: string): BaseAccount => {
  const chainRestAuthApi = new ChainRestAuthApi(
    lcdEndpoint,
  )
  const accountDetailsResponse = await chainRestAuthApi.fetchAccount(
    address,
  )
  const baseAccount = BaseAccount.fromRestApi(accountDetailsResponse)
  const accountDetails = baseAccount.toAccountDetails()

  return accountDetails
}

const getTimeoutHeight = () => {
  const chainRestTendermintApi = new ChainRestTendermintApi(
    lcdEndpoint,
  )
  const latestBlock = await chainRestTendermintApi.fetchLatestBlock()
  const latestHeight = latestBlock.header.height
  const timeoutHeight = latestHeight + DEFAULT_BLOCK_TIMEOUT_HEIGHT

  return timeoutHeight
}

const address = 'biya14au322k9munkmx5wrchz9q30juf5wjgz2cfqku'
const chainId = ChainId.Mainnet
const evmChainId = EvmChainId.Mainnet
const accountDetails = getAccountDetails()
const timeoutHeight = getTimeoutHeight

const txArgs: Eip712ConvertTxArgs = {
  accountNumber: accountDetails.accountNumber.toString(),
  sequence: accountDetails.sequence.toString(),
  timeoutHeight: timeoutHeight.toString(),
  chainId: chainId,
}
const txFeeArgs: Eip712ConvertFeeArgs = getDefaultStdFee()
const biyachainAddress = 'biya14au322k9munkmx5wrchz9q30juf5wjgz2cfqku'
const amount = {
  amount: toChainFormat(0.01).toFixed(),
  denom: "biya",
};

const msg = MsgSend.fromJSON({
  amount,
  srcBiyachainAddress: biyachainAddress,
  dstBiyachainAddress: biyachainAddress,
});

/** 可用于签名的 EIP712 类型数据 **/
const eip712TypedData = getEip712TypedDataV2({
  msgs: msg,
  tx: txArgs,
  evmChainId,
  fee: txFeeArgs
})

/** 在以太坊上签名 */
const signature = await signTransaction(eip712TypedData)

/** 准备用于客户端广播的交易 */
const { txRaw } = createTransaction({
  message: msg,
  memo: '',
  signMode: SIGN_AMINO,
  fee: getDefaultStdFee(),
  pubKey: publicKeyBase64,
  sequence: accountDetails.sequence,
  timeoutHeight: timeoutHeight.toNumber(),
  accountNumber: accountDetails.accountNumber,
  chainId: chainId,
})
const web3Extension = createWeb3Extension({
  evmChainId,
})
const txRawEip712 = createTxRawEIP712(txRaw, web3Extension)

/** 附加签名 */
const signatureBuff = Buffer.from(signature.replace('0x', ''), 'hex')
txRawEip712.signatures = [signatureBuff]

/** 广播交易 **/
const txRestApi = new TxRestApi(lcdEndpoint)
const response = await txRestApi.broadcast(txRawEip712)

if (response.code !== 0) {
  throw new Error(`交易失败: ${response.rawLog}`)
}

return response.txhash

```
