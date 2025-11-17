# 钱包

Biyachain 钱包允许您监控在 Biyachain 上的资产。资产可以是 Biyachain 上的原生代币，也可以是从 Ethereum、Solana、Polygon 以及各种支持 IBC 的链桥接过来的资产。

Biyachain 支持多种不同的钱包。用户可以选择使用 Ethereum 或 Cosmos 原生钱包来提交 Biyachain 上的交易。

## 简介

Biyachain 的账户类型使用 Ethereum 的 ECDSA secp256k1 曲线来生成密钥。简单来说，Biyachain 的账户与 Ethereum 账户兼容，使得像 MetaMask 这样的 Ethereum 原生钱包能够与 Biyachain 进行交互。像 Keplr 和 Leap 这样的流行 Cosmos 钱包也已经与 Biyachain 集成。

## **基于 Ethereum 的钱包**

如上所述，基于 Ethereum 的钱包可以用来与 Biyachain 进行交互。目前，Biyachain 支持最流行的基于 Ethereum 的钱包，包括：

1. [MetaMask](https://metamask.io/)
2. [Ledger](https://www.ledger.com/)
3. [Trezor](https://trezor.io/)
4. [Torus](https://tor.us/index.html)

在 Biyachain 上使用 Ethereum 原生钱包签署交易的过程包括：

1. 将交易转换为 EIP712 类型数据（TypedData），
2. 使用 Ethereum 原生钱包签署 EIP712 类型数据，
3. 将交易打包成原生 Cosmos 交易（包括签名），并将交易广播到区块链上。

这个过程对最终用户是透明的。如果您之前使用过 Ethereum 原生钱包，用户体验将是相同的。

## **基于 Cosmos 的钱包**

Biyachain 支持与 Cosmos 和 IBC 兼容的主流钱包，包括：

1. [Cosmostation](https://cosmostation.io/)
2. [Keplr](https://www.keplr.app/)
3. [Leap](https://www.leapwallet.io/)

## Biyachain **原生钱包**

目前 [Ninji Wallet](https://ninji.xyz/) 是唯一的 Biyachain 原生钱包。这样的钱包专门构建用于与更广泛的 Biyachain 生态系统协同工作。

## **CEX 的钱包**

现在也有一些由中心化交易所（CEX）开发的钱包支持 Biyachain。如果您是这些 CEX 的活跃用户，使用它们的钱包可以提供更流畅的 Web3 体验。目前，支持 Biyachain 的 CEX 钱包包括：

1. [Bitget Wallet](https://web3.bitget.com/en/)
2. [OKX Wallet](https://www.okx.com/web3)
