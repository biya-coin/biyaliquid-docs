# 以太坊交易

Biya Chain 上的每个交易都遵循相同的流程。该流程包括三个步骤：准备、签署和广播交易。让我们分别深入研究每个步骤并详细解释过程（包括示例），以便我们可以理解整个交易流程。

## 准备交易

首先，我们需要准备交易以进行签名。要使用以太坊原生钱包，我们必须将交易转换为 EIP712 类型数据，并使用钱包签署此类型数据。

使用我们为消息提供的自定义抽象，允许开发者直接从特定消息的 proto 文件获取 EIP712 类型数据。

```ts
import {
  MsgSend,
  BaseAccount,
  ChainRestAuthApi,
  getEip712TypedDataV2,
  ChainRestTendermintApi,
} from "@biya-coin/sdk-ts";
import {
  toBigNumber,
  toChainFormat,
  DEFAULT_BLOCK_TIMEOUT_HEIGHT,
} from "@biya-coin/utils";
import { ChainId, EvmChainId } from "@biya-coin/ts-types";
import { Network, getNetworkEndpoints } from "@biya-coin/networks";

const biyachainAddress = "biya1";
const chainId = ChainId.Mainnet;
const evmChainId = EvmChainId.Mainnet;
const restEndpoint =
  "https://lcd.biyachain.network"; /* getNetworkEndpoints(Network.Mainnet).rest */
const amount = {
  denom: "biya",
  amount: toChainFormat(0.01).toFixed(),
};

/** 账户详情 **/
const chainRestAuthApi = new ChainRestAuthApi(restEndpoint);
const accountDetailsResponse = await chainRestAuthApi.fetchAccount(
  biyachainAddress
);
const baseAccount = BaseAccount.fromRestApi(accountDetailsResponse);
const accountDetails = baseAccount.toAccountDetails();

/** 区块详情 */
const chainRestTendermintApi = new ChainRestTendermintApi(restEndpoint);
const latestBlock = await chainRestTendermintApi.fetchLatestBlock();
const latestHeight = latestBlock.header.height;
const timeoutHeight = toBigNumber(latestHeight).plus(
  DEFAULT_BLOCK_TIMEOUT_HEIGHT
);

/** 准备交易 */
const msg = MsgSend.fromJSON({
  amount,
  srcBiyachainAddress: biyachainAddress,
  dstBiyachainAddress: biyachainAddress,
});

/** 用于在以太坊钱包上签名的 EIP712 */
const eip712TypedData = getEip712TypedDataV2({
  msgs: [msg],
  tx: {
    accountNumber: accountDetails.accountNumber.toString(),
    sequence: accountDetails.sequence.toString(),
    timeoutHeight: timeoutHeight.toFixed(),
    chainId: chainId,
  },
  evmChainId,
});
```

## 签署交易

一旦我们准备好 EIP712 类型数据，我们就开始签署。

```ts
/** 使用您首选的方法签署 EIP712 类型数据，使用 Metamask 的示例 */
const signature = await window.ethereum.request({
  method: "eth_signTypedData_v4",
  params: [
    ethereumAddress,
    JSON.stringify(eip712TypedData /* 从上一步获取 */),
  ],
});

/** 获取签名者的公钥 */
const publicKeyHex = recoverTypedSignaturePubKey(eip712TypedData, signature);
const publicKeyBase64 = hexToBase64(publicKeyHex);
```

您还可以使用我们的 `@biya-coin/wallet-strategy` 包来获得开箱即用的钱包提供程序，这将为您提供可用于签署交易的抽象方法。请参阅该包的文档，设置和使用非常简单。**这是推荐的方法，因为您可以在 dApp 中访问多个钱包。`WalletStrategy` 提供的不仅仅是签署交易的抽象。**

## 广播交易

一旦我们准备好签名，我们需要将交易广播到 Biya Chain 链本身。从第二步获得签名后，我们需要将该签名包含在已签名的交易中并将其广播到链。

```ts
import {
  Network,
  SIGN_AMINO,
  getNetworkEndpoints,
} from "@biya-coin/networks";
import { getDefaultStdFee } from "@biya-coin/utils";
import { ChainId, EvmChainId } from "@biya-coin/ts-types";
import { createTransaction, TxRestApi } from "@biya-coin/sdk-ts";

const evmChainId = EvmChainId.Mainnet;

const { txRaw } = createTransaction({
  message: msgs,
  memo: memo,
  signMode: SIGN_AMINO,
  fee: getDefaultStdFee(),
  pubKey: publicKeyBase64 /* 从上一步获取 */,
  sequence: baseAccount.sequence,
  timeoutHeight: timeoutHeight.toNumber(),
  accountNumber: baseAccount.accountNumber,
  chainId: chainId,
});
const web3Extension = createWeb3Extension({
  evmChainId,
});
const txRawEip712 = createTxRawEIP712(txRaw, web3Extension);

/** 附加签名 */
txRawEip712.signatures = [signatureBuff /* 从上一步获取 */];

/** 广播交易 */
const restEndpoint =
  "https://lcd.biyachain.network"; /* getNetworkEndpoints(Network.Mainnet).rest */
const txRestApi = new TxRestApi(restEndpoint);

const txHash = await txRestApi.broadcast(txRawEip712);

/**
 * 一旦我们获得 txHash，因为我们使用同步模式
 * 我们不确定交易是否包含在区块中，
 * 它可能仍在内存池中，所以我们需要查询
 * 链以查看交易何时被包含
 */

/** 这将轮询查询交易并等待其包含在区块中 */
const response = await txRestApi.fetchTxPoll(txHash);
```

