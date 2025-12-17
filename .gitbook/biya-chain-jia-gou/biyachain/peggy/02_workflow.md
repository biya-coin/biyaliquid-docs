---
sidebar_position: 2
title: 工作流程
---

# 工作流程

## 概念概述

回顾一下，每个 `Operator` 负责维护 2 个安全进程：

1. 完全同步的 Biya Chain `Validator` 节点（`biyachaind` 进程）
2. `Orchestrator` 服务（`peggo orchestrator` 进程），它与两个网络交互。隐含地，还需要一个完全同步的 Ethereum 节点的 RPC 端点（参见 peggo .env 示例）

这两个实体结合起来完成 3 件事：

* 将代币资产从 Ethereum 移动到 Biya Chain
* 将代币资产从 Biya Chain 移动到 Ethereum
* 保持 `Peggy.sol` 合约与 Biya Chain 上的活跃 `Validator Set` 同步

可以在不成为 `Validator` 的情况下运行 `peggo`。当配置为使用**未关联** `Validator` 的地址运行时，Peggo 会自动以"中继者模式"运行。\
在此模式下，只能发生 2 件事：

* 可以在 Biya Chain 上创建新的代币批次
* 可以将已确认的 valsets/批次中继到 Ethereum

## 资产类型

### 原生 Ethereum 资产

