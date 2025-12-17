<!--
order: 4
-->

# 交易

本节定义了 `sdk.Msg` 具体类型，这些类型导致上一节中定义的状态转换。

## `MsgEthereumTx`

可以通过使用 `MsgEthereumTx` 实现 EVM 状态转换。此消息将以太坊交易数据（`TxData`）封装为 `sdk.Msg`。它包含必要的交易数据字段。请注意，`MsgEthereumTx` 同时实现了 [`sdk.Msg`](https://github.com/cosmos/cosmos-sdk/blob/v0.39.2/types/tx_msg.go#L7-L29) 和 [`sdk.Tx`](https://github.com/cosmos/cosmos-sdk/blob/v0.39.2/types/tx_msg.go#L33-L41) 接口。通常，SDK 消息只实现前者，而后者是一组捆绑在一起的消息。

```go
type MsgEthereumTx struct {
 // inner transaction data
 Data *types.Any `protobuf:"bytes,1,opt,name=data,proto3" json:"data,omitempty"`
 // DEPRECATED: encoded storage size of the transaction
 Size_ float64 `protobuf:"fixed64,2,opt,name=size,proto3" json:"-"`
 // transaction hash in hex format
 Hash string `protobuf:"bytes,3,opt,name=hash,proto3" json:"hash,omitempty" rlp:"-"`
 // ethereum signer address in hex format. This address value is checked
 // against the address derived from the signature (V, R, S) using the
 // secp256k1 elliptic curve
 From string `protobuf:"bytes,4,opt,name=from,proto3" json:"from,omitempty"`
}
```

如果满足以下条件，此消息字段验证将失败：

- `From` 字段已定义且地址无效
- `TxData` 无状态验证失败

如果满足以下条件，交易执行将失败：

- 任何自定义 `AnteHandler` 以太坊装饰器检查失败：
    - 交易的最低 gas 数量要求
    - 交易发送者账户不存在或没有足够的余额支付费用
    - 账户序列与交易 `Data.AccountNonce` 不匹配
    - 消息签名验证失败
- EVM 合约创建（即 `evm.Create`）失败，或 `evm.Call` 失败

### 转换

`MsgEthereumTx` 可以转换为 go-ethereum `Transaction` 和 `Message` 类型，以便创建和调用 evm 合约。

```go
// AsTransaction creates an Ethereum Transaction type from the msg fields
func (msg MsgEthereumTx) AsTransaction() *ethtypes.Transaction {
 txData, err := UnpackTxData(msg.Data)
 if err != nil {
  return nil
 }

 return ethtypes.NewTx(txData.AsEthereumData())
}

// AsMessage returns the transaction as a core.Message.
func (tx *Transaction) AsMessage(s Signer, baseFee *big.Int) (Message, error) {
 msg := Message{
  nonce:      tx.Nonce(),
  gasLimit:   tx.Gas(),
  gasPrice:   new(big.Int).Set(tx.GasPrice()),
  gasFeeCap:  new(big.Int).Set(tx.GasFeeCap()),
  gasTipCap:  new(big.Int).Set(tx.GasTipCap()),
  to:         tx.To(),
  amount:     tx.Value(),
  data:       tx.Data(),
  accessList: tx.AccessList(),
  isFake:     false,
 }
 // If baseFee provided, set gasPrice to effectiveGasPrice.
 if baseFee != nil {
  msg.gasPrice = math.BigMin(msg.gasPrice.Add(msg.gasTipCap, baseFee), msg.gasFeeCap)
 }
 var err error
 msg.from, err = Sender(s, tx)
 return msg, err
}
```

### 签名

为了使签名验证有效，`TxData` 必须包含来自 `Signer` 的 `v | r | s` 值。Sign 计算 secp256k1 ECDSA 签名并对交易进行签名。它接受密钥环签名者和 chainID，根据 EIP155 标准对以太坊交易进行签名。此方法会改变交易，因为它填充交易签名的 V、R、S 字段。如果消息的发送者地址未定义或发送者未在密钥环上注册，此函数将失败。

```go
// Sign calculates a secp256k1 ECDSA signature and signs the transaction. It
// takes a keyring signer and the chainID to sign an Ethereum transaction according to
// EIP155 standard.
// This method mutates the transaction as it populates the V, R, S
// fields of the Transaction's Signature.
// The function will fail if the sender address is not defined for the msg or if
// the sender is not registered on the keyring
func (msg *MsgEthereumTx) Sign(ethSigner ethtypes.Signer, keyringSigner keyring.Signer) error {
 from := msg.GetFrom()
 if from.Empty() {
  return fmt.Errorf("sender address not defined for message")
 }

 tx := msg.AsTransaction()
 txHash := ethSigner.Hash(tx)

 sig, _, err := keyringSigner.SignByAddress(from, txHash.Bytes())
 if err != nil {
  return err
 }

 tx, err = tx.WithSignature(ethSigner, sig)
 if err != nil {
  return err
 }

 msg.FromEthereumTx(tx)
 return nil
}
```

## TxData

`MsgEthereumTx` 支持来自 go-ethereum 的 3 种有效以太坊交易数据类型：`LegacyTx`、`AccessListTx` 和 `DynamicFeeTx`。这些类型定义为 protobuf 消息，并打包到 `MsgEthereumTx` 字段中的 `proto.Any` 接口类型。

- `LegacyTx`：[EIP-155](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-155.md) 交易类型
- `DynamicFeeTx`：[EIP-1559](https://eips.ethereum.org/EIPS/eip-1559) 交易类型。由 London 硬分叉区块启用
- `AccessListTx`：[EIP-2930](https://eips.ethereum.org/EIPS/eip-2930) 交易类型。由 Berlin 硬分叉区块启用

### `LegacyTx`

常规以太坊交易的交易数据。

```go
type LegacyTx struct {
 // nonce corresponds to the account nonce (transaction sequence).
 Nonce uint64 `protobuf:"varint,1,opt,name=nonce,proto3" json:"nonce,omitempty"`
 // gas price defines the value for each gas unit
 GasPrice *github_com_cosmos_cosmos_sdk_types.Int `protobuf:"bytes,2,opt,name=gas_price,json=gasPrice,proto3,customtype=github.com/cosmos/cosmos-sdk/types.Int" json:"gas_price,omitempty"`
 // gas defines the gas limit defined for the transaction.
 GasLimit uint64 `protobuf:"varint,3,opt,name=gas,proto3" json:"gas,omitempty"`
 // hex formatted address of the recipient
 To string `protobuf:"bytes,4,opt,name=to,proto3" json:"to,omitempty"`
 // value defines the unsigned integer value of the transaction amount.
 Amount *github_com_cosmos_cosmos_sdk_types.Int `protobuf:"bytes,5,opt,name=value,proto3,customtype=github.com/cosmos/cosmos-sdk/types.Int" json:"value,omitempty"`
 // input defines the data payload bytes of the transaction.
 Data []byte `protobuf:"bytes,6,opt,name=data,proto3" json:"data,omitempty"`
 // v defines the signature value
 V []byte `protobuf:"bytes,7,opt,name=v,proto3" json:"v,omitempty"`
 // r defines the signature value
 R []byte `protobuf:"bytes,8,opt,name=r,proto3" json:"r,omitempty"`
 // s define the signature value
 S []byte `protobuf:"bytes,9,opt,name=s,proto3" json:"s,omitempty"`
}
```

如果满足以下条件，此消息字段验证将失败：

- `GasPrice` 无效（`nil`、负数或超出 int256 范围）
- `Fee`（gasprice * gaslimit）无效
- `Amount` 无效（负数或超出 int256 范围）
- `To` 地址无效（非有效的以太坊十六进制地址）

### `DynamicFeeTx`

EIP-1559 动态费用交易的交易数据。

```go
type DynamicFeeTx struct {
 // destination EVM chain ID
 ChainID *github_com_cosmos_cosmos_sdk_types.Int `protobuf:"bytes,1,opt,name=chain_id,json=chainId,proto3,customtype=github.com/cosmos/cosmos-sdk/types.Int" json:"chainID"`
 // nonce corresponds to the account nonce (transaction sequence).
 Nonce uint64 `protobuf:"varint,2,opt,name=nonce,proto3" json:"nonce,omitempty"`
 // gas tip cap defines the max value for the gas tip
 GasTipCap *github_com_cosmos_cosmos_sdk_types.Int `protobuf:"bytes,3,opt,name=gas_tip_cap,json=gasTipCap,proto3,customtype=github.com/cosmos/cosmos-sdk/types.Int" json:"gas_tip_cap,omitempty"`
 // gas fee cap defines the max value for the gas fee
 GasFeeCap *github_com_cosmos_cosmos_sdk_types.Int `protobuf:"bytes,4,opt,name=gas_fee_cap,json=gasFeeCap,proto3,customtype=github.com/cosmos/cosmos-sdk/types.Int" json:"gas_fee_cap,omitempty"`
 // gas defines the gas limit defined for the transaction.
 GasLimit uint64 `protobuf:"varint,5,opt,name=gas,proto3" json:"gas,omitempty"`
 // hex formatted address of the recipient
 To string `protobuf:"bytes,6,opt,name=to,proto3" json:"to,omitempty"`
 // value defines the the transaction amount.
 Amount *github_com_cosmos_cosmos_sdk_types.Int `protobuf:"bytes,7,opt,name=value,proto3,customtype=github.com/cosmos/cosmos-sdk/types.Int" json:"value,omitempty"`
 // input defines the data payload bytes of the transaction.
 Data     []byte     `protobuf:"bytes,8,opt,name=data,proto3" json:"data,omitempty"`
 Accesses AccessList `protobuf:"bytes,9,rep,name=accesses,proto3,castrepeated=AccessList" json:"accessList"`
 // v defines the signature value
 V []byte `protobuf:"bytes,10,opt,name=v,proto3" json:"v,omitempty"`
 // r defines the signature value
 R []byte `protobuf:"bytes,11,opt,name=r,proto3" json:"r,omitempty"`
 // s define the signature value
 S []byte `protobuf:"bytes,12,opt,name=s,proto3" json:"s,omitempty"`
}
```

如果满足以下条件，此消息字段验证将失败：

- `GasTipCap` 无效（`nil`、负数或溢出 int256）
- `GasFeeCap` 无效（`nil`、负数或溢出 int256）
- `GasFeeCap` 小于 `GasTipCap`
- `Fee`（gas price * gas limit）无效（溢出 int256）
- `Amount` 无效（负数或溢出 int256）
- `To` 地址无效（非有效的以太坊十六进制地址）
- `ChainID` 为 `nil`

### `AccessListTx`

EIP-2930 访问列表交易的交易数据。

```go
type AccessListTx struct {
 // destination EVM chain ID
 ChainID *github_com_cosmos_cosmos_sdk_types.Int `protobuf:"bytes,1,opt,name=chain_id,json=chainId,proto3,customtype=github.com/cosmos/cosmos-sdk/types.Int" json:"chainID"`
 // nonce corresponds to the account nonce (transaction sequence).
 Nonce uint64 `protobuf:"varint,2,opt,name=nonce,proto3" json:"nonce,omitempty"`
 // gas price defines the value for each gas unit
 GasPrice *github_com_cosmos_cosmos_sdk_types.Int `protobuf:"bytes,3,opt,name=gas_price,json=gasPrice,proto3,customtype=github.com/cosmos/cosmos-sdk/types.Int" json:"gas_price,omitempty"`
 // gas defines the gas limit defined for the transaction.
 GasLimit uint64 `protobuf:"varint,4,opt,name=gas,proto3" json:"gas,omitempty"`
 // hex formatted address of the recipient
 To string `protobuf:"bytes,5,opt,name=to,proto3" json:"to,omitempty"`
 // value defines the unsigned integer value of the transaction amount.
 Amount *github_com_cosmos_cosmos_sdk_types.Int `protobuf:"bytes,6,opt,name=value,proto3,customtype=github.com/cosmos/cosmos-sdk/types.Int" json:"value,omitempty"`
 // input defines the data payload bytes of the transaction.
 Data     []byte     `protobuf:"bytes,7,opt,name=data,proto3" json:"data,omitempty"`
 Accesses AccessList `protobuf:"bytes,8,rep,name=accesses,proto3,castrepeated=AccessList" json:"accessList"`
 // v defines the signature value
 V []byte `protobuf:"bytes,9,opt,name=v,proto3" json:"v,omitempty"`
 // r defines the signature value
 R []byte `protobuf:"bytes,10,opt,name=r,proto3" json:"r,omitempty"`
 // s define the signature value
 S []byte `protobuf:"bytes,11,opt,name=s,proto3" json:"s,omitempty"`
}
```

如果满足以下条件，此消息字段验证将失败：

- `GasPrice` 无效（`nil`、负数或溢出 int256）
- `Fee`（gas price * gas limit）无效（溢出 int256）
- `Amount` 无效（负数或溢出 int256）
- `To` 地址无效（非有效的以太坊十六进制地址）
- `ChainID` 为 `nil`
