# 设置 Hardhat 并编译智能合约

## 前置条件

确保您已安装最新版本的 NodeJs。
您可以使用以下命令检查：

```shell
node -v
```

本指南使用以下版本编写：

```text
v22.16.0
```

如果您尚未安装 NodeJs，请使用以下方式安装：

- Linux 或 Mac: [NVM](https://github.com/nvm-sh/nvm)
- Windows: [NVM for Windows](https://github.com/coreybutler/nvm-windows)

您需要一个钱包，以及一个已充值了一些测试网 BIYA 的账户。

{% hint style="info" %}
您可以从 [Biya Chain 测试网水龙头](https://prv.faucet.biya.io/) 请求 EVM 测试网资金。
{% endhint %}

创建账户后，请务必将您的私钥复制到可访问的地方，因为您需要它来完成本教程。

{% hint style="info" %}
请注意，私钥应谨慎处理。
此处的说明应被视为足以用于本地开发和测试网。
但是，这些对于主网上使用的私钥来说**不够**安全。
请确保在主网上遵循密钥安全的最佳实践，并且不要在主网和其他网络之间重复使用相同的密钥/账户。
{% endhint %}

## 设置新的 Hardhat 项目

使用 git 克隆演示仓库，该仓库已经为您完全设置好了项目。

```shell
git clone https://github.com/biyachain-dev/hardhat-biya
```

从 npm 安装依赖项：

```shell
npm install
```

## 项目结构

在等待 npm 下载和安装时，在代码编辑器/IDE 中打开仓库，并查看目录结构。

```text
hardhat-biya/
  contracts/
    Counter.sol --> 智能合约 Solidity 代码
  script/
    deploy.js --> 部署脚本
  test/
    Counter.test.js --> 测试用例
  hardhat.config.js --> 配置文件
  .example.env
```

`hardhat.config.js` 文件已经预先配置为连接到 Biya Chain EVM 测试网。
在继续之前，您只需要为其提供 Biya Chain 测试网账户的私钥。

```shell
cp .example.env .env
```

编辑 `.env` 文件以添加私钥。
您也可以选择更新为任何替代的 JSON-RPC 端点。

```shell
PRIVATE_KEY=your private key without 0x prefix
BIYA_TESTNET_RPC_URL=https://k8s.testnet.json-rpc.biyachain.network/

```

## 编辑智能合约

此演示中包含的智能合约非常基础。它：

- 存储一个 `value`，这是一个数字。
- 公开一个 `value()` 查询方法。
- 公开一个 `increment(num)` 交易方法。

打开文件：`contracts/Counter.sol`

```solidity
// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

contract Counter {
    uint256 public value = 0;

    function increment(uint256 num) external {
        value += num;
    }
}

```

## 编译智能合约

运行以下命令：

```shell
npx hardhat compile
```

Hardhat 将自动下载并运行在 `hardhat.config.js` 文件中配置的 Solidity 编译器 (`solc`) 版本。

## 检查编译输出

编译器完成后，您应该在项目目录中看到额外的目录：

```text
hardhat-biya/
  artifacts/
    build-info/
      ...
    contracts/
      Counter.sol/
        Counter.json --> 打开此文件
        ...
  cache/
    ...
```

打开 `Counter.json` 文件 (`artifacts/contracts/Counter.sol/Counter.json`)。
在其中，您应该看到编译器输出，包括 `abi` 和 `bytecode` 字段。
这些构件将在后续所有步骤（测试、部署、验证和交互）中使用。

## 下一步

现在您已经设置了 Hardhat 项目并编译了智能合约，您已准备好测试该智能合约！
接下来查看[使用 Hardhat 测试智能合约](./test-hardhat.md)教程。
