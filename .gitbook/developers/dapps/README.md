# dApps

Biya Chain 是为金融而构建的第一层区块链。Biya Chain 为开发者提供开箱即用的原语，用于构建去中心化金融应用程序，此外还有一个开放且无需许可的智能合约层，为构建强大的 Web3 应用程序提供高级功能。

Biya Chain 与多个知名区块链网络原生互操作，包括以太坊、Solana 以及所有启用 IBC 的 Cosmos 链，如 CosmosHub、Osmosis 等。互操作性不仅允许 Biya Chain 使用户能够从多个链桥接资产，还允许传输任意数据 - 如预言机价格等。

在本节中，我们将探讨配置不同的 UI 框架以与 `@biya-coin` 包一起工作，以便您可以开始在 Biya Chain 上构建去中心化应用程序。我们还将展示在 Biya Chain 上构建的示例（简单）dApps。

出于安全原因，我们建议使用 NPM 包的稳定版本。

**稳定包版本**

![](https://img.shields.io/npm/v/%40biya-coin/sdk-ts/latest?label=%40biya-coin%2Fsdk-ts) ![](https://img.shields.io/npm/v/%40biya-coin/wallet-ts/latest?label=%40biya-coin%2Fwallet-ts) ![](https://img.shields.io/npm/v/%40biya-coin/networks/latest?label=%40biya-coin%2Fnetworks) ![](https://img.shields.io/npm/v/%40biya-coin/ts-types/latest?label=%40biya-coin%2Fts-types) ![](https://img.shields.io/npm/v/%40biya-coin/utils/latest?label=%40biya-coin%2Futils)

**最新包版本：**

![](https://img.shields.io/npm/v/%40biya-coin/sdk-ts/next?label=%40biya-coin%2Fsdk-ts) ![](https://img.shields.io/npm/v/%40biya-coin/wallet-ts/next?label=%40biya-coin%2Fwallet-ts) ![](https://img.shields.io/npm/v/%40biya-coin/networks/next?label=%40biya-coin%2Fnetworks) ![](https://img.shields.io/npm/v/%40biya-coin/ts-types/next?label=%40biya-coin%2Fts-types) ![](https://img.shields.io/npm/v/%40biya-coin/utils/next?label=%40biya-coin%2Futils)

{% hint style="info" %}
最新版本使用 `next` 标签发布。对于稳定版本，请使用 `latest` 标签或检查 npm 注册表以获取最新的稳定版本。
{% endhint %}

{% hint style="info" %}
如果您正在寻找如何在 Biya Chain EVM 上构建 dApp，您应该查看[您的第一个 EVM dApp](../developers-evm/dapps/) 中的指南。
{% endhint %}

### 创建 Biya Chain dApp CLI 工具

在 Biya Chain 上开始您的旅程最简单的方法是使用我们的 CLI 工具。要做到这一点，只需在终端中编写此命令并按照说明操作！

```bash
$ npx @biya-coin/create-biyachain-app
```

### 配置

| 主题                                    | 描述                        |
| --------------------------------------- | --------------------------- |
| [配置 Nuxt](configure-nuxt.md)          | 配置 Nuxt 3.x + Vite        |
| [配置 React](configure-react.md)        | 配置 React 18 + Vite        |

### dApps

| 主题                                               | 描述                                                      |
| -------------------------------------------------- | --------------------------------------------------------- |
| [DEX](example-dex.md)                              | 在 Biya Chain 上构建去中心化交易所                        |
| [简单智能合约](example-smart-contract.md)          | 在 Biya Chain 上构建简单的智能合约应用                    |
| [Webpack](example-webpack.md)                      | 使用 Webpack 和 Biya Chain 的简单 HTML 示例              |
