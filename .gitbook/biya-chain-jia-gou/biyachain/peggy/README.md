# Peggy

## 摘要

peggy 模块使 Biya Chain 能够支持一个无需信任的、链上双向 ERC-20 代币桥接至 Ethereum。在此系统中，\
Ethereum 上的 ERC-20 代币持有者可以将其 ERC-20 代币转换为 Biya Chain 上的 Cosmos 原生代币，\
反之亦然。

这个去中心化桥接由 Biya Chain 的验证者保护和运营。

## 目录

1. [定义](01_definitions.md)
2. [工作流程](02_workflow.md)
3. [状态](03_state.md)
4. [消息](04_messages.md)
5. [惩罚](05_slashing.md)
6. [区块结束](06_end_block.md)
7. [事件](07_events.md)
8. [参数](08_params.md)

### 组件

1. [**Peggy**](https://etherscan.io/address/0xF955C57f9EA9Dc8781965FEaE0b6A2acE2BAD6f3) **Ethereum 上的智能合约**
2. **Biya Chain 上的 Peggy 模块**
3. [**Peggo**](https://github.com/biya-coin/peggo) **（链下中继者，也称为编排器）**
   * **Oracle**（观察 Peggy 合约的事件并向 Peggy 模块发送声明）
   * **EthSigner**（签署 Valset 和 Batch 确认到 Peggy 模块）
   * **Batch Requester**（向 Peggy 模块发送批量代币提取请求）
   * **Valset Relayer**（向 Peggy 合约提交验证者集更新）
   * **Batch Relayer**（向 Peggy 合约提交批量代币提取）

除了运行 `biyachaind` 节点来签名区块外，Biya Chain 验证者还必须运行 `peggo` 编排器来中继来自 Ethereum 上的 Peggy 智能合约和 Biya Chain 上的 Peggy 模块的数据。

### Peggo 功能

1. **在 Ethereum 上维护 Biya Chain 验证者集的最新检查点**
2. **将 ERC-20 代币从 Ethereum 转移到 Biya Chain**
3. **将锚定代币从 Biya Chain 转移到 Ethereum**
