# CosmJs 支持

Biya Chain 在 `@cosmjs` 包中没有原生支持。强烈建议使用我们的 `@biya-coin` 包与 Biya Chain 交互。

如果您熟悉 `@cosmjs` 包，我们导出了类似的接口/类，它们的工作方式与 `@cosmjs` 上的类相同，但也支持 Biya Chain。

再次提醒，推荐的方法是使用 Biya Chain 的标准方法，您可以在 [Cosmos 交易](../developers-native/transactions/cosmos.md)中了解更多信息。

## 使用 Keplr

以下是如何将 `@cosmjs` 包中的 `@biya-coin` 替代方案与 Keplr 一起使用的示例：

```ts
import {
  PrivateKey,
  BiyachainStargate,
} from "@biya-coin/sdk-ts";
import { OfflineDirectSigner } from "@cosmjs/proto-signing";
import { assertIsBroadcastTxSuccess } from '@cosmjs/stargate'

(async () => {
  // Enable Keplr
  await window.keplr.enable(chainId);

  // Get the offline signer
  const offlineSigner = window.getOfflineSigner(chainId);
  const [account] = await offlineSigner.getAccounts();

  // Initialize the stargate client
  const client =
    await BiyachainStargate.biyachainSigningStargateClient.connectWithSigner(
      "https://lcd-cosmoshub.keplr.app/rest",
      offlineSigner,
    );
  })

  const amount = {
    denom: "biya",
    amount: amount.toString(),
  };
  const fee = {
    amount: [
      {
        denom: "biya",
        amount: "5000000000000000",
      },
    ],
    gas: "200000",
  };

  const result = await client.sendTokens(
    account.address,
    recipient,
    [amount],
    fee,
    ""
  );

  assertIsBroadcastTxSuccess(result);

  if (result.code !== undefined && result.code !== 0) {
    alert("Failed to send tx: " + result.log || result.rawLog);
  } else {
    alert("Succeed to send tx:" + result.transactionHash);
  }
})()
```

## 在 CLI/Node 环境中使用

以下是如何在 node 或 CLI 环境中使用 `@cosmjs` 包中的 `@biya-coin` 替代方案的示例。

再次提醒，推荐的方法是使用 [MsgBroadcasterWithPk](../developers-native/transactions/private-key.md#example-with-msgbroadcasterwithpk) 抽象来遵循 Biya Chain 的标准方法。

```ts
import {
  PrivateKey,
  BiyachainStargate,
  biyachaindirectEthSecp256k1Wallet,
} from "@biya-coin/sdk-ts";
import { OfflineDirectSigner } from "@cosmjs/proto-signing";
import { Network, getNetworkInfo } from "@biya-coin/networks";
import { getStdFee } from "@biya-coin/utils";

(async () => {
  const network = getNetworkInfo(Network.Testnet);
  const privateKeyHash = process.env.PRIVATE_KEY as string;
  const privateKey = PrivateKey.fromHex(privateKeyHash);
  const biyachainAddress = privateKey.toBech32();

  const wallet = (await biyachaindirectEthSecp256k1Wallet.fromKey(
    Buffer.from(privateKeyHash, "hex")
  )) as OfflineDirectSigner;
  const [account] = await wallet.getAccounts();

  const client =
    await BiyachainStargate.biyachainSigningStargateClient.connectWithSigner(
      network.rpc as string,
      wallet
    );

  const recipient = biyachainAddress;
  const amount = {
    denom: "biya",
    amount: "1000000000",
  };

  const txResponse = await client.sendTokens(
    account.address,
    recipient,
    [amount],
    getStdFee(),
    "Have fun with your star coins"
  );

  if (txResponse.code !== 0) {
    console.log(`Transaction failed: ${txResponse.rawLog}`);
  } else {
    console.log(
      `Broadcasted transaction hash: ${JSON.stringify(
        txResponse.transactionHash
      )}`
    );
  }
})();
```
