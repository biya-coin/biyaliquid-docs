---
sidebar_position: 5
title: 区块结束
---

# EndBlock

在每个区块结束时，对模块状态执行以下操作

## 1. 惩罚

### 验证者惩罚

验证者因未对超过 `SignedValsetsWindow` 的 valset 更新进行签名而受到惩罚。\
换句话说，如果验证者在预配置的时间内未能提供 valset 更新的确认，他们将因 `SlashFractionValset` 部分的权益而受到惩罚，并立即被监禁。

### 批次惩罚

验证者因未对超过 `SignedBatchesWindow` 的批次进行签名而受到惩罚。\
换句话说，如果验证者在预配置的时间内未能提供批次的确认，他们将因 `SlashFractionBatch` 部分的权益而受到惩罚，并立即被监禁。

## 2. 取消超时的批次

`Outgoing Batch pool` 中仍然存在的任何批次，如果其 `BatchTimeout`（批次应该执行的指定 Ethereum 高度）已超过，则从池中移除，提取将重新插入回 `Outgoing Tx pool`。

## 3. 创建新的 Valset 更新

在以下情况下将自动创建新的 `Validator Set` 更新：

* 最新和当前验证者集之间的权重差异大于 5%
* 验证者开始解绑

新的验证者集最终会中继到 Ethereum 上的 `Peggy contract`。

## 4. 修剪旧的验证者集

之前观察到的超过 `SignedValsetsWindow` 的 valsets 从状态中移除

## 5. 证明处理

处理当前正在投票的所有证明（特定事件的声明聚合）。每个证明逐一处理，以确保每个 `Peggy contract` 事件都被处理。\
在处理每个证明后，模块的 `lastObservedEventNonce` 和 `lastObservedEthereumBlockHeight` 都会更新。

根据证明中声明的类型，执行以下操作：

* `MsgDepositClaim`：为接收者地址铸造/解锁存入的代币
* `MsgWithdrawClaim`：从传出池中移除相应的批次，并取消任何先前的批次
* `MsgValsetUpdatedClaim`：更新模块的 `LastObservedValset`
* `MsgERC20DeployedClaim`：验证新代币元数据并在模块状态中注册（`denom <-> token_contract`）

## 6. 清理已处理的证明

之前处理的证明（高度早于 `lastObservedEthereumBlockHeight`）从模块状态中移除
