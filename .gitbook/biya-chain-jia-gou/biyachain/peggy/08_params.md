---
sidebar_position: 8
title: 参数
---

# 参数

本文档描述并建议 Peggy 模块参数的配置。默认参数可以在 peggy 模块的 genesis.go 中找到。

```go
type Params struct {
	PeggyId                       string                                 
	ContractSourceHash            string                                 
	BridgeEthereumAddress         string                                 
	BridgeChainId                 uint64                                 
	SignedValsetsWindow           uint64                                 
	SignedBatchesWindow           uint64                                 
	SignedClaimsWindow            uint64                                 
	TargetBatchTimeout            uint64                                 
	AverageBlockTime              uint64                                 
	AverageEthereumBlockTime      uint64                                 
	SlashFractionValset           math.LegacyDec 
	SlashFractionBatch            math.LegacyDec 
	SlashFractionClaim            math.LegacyDec 
	SlashFractionConflictingClaim math.LegacyDec 
	UnbondSlashingValsetsWindow   uint64  
	SlashFractionBadEthSignature  math.LegacyDec 
	CosmosCoinDenom               string  
	CosmosCoinErc20Contract       string  
	ClaimSlashingEnabled          bool    
	BridgeContractStartHeight     uint64  
	ValsetReward                  types.Coin
}
```

## `peggy_id`

一个随机的 32 字节值，用于防止签名重用，例如，如果\
Biya Chain 验证者决定将相同的 Ethereum 密钥用于另一条链\
也运行 Peggy，我们不希望可能将链 A 的存款\
回放到链 B 的 Peggy 上。此值在 ETHEREUM 上使用，因此\
必须在启动前在 genesis.json 中设置，并且在\
部署 Peggy 后不能更改。在部署 Peggy 后更改此值将导致\
桥接无法运行。要恢复，只需将其设置回\
合约部署时的原始值。

## `contract_source_hash`

已知良好版本的 Peggy 合约\
solidity 代码的代码哈希。这可用于验证\
已部署合约的正确版本。这是仅用于\
治理操作的参考值，任何 Peggy 代码都不会读取它

## `bridge_ethereum_address`

是 Ethereum 端桥接合约的地址，这是\
仅用于治理的参考值，实际上不被任何\
Peggy 模块代码使用。

Ethereum 桥接中继者使用此值与 Peggy 合约交互，以查询事件并向 Peggy 合约提交 valset/批次。

## `bridge_chain_id`

桥接链 ID 是 Ethereum 链的唯一标识符。这仅是参考值，实际上不被任何 Peggy 代码使用

这些参考值可能被未来的 Peggy 客户端实现用于一致性检查。

## 签名窗口

* `signed_valsets_window`
* `signed_batches_window`
* `signed_claims_window`

这些值表示验证者必须提交\
批次或 valset 的签名，或为特定\
证明 nonce 提交声明的时间（以区块为单位）。

对于证明，此时钟在\
创建证明时开始，但仅在事件过去后才允许惩罚。\
请注意，声明惩罚目前未启用，请参见[惩罚规范](05_slashing.md)

## `target_batch_timeout`

这是批次超时的"目标"值，这是一个目标，因为\
Ethereum 是一个概率链，您无法提前确定\
区块频率。

## Ethereum 时间

* `average_block_time`
* `average_ethereum_block_time`

这些值分别是 Biya Chain 平均区块时间和 Ethereum 区块时间\
，它们用于计算目标批次超时。重要的是\
治理在产生区块所需时间发生任何重大、长期变化时更新这些值

## 惩罚比例

* `slash_fraction_valset`
* `slash_fraction_batch`
* `slash_fraction_claim`
* `slash_fraction_conflicting_claim`

各种 peggy 相关惩罚条件的惩罚比例。前三个\
指未提交特定消息，第三个指未能提交声明，最后一个指提交与其他验证者不同的声明。

请注意，声明惩罚目前已禁用，如[惩罚规范](05_slashing.md)中所述

## `valset_reward`

Valset 奖励是当中继者将 valset 中继到 Ethereum 上的 Peggy 合约时支付给中继者的奖励金额。
