# Convert addresses

Within this document, we'll outline some examples on how to convert addresses between different formats and derivation paths.

### Convert Hex <> Bech32 address

As we've mentioned in the [wallet](../defi/wallet/README.md "mention") section, Biyachain addresses are compatible with Ethereum addresses. You can convert between the two formats easily.

### Using TypeScript

You can easily convert between an Biyachain address and Ethereum address by using our utility functions in the `@biya-coin/sdk-ts` package:

```typescript
import { getBiyachainAddress, getEthereumAddress } from '@biya-coin/sdk-ts'

const biyachainAddress = 'biya1...'
const ethereumAddress = '0x..'

console.log('Biyachain address from Ethereum address => ', getBiyachainAddress(ethereumAddress))
console.log('Ethereum address from Biyachain address => ', getEthereumAddress(biyachainAddress))
```

### **Convert Cosmos address to Biyachain Address**

As Biyachain has a different derivation path than the default Cosmos one, you need the `publicKey` of the account to convert a Cosmos `publicAddress` to Biyachain one.

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
More examples can be found in [wallet accounts](../defi/wallet/accounts.md).
{% endhint %}
