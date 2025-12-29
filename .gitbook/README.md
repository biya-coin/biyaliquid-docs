# 关于 Biya Chain

## 什么是 Biya Chain ？

**Biya Chain** 是一个高性能、模块化的区块链，专注于构建一个全球化、综合型的链上金融生态。通过采用各种预构建、可定制的[模块](developers/developers-native/)，实现安全、高效的构建链上动态应用，引领链上金融新时代。

## 技术概览

Biya Chain 是一个专为链上金融应用构建和优化的高性能 Layer 1 区块链（L1）。

Biya Chain 使用一种名为 **Tendermint-based Consensus** 的共识机制，该机制基于经典的 Tendermint BFT 算法，并针对金融衍生品交易场景进行了深度优化。共识算法与底层网络栈均从零构建，以满足高频、低延迟交易的独特需求。

Biya Chain 的状态执行分为两大核心组件：**Biya Chain  Core** 和 **Biya Chain  EVM**。

* **Biya Chain  Core** 包含完全链上的现货/杠杆、永续合约订单簿等金融原语。每一笔下单、撤单、成交、清算和结算均在链上透明执行，并享有 Tendermint 提供的一块确认最终性（one-block finality）。当前 Biya Chain Core 支持极高的订单处理能力（峰值可达 2.5 万笔/秒），并通过持续的节点软件优化不断提升吞吐量。
* **Biya Chain EVM** 将以太坊开创的通用智能合约平台无缝集成到 Biya Chain 中。通过 Biya Chain EVM，开发者可以无许可地访问 Biya Chain Core 提供的高性能流动性和金融原语，将其作为可组合的构建模块，用于创建复杂的 DeFi 应用和衍生品协议。更多技术细节请参阅 Biya Chain EVM 文档部分。

***

<table data-view="cards"><thead><tr><th></th><th></th><th data-hidden data-card-target data-type="content-ref"></th><th data-hidden data-card-cover data-type="files"></th></tr></thead><tbody><tr><td>您是用户吗？</td><td>了解如何创建钱包</td><td><a href="users/wallet/">wallet</a></td><td><a href=".gitbook/assets/user-hero.png">user-hero.png</a></td></tr><tr><td>您想使用 DeFi 吗？</td><td>了解如何在 Biya Chain 上开始交易</td><td><a href="users/">users</a></td><td><a href=".gitbook/assets/trader-hero.png">trader-hero.png</a></td></tr><tr><td>您想运行基础设施吗？</td><td>了解如何运行哨兵节点和验证节点</td><td><a href="operations/">operations</a></td><td><a href=".gitbook/assets/validator-hero.png">validator-hero.png</a></td></tr><tr><td>您是开发者吗？</td><td>了解如何在 Biya Chain 上构建</td><td><a href="developers/">developers</a></td><td><a href=".gitbook/assets/dev-hero.png">dev-hero.png</a></td></tr></tbody></table>

## 入门指南

欢迎您探索 Biya Chain 的旅程！在提问之前，请先尝试使用文档中的搜索功能。我们的目标是使文档自给自足，确保入门过程顺畅，每个人都能轻松了解更多关于 Biya Chain 的信息。

### Biya Chain 快速入门指南

<table data-view="cards"><thead><tr><th></th><th></th><th data-hidden data-card-cover data-type="files"></th><th data-hidden data-card-target data-type="content-ref"></th></tr></thead><tbody><tr><td>钱包</td><td>了解如何在 Biya Chain 上创建钱包，并查看 Biya Chain 上支持的钱包</td><td><a href=".gitbook/assets/wallet-hero-2.png">wallet-hero-2.png</a></td><td><a href="users/wallet/">wallet</a></td></tr><tr><td>代币标准</td><td>了解 Biya Chain 上的不同代币标准</td><td><a href=".gitbook/assets/token-hero.png">token-hero.png</a></td><td><a href="users/tokens/">tokens</a></td></tr><tr><td>交易</td><td>了解如何在 Biya Chain 上准备、签名和提交交易</td><td><a href=".gitbook/assets/txs-hero.png">txs-hero.png</a></td><td><a href="users/transactions.md">transactions.md</a></td></tr></tbody></table>
