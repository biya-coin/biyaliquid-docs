# 预编译合约

### Biya Chain 上的预编译合约是什么？

在 Biya Chain 上，预编译合约是直接嵌入到我们的 EVM（以太坊虚拟机）层协议级别的特殊的、高度优化的智能合约。与用户部署的标准 Solidity 智能合约不同，预编译合约是链核心逻辑的一部分。它们使用 Go 而不是 Solidity 编写，并以固定地址暴露给 EVM，使它们可以像任何其他智能合约一样从您的 Solidity 智能合约中调用。

可以将它们视为 Biya Chain 链的原生函数，这些函数被赋予了以太坊风格的接口。

### 为什么它们是必要的？（桥接 EVM 和原生模块）

Biya Chain EVM 不是孤立运行的。它与 Biya Chain 强大的原生 Cosmos SDK 模块深度集成，例如 Bank 模块（用于代币管理）、Exchange 模块（用于链上订单簿）、Staking 模块等。

预编译合约充当 EVM 世界（您的 Solidity 合约所在的地方）和这些原生 Biya Chain 功能之间的关键**桥梁**。如果没有预编译合约，您的 EVM 智能合约将被隔离，无法利用更广泛的 Biya Chain 生态系统的丰富功能和流动性。

例如，我们的[多虚拟机代币标准（MTS）](./multivm-token-standard.md)模型确保原生和 EVM 环境中的统一代币余额，它在很大程度上依赖于 **Bank 预编译合约**。

### 对开发者的好处

* **访问原生功能：** 直接与 Biya Chain 的独特模块交互，如链上订单簿、原生质押、治理和用于 MTS 的 bank 模块。
* **增强性能：** 通过预编译合约执行的操作可以比尝试纯粹在 Solidity 中复制复杂的原生逻辑要快得多且更节省 gas，因为它们作为优化的原生代码运行。
* **无缝互操作性：** 构建真正集成的应用程序，利用 EVM 和 Biya Chain 的 Cosmos 原生功能的优势。
* **简化开发：** 通过熟悉的 Solidity 接口与复杂的原生功能交互，抽象掉大部分底层 Cosmos 复杂性。

[Biya Chain 的 Solidity 合约仓库](https://github.com/biya-coin/solidity-contracts)提供了一系列由 Bank 预编译合约支持的 ERC-20 实现，以及预编译合约接口和抽象合约。关键合约包括：

* [**Bank.sol**](https://github.com/biya-coin/solidity-contracts/blob/master/src/Bank.sol) – 预编译合约接口
* [**BankERC20.sol**](https://github.com/biya-coin/solidity-contracts/blob/master/src/BankERC20.sol) – 由 Bank 预编译合约支持的抽象 ERC20 实现
* [**FixedSupplyBankERC20.sol**](https://github.com/biya-coin/solidity-contracts/blob/master/src/FixedSupplyBankERC20.sol) – 固定供应的去中心化 ERC20（无所有者，无铸造或销毁）
* [**MintBurnBankERC20.sol**](https://github.com/biya-coin/solidity-contracts/blob/master/src/MintBurnBankERC20.sol) – 具有授权铸造和销毁代币的所有者的 ERC20

这些实现基于 OpenZeppelin 的 ERC20 合约。开发者可以自由创建利用 Bank 预编译合约的自定义 ERC20 合约。

### 帮助您入门的演示

我们准备了一些演示，展示如何使用 Bank、Exchange 和 Staking 预编译合约构建合约。这些示例还演示了如何使用最常见的以太坊开发框架 **Foundry** 与 Biya Chain EVM 交互。

通过利用 Foundry 的 `cast` 工具，您可以直接从终端轻松部署合约并与 Biya Chain 链交互。这使构建者能够快速实验、测试和部署利用 Biya Chain 原生模块的强大应用程序。

浏览下面的演示以查看：

- 如何编写调用预编译合约进行代币管理、交易和质押的 Solidity 合约。
- 如何使用 Foundry 脚本和 `cast` 命令在 Biya Chain EVM 上部署和与这些合约交互。
- 桥接 EVM 逻辑与 Biya Chain 原生功能的最佳实践。

通过克隆 [Biya Chain Solidity 合约仓库](https://github.com/biya-coin/solidity-contracts/tree/master/demos)并按照每个演示目录中的分步指南来快速启动您的开发。

* [Bank 预编译合约演示](https://github.com/biya-coin/solidity-contracts/tree/master/demos/erc20)
* [Exchange 预编译合约演示](https://github.com/biya-coin/solidity-contracts/tree/master/demos/exchange)
* [Staking 预编译合约演示](https://github.com/biya-coin/solidity-contracts/tree/master/demos/staking)

### 预编译合约地址

| 名称                               | 用途                       | EVM 地址    |
| ---------------------------------- | -------------------------- | ----------- |
| [Bank](bank-precompile.md)         | 代币管理                   | `0x64`      |
| [Exchange](exchange-precompile.md) | 链上订单簿                 | `0x65`      |
| Staking                            | 链上原生质押代币           | `0x66`      |

## 非合约地址错误

当使用 Foundry 时，如果您在本地"分叉"Biya Chain 主网或 Biya Chain 测试网，
并在该环境中执行您的智能合约，
您可能会看到类似以下的错误：

```text
[Revert] call to non-contract address 0x0000000000000000000000000000000000000064
```

这是因为 Foundry 在本地*模拟* Biya Chain，
而不是实际在 Biya Chain 上运行。
因此它运行的是*通用 EVM* 模拟，
而不是特定于 Biya Chain 的模拟。
区别在于 Biya Chain 的原生功能不存在，
因此它不知道预编译合约。

解决方法很简单：
使用已打补丁以包含 Biya Chain 预编译合约的 Foundry 版本：
[github.com/biya-coin/foundry/releases](https://github.com/biya-coin/foundry/releases)。

这些版本包括 x86_64 Linux 和 macOS ARM64 的预构建二进制文件。
