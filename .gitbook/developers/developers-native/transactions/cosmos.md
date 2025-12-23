# Cosmos 交易

Biya Chain 上的每个交易都遵循相同的流程。该流程包括三个步骤：准备、签署和广播交易。让我们分别深入研究每个步骤并详细解释过程（包括示例），以便我们可以理解整个交易流程。

## 准备交易

首先，我们需要准备交易以进行签名。

此时，您**不能**使用某些在线抽象，这些抽象基于提供的消息和签名者为您提供快速准备交易的方法（例如使用 `@cosmjs/stargate` 包）。原因是这些包不支持 Biya Chain 的 publicKey typeUrl，因此我们必须在客户端进行地址准备。

为了解决这个问题，我们在 `@biya-coin/sdk-ts` 包中提供了可以准备 `txRaw` 交易的函数。`txRaw` 是 Cosmos 中使用的交易接口，包含有关交易和签名者本身的详细信息。

从 cosmos 钱包获取私钥通常是通过获取 chainId 的当前密钥并从那里访问 pubKey 来完成的（例如：`const key = await window.keplr.getKey(chainId)` => `const pubKey = key.publicKey`）。

```ts
import {
  MsgSend,
  BaseAccount,
  ChainRestAuthApi,
  createTransaction,
  ChainRestTendermintApi,
} from "@biya-coin/sdk-ts";
import { toBigNumber, toChainFormat } from "@biya-coin/utils";
import { getStdFee, DEFAULT_BLOCK_TIMEOUT_HEIGHT } from "@biya-coin/utils";

(async () => {
  const biyachainAddress = "biya1";
  const chainId = "biyachain-1"; /* ChainId.Mainnet */
  const restEndpoint =
    "https://sentry.lcd.biyachain.network"; /* getNetworkEndpoints(Network.MainnetSentry).rest */
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

  /** 从钱包/私钥获取签名者的公钥 */
  const pubKey = await getPubKey();

  /** 准备交易 **/
  const { txRaw, signDoc } = createTransaction({
    pubKey,
    chainId,
    fee: getStdFee({}),
    message: msg,
    sequence: baseAccount.sequence,
    timeoutHeight: timeoutHeight.toNumber(),
    accountNumber: baseAccount.accountNumber,
  });
})();
```

## 签署交易

一旦我们准备好交易，我们就开始签署。从上一步获得 `txRaw` 交易后，使用任何 Cosmos 原生钱包进行签名（例如：Keplr），

```ts
import { ChainId } from '@biya-coin/ts-types'
import { SignDoc } from '@keplr-wallet/types'

const getKeplr = async (chainId: string) => {
  await window.keplr.enable(chainId);

  const offlineSigner = window.keplr.getOfflineSigner(chainId);
  const accounts = await offlineSigner.getAccounts();
  const key = await window.keplr.getKey(chainId);

  return { offlineSigner, accounts, key }
}

const { offlineSigner } = await getKeplr(ChainId.Mainnet)

/* 签署交易 */
const address = 'biya1...'
const signDoc = /* 从上一步获取 */
const directSignResponse = await offlineSigner.signDirect(address, signDoc as SignDoc)
```

您还可以使用我们的 `@biya-coin/wallet-strategy` 包来获得开箱即用的钱包提供程序，这将为您提供可用于签署交易的抽象方法。请参阅该包的文档，设置和使用非常简单。**这是推荐的方法，因为您可以在 dApp 中访问多个钱包。`WalletStrategy` 提供的不仅仅是签署交易的抽象。**

## 广播交易

一旦我们准备好签名，我们需要将交易广播到 Biya Chain 链本身。从第二步获得签名后，我们需要将其包含在已签名的交易中并将其广播到链。

