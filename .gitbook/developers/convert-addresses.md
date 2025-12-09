# Convert addresses

Within this document, we'll outline some examples on how to convert addresses between different formats and derivation paths.

### Convert Hex <> Bech32 address

As we've mentioned in the [wallet](../defi/wallet/README.md "mention") section, Biyaliquid addresses are compatible with Ethereum addresses. You can convert between the two formats easily.

### Using TypeScript

You can easily convert between an Biyaliquid address and Ethereum address by using our utility functions in the `@biya-coin/sdk-ts` package:

```typescript
import { getBiyaliquidAddress, getEthereumAddress } from '@biya-coin/sdk-ts'

const biyaliquidAddress = 'biya1...'
const ethereumAddress = '0x..'

console.log('Biyaliquid address from Ethereum address => ', getBiyaliquidAddress(ethereumAddress))
console.log('Ethereum address from Biyaliquid address => ', getEthereumAddress(biyaliquidAddress))
```

### **Convert Cosmos address to Biyaliquid Address**

As Biyaliquid has a different derivation path than the default Cosmos one, you need the `publicKey` of the account to convert a Cosmos `publicAddress` to Biyaliquid one.

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
    "biyaliquidAddress",
    PublicKey.fromBase64(account.pub_key.key || "")
      .toAddress()
      .toBech32()
  );
})();
```

{% hint style="info" %}
More examples can be found in [wallet accounts](../defi/wallet/accounts.md).
{% endhint %}
