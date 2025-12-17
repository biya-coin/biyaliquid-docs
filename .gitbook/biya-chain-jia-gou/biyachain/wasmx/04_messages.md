---
sidebar_position: 4
title: 消息
---

# 消息

## MsgUpdateContract

更新已注册合约的执行参数（gas 价格、限制）。也可以定义新的管理员账户。\
只能由管理员（如果已定义）或合约本身调用。

```go

type MsgUpdateContract struct {
    Sender string `json:"sender,omitempty"`
    // Unique Identifier for contract instance to be registered.
    ContractAddress string `json:"contract_address,omitempty"`
    // Maximum gas to be used for the smart contract execution.
    GasLimit uint64 `json:"gas_limit,omitempty"`
    // gas price to be used for the smart contract execution.
    GasPrice uint64 `json:"gas_price,omitempty"`
    // optional - admin account that will be allowed to perform any changes
    AdminAddress string `json:"admin_address,omitempty"`
}
```

## MsgDeactivateContract

停用已注册的合约（它将不再在 begin blocker 中执行）

```go

type MsgDeactivateContract struct {
    Sender string `json:"sender,omitempty"`
    // Unique Identifier for contract instance to be activated.
    ContractAddress string `json:"contract_address,omitempty"`
}
```

## MsgActivateContract

重新激活已注册的合约（从现在开始它将再次在 begin blocker 中执行）

```go

type MsgActivateContract struct {
    Sender string `json:"sender,omitempty"`
    // Unique Identifier for contract instance to be activated.
    ContractAddress string `json:"contract_address,omitempty"`
}
```

## MsgExecuteContract

调用智能合约内定义的函数。函数和参数编码在 `ExecuteMsg` 中，这是一个 Base64 编码的 JSON 消息。

```go
type MsgExecuteContract struct {
    Sender     sdk.AccAddress   `json:"sender" yaml:"sender"`
    Contract   sdk.AccAddress   `json:"contract" yaml:"contract"`
    ExecuteMsg core.Base64Bytes `json:"execute_msg" yaml:"execute_msg"`
    Coins      sdk.Coins        `json:"coins" yaml:"coins"`
}
```

## MsgMigrateContract

可由可迁移智能合约的所有者发出，以将其代码 ID 重置为另一个。`MigrateMsg` 是一个 Base64 编码的 JSON 消息。

```go
type MsgMigrateContract struct {
    Owner      sdk.AccAddress   `json:"owner" yaml:"owner"`
    Contract   sdk.AccAddress   `json:"contract" yaml:"contract"`
    NewCodeID  uint64           `json:"new_code_id" yaml:"new_code_id"`
    MigrateMsg core.Base64Bytes `json:"migrate_msg" yaml:"migrate_msg"`
}
```

## MsgUpdateContractOwner

可由智能合约的所有者发出以转移所有权。

```go
type MsgUpdateContractOwner struct {
    Owner    sdk.AccAddress `json:"owner" yaml:"owner"`
    NewOwner sdk.AccAddress `json:"new_owner" yaml:"new_owner"`
    Contract sdk.AccAddress `json:"contract" yaml:"contract"`
}
```
