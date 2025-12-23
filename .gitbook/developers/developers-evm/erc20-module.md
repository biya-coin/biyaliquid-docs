# ERC20 模块

### ERC20 模块

ERC20 模块使**现有的** bank 面额（例如，IBC 桥接代币、USDC、tokenfactory 和 Peggy）能够与 Biya Chain EVM 集成。它在其存储中维护代币对之间的映射，在 ERC20 代币及其相应的 bank 面额之间创建关联。当为现有 bank 面额生成新的代币对时，该模块部署一个与 Bank 预编译合约交互的 ERC20 合约，然后引用存储映射以将 ERC20 地址与相应的 bank 面额对齐。此模块服务于几个基本目的：

1. **存储**：在 bank 面额 ↔ ERC20 地址之间映射
2. **新消息类型**：使用户能够通过发出链消息来建立新的代币对映射

#### 创建新的代币对

目前，三种类型的 bank 面额可以具有关联的代币对，每种都有特定的规则：

* **Tokenfactory (`factory/...`)**\
  只有面额管理员或治理可以创建代币对。发送者可以指定现有的 ERC20 合约地址作为自定义实现。如果省略，将部署 `MintBurnBankERC20.sol` 的新实例，`msg.sender` 作为所有者，允许通过合约进行铸造和销毁。
* **IBC (`ibc/...`)**\
  任何用户都可以通过创建代币对将 IBC 面额集成到 EVM 中，但没有自定义 ERC20 地址的选项。这些将始终部署 `FixedSupplyBankERC20.sol` 的新的、无所有者的实例。
* **Peggy (`peggy0x...`)**\
  任何用户都可以通过创建代币对将 Peggy 面额集成到 EVM 中，但没有自定义 ERC20 地址的选项。这些将始终部署 `FixedSupplyBankERC20.sol` 的新的、无所有者的实例。
