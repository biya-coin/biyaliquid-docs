# MsgBroadcaster 交易

`MsgBroadcaster` 抽象类是一种在 Biya Chain 上轻松广播交易的方法。使用它，您可以传递要打包到交易中的消息和签名者的地址，交易将被准备、签署和广播。

可以在我们的 [Helix 演示仓库](https://github.com/biya-coin/biyachain-helix-demo)中找到使用示例。至于您可以传递给 `broadcast` 方法的消息，您可以在文档的[核心模块](../examples/)部分找到示例。

## MsgBroadcaster + 钱包策略

此 MsgBroadcaster 与钱包策略类一起使用，用于构建去中心化应用程序。

要实例化（和使用）`MsgBroadcaster` 类，您可以使用以下代码片段

```ts
import { MsgSend } from "@biya-coin/sdk-ts";
import { toChainFormat } from "@biya-coin/utils";
import { MsgBroadcaster } from "@biya-coin/wallet-core";
import { ChainId, EvmChainId } from "@biya-coin/ts-types";
import { WalletStrategy } from "@biya-coin/wallet-strategy";
import { Network, getNetworkEndpoints } from "@biya-coin/networks";

const chainId = ChainId.Testnet; // Biya Chain 测试网链 ID
const evmChainId = EvmChainId.TestnetEvm; // Biya Chain Evm 测试网链 ID

export const alchemyRpcEndpoint = `https://eth-goerli.alchemyapi.io/v2/${process.env.APP_ALCHEMY_SEPOLIA_KEY}`;

export const walletStrategy = new WalletStrategy({
  chainId,
  evmOptions: {
    evmChainId,
    rpcUrl: alchemyRpcEndpoint,
  },
});

export const msgBroadcaster = new MsgBroadcaster({
  walletStrategy,
  simulateTx: true,
  network: Network.Testnet,
  endpoints: getNetworkEndpoints(Network.Testnet),
  gasBufferCoefficient: 1.1,
})(
  // 使用示例
  async () => {
    const signer = "biya1...";

    const msg = MsgSend.fromJSON({
      amount: {
        denom: "biya",
        amount: toChainFormat(0.01).toFixed(),
      },
      srcBiyachainAddress: signer,
      dstBiyachainAddress: "biya1...",
    });

    // 使用钱包策略准备 + 签署 + 广播交易
    await msgBroadcastClient.broadcast({
      biyachainAddress: signer,
      msgs: msg,
    });
  }
)();
```

### 构造函数/广播选项

我们允许覆盖传递给 `MsgBroadcaster` 构造函数的一些选项以及广播交易时的选项。以下是接口和每个字段的含义

````typescript
import { Msgs } from '@biya-coin/sdk-ts'
import { ChainId } from '@biya-coin/ts-types'
import { Network, NetworkEndpoints } from '@biya-coin/networks'
import type { WalletStrategy } from '../strategies'

export interface MsgBroadcasterOptions {
  network: Network /** 网络配置（chainId、费用等）- 主网使用 Network.MainnetSentry，测试网使用 Network.TestnetSentry */
  endpoints?: NetworkEndpoints /** 可选 - 覆盖从 `network` 参数获取的端点 **/
  feePayerPubKey?: string /** 可选 - 如果您使用费用委托服务，可以设置费用支付者，这样您就不需要对 Web3Gateway 进行额外查询 */
  simulateTx?: boolean /** 在广播前模拟交易 + 获取交易所需的 gas 费用 */
  txTimeout?: number /** 可选 - 等待交易被包含在区块中的区块数 **/
  walletStrategy: WalletStrategy
  gasBufferCoefficient?: number /** 可选 - 作为 gas 缓冲添加到模拟/硬编码的 gas 中，以确保交易被包含在区块中 */
}

export interface MsgBroadcasterTxOptions {
  memo?: string /** 添加到交易的备注 **/
  biyachainAddress: string /** 交易的签名者 **/
  msgs: Msgs | Msgs[] /** 要打包到交易中的消息 **/

  /*
  *** 覆盖硬编码的 gas/模拟 -
  *** 取决于 MsgBroadcaster 构造函数中的
  *** simulateTx 参数
  */
  gas?: {
    gasPrice?: string
    gas?: number /** gas 限制 */
    feePayer?: string
    granter?: string
  }
}

```
````

\{% hint style="info" %\} 要覆盖 `endpoints` 并使用您的基础设施（这是我们推荐的），请在[网络](../../concepts/networks.md)页面上阅读更多关于您需要提供的端点以及如何设置它们的信息。\{% endhint %\}

## 使用私钥的 MsgBroadcaster

此 MsgBroadcaster 与私钥一起使用（主要用于 CLI 环境）。构造函数/广播选项与 `MsgBroadcaster` 非常相似。

```ts
import { toChainFormat } from "@biya-coin/utils";
import { MsgSend, MsgBroadcasterWithPk } from "@biya-coin/sdk-ts";

export const msgBroadcasterWithPk = new MsgBroadcasterWithPk({
  privateKey: `0x...` /** 私钥哈希或 sdk-ts 中的 PrivateKey 类 */,
  network: NETWORK,
})(
  // 使用示例
  async () => {
    const signer = "biya1...";

    const msg = MsgSend.fromJSON({
      amount: {
        denom: "biya",
        amount: toChainFormat(0.01).toFixed(),
      },
      srcBiyachainAddress: signer,
      dstBiyachainAddress: "biya1...",
    });

    // 使用钱包策略准备 + 签署 + 广播交易
    await msgBroadcasterWithPk.broadcast({
      biyachainAddress: signer,
      msgs: msg,
    });
  }
)();
```