任何源自 Ethereum 并实现 ERC-20 标准的资产都可以通过调用 [Peggy.sol](https://github.com/biya-coin/peggo/blob/master/solidity/contracts/Peggy.sol) 合约上的 `sendToBiyachain` 函数从 Ethereum 转移到 Biya Chain，该函数将代币从发送者的余额转移到 Peggy 合约。

所有 `Operators` 都运行其 `peggo` 进程，这些进程提交描述他们观察到的存款的 `MsgDepositClaim` 消息。一旦超过 66% 的投票权为此特定存款提交了声明，就会铸造代表代币并发行到发送者请求的 Biya Chain 地址。

这些代表代币的面额前缀为 `peggy`，后跟 ERC-20 代币的十六进制地址，例如 `peggy0xdac17f958d2ee523a2206206994597c13d831ec7`。

### 原生 Cosmos SDK 资产

Cosmos SDK 链的原生资产（例如 `ATOM`）首先必须在 Ethereum 上表示，然后才能桥接。为此，[Peggy 合约](https://github.com/biya-coin/peggo/blob/master/solidity/contracts/Peggy.sol) 允许任何人通过调用 `deployERC20` 函数创建代表 Cosmos 资产的新 ERC-20 代币。

此端点不受权限限制，因此由验证者和 Peggy 桥接的用户来声明任何给定的 ERC-20 代币作为给定资产的表示。

当 Ethereum 上的用户调用 `deployERC20` 时，他们传递描述所需资产的参数。[Peggy.sol](https://github.com/biya-coin/peggo/blob/master/solidity/contracts/Peggy.sol) 使用 ERC-20 工厂部署实际的 ERC-20 合约，并在发出 `ERC20DeployedEvent` 之前将新代币的全部余额的所有权分配给 Peggy 合约本身。

peggo 编排器观察此事件并决定 Cosmos 资产是否已准确表示（正确的小数位数、正确的名称、没有预先存在的表示）。如果是这种情况，则采用 ERC-20 合约地址并将其存储为该 Cosmos 资产在 Ethereum 上的确定表示。

## `Orchestrator` (Peggo) 子进程

`peggo orchestrator` 进程由 4 个以精确间隔（循环）并发运行的子进程组成。这些是：

* `Signer`（签名者）- 使用 `Operator` 的 Ethereum 密钥签署新的 `Validator Set` 更新和 `Token Batches`，并使用[消息](04_messages.md#Ethereum-Signer-messages)提交。
* `Oracle`（预言机）- 观察 Ethereum 事件并将它们作为[声明](04_messages.md#Oracle-messages)发送到 Biya Chain。
* `Relayer`（中继者）- 将已确认的 `Validator Set` 更新和 `Token Batches` 提交到 Ethereum 上的 `Peggy Contract`
* `Batch Creator`（批次创建者）- 观察 Biya Chain 上的（新）提取，并根据其类型和配置的 `PEGGO_MIN_BATCH_FEE_USD` 值决定将哪些提取进行批次处理

### Batch Creator

`Batch Creator` 的目的仅在 Biya Chain 端创建代币批次。相关的 `Peggy module` RPC 不受权限限制，因此任何人都可以创建批次。

当用户想要从 Biya Chain 提取资产到 Ethereum 时，他们向 Biya Chain 发送特殊消息（`MsgSendToEth`），这会将他们的提取添加到 `Peggy Tx Pool`。`Batch Creator` 持续查询池中的提取（按代币类型），当潜在批次满足配置的 `PEGGO_MIN_BATCH_FEE_USD` 值时，向 Biya Chain 发出 `MsgRequestBatch`（参见 .env 示例）。

在接收端，所有与请求中代币类型匹配的合并提取都从 `Outgoing Tx Pool` 作为单个批次移动并放置在 `Outgoing Batch Pool` 中。

### Signer

Signer 的职责是提供确认，证明 `Operator (Orchestrator)` 正在参与桥接活动。未能提供这些确认会导致编排器的 `Validator` 受到惩罚。\
换句话说，对于 `Validator` 节点，此进程**必须始终运行**。

在 Biya Chain->Ethereum 管道中移动的任何有效负载（`Validator Set` 更新/`Token Batches`）都需要 `Validator` 签名才能成功中继到 Ethereum。`Peggy Contract` 上的某些调用接受一个签名数组，这些签名将与合约本身中的 `Validator Set` 进行核对。`Orchestrators` 使用其 `Delegate Ethereum address` 进行这些签名：这是 `Operator` 在初始设置时决定的 Ethereum 地址（[SetOrchestratorAddress](04_messages.md#setorchestratoraddresses)）。然后，此地址在 Ethereum 区块链上代表该验证者，并将作为多重签名的签名成员添加，其加权投票权尽可能接近 Biya Chain 投票权。

每当 `Signer` 发现 `Peggy Module` 中存在未确认的 valset 更新（代币批次）时，它会发出 `MsgConfirmValset`（`MsgConfirmBatch`）作为证明，表明正在运行的 `Validator` 在桥接活动中处于活跃状态。

### Oracle

监控 Ethereum 网络以查找涉及 `Peggy Contract` 的新事件。

合约发出的每个事件都有一个唯一的事件 nonce。此 nonce 值对于协调 `Orchestrators` 正确观察合约活动并确保 Biya Chain 通过 `Claims` 确认它们至关重要。\
相同 nonce 的多个声明组成一个 `Attestation`，当大多数（2/3）编排器观察到事件时，其特定逻辑会在 Biya Chain 上执行。

如果 2/3 的验证者无法就单个 `Attestation` 达成一致，则预言机将停止。这意味着在部分验证者更改其投票之前，不会从 Ethereum 中继新事件。这没有惩罚条件，原因在[惩罚规范](05_slashing.md)中概述

Peggy.sol 发出 4 种类型的事件：

1. `TransactionBatchExecutedEvent` - 表示代币批次（提取）已成功中继到 Ethereum 的事件
2. `ValsetUpdatedEvent` - 表示 `Validator Set` 更新已成功中继到 Ethereum 的事件
3. `SendToBiyachainEvent` - 表示已启动向 Biya Chain 的新存款的事件
4. `ERC20DeployedEvent` - 表示新 Cosmos 代币已在 Ethereum 上注册的事件

Biya Chain 的 `Oracle` 实现忽略 Ethereum 上的最后 12 个区块以确保区块最终性。实际上，这意味着最新事件在发生 2-3 分钟后才会被观察到。

### Relayer

`Relayer` 将 valset 更新（或代币批次）及其确认打包到 Ethereum 交易中，并将其发送到 `Peggy contract`。

请记住，这些消息的成本会根据 Ethereum gas 价格的剧烈变化而变化，因此单个批次花费超过一百万 gas 并非不合理。\
我们中继者奖励的一个主要设计决策是始终在 Ethereum 链上发放它们。这有缺点，即在验证者集更新奖励的情况下会出现一些奇怪的行为。

但优点是不可否认的，因为 Ethereum 消息向 `msg.sender` 支付费用，Ethereum 生态系统中的任何现有机器人都会接收它们并尝试提交它们。这使得中继市场更具竞争力，更不容易出现小团体行为。

## 端到端生命周期

本文档描述了 Peggy 桥接的端到端生命周期。

### Peggy 智能合约部署

为了部署 Peggy 合约，必须知道原生链（Biya Chain）的验证者集。在部署 Peggy 合约套件（Peggy Implementation、Proxy 合约和 ProxyAdmin 合约）后，必须使用验证者集初始化 Peggy 合约（Proxy 合约）。\
初始化时，合约会发出 `ValsetUpdatedEvent`。

代理合约用于升级 Peggy Implementation 合约，这在初始阶段需要用于错误修复和潜在改进。它是一个简单的包装器或"代理"，用户直接与之交互，负责将交易转发到包含逻辑的 Peggy 实现合约。需要理解的关键概念是，实现合约可以被替换，但代理（访问点）永远不会改变。

ProxyAdmin 是 Peggy 代理的中央管理员，简化了管理。它控制可升级性和所有权转移。ProxyAdmin 合约本身具有内置的过期时间，一旦过期，将阻止 Peggy 实现合约在未来被升级。

然后应更新以下 peggy 创世参数：

1. `bridge_ethereum_address` 使用 Peggy 代理合约地址
2. `bridge_contract_start_height` 使用部署 Peggy 代理合约的高度

这完成了 Peggy 桥接的引导，链可以启动。之后，`Operators` 应该启动其 `peggo` 进程，并最终观察到初始 `ValsetUpdatedEvent` 在 Biya Chain 上得到证明。

### **在 Ethereum 上更新 Biya Chain 验证者集**

![img.png](/broken/files/YYRuo8K4QkB7PA2NQuOZ)

验证者集是一系列带有附加标准化权重的 Ethereum 地址，用于在 Ethereum 上的 Peggy 合约中表示 Biya Chain 验证者集（Valset）。Peggy 合约通过以下机制与 Biya Chain 验证者集保持同步：

1. **在 Biya Chain 上创建新的 Valset：** 在以下任一情况下，Biya Chain 上会自动创建新的 Valset：
   * 当前验证者集权重与最后记录的 Valset 相比的累积差异超过 5%
   * 验证者开始从集合中解绑
2. **在 Biya Chain 上确认 Valset：** 每个 `Operator` 负责确认在 Biya Chain 上创建的 Valset 更新。`Signer` 进程通过让验证者的委托 Ethereum 密钥对 Valset 数据的压缩表示进行签名，通过 `MsgConfirmValset` 发送这些确认。`Peggy module` 验证签名的有效性并将其持久化到其状态。
3. **更新 Peggy 合约上的 Valset：** 在 2/3+ 1 多数验证者提交了对给定 Valset 的确认后，`Relayer` 通过调用 `updateValset` 将新的 Valset 数据提交到 Peggy 合约。\
   然后 Peggy 合约验证数据，更新 valset 检查点，将 valset 奖励转移给发送者，并发出 `ValsetUpdatedEvent`。
4. **在 Biya Chain 上确认 `ValsetUpdatedEvent`：** `Oracle` 见证 Ethereum 上的 `ValsetUpdatedEvent`，并发送 `MsgValsetUpdatedClaim`，通知 `Peggy module` Valset 已在 Ethereum 上更新。
5. **在 Biya Chain 上修剪 Valsets：** 一旦 2/3 多数验证者发送了对给定 `ValsetUpdateEvent` 的声明，所有先前的 valsets 都会从 `Peggy module` 状态中修剪。
6. **验证者惩罚：** 验证者在配置的时间窗口（`SignedValsetsWindow`）内未提供确认后将受到惩罚。阅读更多[valset 惩罚](05_slashing.md)

***

### **将 ERC-20 代币从 Ethereum 转移到 Biya Chain**

![img.png](/broken/files/IkOQm1tLFSeymMPsomcp)

ERC-20 代币通过以下机制从 Ethereum 转移到 Biya Chain：

1. **在 Peggy 合约上存入 ERC-20 代币：** 用户通过调用 Peggy 合约上的 `sendToBiyachain` 函数启动从 Ethereum 到 Biya Chain 的 ERC-20 代币转移，该函数将代币存入 Peggy 合约并发出 `SendToBiyachainEvent`。\
   存入的代币将保持锁定状态，直到在未来某个未确定的时间点提取。此事件包含代币的数量和类型，以及 Biya Chain 上接收资金的目标地址。
2. **确认存款：** 每个 `Oracle` 见证 `SendToBiyachainEvent` 并发送包含存款信息的 `MsgDepositClaim` 到 Peggy 模块。
3. **在 Biya Chain 上铸造代币：** 一旦大多数验证者确认存款声明，就会处理存款。

* 如果资产源自 Ethereum，则代币被铸造并转移到 Biya Chain 上的预期接收者地址。
* 如果资产源自 Cosmos-SDK，则代币被解锁并转移到 Biya Chain 上的预期接收者地址。

***

### **从 Biya Chain 提取代币到 Ethereum**

![img.png](/broken/files/6cfRB5jvLu98zFk7AAtH)

1. **从 Biya Chain 请求提取：** 用户可以通过向 peggy 模块发送 `MsgSendToEth` 交易来启动从 Biya Chain 到 Ethereum 的资产转移。
   * 如果资产是 Ethereum 原生的，则代表代币被销毁。
   * 如果资产是 Cosmos SDK 原生的，则代币被锁定在模块中。然后提取被添加到 `Outgoing Tx Pool`。
2. **批次创建：** `Batch Creator` 观察待处理提取池。然后批次创建者（或任何外部第三方）通过向 Biya Chain 发送 `MsgRequestBatch` 来请求为给定代币创建批次。`Peggy module` 将匹配代币类型的提取收集到批次中，并将其放入 `Outgoing Batch Pool`。
3. **批次确认：** 检测到 Outgoing Batch 存在后，`Signer` 使用其 Ethereum 密钥对批次进行签名，并向 Peggy 模块提交 `MsgConfirmBatch` 交易。
4. **向 Peggy 合约提交批次：** 一旦大多数验证者确认批次，`Relayer` 使用批次及其确认调用 Peggy 合约上的 `submitBatch`。Peggy 合约验证签名，更新批次检查点，处理批次 ERC-20 提取，将批次费用转移给交易发送者，并发出 `TransactionBatchExecutedEvent`。
5. **向 Biya Chain 发送提取声明：** `Oracles` 见证 `TransactionBatchExecutedEvent` 并向 Peggy 模块发送包含提取信息的 `MsgWithdrawClaim`。
6. **修剪批次** 一旦大多数验证者提交其 `MsgWithdrawClaim`，批次将被删除，并且所有先前的批次在 Peggy 模块上被取消。已取消批次中的提取会移回 `Outgoing Tx Pool`。
7. **批次惩罚：** 验证者负责确认批次，如果未能这样做，将受到惩罚。阅读更多关于[批次惩罚](05_slashing.md)的内容。

请注意，虽然批次处理大大降低了单个提取成本，但这以延迟和实施复杂性为代价。如果用户希望快速提取，他们将不得不支付更高的费用。但是，此费用大约与非批次系统中桥接的每次提取所需的费用相同。
