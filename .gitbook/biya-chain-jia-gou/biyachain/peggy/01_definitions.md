---
sidebar_position: 1
title: 定义
---

# 定义

本文档旨在从技术角度概述 `Peggy`（Biya Chain 的 Ethereum 桥接），并深入探讨其操作逻辑。\
Peggy 是构建在 Biya Chain 上的自定义 Cosmos SDK 模块的名称，也是构成桥接两端的 Ethereum 合约（Peggy.sol）的名称。\
通过称为 `Peggo` 的中间过程连接，用户可以在网络之间安全地移动代币资产。

要提出改进建议，请打开 GitHub issue。

### 关键定义

术语很重要，我们寻求术语的清晰性，以便我们的思考和沟通更加清晰。\
为了更好地理解，以下是一些关键定义：

* `Operator`（操作者）- 控制并运营 `Validator` 和 `Orchestrator` 进程的人员
* `Validator`（验证者）- 这是 Biya Chain 验证节点（例如 `biyachaind` 进程）
* `Validator Set`（验证者集）- Biya Chain `Validators`（Valset）的（活跃）集合，以及根据其权益权重确定的各自投票权。每个验证者都与一个 Ethereum 地址关联，以在 Ethereum 网络上表示
* `Orchestrator (Peggo)`（编排器）- 在 Biya Chain 和 Ethereum 之间扮演中间人角色的链下进程（`peggo`）。编排器负责保持桥接在线，需要完全同步的 Biya Chain（Ethereum）节点的活动端点
* `Peggy module`（Peggy 模块）- `Peggy contract` 的对应 Cosmos 模块。除了提供桥接代币资产的服务外，它还会自动反映活跃的 `Validator Set` 随时间的变化。更新稍后通过 `Peggo` 应用到 Ethereum
* `Peggy Contract`（Peggy 合约）- 持有所有 ERC-20 代币的 Ethereum 合约。它还使用 `Delegate Keys` 和标准化权重维护 Biya Chain `Validator Set` 的压缩检查点表示
* `Delegate Keys`（委托密钥）- 当 `Operator` 首次设置其 `Orchestrator` 时，他们在 Biya Chain 上将其 `Validator` 的地址与一个 Ethereum 地址注册。相应的密钥用于签名消息并在 Ethereum 上代表该验证者。\
  可选地，可以提供一个委托的 Biya Chain 账户密钥来代表 `Validator` 签署 Biya Chain 消息（例如 `Claims`）
* `Peggy Tx pool (withdrawals)`（Peggy 交易池（提取））- 当用户希望将其资产从 Biya Chain 移动到 Ethereum 时，他们的个人交易会与具有相同资产的其他交易合并
* `Peggy Batch pool`（Peggy 批次池）- 合并的提取被批量处理（由 `Orchestrator`）以进行签名并最终中继到 Ethereum。这些批次保存在此池中
* `Claim`（声明）- 由 `Orchestrator` 签名的证明，证明 `Peggy contract` 中发生了事件
* `Attestation`（证明）- 来自 `Peggy contract` 的特定事件 nonce 的声明聚合。在大多数 `Orchestrators` 对声明进行证明后，事件在 Biya Chain 上被确认并执行
* `Majority`（多数）- Biya Chain 网络的多数，2/3 + 1 个验证者
* `Deposit`（存款）- 从 Ethereum 发起的资产转移到 Biya Chain
* `Withdrawal`（提取）- 从 Biya Chain 发起的资产转移到 Ethereum（存在于 `Peggy Tx pool` 中）
* `Batch`（批次）- 具有相同代币类型的提取批次（存在于 `Peggy Batch pool` 中）
