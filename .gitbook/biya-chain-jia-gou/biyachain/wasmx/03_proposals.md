---
sidebar_position: 3
title: 治理提案
---

## 治理提案

### ContractRegistrationRequest

`ContractRegistrationRequest` 是注册新合约的基础消息（不应直接使用，而应作为提案的一部分）

```go
type ContractRegistrationRequest struct {
	ContractAddress string 
	GasLimit uint64 
	GasPrice    uint64 
	PinContract bool   
	AllowUpdating bool
	CodeId uint64
    ContractAdmin string 
	GranterAddress string
	FundMode FundingMode
}
```

**字段描述**

- `ContractAddress` - 要注册的合约实例的唯一标识符。
- `GasLimit` - 智能合约执行要使用的最大 gas。
- `GasPrice` - 智能合约执行要使用的 gas 价格。
- `PinContract` - 合约是否应该被固定。
- `AllowUpdating` - 定义合约所有者是否可以在不需要重新注册的情况下迁移它（如果为 false，则只允许执行当前的 code_id）
- `CodeId` - 正在注册的合约的 code_id - 将在执行时进行验证，以允许最后一刻的更改（在投票后）
- `AdminAddress` - 管理员账户的可选地址（将被允许暂停或更新合约参数）
- `GranterAddress` - 为执行提供资金的账户地址。如果 `FundMode` 不是 `SelfFunded`，则必须设置（见下面的说明）

`FundingMode` 指示合约将如何为其自己的执行提供资金。

```go
enum FundingMode {
    Unspecified = 0;
    SelfFunded = 1;
    GrantOnly = 2; 
    Dual = 3;      
}
```

- `SelfFunded` - 合约将使用自己的资金执行。
- `GrantOnly` - 合约将仅使用授权提供的资金。
- `Dual` - 合约将首先耗尽授权的资金，然后再使用自己的资金。

### ContractRegistrationRequestProposal

`ContractRegistrationRequestProposal` 定义了一个 SDK 消息，用于在 wasmx 合约注册表中注册单个合约。

```go
type ContractRegistrationRequestProposal struct {
    Title                       string                      
    Description                 string                      
    ContractRegistrationRequest ContractRegistrationRequest 
}
```

**字段描述**

- `Title` - 描述提案的标题。
- `Description` - 描述提案的描述。
- `ContractRegistrationRequest` - 包含合约注册请求（如上所述）




### BatchContractRegistrationRequestProposal

`BatchContractRegistrationRequestProposal` 定义了一个 SDK 消息，用于在 wasmx 合约注册表中注册一批合约。

```go
type BatchContractRegistrationRequestProposal struct {
    Title                       string                      
    Description                 string
	ContractRegistrationRequests  []ContractRegistrationRequest 
}
```

**字段描述**

- `Title` - 描述提案的标题。
- `Description` - 描述提案的描述。
- `ContractRegistrationRequests` - 包含合约注册请求列表（如上所述）


### BatchStoreCodeProposal

`BatchStoreCodeProposal` 定义了一个 SDK 消息，用于在 wasm 中存储一批合约。

```go
type BatchStoreCodeProposal struct {
    Title                       string                      
    Description                 string
	Proposals   []types.StoreCodeProposal
}
```

**字段描述**

- `Title` - 描述提案的标题。
- `Description` - 描述提案的描述。
- `Proposals` - 包含存储代码提案列表（由 Cosmos wasm 模块定义）


### BatchContractDeregistrationProposal

`BatchContractDeregistrationProposal` 定义了一个 SDK 消息，用于在 wasm 中注销一批合约。

```go
type BatchContractDeregistrationProposal struct {
    Title                       string                      
    Description                 string
	Contracts   []string 
}
```

**字段描述**

- `Title` - 描述提案的标题。
- `Description` - 描述提案的描述。
- `Contracts` - 包含要注销的合约地址列表



