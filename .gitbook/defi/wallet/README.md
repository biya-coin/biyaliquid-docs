# 钱包

Biyachain 钱包允许您监控您在 Biyachain 上的资产。资产可以是 Biyachain 上的原生代币，也可以是从 Ethereum、Solana、Polygon 和各种支持 IBC 的链桥接过来的资产。请参阅 [Biyachain Hub 质押指南](https://biyachain.com/blog/biyachain-hub/)

Biyachain 支持多种不同的钱包。用户可以选择使用他们的 Ethereum 或 Cosmos 原生钱包在 Biyachain 上提交交易。

### 概述

Biyachain 的 `Account` 类型使用 Ethereum 的 ECDSA secp256k1 曲线作为密钥。简单来说，Biyachain 的账户与 Ethereum 原生账户兼容，允许 Ethereum 原生钱包（如 MetaMask）与 Biyachain 交互。流行的 Cosmos 钱包（如 Keplr 和 Leap）也已与 Biyachain 集成。

#### 基于 Ethereum 的钱包

如上所述，基于 Ethereum 的钱包可用于与 Biyachain 交互。目前，最流行的基于 Ethereum 的钱包都支持 Biyachain。这些包括：

1. [MetaMask](https://metamask.io/)
2. [Ledger](https://www.ledger.com/)
3. [Trezor](https://trezor.io/)
4. [Torus](https://tor.us/index.html)

使用 Ethereum 原生钱包在 Biyachain 上签名交易的过程包括：

1. 将交易转换为 EIP712 TypedData，
2. 使用 Ethereum 原生钱包对 EIP712 TypedData 进行签名，
3. 将交易打包成原生 Cosmos 交易（包括签名），并将交易广播到链上。

这个过程对最终用户是透明的。如果您之前使用过 Ethereum 原生钱包，用户体验将是相同的。

#### 基于 Cosmos 的钱包

Biyachain 支持与 Cosmos 和 IBC 兼容的主要钱包，包括：

1. [Cosmostation](https://cosmostation.io/)
2. [Keplr](https://www.keplr.app/)
3. [Leap](https://www.leapwallet.io/)

#### 基于中心化交易所的钱包

还有一些由中心化交易所（CEX）开发的钱包现在也支持 Biyachain。如果您是这些 CEX 的活跃用户，使用他们的钱包可以提供更无缝的 web3 体验。目前，支持 Biyachain 的基于 CEX 的钱包有：

1. [Bitget Wallet](https://web3.bitget.com/en/)
2. [OKX Wallet](https://www.okx.com/web3)
