# 转换地址

Within this document, we'll outline some examples on how to convert addresses between different formats and derivation paths.

### Convert Hex <> Bech32 address

As we've mentioned in the [wallet](../../users/wallet/ "mention") section, Biya Chain addresses are compatible with Ethereum addresses. You can convert between the two formats easily.

### Using TypeScript

You can easily convert between an Biya Chain address and Ethereum address by using our utility functions in the `@biya-coin/sdk-ts` package:

```typescript
import { getBiyachainAddress, getEthereumAddress } from '@biya-coin/sdk-ts'

const biyachainAddress = 'biya1...'
const ethereumAddress = '0x..'

console.log('Biya Chain address from Ethereum address => ', getBiyachainAddress(ethereumAddress))
console.log('Ethereum address from Biya Chain address => ', getEthereumAddress(biyachainAddress))
```

### **Convert Cosmos address to Biya Chain Address**

As Biya Chain has a different derivation path than the default Cosmos one, you need the `publicKey` of the account to convert a Cosmos `publicAddress` to Biya Chain one.

### Using TypeScript

```typescript
import { config } from "dotenv";
import { ChainRestAuthApi, PublicKey } from "@biya-coin/sdk-ts";

config();

(async () => {
  const chainApi = new ChainRestAuthApi(
    "https://rest.cosmos.directory/cosmoshub"
  );

  const cosmosAddress = "cosmos1..";
  const account = await chainApi.fetchCosmosAccount(cosmosAddress);

  if (!account.pub_key?.key) {
    console.log("No public key found");
    return;
  }

  console.log(
    "biyachainAddress",
    PublicKey.fromBase64(account.pub_key.key || "")
      .toAddress()
      .toBech32()
  );
})();
```

{% hint style="info" %}
More examples can be found in [wallet accounts](../../users/wallet/accounts.md).
{% endhint %}
