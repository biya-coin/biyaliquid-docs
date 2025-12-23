# 账户

Biya Chain 定义了自己的自定义账户类型，该类型使用以太坊的 ECDSA secp256k1 曲线作为密钥。这满足了完整 [BIP44](https://github.com/bitcoin/bips/blob/master/bip-0044.mediawiki) 路径的 [EIP84](https://github.com/ethereum/EIPs/issues/84)。基于 Biya Chain 的账户的根 HD 路径是 `m/44'/60'/0'/0.`

### 地址转换

您可以使用 `@biya-coin/sdk-ts` 包中的实用函数轻松在 Biya Chain 地址和以太坊地址之间进行转换：

```ts
import { getBiyachainAddress, getEthereumAddress } from '@biya-coin/sdk-ts'

const biyachainAddress = 'biya1...'
const ethereumAddress = '0x..'

console.log('从以太坊地址获取 Biya Chain 地址 => ', getBiyachainAddress(ethereumAddress))
console.log('从 Biya Chain 地址获取以太坊地址 => ', getEthereumAddress(biyachainAddress))
```

### 派生钱包

**使用 Biya Chain 实用类**

* 从私钥和/或助记词派生 Biya Chain 账户的示例代码片段：

```ts
import { PrivateKey } from '@biya-coin/sdk-ts'

const mnemonic = "indoor dish desk flag debris potato excuse depart ticket judge file exit"
const privateKey = "afdfd9c3d2095ef696594f6cedcae59e72dcd697e2a7521b1578140422a4f890"
const privateKeyFromMnemonic = PrivateKey.fromMnemonic(mnemonic)
const privateKeyFromHex = PrivateKey.fromPrivateKey(privateKey)

const address = privateKeyFromMnemonic.toAddress() /* 或 privateKeyFromHex.toAddress() */
console.log({ biyachainAddress: address.toBech32(), ethereumAddress: address.toHex() })
```

* 从公钥派生公共地址的示例代码片段：

```ts
import { PublicKey } from '@biya-coin/sdk-ts'

const pubKey = "AuY3ASbyRHfgKNkg7rumWCXzSGCvvgtpR6KKWlpuuQ9Y"
const publicKey = PublicKey.fromBase64(pubKey)

console.log(publicKey.toAddress().toBech32())
```

* 从私钥派生地址的示例代码片段：

```ts
import { PublicKey } from '@biya-coin/sdk-ts'

const privateKey = "afdfd9c3d2095ef696594f6cedcae59e72dcd697e2a7521b1578140422a4f890"
const publicKey = PublicKey.fromPrivateKeyHex(privateKey)
const type = '/biyachain.crypto.v1beta1.ethsecp256k1.PubKey'

console.log(publicKey.toBase64())
```

**不使用 Biya Chain 实用类**

* 从私钥和/或助记词派生 Biya Chain 账户的示例代码片段：

```ts
import { Wallet } from 'ethers'
import { Address as EthereumUtilsAddress } from 'ethereumjs-util'

const mnemonic = "indoor dish desk flag debris potato excuse depart ticket judge file exit"
const privateKey = "afdfd9c3d2095ef696594f6cedcae59e72dcd697e2a7521b1578140422a4f890"
const defaultDerivationPath = "m/44'/60'/0'/0/0"
const defaultBech32Prefix = 'biya'
const isPrivateKey: boolean = true /* 仅用于示例 */

const wallet = isPrivateKey ? Wallet.fromMnemonic(mnemonic, defaultDerivationPath) : new Wallet(privateKey)
const ethereumAddress = wallet.address
const addressBuffer = EthereumUtilsAddress.fromString(ethereumAddress.toString()).toBuffer()
const biyachainAddress = bech32.encode(defaultBech32Prefix, bech32.toWords(addressBuffer))
```

* 从私钥派生公钥的示例代码片段：

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

#### 将 Cosmos 地址转换为 Biya Chain 地址

由于 Biya Chain 的派生路径与默认的 Cosmos 路径不同，您需要账户的 `publicKey` 才能将 Cosmos `publicAddress` 转换为 Biya Chain 地址。

以下是如何执行此操作的示例

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
    console.log("未找到公钥");
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
