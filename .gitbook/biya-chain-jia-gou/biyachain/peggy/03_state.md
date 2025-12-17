---
sidebar_position: 3
title: 状态
---

# 状态

本文档列出了 Peggy 模块读取/写入其状态的所有数据，以 KV 对形式列出

### Module Params

Params 是一个模块范围的配置结构，存储参数并定义 peggy 模块的整体功能。每个参数的详细规范可以在[参数部分](08_params.md)中找到。

| key           | Value         | Type           | Encoding         |
| ------------- | ------------- | -------------- | ---------------- |
| `[]byte{0x4}` | Module params | `types.Params` | Protobuf encoded |

### Validator Info

#### Ethereum Address by Validator

存储按 `Validator` 账户地址索引的 `Delegate Ethereum address`

| key                                   | Value            | Type             | Encoding         |
| ------------------------------------- | ---------------- | ---------------- | ---------------- |
| `[]byte{0x1} + []byte(validatorAddr)` | Ethereum address | `common.Address` | Protobuf encoded |

#### Validator by Ethereum Address

存储按 `Delegate Ethereum address` 索引的 `Validator` 账户地址

| key                                 | Value             | Type             | Encoding         |
| ----------------------------------- | ----------------- | ---------------- | ---------------- |
| `[]byte{0xfb} + []byte(ethAddress)` | Validator address | `sdk.ValAddress` | Protobuf encoded |

#### OrchestratorValidator

当验证者希望将其投票权委托给另一个密钥时。使用编排器地址作为键存储值

| Key                                 | Value                                        | Type     | Encoding         |
| ----------------------------------- | -------------------------------------------- | -------- | ---------------- |
| `[]byte{0xe8} + []byte(AccAddress)` | Orchestrator address assigned by a validator | `[]byte` | Protobuf encoded |

### Valset

这是桥接的验证者集。由 `Peggy module` 在 EndBlocker 期间自动创建。

以两种可能的方式存储，第一种带高度，第二种不带（不安全）。不安全的方式用于测试以及状态的导出和导入。

```go
type Valset struct {
	Nonce        uint64                               
	Members      []*BridgeValidator                   
	Height       uint64                               
	RewardAmount math.Int 
	RewardToken string
}

```

| key                                        | Value         | Type           | Encoding         |
| ------------------------------------------ | ------------- | -------------- | ---------------- |
| `[]byte{0x2} + nonce (big endian encoded)` | Validator set | `types.Valset` | Protobuf encoded |

### SlashedValsetNonce

最新的验证者集惩罚 nonce。用于跟踪哪个验证者集需要被惩罚以及哪个已经被惩罚。

| Key            | Value | Type   | Encoding               |
| -------------- | ----- | ------ | ---------------------- |
| `[]byte{0xf5}` | Nonce | uint64 | encoded via big endian |

### ValsetNonce

最新验证者集的 Nonce。在每个新验证者集时更新。

| key            | Value | Type     | Encoding               |
| -------------- | ----- | -------- | ---------------------- |
| `[]byte{0xf6}` | Nonce | `uint64` | encoded via big endian |

### Valset Confirmation

