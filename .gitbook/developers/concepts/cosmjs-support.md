# CosmJs 支持

Biya Chain is not natively supported on the `@cosmjs` packages. It's highly recommended to use our `@biya-coin` packages to interact with Biya Chain.

If you are familiar with the `@cosmjs` packages we are exporting similar interfaces/classes that work the same as the classes on `@cosmjs` but have support for Biya Chain as well.

Again, keep in mind that the recommended approach is to use the Biya Chain's standard approach, which you can learn more about in [Cosmos transactions](../developers-native/transactions/cosmos.md).

## Usage using Keplr

Here is an example on how to use the `@biya-coin` alternatives from the `@cosmjs` packages with Keplr:

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

## Usage in a CLI/Node environment

Here is an example on how to use the `@biya-coin` alternatives from the `@cosmjs` packages in a node or CLI environment.

Again, keep in mind that the recommended approach is to use the [MsgBroadcasterWithPk](../developers-native/transactions/private-key.md#example-with-msgbroadcasterwithpk) abstraction to follow the Biya Chain's standard approach.

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
