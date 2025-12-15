# Accounts

Biya Chain defines its own custom Account type that uses Ethereum's ECDSA secp256k1 curve for keys. This satisfies the [EIP84](https://github.com/ethereum/EIPs/issues/84) for full [BIP44](https://github.com/bitcoin/bips/blob/master/bip-0044.mediawiki) paths. The root HD path for Biya Chain-based accounts is `m/44'/60'/0'/0.`

### Address conversion

You can easily convert between an Biya Chain address and Ethereum address by using our utility functions in the `@biya-coin/sdk-ts` package:

```ts
import { getBiya ChainAddress, getEthereumAddress } from '@biya-coin/sdk-ts'

const biyachainAddress = 'biya1...'
const ethereumAddress = '0x..'

console.log('Biya Chain address from Ethereum address => ', getBiya ChainAddress(ethereumAddress))
console.log('Ethereum address from Biya Chain address => ', getEthereumAddress(biyachainAddress))
```

### Deriving wallets

**Using Biya Chain utility classes**

* Example code snippet on how to derive Biya Chain Account from a private key and/or a mnemonic phrase:

```ts
import { PrivateKey } from '@biya-coin/sdk-ts'

const mnemonic = "indoor dish desk flag debris potato excuse depart ticket judge file exit"
const privateKey = "afdfd9c3d2095ef696594f6cedcae59e72dcd697e2a7521b1578140422a4f890"
const privateKeyFromMnemonic = PrivateKey.fromMnemonic(mnemonic)
const privateKeyFromHex = PrivateKey.fromPrivateKey(privateKey)

const address = privateKeyFromMnemonic.toAddress() /* or privateKeyFromHex.toAddress() */
console.log({ biyachainAddress: address.toBech32(), ethereumAddress: address.toHex() })
```

* Example code snipped on how to derive a public address from a public key:

```ts
import { PublicKey } from '@biya-coin/sdk-ts'

const pubKey = "AuY3ASbyRHfgKNkg7rumWCXzSGCvvgtpR6KKWlpuuQ9Y"
const publicKey = PublicKey.fromBase64(pubKey)

console.log(publicKey.toAddress().toBech32())
```

* Example code snipped on how to derive an address from a private key:

```ts
import { PublicKey } from '@biya-coin/sdk-ts'

const privateKey = "afdfd9c3d2095ef696594f6cedcae59e72dcd697e2a7521b1578140422a4f890"
const publicKey = PublicKey.fromPrivateKeyHex(privateKey)
const type = '/biyachain.crypto.v1beta1.ethsecp256k1.PubKey'

console.log(publicKey.toBase64())
```

**Without using Biya Chain utility classes**

* Example code snippet on how to derive Biya Chain Account from a private key and/or a mnemonic phrase:

```ts
import { Wallet } from 'ethers'
import { Address as EthereumUtilsAddress } from 'ethereumjs-util'

const mnemonic = "indoor dish desk flag debris potato excuse depart ticket judge file exit"
const privateKey = "afdfd9c3d2095ef696594f6cedcae59e72dcd697e2a7521b1578140422a4f890"
const defaultDerivationPath = "m/44'/60'/0'/0/0"
const defaultBech32Prefix = 'biya'
const isPrivateKey: boolean = true /* just for the example */

const wallet = isPrivateKey ? Wallet.fromMnemonic(mnemonic, defaultDerivationPath) : new Wallet(privateKey)
const ethereumAddress = wallet.address
const addressBuffer = EthereumUtilsAddress.fromString(ethereumAddress.toString()).toBuffer()
const biyachainAddress = bech32.encode(defaultBech32Prefix, bech32.toWords(addressBuffer))
```

* Example code snipped on how to derive a public key from a private key:

```ts
import secp256k1 from 'secp256k1'

const privateKey = "afdfd9c3d2095ef696594f6cedcae59e72dcd697e2a7521b1578140422a4f890"
const privateKeyHex = Buffer.from(privateKey.toString(), 'hex')
const publicKeyByte = secp256k1.publicKeyCreate(privateKeyHex)

const buf1 = Buffer.from([10])
const buf2 = Buffer.from([publicKeyByte.length])
const buf3 = Buffer.from(publicKeyByte)

const publicKey = Buffer.concat([buf1, buf2, buf3]).toString('base64')
const type = '/biyachain.crypto.v1beta1.ethsecp256k1.PubKey'
```

#### Convert Cosmos address to Biya Chain Address

As Biya Chain has a different derivation path than the default Cosmos one, you need the `publicKey` of the account to convert a Cosmos `publicAddress` to Biya Chain one.

Here is an example of how to do it

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
