# 以太坊桥接

Biya Chain 以太坊桥接使 Biya Chain 能够支持无需信任的链上双向代币桥接。在这个系统中，以太坊上的 ERC-20 代币持有者可以即时将其 ERC-20 代币转换为 Biya Chain 上的 Cosmos 原生代币，反之亦然。

Biya Chain Peggy 桥接由三个主要组件组成：

1. 以太坊上的 Peggy 合约
2. Peggo 编排器
3. Biya Chain 上的 Peggy 模块

## Peggy 合约

Peggy 合约的功能是促进从以太坊到 Biya Chain 的 ERC-20 代币的高效双向跨链转移。与其他代币桥接设置不同，Biya Chain Peggy 桥接是一个去中心化、非托管的桥接，完全由 Biya Chain 上的验证者运营。桥接由 Biya Chain 的权益证明安全性保护，因为存款和提款是根据至少三分之二的验证者基于共识质押权重的证明来处理的。

## Peggo 编排器

编排器是每个 Biya Chain 验证者运行的链下中继器，其功能是将 ERC-20 代币转移数据从以太坊传输到 Biya Chain。

## Peggy 模块

基本上，Peggy 模块在从以太坊存入 ERC-20 代币时在 Biya Chain 上铸造新代币，并在从 Biya Chain 提取代币回以太坊时销毁代币。Peggy 模块还管理经济激励，通过各种机制（包括惩罚、原生代币奖励和提款费用）确保验证者诚实高效地行动。

## 从以太坊到 Biya Chain

要从以太坊转移到 Biya Chain，您需要进行 Web3 交易并与以太坊上的 Peggy 合约交互。进行转移需要两个步骤：

