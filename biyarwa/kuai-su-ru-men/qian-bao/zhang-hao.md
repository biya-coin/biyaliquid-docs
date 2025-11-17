# 账号

本节介绍 Injective 内置的账户系统。

{% hint style="info" %}
本文档介绍了 Injective 内置的账户系统。

**前置阅读：**

* [Cosmos SDK Accounts](https://docs.cosmos.network/main/basics/accounts)
* [Ethereum Accounts](https://ethereum.org/en/whitepaper/#ethereum-accounts)
{% endhint %}

Injective 定义了其自定义的账户类型，使用 Ethereum 的 ECDSA secp256k1 曲线来生成密钥。这符合 [EIP84](https://github.com/ethereum/EIPs/issues/84) 规范，适用于完整的 [BIP44](https://github.com/bitcoin/bips/blob/master/bip-0044.mediawiki) 路径。Injective 账户的根 HD 路径为 `m/44'/60'/0'/0`。

## 地址和公钥

Injective 默认提供 3 种主要类型的地址和公钥（PubKeys）：

1. **账户地址和密钥**：用于标识用户（例如消息的发送者），使用 **eth\_secp256k1** 曲线生成。
2. **验证者操作员地址和密钥**：用于标识验证者的操作员，使用 **eth\_secp256k1** 曲线生成。
3. **共识节点地址和密钥**：用于标识参与共识的验证者节点，使用 **ed25519** 曲线生成。

|        | Address bech32 Prefix | Pubkey bech32 Prefix | Curve           | Address byte length | Pubkey byte length |
| ------ | --------------------- | -------------------- | --------------- | ------------------- | ------------------ |
| 账户地址   | `biya`                | `biyapub`            | `eth_secp256k1` | `20`                | `33` (compressed)  |
| 验证者操作员 | `biyavaloper`         | `biyavaloperpub`     | `eth_secp256k1` | `20`                | `33` (compressed)  |
| 共识节点   | `biyavalcons`         | `biyavalconspub`     | `ed25519`       | `20`                | `32`               |

## 客户端的地址格式

EthAccounts 可以采用 **Bech32** 和 **十六进制（Hex）** 两种格式表示，以兼容 Ethereum 的 Web3 工具。

* **Bech32 格式**：是 Cosmos-SDK 进行 CLI 和 REST 客户端查询与交易的默认格式。
* **十六进制（EIP55 Hex）格式**：是 Cosmos `sdk.AccAddress` 在 Ethereum 中的 `common.Address` 表示方式。

示例：

* **地址（Bech32）**：biya14au322k9munkmx5wrchz9q30juf5wjgz2cfqku
* **地址（EIP55 Hex）**：0xAF79152AC5dF276D9A8e1E2E22822f9713474902
*   **压缩公钥**：

    ```json
    {
      "@type": "/biyachain.crypto.v1beta1.ethsecp256k1.PubKey",
      "key": "ApNNebT58zlZxO2yjHiRTJ7a7ufjIzeq5HhLrbmtg9Y/"
    }
    ```

您可以使用 Cosmos CLI 或 REST 客户端查询账户地址。

```bash
# NOTE: the --output (-o) flag will define the output format in JSON or YAML (text)
biyachaind q auth account $(injectived keys show <MYKEY> -a) -o text
|
  '@type': /biyachain.types.v1beta1.EthAccount
  base_account:
    account_number: "3"
    address: biya14au322k9munkmx5wrchz9q30juf5wjgz2cfqku
    pub_key: null
    sequence: "0"
  code_hash: xdJGAYb3IzySfn2y3McDwOUAtlPKgic7e/rYBF2FpHA=
```

```bash
# GET /cosmos/auth/v1beta1/accounts/{address}
curl -X GET "http://localhost:10337/cosmos/auth/v1beta1/accounts/biya14au322k9munkmx5wrchz9q30juf5wjgz2cfqku" -H "accept: application/json"
```

请参阅 [Swagger API](https://lcd.injective.network/swagger/) 文档，获取有关账户 API 的完整文档。

{% hint style="info" %}
Cosmos SDK 密钥环输出（即 `biyachaind keys`）仅支持 Bech32 格式的地址。
{% endhint %}

## 从私钥/助记词派生Injective账户

下面是如何从私钥和/或助记词派生 Biyachain 账户的示例：

```js
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

下面是如何从私钥派生公钥的示例：

```js
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
