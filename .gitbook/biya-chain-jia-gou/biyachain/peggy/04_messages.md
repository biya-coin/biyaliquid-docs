---
sidebar_position: 4
title: 消息
---

# 消息

这是 Peggy 消息类型的参考文档。有关代码参考和确切参数，请参见 [proto 定义](https://github.com/biya-coin/biyachain-core/blob/master/proto/biyachain/peggy/v1/msgs.proto)。

## 用户消息

这些是最终用户在 Biya Chain peggy 模块上发送的消息。有关整个存款和提取过程的更详细摘要，请参见[工作流程](02_workflow.md)。

### SendToEth

每当用户希望提取回 Ethereum 时发送到 Biya Chain。提交的金额会立即从用户余额中扣除。\
提取作为 `types.OutgoingTransferTx` 添加到传出交易池中，它将保留在那里，直到包含在批次中。

```go
type MsgSendToEth struct {
	Sender    string    // sender's Biya Chain address
	EthDest   string    // receiver's Ethereum address
	Amount    types.Coin    // amount of tokens to bridge
	BridgeFee types.Coin    // additional fee for bridge relayers. Must be of same token type as Amount
}

```

### CancelSendToEth

此消息允许用户取消尚未批处理的特定提取。用户余额将被退还（`Amount` + `BridgeFee`）。

```go
type MsgCancelSendToEth struct {
	TransactionId uint64    // unique tx nonce of the withdrawal
	Sender        string    // original sender of the withdrawal
}

```

### SubmitBadSignatureEvidence

此调用允许任何人提交证据，证明验证者已对从未存在的 valset 或批次进行签名。Subject 包含批次或 valset。

```go
type MsgSubmitBadSignatureEvidence struct {
	Subject   *types1.Any 
	Signature string      
	Sender    string      
}
```

## Batch Creator Messages

这些消息由 `peggo` 的 `Batch Creator` 子进程发送

### RequestBatch

当某个 `Batch Creator` 发现合并的提取在批处理后可以满足其最小批次费用（`PEGGO_MIN_BATCH_FEE_USD`）时发送此消息。\
收到此消息后，`Peggy module` 收集请求的代币 denom 的所有提取，创建唯一的代币批次（`types.OutgoingTxBatch`）并将其放置在 `Outgoing Batch pool` 中。\
已批处理的提取不能使用 `MsgCancelSendToEth` 取消。

```go
type MsgRequestBatch struct {
	Orchestrator string // orchestrator address interested in creating the batch. Not permissioned.  
	Denom        string // the specific token whose withdrawals will be batched together
}
```

## Oracle Messages

这些消息由 `peggo` 的 `Oracle` 子进程发送

### DepositClaim

当 `Peggy contract` 发出 `SendToBiyachainEvent` 时发送到 Biya Chain。\
每当用户从 Ethereum 向 Biya Chain 进行个人存款时都会发生这种情况。

```go
type MsgDepositClaim struct {
	EventNonce     uint64   // unique nonce of the event                                
	BlockHeight    uint64   // Ethereum block height at which the event was emitted                                
	TokenContract  string   // contract address of the ERC20 token                                 
	Amount         sdkmath.Int  // amount of deposited tokens 
	EthereumSender string   // sender's Ethereum address                                 
	CosmosReceiver string   // receiver's Biya Chain address                                 
	Orchestrator   string   // address of the Orchestrator which observed the event                               
}
```

### WithdrawClaim

当 `Peggy contract` 发出 `TransactionBatchExecutedEvent` 时发送到 Biya Chain。\
当 `Relayer` 成功调用合约上的 `submitBatch` 以完成一批提取时会发生这种情况。

```go
type MsgWithdrawClaim struct {
	EventNonce    uint64    // unique nonce of the event
	BlockHeight   uint64    // Ethereum block height at which the event was emitted
	BatchNonce    uint64    // nonce of the batch executed on Ethereum
	TokenContract string    // contract address of the ERC20 token
	Orchestrator  string    // address of the Orchestrator which observed the event
}
```

### ValsetUpdatedClaim

当 `Peggy contract` 发出 `ValsetUpdatedEvent` 时发送到 Biya Chain。\
当 `Relayer` 成功调用合约上的 `updateValset` 以更新 Ethereum 上的 `Validator Set` 时会发生这种情况。

```go

type MsgValsetUpdatedClaim struct {
	EventNonce   uint64 // unique nonce of the event                      
	ValsetNonce  uint64 // nonce of the valset                           
	BlockHeight  uint64 // Ethereum block height at which the event was emitted                           
	Members      []*BridgeValidator // members of the Validator Set               
	RewardAmount sdkmath.Int // Reward for relaying the valset update 
	RewardToken  string // reward token contract address                                 
	Orchestrator string // address of the Orchestrator which observed the event                                 
}
```

### ERC20DeployedClaim

当 `Peggy contract` 发出 `ERC20DeployedEvent` 时发送到 Biya Chain。\
每当在合约上调用 `deployERC20` 方法以发行符合桥接条件的新代币资产时都会发生这种情况。

```go
type MsgERC20DeployedClaim struct {
	EventNonce    uint64    // unique nonce of the event
	BlockHeight   uint64    // Ethereum block height at which the event was emitted
	CosmosDenom   string    // denom of the token
	TokenContract string    // contract address of the token
	Name          string    // name of the token
	Symbol        string    // symbol of the token
	Decimals      uint64    // number of decimals the token has
	Orchestrator  string    // address of the Orchestrator which observed the event
}
```

## Signer Messages

这些消息由 `peggo` 的 `Signer` 子进程发送

### ConfirmBatch

当 `Signer` 发现 `Orchestrator`（`Validator`）尚未签名的批次时，它使用其 `Delegated Ethereum Key` 构造签名并将确认发送到 Biya Chain。\
验证者最终必须为其创建的批次提供确认，否则将受到惩罚。

```go
type MsgConfirmBatch struct {
	Nonce         uint64    // nonce of the batch 
	TokenContract string    // contract address of batch token
	EthSigner     string    // Validator's delegated Ethereum address (previously registered)
	Orchestrator  string    // address of the Orchestrator confirming the batch
	Signature     string    // Validator's signature of the batch
}
```

### ValsetConfirm

当 `Signer` 发现 `Orchestrator`（`Validator`）尚未签名的 valset 更新时，它使用其 `Delegated Ethereum Key` 构造签名并将确认发送到 Biya Chain。\
验证者最终必须为其创建的 valset 更新提供确认，否则将受到惩罚。

```go
type MsgValsetConfirm struct {
	Nonce        uint64 // nonce of the valset 
	Orchestrator string // address of the Orchestrator confirming the valset
	EthAddress   string // Validator's delegated Ethereum address (previously registered)
	Signature    string // Validator's signature of the valset
}
```

## Relayer Messages

`Relayer` 不向 Biya Chain 发送任何消息，而是使用 Biya Chain 数据构造 Ethereum 交易，通过 `submitBatch` 和 `updateValset` 方法更新 `Peggy contract`。

## Validator Messages

这些是使用验证者的消息密钥直接发送的消息。

### SetOrchestratorAddresses

由管理 `Validator` 节点的 `Operator` 发送到 Biya Chain。在能够启动其 `Orchestrator`（`peggo`）进程之前，他们必须注册一个选定的 Ethereum 地址以在 Ethereum 上代表其 `Validator`。\
可选地，可以提供额外的 Biya Chain 地址（`Orchestrator` 字段）以在桥接过程（`peggo`）中代表该 `Validator`。如果省略，则默认为 `Validator` 自己的地址。

```go
type MsgSetOrchestratorAddresses struct {
	Sender       string // address of the Biya Chain validator
	Orchestrator string // optional Biya Chain address to represent the Validator in the bridging process (Defaults to Sender if left empty)
	EthAddress   string // the Sender's (Validator) delegated Ethereum address
}
```

此消息设置 Orchestrator 的委托密钥。