1. 由于我们基本上是将 ERC20 资产锁定在以太坊上的 Peggy 合约中，我们需要为要转移到 Peggy 合约的资产设置授权。我们这里有一个[示例](https://github.com/biya-coin/biyachain-ts/blob/1fbc2577b9278a62d1676041d6e502e12f5880a8/deprecated/sdk-ui-ts/src/services/web3/Web3Composer.ts#L41-L91)，说明如何进行此交易，您可以使用任何 web3 提供者来签名并将交易广播到以太坊网络。
2. 设置授权后，我们需要在 Peggy 合约上调用 `sendToBiyachain` 函数，传入要转移到 Biya Chain 的所需数量和资产，可以在此处找到[示例](https://github.com/biya-coin/biyachain-ts/blob/1fbc2577b9278a62d1676041d6e502e12f5880a8/deprecated/sdk-ui-ts/src/services/web3/Web3Composer.ts#L93-L156)。一旦我们获得交易，我们可以使用 web3 提供者来签名并将交易广播到以太坊网络。交易确认后，资产将在几分钟内显示在 Biya Chain 上。

关于上述示例的一些说明：

- 目标地址（如果您想自己构建交易）采用以下格式

```ts
"0x000000000000000000000000{ETHEREUM_ADDRESS_HERE_WITHOUT_0X_PREFIX}";
// example
"0x000000000000000000000000e28b3b32b6c345a34ff64674606124dd5aceca30";
```

其中以太坊地址是目标 Biya Chain 地址对应的以太坊地址。

- `const web3 = walletStrategy.getWeb3()` `walletStrategy` 是我们构建的一个抽象，支持许多可用于签名和广播交易的钱包（在以太坊和 Biya Chain 上），更多详细信息可以在 npm 包 [@biya-coin/wallet-ts](https://github.com/biya-coin/biyachain-ts/blob/master/packages/wallet-ts) 的文档中找到。显然，这只是一个示例，您可以直接使用 web3 包或任何 web3 提供者来处理交易。

```ts
import { PeggyContract } from "@biya-coin/contracts";

const contract = new PeggyContract({
  ethereumChainId,
  address: peggyContractAddress,
  web3: web3 as any,
});
```

- 下面的代码片段实例化了一个 PeggyContract 实例，可以使用我们提供给合约构造函数的 `web3` 轻松进行 `estimateGas` 和 `sendTransaction`。其实现可以在此处找到[这里](https://github.com/biya-coin/biyachain-ts/blob/master/packages/contracts/src/contracts/Peggy.ts)。显然，这只是一个示例，您可以直接使用 web3 包 + 合约的 ABI 来实例化合约，然后使用某个 web3 提供者处理签名和广播交易的逻辑。

## 从 Biya Chain 到以太坊

现在您已经将 ERC20 版本的 BIYA 转移到 Biya Chain，Biya Chain 上的原生 `biya` 代币单位被铸造，它是 BIYA 代币的规范版本。要从 Biya Chain 提取 `biya` 到以太坊，我们必须在 Biya Chain 上准备、签名然后广播一个原生 Cosmos 交易。

如果您不熟悉 Cosmos 上的交易（和消息）如何工作，可以在此处找到更多信息。我们需要打包到交易中以指示 Biya Chain 从 Biya Chain 提取资金到以太坊的消息是 `MsgSendToEth`。

当在链上调用 `MsgSendToEth` 时，一些验证者将拾取交易，将多个 `MsgSendToEth` 请求批处理为一个，然后：在 Biya Chain 上销毁正在提取的资产，在以太坊上的 Peggy 智能合约上解锁这些资金，并将它们发送到相应的地址。

这些交易中包含桥接费用，以激励验证者更快地拾取和处理您的提款请求。桥接费用以用户想要提取到以太坊的资产计价（如果您提取 BIYA，您也必须以 BIYA 支付桥接费用）。

以下是一个示例实现，它准备交易，使用私钥签名，最后将其广播到 Biya Chain：

```ts
import { getNetworkInfo, Network } from "@biya-coin/networks";
import {
  TxClient,
  PrivateKey,
  TxRestClient,
  MsgSendToEth,
  getDefaultStdFee,
  ChainRestAuthApi,
  createTransaction,
} from "@biya-coin/sdk-ts";
import { toChainFormat } from "@biya-coin/utils";

/** MsgSendToEth Example */
(async () => {
  const network = getNetworkInfo(Network.Mainnet); // Gets the rpc/lcd endpoints
  const privateKeyHash =
    "f9db9bf330e23cb7839039e944adef6e9df447b90b503d5b4464c90bea9022f3";
  const privateKey = PrivateKey.fromPrivateKey(privateKeyHash);
  const biyachainAddress = privateKey.toBech32();
  const ethAddress = privateKey.toHex();
  const publicKey = privateKey.toPublicKey().toBase64();

  /** Account Details **/
  const accountDetails = await new ChainRestAuthApi(network.rest).fetchAccount(
    biyachainAddress
  );

  /** Prepare the Message */
  const amount = {
    amount: toChainFormat(0.01).toFixed(),
    denom: "biya",
  };
  const bridgeFee = {
    amount: toChainFormat(0.01).toFixed(),
    denom: "biya",
  };

  const msg = MsgSendToEth.fromJSON({
    amount,
    bridgeFee,
    biyachainAddress,
    address: ethAddress,
  });

  /** Prepare the Transaction **/
  const { signBytes, txRaw } = createTransaction({
    message: msg,
    pubKey: publicKey,
    fee: getDefaultStdFee(),
    sequence: parseInt(accountDetails.account.base_account.sequence, 10),
    accountNumber: parseInt(
      accountDetails.account.base_account.account_number,
      10
    ),
    chainId: network.chainId,
  });

  /** Sign transaction */
  const signature = await privateKey.sign(Buffer.from(signBytes));

  /** Append Signatures */
  txRaw.signatures = [signature];

  /** Calculate hash of the transaction */
  console.log(`Transaction Hash: ${TxClient.hash(txRaw)}`);

  const txService = new TxRestClient(network.rest);

  /** Simulate transaction */
  const simulationResponse = await txService.simulate(txRaw);

  console.log(
    `Transaction simulation response: ${JSON.stringify(
      simulationResponse.gasInfo
    )}`
  );

  /** Broadcast transaction */
  const txResponse = await txService.broadcast(txRaw);

  if (txResponse.code !== 0) {
    console.log(`Transaction failed: ${txResponse.rawLog}`);
  } else {
    console.log(
      `Broadcasted transaction hash: ${JSON.stringify(txResponse.txhash)}`
    );
  }
})();
```