## 不使用 WalletStrategy 的示例（准备 + 签署 + 广播）

让我们看看整个流程（使用 Metamask 作为签名钱包）

```ts
import {
  MsgSend,
  TxRestApi,
  SIGN_AMINO,
  BaseAccount,
  hexToBase64,
  ChainRestAuthApi,
  createTransaction,
  createTxRawEIP712,
  getEip712TypedData,
  getEthereumAddress,
  createWeb3Extension,
  ChainRestTendermintApi,
  recoverTypedSignaturePubKey,
} from "@biya-coin/sdk-ts";
import {
  toBigNumber,
  toChainFormat,
  getDefaultStdFee,
  DEFAULT_BLOCK_TIMEOUT_HEIGHT,
} from "@biya-coin/utils";
import { ChainId, EvmChainId } from "@biya-coin/ts-types";
import { Network, getNetworkEndpoints } from "@biya-coin/networks";

const biyachainAddress = "biya1";
const chainId = ChainId.Mainnet;
const evmChainId = EvmChainId.Mainnet;
const ethereumAddress = getEthereumAddress(biyachainAddress);
const restEndpoint = getNetworkEndpoints(Network.MainnetSentry).rest;
const amount = {
  denom: "biya",
  amount: toChainFormat(0.01).toFixed(),
};

/** 账户详情 **/
const chainRestAuthApi = new ChainRestAuthApi(restEndpoint);
const accountDetailsResponse = await chainRestAuthApi.fetchAccount(
  biyachainAddress
);
const baseAccount = BaseAccount.fromRestApi(accountDetailsResponse);
const accountDetails = baseAccount.toAccountDetails();

/** 区块详情 */
const chainRestTendermintApi = new ChainRestTendermintApi(restEndpoint);
const latestBlock = await chainRestTendermintApi.fetchLatestBlock();
const latestHeight = latestBlock.header.height;
const timeoutHeight = toBigNumber(latestHeight).plus(
  DEFAULT_BLOCK_TIMEOUT_HEIGHT
);

/** 准备交易 */
const msg = MsgSend.fromJSON({
  amount,
  srcBiyachainAddress: biyachainAddress,
  dstBiyachainAddress: biyachainAddress,
});

/** 用于在以太坊钱包上签名的 EIP712 */
const eip712TypedData = getEip712TypedData({
  msgs: [msg],
  tx: {
    accountNumber: accountDetails.accountNumber.toString(),
    sequence: accountDetails.sequence.toString(),
    timeoutHeight: timeoutHeight.toFixed(),
    chainId,
  },
  evmChainId,
});

/** 使用您首选的方法签署 EIP712 类型数据，使用 Metamask 的示例 */
const signature = await window.ethereum.request({
  method: "eth_signTypedData_v4",
  params: [ethereumAddress, JSON.stringify(eip712TypedData)],
});

/** 获取签名者的公钥 */
const publicKeyHex = recoverTypedSignaturePubKey(eip712TypedData, signature);
const publicKeyBase64 = hexToBase64(publicKeyHex);
const signatureBuff = Buffer.from(signature.replace("0x", ""), "hex");

const { txRaw } = createTransaction({
  message: [msg],
  memo: "",
  signMode: SIGN_AMINO,
  fee: getDefaultStdFee(),
  pubKey: publicKeyBase64,
  sequence: baseAccount.sequence,
  timeoutHeight: timeoutHeight.toNumber(),
  accountNumber: baseAccount.accountNumber,
  chainId: chainId,
});
const web3Extension = createWeb3Extension({
  evmChainId,
});
const txRawEip712 = createTxRawEIP712(txRaw, web3Extension);

/** 附加签名 */
txRawEip712.signatures = [signatureBuff];

/** 广播交易 */
const txRestApi = new TxRestApi(restEndpoint);

const txResponse = await txRestApi.broadcast(txRawEip712);
const response = await txRestApi.fetchTxPoll(txResponse.txHash);
```

## 使用 WalletStrategy 的示例（准备 + 签署 + 广播）

示例可以在[这里](https://github.com/biya-coin/biyachain-ts/blob/862e7c30d96120947b056abffbd01b4f378984a1/packages/wallet-ts/src/broadcaster/MsgBroadcaster.ts#L166-L248)找到。
