# 私钥交易

在本文档中，我们将向您展示如何使用私钥在 Biya Chain 上签署交易。

Biya Chain 上的每个交易都遵循相同的流程。该流程包括三个步骤：准备、签署和广播交易。让我们分别深入研究每个步骤并详细解释过程（包括示例），以便我们可以理解整个交易流程。

## 准备交易

首先，我们需要准备交易以进行签名。

```ts
import {
  MsgSend,
  PrivateKey,
  BaseAccount,
  ChainRestAuthApi,
  createTransaction,
  ChainRestTendermintApi,
} from "@biya-coin/sdk-ts";
import {
  toBigNumber,
  toChainFormat,
  getDefaultStdFee,
  DEFAULT_BLOCK_TIMEOUT_HEIGHT,
} from "@biya-coin/utils";
import { ChainId } from "@biya-coin/ts-types";
import { Network, getNetworkEndpoints } from "@biya-coin/networks";

const privateKeyHash = "";
const privateKey = PrivateKey.fromHex(privateKeyHash);
const biyachainAddress = privateKey.toBech32();
const address = privateKey.toAddress();
const pubKey = privateKey.toPublicKey().toBase64();
const chainId = "biyachain-1"; /* ChainId.Mainnet */
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

/** 准备交易 **/
const { txRaw, signBytes } = createTransaction({
  pubKey,
  chainId,
  message: msgs,
  fee: getDefaultStdFee(),
  sequence: baseAccount.sequence,
  timeoutHeight: timeoutHeight.toNumber(),
  accountNumber: baseAccount.accountNumber,
});
```

## 签署交易

一旦我们准备好交易，我们就开始签署。从上一步获得 `txRaw` 交易后，使用任何 Cosmos 原生钱包进行签名（例如：Keplr），

```ts
import { ChainId } from '@biya-coin/ts-types'

/* 签署交易 */
const privateKeyHash = ''
const privateKey = PrivateKey.fromHex(privateKeyHash);
const signBytes = /* 从上一步获取 */

/** 签署交易 */
const signature = await privateKey.sign(Buffer.from(signBytes));
```

## 广播交易

一旦我们准备好签名，我们需要将交易广播到 Biya Chain 链本身。从第二步获得签名后，我们需要将该签名包含在已签名的交易中并将其广播到链。

```ts
import { ChainId } from '@biya-coin/ts-types'
import { TxRestClient } from '@biya-coin/sdk-ts'
import { Network, getNetworkInfo } from '@biya-coin/networks'

/** 附加签名 */
const network = getNetworkInfo(Network.Testnet);
const txRaw = /* 从第一步获取 */
const signature = /* 从第二步获取 */
txRaw.signatures = [signature];

/** 计算交易哈希 */
console.log(`交易哈希: ${TxClient.hash(txRaw)}`);

const txService = new TxGrpcClient(network.grpc);

/** 模拟交易 */
const simulationResponse = await txService.simulate(txRaw);

console.log(
  `交易模拟响应: ${JSON.stringify(
    simulationResponse.gasInfo
  )}`
);

/** 广播交易 */
const txResponse = await txService.broadcast(txRaw);

console.log(txResponse);

if (txResponse.code !== 0) {
  console.log(`交易失败: ${txResponse.rawLog}`);
} else {
  console.log(
    `已广播的交易哈希: ${JSON.stringify(txResponse.txHash)}`
  );
}
```

## 示例（准备 + 签署 + 广播）

让我们看看整个流程（使用 Keplr 作为签名钱包）

```ts
import { getNetworkInfo, Network } from "@biya-coin/networks";
import {
  TxClient,
  PrivateKey,
  TxGrpcClient,
  ChainRestAuthApi,
  createTransaction,
} from "@biya-coin/sdk-ts";
import { MsgSend } from "@biya-coin/sdk-ts";
import { toChainFormat, getDefaultStdFee } from "@biya-coin/utils";

/** MsgSend 示例 */
(async () => {
  const network = getNetworkInfo(Network.Testnet);
  const privateKeyHash =
    "f9db9bf330e23cb7839039e944adef6e9df447b90b503d5b4464c90bea9022f3";
  const privateKey = PrivateKey.fromHex(privateKeyHash);
  const biyachainAddress = privateKey.toBech32();
  const publicKey = privateKey.toPublicKey().toBase64();

  /** 账户详情 **/
  const accountDetails = await new ChainRestAuthApi(network.rest).fetchAccount(
    biyachainAddress
  );

  /** 准备消息 */
  const amount = {
    denom: "biya",
    amount: toChainFormat(0.01).toFixed(),
  };

  const msg = MsgSend.fromJSON({
    amount,
    srcBiyachainAddress: biyachainAddress,
    dstBiyachainAddress: biyachainAddress,
  });

  /** 准备交易 **/
  const { signBytes, txRaw } = createTransaction({
    message: msg,
    memo: "",
    pubKey: publicKey,
    fee: getDefaultStdFee(),
    sequence: parseInt(accountDetails.account.base_account.sequence, 10),
    accountNumber: parseInt(
      accountDetails.account.base_account.account_number,
      10
    ),
    chainId: network.chainId,
  });

  /** 签署交易 */
  const signature = await privateKey.sign(Buffer.from(signBytes));

  /** 附加签名 */
  txRaw.signatures = [signature];

  /** 计算交易哈希 */
  console.log(`交易哈希: ${TxClient.hash(txRaw)}`);

  const txService = new TxGrpcClient(network.grpc);

  /** 模拟交易 */
  const simulationResponse = await txService.simulate(txRaw);
  console.log(
    `交易模拟响应: ${JSON.stringify(
      simulationResponse.gasInfo
    )}`
  );

  /** 广播交易 */
  const txResponse = await txService.broadcast(txRaw);

  if (txResponse.code !== 0) {
    console.log(`交易失败: ${txResponse.rawLog}`);
  } else {
    console.log(
      `已广播的交易哈希: ${JSON.stringify(txResponse.txHash)}`
    );
  }
})();
```

## 使用 MsgBroadcasterWithPk 的示例

您可以使用 `@biya-coin/sdk-ts` 包中的 `MsgBroadcasterWithPk` 类，它将上面编写的大部分逻辑抽象为一个类。

**此抽象允许您在 Node/CLI 环境中签署交易。**

```ts
import { Network } from "@biya-coin/networks";
import { toChainFormat } from "@biya-coin/utils";
import { MsgSend, MsgBroadcasterWithPk } from "@biya-coin/sdk-ts";

const privateKey = "0x...";
const biyachainAddress = "biya1...";
const amount = {
  denom: "biya",
  amount: toChainFormat(1).toFixed(),
};
const msg = MsgSend.fromJSON({
  amount,
  srcBiyachainAddress: biyachainAddress,
  dstBiyachainAddress: biyachainAddress,
});

const txHash = await new MsgBroadcasterWithPk({
  privateKey,
  network: Network.Testnet,
}).broadcast({
  msgs: msg,
});

console.log(txHash);
```
