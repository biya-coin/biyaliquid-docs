# 账户

本节介绍 Biyaliquid 的内置账户系统。

{% hint style="info" %}
本文档介绍 Biyaliquid 的内置账户系统。

前置阅读：

* [Cosmos SDK 账户](https://docs.cosmos.network/main/basics/accounts)
* [Ethereum 账户](https://ethereum.org/en/whitepaper/#ethereum-accounts)
{% endhint %}

Biyaliquid 定义了其自定义的 `Account` 类型，使用 Ethereum 的 ECDSA secp256k1 曲线作为密钥。这满足 [EIP84](https://github.com/ethereum/EIPs/issues/84) 的完整 [BIP44](https://github.com/bitcoin/bips/blob/master/bip-0044.mediawiki) 路径。基于 Biyaliquid 的账户的根 HD 路径是 `m/44'/60'/0'/0`。

### 地址和公钥

Biyaliquid 默认提供 3 种主要的 `Addresses`/`PubKeys` 类型：

* **账户**的地址和密钥，用于标识用户（即 `message` 的发送者）。它们使用 **`eth_secp256k1`** 曲线派生。
* **验证器操作者**的地址和密钥，用于标识验证器的操作者。它们使用 **`eth_secp256k1`** 曲线派生。
* **共识节点**的地址和密钥，用于标识参与共识的验证器节点。它们使用 **`ed25519`** 曲线派生。

|                    | 地址 bech32 前缀 | 公钥 bech32 前缀 | 曲线           | 地址字节长度 | 公钥字节长度 |
| ------------------ | ---------------- | ---------------- | -------------- | ------------ | ------------ |
| 账户               | `biya`           | `biyapub`        | `eth_secp256k1` | `20`         | `33` (压缩)  |
| 验证器操作者       | `biyavaloper`    | `biyavaloperpub` | `eth_secp256k1` | `20`         | `33` (压缩)  |
| 共识节点           | `biyavalcons`     | `biyavalconspub` | `ed25519`       | `20`         | `32`         |

### 客户端地址格式

`EthAccount` 可以表示为 [Bech32](https://en.bitcoin.it/wiki/Bech32) 和十六进制格式，以兼容 Ethereum 的 Web3 工具。

Bech32 格式是通过 CLI 和 REST 客户端进行 Cosmos-SDK 查询和交易的默认格式。十六进制格式是 Cosmos `sdk.AccAddress` 的 Ethereum `common.Address` 表示。

* 地址 (Bech32): `biya14au322k9munkmx5wrchz9q30juf5wjgz2cfqku`
* 地址 ([EIP55](https://eips.ethereum.org/EIPS/eip-55) 十六进制): `0xAF79152AC5dF276D9A8e1E2E22822f9713474902`
* 压缩公钥: `{"@type":"/biyaliquid.crypto.v1beta1.ethsecp256k1.PubKey","key":"ApNNebT58zlZxO2yjHiRTJ7a7ufjIzeq5HhLrbmtg9Y/"}`

您可以使用 Cosmos CLI 或 REST 客户端查询账户地址：

```bash
# 注意：--output (-o) 标志将定义输出格式为 JSON 或 YAML (text)
biyaliquidd q auth account $(biyaliquidd keys show <MYKEY> -a) -o text
|
  '@type': /biyaliquid.types.v1beta1.EthAccount
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

请参阅 [Swagger API](https://lcd.biyaliquid.network/swagger/) 参考以获取账户 API 的完整文档。

{% hint style="info" %}
Cosmos SDK Keyring 输出（即 `biyaliquidd keys`）仅支持 Bech32 格式的地址。
{% endhint %}

### 从私钥/助记词派生 Biyaliquid 账户

以下是从私钥和/或助记词短语派生 Biyaliquid 账户的示例：

```js
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
const biyaliquidAddress = bech32.encode(defaultBech32Prefix, bech32.toWords(addressBuffer))
```

以下是从私钥派生公钥的示例：

```js
import secp256k1 from 'secp256k1'

const privateKey = "afdfd9c3d2095ef696594f6cedcae59e72dcd697e2a7521b1578140422a4f890"
const privateKeyHex = Buffer.from(privateKey.toString(), 'hex')
const publicKeyByte = secp256k1.publicKeyCreate(privateKeyHex)

const buf1 = Buffer.from([10])
const buf2 = Buffer.from([publicKeyByte.length])
const buf3 = Buffer.from(publicKeyByte)

const publicKey = Buffer.concat([buf1, buf2, buf3]).toString('base64')
const type = '/biyaliquid.crypto.v1beta1.ethsecp256k1.PubKey'
```
