# 钱包

Biya Chain 钱包允许你在 Biya Chain 上监控你的资产，资产可以是：

* Biya Chain 上的原生代币
* 来自以太坊、Solana、Polygon 和各种 IBC 支持链的桥接资产

Biya Chain 支持多种不同的钱包，在 Biya Chain 上提交交易，用户可以选择的钱包类型包括：

* 以太坊钱包
* Cosmos 原生钱包。

#### [​](https://docs.injective.network/defi/wallet#overview)概述 <a href="#overview" id="overview"></a>

Biya Chain 的`账户`类型使用以太坊的 ECDSA secp256k1 曲线作为密钥。简单来说，Biya Chain 的账户原生（兼容）以太坊账户，允许以太坊原生钱包如 MetaMask 与 Biya Chain 交互。像 Keplr 和 Leap 这样的热门 Cosmos 钱包也已与 Biya Chain 集成。

[**​**](https://docs.injective.network/defi/wallet#ethereum-based-wallets)**基于以太坊的钱包**

如上所述，基于以太坊的钱包可以用来与 Biya Chain 交互。目前，最受欢迎的以太坊钱包都支持 Biya Chain。这些包括：

1. [元面具](https://metamask.io/)
2. [账本](https://www.ledger.com/)
3. [特雷佐尔](https://trezor.io/)
4. [环面](https://tor.us/index.html)

使用以太坊原生钱包在 Biya Chain 上签署交易的过程包括：

1. 将事务转换为 EIP712 TypedData，
2. 使用以太坊原生钱包签署 EIP712 TypedData，
3. 将交易打包到原生的 Cosmos 事务中（包括签名），并将交易广播到链中。

该过程被抽象化，远离终端用户。如果你之前使用过以太坊原生钱包，用户体验会是一样的。

[**​**](https://docs.injective.network/defi/wallet#cosmos-based-wallets)**基于宇宙的钱包**

Biya Chain 支持与 Cosmos 和 IBC 兼容的顶级钱包，包括：

1. [宇宙站](https://cosmostation.io/)
2. [Keplr](https://www.keplr.app/)
3. [跳跃](https://www.leapwallet.io/)

[**​**](https://docs.injective.network/defi/wallet#injective-native-wallets)**单射-原生钱包**

目前，[Ninji Wallet](https://ninji.xyz/) 是唯一原生于 Biya Chain 的钱包。这样的钱包专门设计用于与更广泛的 Biya Chain 生态系统协同。

[**​**](https://docs.injective.network/defi/wallet#cex-based-wallets)**基于 CEX 的钱包**

还有一些由中心化交易所（CEX）开发的钱包现在支持 Biya Chain。如果你是这些 CEX 的活跃用户，使用他们的钱包可以带来更顺畅的 Web3 体验。目前，支持 Biya Chain 的基于 CEX 的钱包有：

1. [Bitget 钱包](https://web3.bitget.com/en/)
2. [OKX 钱包](https://www.okx.com/web3)
