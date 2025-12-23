---
description: 了解 Biya Chain 多虚拟机架构中的代币表示
---

# 多虚拟机代币标准

## 什么是多虚拟机代币标准（MTS）？

MTS（MultiVM Token Standard，多虚拟机代币标准）确保 Biya Chain 上的每个代币——无论是使用 Cosmos 模块部署还是通过以太坊虚拟机（EVM）部署——都具有一个规范的余额和身份。这种统一的方法防止了碎片化，并消除了桥接或包装代币的需要，从而实现了去中心化金融（DeFi）和 dApp 交互的无缝互操作性和统一流动性。

## 为什么 MTS 很重要？

* **无缝互操作性：** 代币在 Cosmos 和 EVM 环境中保持一致。
* **统一流动性：** 单一的真实来源避免了流动性碎片化。
* **增强的开发者体验：** Hardhat、Foundry 和 MetaMask 等标准工具开箱即用。
* **安全性和效率：** 所有代币状态都集中维护在 bank 模块中，确保强大的安全性。

## 架构

该系统包含两个主要组件：

* [**Bank 预编译合约**](bank-precompile.md)：
  * 使用 Go 开发，此预编译合约直接嵌入到 Biya Chain EVM 中。
  * 它提供了一个 Solidity 接口，将 ERC20 操作（如铸造、销毁和转账）代理到 bank 模块。
* [**ERC20 模块**](erc20-module.md)：
  * 此模块将原生 bank 面额（例如 BIYA、IBC 代币、Peggy 资产）映射到 EVM 中的 ERC20 合约。
  * 它部署符合 MTS 的 ERC20 合约，这些合约始终反映由 bank 模块维护的规范代币余额。

<figure><img src="https://github.com/biya-coin/biyachain-docs/blob/master/.gitbook/assets/multivm-token-single-token-representation-architecture.png" alt=""><figcaption><p>单一代币表示架构</p></figcaption></figure>

### **创建符合 MTS 的代币**

1. [**使用我们的预构建模板**](https://github.com/biya-coin/solidity-contracts/tree/master/src)：
   * 从提供的 Solidity 模板开始，例如 `BankERC20.sol`、`MintBurnBankERC20.sol` 或 `FixedSupplyBankERC20.sol`。
2. [**部署合约**](smart-contracts/)：
   * 在 Biya Chain EVM 网络上部署您的 MTS 代币合约。
   * 合约自动与 Bank 预编译合约交互以更新规范状态。

### **互操作性和跨链集成**

#### **原生互操作性**

Biya Chain 的 EVM 直接集成到基于 Cosmos 的链中。

* 使用 MTS 的 EVM 智能合约执行的操作会立即反映在原生模块（如交易所、质押和治理模块）上。
* Biya Chain 二进制文件中提供的 [JSON-RPC 端点](network-information.md)与以太坊兼容，确保顺畅的开发者集成。

#### **跨链操作**

* **IBC 兼容性：** 现有的原生代币（例如，通过[代币工厂](../../developers-native/biyachain/tokenfactory/)创建或通过 Peggy 挂钩的代币）一旦建立 MTS 配对，就可以从 EVM 访问。
* **桥接替代方案：** 虽然许多区块链需要单独的桥接操作（锁定、铸造、解锁），但 MTS 通过原生同步状态来避免这些步骤。

#### **授权和扩展的 ERC20 功能**

* MTS 合约维护标准的 ERC20 功能，例如授权（approve/transferFrom）。
* 请注意，虽然授权机制为方便起见在 EVM 合约中维护，但最终余额由 bank 模块管理，保持完整性。

### **性能、Gas 和安全性考虑**

#### **Gas 成本和效率**

* Gas 费用以 BIYA 支付。虽然通过 EVM 的 MTS 操作引入了一个抽象层，与原生交易相比可能会略微增加 gas 使用量，但总体成本仍然低于以太坊上的类似操作。
* Gas 模型旨在反映 EVM 风格的操作码成本和原生模块交互之间的平衡。

#### **安全性**

* [bank 模块](../../biya-chain-jia-gou/core/bank.md)作为单一真实来源，通过确保代币余额一致且可验证来支撑 MTS 的安全性。
* 使用[预编译合约](precompiles.md)可以防止常见的陷阱，如状态不同步，确保所有操作——无论从何处发起——都更新相同的规范账本。
* 我们的安全部分和外部资源中提供了智能合约开发的高级安全指南和最佳实践。

**ℹ️ 注意：**

为了防止面额垃圾邮件，通过 ERC20 模块部署 ERC20 合约是一个**付费操作**，需要支付 **1 BIYA** 的部署费用。确保您的 ERC20 合约部署交易包含此金额，否则操作将被拒绝。