```ts
import { ChainId } from '@biya-coin/ts-types'
import {
  TxRestApi,
  CosmosTxV1Beta1Tx,
  BroadcastModeKeplr,
  getTxRawFromTxRawOrDirectSignResponse,
  TxRaw,
} from '@biya-coin/sdk-ts'
import { TransactionException } from '@biya-coin/exceptions'

/**
 * 重要提示：
 * 如果我们使用 Keplr/Leap 钱包
 * 在签署交易后，我们会得到一个 `directSignResponse`，
 * 而不是将签名添加到我们使用 `createTransaction` 函数创建的 `txRaw` 中
 * 我们需要将 `directSignResponse` 中的签名附加到
 * 实际签署的交易（即 `directSignResponse.signed`）
 * 原因是用户可以对原始交易进行一些更改
 * （即更改 gas 限制或 gas 价格），签署的交易和
 * 广播的交易不相同。
 */
const directSignResponse = /* 从上面的第二步获取 */;
const txRaw = getTxRawFromTxRawOrDirectSignResponse(directSignResponse)

const broadcastTx = async (chainId: String, txRaw: TxRaw) => {
  const getKeplr = async (chainId: string) => {
    await window.keplr.enable(chainId);

    return window.keplr
  }

  const keplr = await getKeplr(ChainId.Mainnet)
  const result = await keplr.sendTx(
    chainId,
    CosmosTxV1Beta1Tx.TxRaw.encode(txRaw).finish(),
    BroadcastModeKeplr.Sync,
  )

  if (!result || result.length === 0) {
    throw new TransactionException(
      new Error('交易广播失败'),
      { contextModule: 'Keplr' },
    )
  }

  return Buffer.from(result).toString('hex')
}

const txHash = await broadcastTx(ChainId.Mainnet, txRaw)

/**
 * 一旦我们获得 txHash，因为我们使用同步模式
 * 我们不确定交易是否包含在区块中，
 * 它可能仍在内存池中，所以我们需要查询
 * 链以查看交易何时被包含
 */
const restEndpoint = 'https://sentry.lcd.biyachain.network' /* getNetworkEndpoints(Network.MainnetSentry).rest */
const txRestApi = new TxRestApi(restEndpoint)

 /** 这将轮询查询交易并等待其包含在区块中 */
const response = await txRestApi.fetchTxPoll(txHash)
```

## 示例（准备 + 签署 + 广播）

让我们看看整个流程（使用 Keplr 作为签名钱包）

```ts
import {
  TxRaw,
  MsgSend,
  BaseAccount,
  TxRestApi,
  ChainRestAuthApi,
  createTransaction,
  CosmosTxV1Beta1Tx,
  BroadcastModeKeplr,
  ChainRestTendermintApi,
  getTxRawFromTxRawOrDirectSignResponse,
} from "@biya-coin/sdk-ts";
import { getStdFee, DEFAULT_BLOCK_TIMEOUT_HEIGHT } from "@biya-coin/utils";
import { ChainId } from "@biya-coin/ts-types";
import { toBigNumber, toChainFormat } from "@biya-coin/utils";
import { TransactionException } from "@biya-coin/exceptions";
import { SignDoc } from "@keplr-wallet/types";

const getKeplr = async (chainId: string) => {
  await window.keplr.enable(chainId);

  const offlineSigner = window.keplr.getOfflineSigner(chainId);
  const accounts = await offlineSigner.getAccounts();
  const key = await window.keplr.getKey(chainId);

  return { offlineSigner, accounts, key };
};

const broadcastTx = async (chainId: string, txRaw: TxRaw) => {
  const keplr = await getKeplr(ChainId.Mainnet);
  const result = await keplr.sendTx(
    chainId,
    CosmosTxV1Beta1Tx.TxRaw.encode(txRaw).finish(),
    BroadcastModeKeplr.Sync
  );

  if (!result || result.length === 0) {
    throw new TransactionException(
      new Error("交易广播失败"),
      { contextModule: "Keplr" }
    );
  }

  return Buffer.from(result).toString("hex");
};

(async () => {
  const chainId = "biyachain-1"; /* ChainId.Mainnet */
  const { key, offlineSigner } = await getKeplr(chainId);
  const pubKey = Buffer.from(key.pubKey).toString("base64");
  const biyachainAddress = key.bech32Address;
  const restEndpoint =
    "https://sentry.lcd.biyachain.network"; /* getNetworkEndpoints(Network.MainnetSentry).rest */
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

  /** 准备交易 **/
  const { signDoc } = createTransaction({
    pubKey,
    chainId,
    fee: getStdFee({}),
    message: msg,
    sequence: baseAccount.sequence,
    timeoutHeight: timeoutHeight.toNumber(),
    accountNumber: baseAccount.accountNumber,
  });

  const directSignResponse = await offlineSigner.signDirect(
    biyachainAddress,
    signDoc as SignDoc
  );
  const txRaw = getTxRawFromTxRawOrDirectSignResponse(directSignResponse);
  const txHash = await broadcastTx(ChainId.Mainnet, txRaw);
  const response = await new TxRestApi(restEndpoint).fetchTxPoll(txHash);

  console.log(response);
})();
```

## 使用 WalletStrategy 的示例（准备 + 签署 + 广播）

示例可以在[这里](https://github.com/biya-coin/biyachain-ts/blob/862e7c30d96120947b056abffbd01b4f378984a1/packages/wallet-ts/src/broadcaster/MsgBroadcaster.ts#L301-L365)找到。
