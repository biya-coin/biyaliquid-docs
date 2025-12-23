# 设置 Foundry 并编译智能合约

## 前置条件

确保您已安装 Foundry，运行以下命令：

```shell
forge --version
```

请注意，本教程中使用的版本是 `1.2.3-stable`。在学习时请确保使用此版本或更高版本。

如果您还没有 foundry，请运行以下命令进行安装：

```shell
curl -L https://foundry.paradigm.xyz | bash
```

{% hint style="info" %}
还有其他安装 Foundry 的选项。
请参阅 [Foundry 安装文档](https://getfoundry.sh/introduction/installation)。
{% endhint %}

您需要一个钱包，以及一个已充值了一些测试网 BIYA 的账户。

{% hint style="info" %}
您可以从 [Biya Chain 测试网水龙头](https://testnet.faucet.biyachain.network/) 请求 EVM 测试网资金。
{% endhint %}

创建账户后，请务必将您的私钥复制到可访问的地方，因为您需要它来完成本教程。

{% hint style="info" %}
请注意，私钥应谨慎处理。
此处的说明应被视为足以用于本地开发和测试网。
但是，这些对于主网上使用的私钥来说**不够**安全。
请确保在主网上遵循密钥安全的最佳实践，并且不要在主网和其他网络之间重复使用相同的密钥/账户。
{% endhint %}

## 设置新的 Foundry 项目

使用 git 克隆演示仓库，该仓库已经为您完全设置好了项目。

```shell
git clone https://github.com/biyachain-dev/foundry-biya
cd foundry-biya
```

安装 `forge-std` 库，它提供了本项目中使用的实用函数。

```shell
forge install foundry-rs/forge-std
```

## 项目结构

在代码编辑器/IDE 中打开仓库，并查看目录结构。

```text
foundry-biya/
  src/
    Counter.sol --> 智能合约 Solidity 代码
  test/
    Counter.t.sol --> 测试用例
  foundry.toml --> 配置文件
```

`foundry.toml` 文件已经预先配置为连接到 Biya Chain EVM 测试网。
在继续之前，您只需要为其提供 Biya Chain 测试网账户的私钥。

输入以下命令导入私钥，并将其保存到名为 `biyaTest` 的账户：

```shell
cast wallet import biyaTest --interactive
```

这将提示您输入私钥，以及每次使用此账户时需要输入的密码。
使用您刚刚创建并充值的账户的私钥（例如，通过 Biya Chain 测试网水龙头）。
请注意，当您为私钥和密码输入或粘贴文本时，终端中不会显示任何内容。
输出应类似于：

```text
Enter private key:
Enter password:
`biyaTest` keystore was saved successfully. Address: 0x58f936cb685bd6a7dc9a21fa83e8aaaf8edd5724
```

{% hint style="info" %}
这会将私钥的加密版本保存在 `~/.foundry/keystores` 中，
在后续命令中可以使用 `--account` CLI 标志访问。
{% endhint %}

## 编辑智能合约

此演示中包含的智能合约非常基础。它：

- 存储一个 `value`，这是一个数字。
- 公开一个 `value()` 查询方法。
- 公开一个 `increment(num)` 交易方法。

打开文件：`src/Counter.sol`

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
forge build
```

Foundry 将自动下载并运行在 `foundry.toml` 文件中配置的 Solidity 编译器 (`solc`) 版本。

## 检查编译输出

编译器完成后，您应该在项目目录中看到额外的目录：

```text
foundry-biya/
  cache/
    ...
  out/
    build-info/
      ...
    Counter.sol/
        Counter.json --> 打开此文件
```

打开 `Counter.json` 文件 (`out/Counter.sol/Counter.json`)。
在其中，您应该看到编译器输出，包括 `abi` 和 `bytecode` 字段。
这些构件将在后续所有步骤（测试、部署、验证和交互）中使用。

## 下一步

现在您已经设置了 Foundry 项目并编译了智能合约，您已准备好测试该智能合约！
接下来查看[使用 Foundry 测试智能合约](./test-foundry.md)教程。