`Signer` 对特定验证者集的确认。参见[签名者消息](04_messages.md#ValsetConfirm)

| Key                                         | Value                  | Type                     | Encoding         |
| ------------------------------------------- | ---------------------- | ------------------------ | ---------------- |
| `[]byte{0x3} + (nonce + []byte(AccAddress)` | Validator Confirmation | `types.MsgValsetConfirm` | Protobuf encoded |

### Batch Confirmation

`Signer` 对特定代币批次的确认。参见[签名者消息](04_messages.md#ConfirmBatch)

| Key                                                                 | Value                        | Type                    | Encoding         |
| ------------------------------------------------------------------- | ---------------------------- | ----------------------- | ---------------- |
| `[]byte{0xe1} + []byte(tokenContract) + nonce + []byte(AccAddress)` | Validator Batch Confirmation | `types.MsgConfirmBatch` | Protobuf encoded |

### OutgoingTransferTx

用户提取在 `Peggy Tx Pool` 中合并在一起，准备稍后由 `Batch Creator` 进行批次处理。

每个提取由 `Peggy module` 在收到提取时设置的唯一 nonce 索引。

```go
type OutgoingTransferTx struct {
	Id          uint64     
	Sender      string     
	DestAddress string     
	Erc20Token  *ERC20Token 
	Erc20Fee    *ERC20Token 
}
```

| Key                                    | Value                        | Type     | Encoding           |
| -------------------------------------- | ---------------------------- | -------- | ------------------ |
| `[]byte{0x7} + []byte("lastTxPoolId")` | nonce of outgoing withdrawal | `uint64` | Big endian encoded |

### LastTXPoolID

Biya Chain 收到的每个提取的单调递增值

| Key                                    | Value                   | Type     | Encoding           |
| -------------------------------------- | ----------------------- | -------- | ------------------ |
| `[]byte{0x6} + []byte("lastTxPoolId")` | Last used withdrawal ID | `uint64` | Big endian encoded |

### OutgoingTxBatch

`OutgoingTxBatch` 表示相同代币类型的提取集合。在每次成功的 `MsgRequestBatch` 时创建。

以两种可能的方式存储，第一种带高度，第二种不带（不安全）。不安全的方式用于测试以及状态的导出和导入。\
目前 [Peggy.sol](https://github.com/biya-coin/peggo/blob/master/solidity/contracts/Peggy.sol) 硬编码为仅接受单一代币类型的批次，并且仅以相同代币类型支付奖励。

```go
type OutgoingTxBatch struct {
	BatchNonce    uint64               
	BatchTimeout  uint64               
	Transactions  []*OutgoingTransferTx 
	TokenContract string                
	Block         uint64               
}
```

| key                                                                | Value                            | Type                    | Encoding         |
| ------------------------------------------------------------------ | -------------------------------- | ----------------------- | ---------------- |
| `[]byte{0xa} + []byte(tokenContract) + nonce (big endian encoded)` | A batch of outgoing transactions | `types.OutgoingTxBatch` | Protobuf encoded |
| `[]byte{0xb} + block (big endian encoded)`                         | A batch of outgoing transactions | `types.OutgoingTxBatch` | Protobuf encoded |

### LastOutgoingBatchID

由某个 `Batch Creator` 在 Biya Chain 上创建的每个批次的单调递增值

| Key                                   | Value              | Type     | Encoding           |
| ------------------------------------- | ------------------ | -------- | ------------------ |
| `[]byte{0x7} + []byte("lastBatchId")` | Last used batch ID | `uint64` | Big endian encoded |

### SlashedBlockHeight

表示最新的惩罚区块高度。始终只存储单个值。

| Key            | Value                                   | Type     | Encoding           |
| -------------- | --------------------------------------- | -------- | ------------------ |
| `[]byte{0xf7}` | Latest height a batch slashing occurred | `uint64` | Big endian encoded |

### LastUnbondingBlockHeight

表示 `Validator` 开始从 `Validator Set` 解绑的最新区块高度。用于确定惩罚条件。

| Key            | Value                                                | Type     | Encoding           |
| -------------- | ---------------------------------------------------- | -------- | ------------------ |
| `[]byte{0xf8}` | Latest height at which a Validator started unbonding | `uint64` | Big endian encoded |

### TokenContract & Denom

原本来自对应链的 denom 将来自合约。代币合约和 denom 以两种方式存储。首先，denom 用作键，值是代币合约。其次，合约用作键，值是代币合约代表的 denom。

| Key                                    | Value                  | Type     | Encoding              |
| -------------------------------------- | ---------------------- | -------- | --------------------- |
| `[]byte{0xf3} + []byte(denom)`         | Token contract address | `[]byte` | stored in byte format |
| `[]byte{0xf4} + []byte(tokenContract)` | Token denom            | `[]byte` | stored in byte format |

### LastObservedValset

此条目表示成功中继到 Ethereum 的最后观察到的 Valset。在 Biya Chain 上处理 `ValsetUpdatedEvent` 的证明后更新。

| Key            | Value                            | Type           | Encoding         |
| -------------- | -------------------------------- | -------------- | ---------------- |
| `[]byte{0xfa}` | Last observed Valset on Ethereum | `types.Valset` | Protobuf encoded |

### LastEventNonce

Ethereum 上最后观察到的事件的 nonce。在调用 `TryAttestation()` 时设置。此存储中始终只保存单个值。

| Key            | Value                     | Type     | Encoding           |
| -------------- | ------------------------- | -------- | ------------------ |
| `[]byte{0xf2}` | Last observed event nonce | `uint64` | Big endian encoded |

### LastObservedEthereumHeight

Ethereum 上最后观察到的事件的区块高度。此存储中始终只保存单个值。

| Key            | Value                         | Type     | Encoding         |
| -------------- | ----------------------------- | -------- | ---------------- |
| `[]byte{0xf9}` | Last observed Ethereum Height | `uint64` | Protobuf encoded |

### LastEventByValidator

这是来自特定 `Validator` 的 Ethereum 上最后观察到的事件。每次关联的 `Orchestrator` 发送事件声明时都会更新。

```go
type LastClaimEvent struct {
    EthereumEventNonce  uint64 
    EthereumEventHeight uint64 
}
```

| Key                                        | Value                                 | Type                   | Encoding         |
| ------------------------------------------ | ------------------------------------- | ---------------------- | ---------------- |
| `[]byte{0xf1} + []byte(validator address)` | Last observed event by some Validator | `types.LastClaimEvent` | Protobuf encoded |

### Attestation

Attestation 是声明的聚合，随着更多投票（声明）的到来，最终被所有编排器观察到。一旦被观察到，声明的特定逻辑就会被执行。

每个证明都绑定到一个唯一的事件 nonce（由 `Peggy contract` 生成），并且必须按顺序处理。这是一个正确性问题，如果乱序中继，交易重放攻击就会成为可能。

```go
type Attestation struct {
	Observed bool       
	Votes    []string   
	Height   uint64     
	Claim    *types.Any 
}
```

| Key                                                                  | Value                                 | Type                | Encoding         |
| -------------------------------------------------------------------- | ------------------------------------- | ------------------- | ---------------- |
| `[]byte{0x5} + event nonce (big endian encoded) + []byte(claimHash)` | Attestation of occurred events/claims | `types.Attestation` | Protobuf encoded |

### PastEthSignatureCheckpoint

一个计算出的哈希，表明验证者集/代币批次实际上存在于 Biya Chain 上。此检查点也存在于 `Peggy contract` 中。\
在每个新的 valset 更新和代币批次创建时更新。

| Key            | Value                                     | Type              | Encoding             |
| -------------- | ----------------------------------------- | ----------------- | -------------------- |
| `[]byte{0x1b}` | Last created checkpoint hash on Biya Chain | `gethcommon.Hash` | store in byte format |

### EthereumBlacklist

已知恶意 Ethereum 地址列表，这些地址被阻止使用桥接。

| Key                                       | Value               | Type              | Encoding               |
| ----------------------------------------- | ------------------- | ----------------- | ---------------------- |
| `[]byte{0x1c} + []byte(ethereum address)` | Empty \[]byte slice | `gethcommon.Hash` | stored in byte format] |
