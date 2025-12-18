---
sidebar_position: 1
---

# Feegrant

## 摘要

本文档指定了费用授权模块。完整的 ADR，请参见 [费用授权 ADR-029](https://github.com/cosmos/cosmos-sdk/blob/main/docs/architecture/adr-029-fee-grant-module.md)。

此模块允许账户授予费用授权并使用其账户的费用。被授权者可以执行任何交易，无需维持足够的费用。

## 概念

### 授权授予

`Grant` 存储在 KVStore 中以记录具有完整上下文的授权授予。每个授权授予将包含 `granter`、`grantee` 以及授予的 `allowance` 类型。`granter` 是授予 `grantee`（受益人账户地址）权限以支付 `grantee` 的部分或全部交易费用的账户地址。`allowance` 定义授予 `grantee` 的费用授权类型（`BasicAllowance` 或 `PeriodicAllowance`，见下文）。`allowance` 接受实现 `FeeAllowanceI` 的接口，编码为 `Any` 类型。对于 `grantee` 和 `granter`，只允许存在一个费用授权授予，不允许自我授权。

```protobuf
https://github.com/cosmos/cosmos-sdk/blob/v0.47.0-rc1/proto/cosmos/feegrant/v1beta1/feegrant.proto#L83-L93
```

`FeeAllowanceI` looks like:

```go
https://github.com/cosmos/cosmos-sdk/blob/v0.47.0-rc1/x/feegrant/fees.go#L9-L32
```

### 费用授权类型

目前存在三种费用授权类型：

* `BasicAllowance`
* `PeriodicAllowance`
* `AllowedMsgAllowance`

### BasicAllowance

`BasicAllowance` 是 `grantee` 使用 `granter` 账户费用的权限。如果 `spend_limit` 或 `expiration` 中的任何一个达到其限制，授权授予将从状态中移除。

```protobuf
https://github.com/cosmos/cosmos-sdk/blob/v0.47.0-rc1/proto/cosmos/feegrant/v1beta1/feegrant.proto#L15-L28
```

* `spend_limit` 是允许从 `granter` 账户使用的代币限制。如果为空，则假设没有支出限制，`grantee` 可以在过期前使用 `granter` 账户地址中的任何数量的可用代币。
* `expiration` 指定此授权过期的可选时间。如果值留空，则授权没有过期时间。
* 当使用 `spend_limit` 和 `expiration` 的空值创建授权授予时，它仍然是有效的授权授予。它不会限制 `grantee` 使用 `granter` 的任何数量的代币，也不会有任何过期时间。限制 `grantee` 的唯一方法是撤销授权授予。

### PeriodicAllowance

`PeriodicAllowance` 是指定周期的重复费用授权，我们可以指定授权何时过期以及周期何时重置。我们还可以定义在指定时间段内可以使用的最大代币数量。

```protobuf
https://github.com/cosmos/cosmos-sdk/blob/v0.47.0-rc1/proto/cosmos/feegrant/v1beta1/feegrant.proto#L34-L68
```

* `basic` 是 `BasicAllowance` 的实例，对于周期性费用授权是可选的。如果为空，授权将没有 `expiration` 和 `spend_limit`。
* `period` 是特定的时间段，每个周期过去后，`period_can_spend` 将被重置。
* `period_spend_limit` 指定在周期内可以花费的最大代币数量。
* `period_can_spend` 是在 period\_reset 时间之前剩余可花费的代币数量。
* `period_reset` 跟踪下一个周期重置应该发生的时间。

### AllowedMsgAllowance

`AllowedMsgAllowance` 是一种费用授权，它可以是 `BasicFeeAllowance`、`PeriodicAllowance` 中的任何一种，但仅限于授权者提到的允许消息。

```protobuf
https://github.com/cosmos/cosmos-sdk/blob/v0.47.0-rc1/proto/cosmos/feegrant/v1beta1/feegrant.proto#L70-L81
```

* `allowance` 是 `BasicAllowance` 或 `PeriodicAllowance`。
* `allowed_messages` 是允许执行给定授权的消息数组。

### FeeGranter 标志

`feegrant` 模块为 CLI 引入了 `FeeGranter` 标志，以便使用费用授权者执行交易。设置此标志后，`clientCtx` 将为通过 CLI 生成的交易附加授权者账户地址。

```go
https://github.com/cosmos/cosmos-sdk/blob/v0.47.0-rc1/client/cmd.go#L249-L260
```

```go
https://github.com/cosmos/cosmos-sdk/blob/v0.47.0-rc1/client/tx/tx.go#L109-L109
```

```go
https://github.com/cosmos/cosmos-sdk/blob/v0.47.0-rc1/x/auth/tx/builder.go#L275-L284
```

```protobuf
https://github.com/cosmos/cosmos-sdk/blob/v0.47.0-rc1/proto/cosmos/tx/v1beta1/tx.proto#L203-L224
```

示例命令：

```go
./simd tx gov submit-proposal --title="Test Proposal" --description="My awesome proposal" --type="Text" --from validator-key --fee-granter=cosmos1xh44hxt7spr67hqaa7nyx5gnutrz5fraw6grxn --chain-id=testnet --fees="10stake"
```

### 授权费用扣除

费用在 `x/auth` ante handler 中从授权授予中扣除。要了解更多关于 ante handler 的工作原理，请阅读 [Auth 模块 AnteHandlers 指南](auth.md#antehandlers)。

### Gas

为了防止 DoS 攻击，使用过滤的 `x/feegrant` 会产生 gas。SDK 必须确保 `grantee` 的交易都符合 `granter` 设置的过滤器。SDK 通过遍历过滤器中的允许消息并为每个过滤的消息收取 10 gas 来实现这一点。然后 SDK 将遍历 `grantee` 发送的消息，以确保消息遵守过滤器，每个消息也收取 10 gas。如果 SDK 发现不符合过滤器的消息，它将停止迭代并使交易失败。

**警告**：gas 从授予的授权中扣除。在使用您的授权发送交易之前，请确保您的消息符合过滤器（如果有）。

### 清理

状态中维护一个队列，使用授权授予的过期时间作为前缀，并在每个区块的 EndBlock 中使用当前区块时间检查它们以进行清理。

## 状态

### 费用授权

费用授权通过组合 `Grantee`（费用授权被授权者的账户地址）和 `Granter`（费用授权授权者的账户地址）来标识。

费用授权授予在状态中存储如下：

* Grant: `0x00 | grantee_addr_len (1 byte) | grantee_addr_bytes | granter_addr_len (1 byte) | granter_addr_bytes -> ProtocolBuffer(Grant)`

```go
https://github.com/cosmos/cosmos-sdk/blob/v0.47.0-rc1/x/feegrant/feegrant.pb.go#L222-L230
```

### 费用授权队列

费用授权队列项通过组合 `FeeAllowancePrefixQueue`（即 0x01）、`expiration`、`grantee`（费用授权被授权者的账户地址）、`granter`（费用授权授权者的账户地址）来标识。Endblocker 检查 `FeeAllowanceQueue` 状态中的过期授权授予，如果找到任何，则从 `FeeAllowance` 中清理它们。

费用授权队列键在状态中存储如下：

* Grant: `0x01 | expiration_bytes | grantee_addr_len (1 byte) | grantee_addr_bytes | granter_addr_len (1 byte) | granter_addr_bytes -> EmptyBytes`

## 消息

### Msg/GrantAllowance

费用授权授予将使用 `MsgGrantAllowance` 消息创建。

```protobuf
https://github.com/cosmos/cosmos-sdk/blob/v0.47.0-rc1/proto/cosmos/feegrant/v1beta1/tx.proto#L25-L39
```

### Msg/RevokeAllowance

允许的费用授权授予可以使用 `MsgRevokeAllowance` 消息移除。

```protobuf
https://github.com/cosmos/cosmos-sdk/blob/v0.47.0-rc1/proto/cosmos/feegrant/v1beta1/tx.proto#L41-L54
```

## 事件

feegrant 模块发出以下事件：

## 消息服务器

### MsgGrantAllowance

| 类型    | 属性键   | 属性值          |
| ------- | -------- | --------------- |
| message | action   | set\_feegrant    |
| message | granter  | {granterAddress} |
| message | grantee  | {granteeAddress} |

### MsgRevokeAllowance

| 类型    | 属性键   | 属性值            |
| ------- | -------- | ----------------- |
| message | action   | revoke\_feegrant  |
| message | granter  | {granterAddress}  |
| message | grantee  | {granteeAddress}  |

### 执行费用授权

| 类型    | 属性键   | 属性值          |
| ------- | -------- | --------------- |
| message | action   | use\_feegrant    |
| message | granter  | {granterAddress} |
| message | grantee  | {granteeAddress} |

### 清理费用授权

| 类型    | 属性键   | 属性值          |
| ------- | -------- | --------------- |
| message | action   | prune\_feegrant |
| message | pruner   | {prunerAddress} |

## 客户端

### CLI

用户可以使用 CLI 查询和与 `feegrant` 模块交互。

#### 查询

`query` 命令允许用户查询 `feegrant` 状态。

```shell
simd query feegrant --help
```

**grant**

`grant` 命令允许用户查询给定授权者-被授权者对的授权授予。

```shell
simd query feegrant grant [granter] [grantee] [flags]
```

示例：

```shell
simd query feegrant grant cosmos1.. cosmos1..
```

示例输出：

```yml
allowance:
  '@type': /cosmos.feegrant.v1beta1.BasicAllowance
  expiration: null
  spend_limit:
  - amount: "100"
    denom: stake
grantee: cosmos1..
granter: cosmos1..
```

**grants**

`grants` 命令允许用户查询给定被授权者的所有授权授予。

```shell
simd query feegrant grants [grantee] [flags]
```

示例：

```shell
simd query feegrant grants cosmos1..
```

示例输出：

```yml
allowances:
- allowance:
    '@type': /cosmos.feegrant.v1beta1.BasicAllowance
    expiration: null
    spend_limit:
    - amount: "100"
      denom: stake
  grantee: cosmos1..
  granter: cosmos1..
pagination:
  next_key: null
  total: "0"
```

#### 交易

`tx` 命令允许用户与 `feegrant` 模块交互。

```shell
simd tx feegrant --help
```

**grant**

`grant` 命令允许用户向另一个账户授予费用授权。费用授权可以有过期日期、总支出限制和/或周期性支出限制。

```shell
simd tx feegrant grant [granter] [grantee] [flags]
```

示例（一次性支出限制）：

```shell
simd tx feegrant grant cosmos1.. cosmos1.. --spend-limit 100stake
```

示例（周期性支出限制）：

```shell
simd tx feegrant grant cosmos1.. cosmos1.. --period 3600 --period-limit 10stake
```

**revoke**

`revoke` 命令允许用户撤销已授予的费用授权。

```shell
simd tx feegrant revoke [granter] [grantee] [flags]
```

示例：

```shell
simd tx feegrant revoke cosmos1.. cosmos1..
```

### gRPC

用户可以使用 gRPC 端点查询 `feegrant` 模块。

#### Allowance

`Allowance` 端点允许用户查询已授予的费用授权。

```shell
cosmos.feegrant.v1beta1.Query/Allowance
```

示例：

```shell
grpcurl -plaintext \
    -d '{"grantee":"cosmos1..","granter":"cosmos1.."}' \
    localhost:9090 \
    cosmos.feegrant.v1beta1.Query/Allowance
```

示例输出：

```json
{
  "allowance": {
    "granter": "cosmos1..",
    "grantee": "cosmos1..",
    "allowance": {"@type":"/cosmos.feegrant.v1beta1.BasicAllowance","spendLimit":[{"denom":"stake","amount":"100"}]}
  }
}
```

#### Allowances

`Allowances` 端点允许用户查询给定被授权者的所有已授予费用授权。

```shell
cosmos.feegrant.v1beta1.Query/Allowances
```

示例：

```shell
grpcurl -plaintext \
    -d '{"address":"cosmos1.."}' \
    localhost:9090 \
    cosmos.feegrant.v1beta1.Query/Allowances
```

示例输出：

```json
{
  "allowances": [
    {
      "granter": "cosmos1..",
      "grantee": "cosmos1..",
      "allowance": {"@type":"/cosmos.feegrant.v1beta1.BasicAllowance","spendLimit":[{"denom":"stake","amount":"100"}]}
    }
  ],
  "pagination": {
    "total": "1"
  }
}
```
