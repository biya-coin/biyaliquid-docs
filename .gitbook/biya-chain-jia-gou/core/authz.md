---
sidebar_position: 1
---

# AuthZ

## 摘要

`x/authz` 是 Cosmos SDK 模块的实现，根据 [ADR 30](https://github.com/cosmos/cosmos-sdk/blob/main/docs/architecture/adr-030-authz-module.md)，它允许\
从一个账户（授权者）向另一个账户（被授权者）授予任意权限。必须使用 `Authorization` 接口的实现逐个为特定的 Msg 服务方法授予授权。

## 目录

* [概念](authz.md#concepts)
  * [授权和授权授予](authz.md#authorization-and-grant)
  * [内置授权](authz.md#built-in-authorizations)
  * [Gas](authz.md#gas)
* [状态](authz.md#state)
  * [授权授予](authz.md#grant)
  * [授权队列](authz.md#grantqueue)
* [消息](authz.md#messages)
  * [MsgGrant](authz.md#msggrant)
  * [MsgRevoke](authz.md#msgrevoke)
  * [MsgExec](authz.md#msgexec)
* [事件](authz.md#events)
* [客户端](authz.md#client)
  * [CLI](authz.md#cli)
  * [gRPC](authz.md#grpc)
  * [REST](authz.md#rest)

## 概念

### 授权和授权授予

`x/authz` 模块定义接口和消息，授予代表一个账户向其他账户执行操作的授权。\
该设计在 [ADR 030](https://github.com/cosmos/cosmos-sdk/blob/main/docs/architecture/adr-030-authz-module.md) 中定义。

授权授予（grant）是被授权者代表授权者执行 Msg 的许可。\
授权是一个接口，必须由具体的授权逻辑实现以验证和执行授权授予。授权是可扩展的，可以为任何 Msg 服务方法定义，甚至可以在定义 Msg 方法的模块之外定义。有关更多详细信息，请参见下一节中的 `SendAuthorization` 示例。

**注意：** authz 模块不同于负责指定基础交易和账户类型的 [auth（身份验证）](auth.md) 模块。

```go
https://github.com/cosmos/cosmos-sdk/blob/v0.47.0-rc1/x/authz/authorizations.go#L11-L25
```

### 内置授权

Cosmos SDK `x/authz` 模块附带以下授权类型：

#### GenericAuthorization

`GenericAuthorization` 实现 `Authorization` 接口，授予代表授权者账户执行提供的 Msg 的无限制权限。

```protobuf
https://github.com/cosmos/cosmos-sdk/blob/v0.47.0-rc1/proto/cosmos/authz/v1beta1/authz.proto#L14-L22
```

```go
https://github.com/cosmos/cosmos-sdk/blob/v0.47.0-rc1/x/authz/generic_authorization.go#L16-L29
```

* `msg` 存储 Msg 类型 URL。

#### SendAuthorization

`SendAuthorization` 为 `cosmos.bank.v1beta1.MsgSend` Msg 实现 `Authorization` 接口。

* 它接受一个（正数）`SpendLimit`，指定被授权者可以花费的最大代币数量。`SpendLimit` 会随着代币的消费而更新。
* 它接受一个（可选的）`AllowList`，指定被授权者可以向哪些地址发送代币。

```protobuf
https://github.com/cosmos/cosmos-sdk/blob/v0.47.0-rc1/proto/cosmos/bank/v1beta1/authz.proto#L11-L30
```

```go
https://github.com/cosmos/cosmos-sdk/blob/v0.47.0-rc1/x/bank/types/send_authorization.go#L29-L62
```

* `spend_limit` 跟踪授权中剩余多少代币。
* `allow_list` 指定被授权者可以代表授权者向其发送代币的可选地址列表。

#### StakeAuthorization

`StakeAuthorization` 为 [staking 模块](https://docs.cosmos.network/v0.50/build/modules/staking) 中的消息实现 `Authorization` 接口。它接受一个 `AuthorizationType` 来指定您是要授权委托、取消委托还是重新委托（即这些必须分别授权）。它还接受一个可选的 `MaxTokens`，跟踪可以委托/取消委托/重新委托的代币数量限制。如果留空，则数量不受限制。此外，此 Msg 接受 `AllowList` 或 `DenyList`，允许您选择允许或拒绝被授权者与之质押的验证者。

```protobuf
https://github.com/cosmos/cosmos-sdk/blob/v0.47.0-rc1/proto/cosmos/staking/v1beta1/authz.proto#L11-L35
```

```go
https://github.com/cosmos/cosmos-sdk/blob/v0.47.0-rc1/x/staking/types/authz.go#L15-L35
```

### Gas

为了防止 DoS 攻击，使用 `x/authz` 授予 `StakeAuthorization` 会产生 gas。`StakeAuthorization` 允许您授权另一个账户向验证者委托、取消委托或重新委托。授权者可以定义他们允许或拒绝委托的验证者列表。Cosmos SDK 遍历这些列表，并为两个列表中的每个验证者收取 10 gas。

由于状态维护具有相同过期时间的授权者、被授权者对列表，我们遍历列表以从列表中移除授权授予（以防撤销特定 `msgType`），每次迭代收取 20 gas。

## 状态

### 授权授予

授权授予通过组合授权者地址（授权者的地址字节）、被授权者地址（被授权者的地址字节）和授权类型（其类型 URL）来标识。因此，我们只允许（授权者、被授权者、授权）三元组有一个授权授予。

* Grant: `0x01 | granter_address_len (1 byte) | granter_address_bytes | grantee_address_len (1 byte) | grantee_address_bytes | msgType_bytes -> ProtocolBuffer(AuthorizationGrant)`

授权授予对象封装了一个 `Authorization` 类型和一个过期时间戳：

```protobuf
https://github.com/cosmos/cosmos-sdk/blob/v0.47.0-rc1/proto/cosmos/authz/v1beta1/authz.proto#L24-L32
```

### 授权队列

我们维护一个用于 authz 清理的队列。每当创建授权授予时，将向 `GrantQueue` 添加一个项目，键为过期时间、授权者、被授权者。

在 `EndBlock`（每个区块运行）中，我们通过使用当前区块时间形成前缀键（该时间已超过 `GrantQueue` 中存储的过期时间）来持续检查和清理过期的授权授予，我们遍历 `GrantQueue` 中的所有匹配记录，并从 `GrantQueue` 和 `Grant` 存储中删除它们。

```go
https://github.com/cosmos/cosmos-sdk/blob/5f4ddc6f80f9707320eec42182184207fff3833a/x/authz/keeper/keeper.go#L378-L403
```

* GrantQueue: `0x02 | expiration_bytes | granter_address_len (1 byte) | granter_address_bytes | grantee_address_len (1 byte) | grantee_address_bytes -> ProtocalBuffer(GrantQueueItem)`

`expiration_bytes` 是 UTC 格式的过期日期，格式为 `"2006-01-02T15:04:05.000000000"`。

```go
https://github.com/cosmos/cosmos-sdk/blob/v0.47.0-rc1/x/authz/keeper/keys.go#L77-L93
```

`GrantQueueItem` 对象包含授权者和被授权者之间在键中指示的时间过期的类型 URL 列表。

## 消息

在本节中，我们描述 authz 模块的消息处理。

### MsgGrant

使用 `MsgGrant` 消息创建授权授予。\
如果 `(granter, grantee, Authorization)` 三元组已存在授权授予，则新授权授予将覆盖前一个。要更新或扩展现有授权授予，应创建具有相同 `(granter, grantee, Authorization)` 三元组的新授权授予。

```protobuf
https://github.com/cosmos/cosmos-sdk/blob/v0.47.0-rc1/proto/cosmos/authz/v1beta1/tx.proto#L35-L45
```

如果出现以下情况，消息处理应失败：

* 授权者和被授权者具有相同的地址。
* 提供的 `Expiration` 时间小于当前 unix 时间戳（但如果未提供 `expiration` 时间，将创建授权授予，因为 `expiration` 是可选的）。
* 提供的 `Grant.Authorization` 未实现。
* `Authorization.MsgTypeURL()` 未在路由器中定义（应用路由器中没有定义的处理程序来处理该 Msg 类型）。

### MsgRevoke

可以使用 `MsgRevoke` 消息移除授权授予。

```protobuf
https://github.com/cosmos/cosmos-sdk/blob/v0.47.0-rc1/proto/cosmos/authz/v1beta1/tx.proto#L69-L78
```

如果出现以下情况，消息处理应失败：

* 授权者和被授权者具有相同的地址。
* 提供的 `MsgTypeUrl` 为空。

注意：如果授权授予已过期，`MsgExec` 消息会移除授权授予。

### MsgExec

当被授权者想要代表授权者执行交易时，他们必须发送 `MsgExec`。

```protobuf
https://github.com/cosmos/cosmos-sdk/blob/v0.47.0-rc1/proto/cosmos/authz/v1beta1/tx.proto#L52-L63
```

如果出现以下情况，消息处理应失败：

* 提供的 `Authorization` 未实现。
* 被授权者没有运行交易的权限。
* 如果授予的授权已过期。

## 事件

authz 模块发出在 [Protobuf 参考](https://buf.build/cosmos/cosmos-sdk/docs/main/cosmos.authz.v1beta1#cosmos.authz.v1beta1.EventGrant) 中定义的 proto 事件。

## 客户端

### CLI

用户可以使用 CLI 查询和与 `authz` 模块交互。

#### 查询

`query` 命令允许用户查询 `authz` 状态。

```bash
simd query authz --help
```

**grants**

`grants` 命令允许用户查询授权者-被授权者对的授权授予。如果设置了消息类型 URL，它仅选择该消息类型的授权授予。

```bash
simd query authz grants [granter-addr] [grantee-addr] [msg-type-url]? [flags]
```

示例：

```bash
simd query authz grants cosmos1.. cosmos1.. /cosmos.bank.v1beta1.MsgSend
```

示例输出：

```bash
grants:
- authorization:
    '@type': /cosmos.bank.v1beta1.SendAuthorization
    spend_limit:
    - amount: "100"
      denom: stake
  expiration: "2022-01-01T00:00:00Z"
pagination: null
```

#### 交易

`tx` 命令允许用户与 `authz` 模块交互。

```bash
simd tx authz --help
```

**exec**

`exec` 命令允许被授权者代表授权者执行交易。

```bash
  simd tx authz exec [tx-json-file] --from [grantee] [flags]
```

示例：

```bash
simd tx authz exec tx.json --from=cosmos1..
```

**grant**

`grant` 命令允许授权者向被授权者授予授权。

```bash
simd tx authz grant <grantee> <authorization_type="send"|"generic"|"delegate"|"unbond"|"redelegate"> --from <granter> [flags]
```

* `send` authorization\_type 指的是内置的 `SendAuthorization` 类型。可用的自定义标志是 `spend-limit`（必需）和 `allow-list`（可选），文档在[这里](authz.md#SendAuthorization)

示例：

```bash
    simd tx authz grant cosmos1.. send --spend-limit=100stake --allow-list=cosmos1...,cosmos2... --from=cosmos1..
```

* `generic` authorization\_type 指的是内置的 `GenericAuthorization` 类型。可用的自定义标志是 `msg-type`（必需），文档在[这里](authz.md#GenericAuthorization)。

> 注意：`msg-type` 是任何有效的 Cosmos SDK `Msg` 类型 URL。

示例：

```bash
    simd tx authz grant cosmos1.. generic --msg-type=/cosmos.bank.v1beta1.MsgSend --from=cosmos1..
```

* `delegate`、`unbond`、`redelegate` authorization\_types 指的是内置的 `StakeAuthorization` 类型。可用的自定义标志是 `spend-limit`（可选）、`allowed-validators`（可选）和 `deny-validators`（可选），文档在[这里](authz.md#StakeAuthorization)。

> 注意：`allowed-validators` 和 `deny-validators` 不能都为空。`spend-limit` 表示 `MaxTokens`

示例：

```bash
simd tx authz grant cosmos1.. delegate --spend-limit=100stake --allowed-validators=cosmos...,cosmos... --deny-validators=cosmos... --from=cosmos1..
```

**revoke**

`revoke` 命令允许授权者撤销被授权者的授权。

```bash
simd tx authz revoke [grantee] [msg-type-url] --from=[granter] [flags]
```

示例：

```bash
simd tx authz revoke cosmos1.. /cosmos.bank.v1beta1.MsgSend --from=cosmos1..
```

### gRPC

用户可以使用 gRPC 端点查询 `authz` 模块。

#### Grants

`Grants` 端点允许用户查询授权者-被授权者对的授权授予。如果设置了消息类型 URL，它仅选择该消息类型的授权授予。

```bash
cosmos.authz.v1beta1.Query/Grants
```

示例：

```bash
grpcurl -plaintext \
    -d '{"granter":"cosmos1..","grantee":"cosmos1..","msg_type_url":"/cosmos.bank.v1beta1.MsgSend"}' \
    localhost:9090 \
    cosmos.authz.v1beta1.Query/Grants
```

示例输出：

```bash
{
  "grants": [
    {
      "authorization": {
        "@type": "/cosmos.bank.v1beta1.SendAuthorization",
        "spendLimit": [
          {
            "denom":"stake",
            "amount":"100"
          }
        ]
      },
      "expiration": "2022-01-01T00:00:00Z"
    }
  ]
}
```

### REST

用户可以使用 REST 端点查询 `authz` 模块。

```bash
/cosmos/authz/v1beta1/grants
```

示例：

```bash
curl "localhost:1317/cosmos/authz/v1beta1/grants?granter=cosmos1..&grantee=cosmos1..&msg_type_url=/cosmos.bank.v1beta1.MsgSend"
```

示例输出：

```bash
{
  "grants": [
    {
      "authorization": {
        "@type": "/cosmos.bank.v1beta1.SendAuthorization",
        "spend_limit": [
          {
            "denom": "stake",
            "amount": "100"
          }
        ]
      },
      "expiration": "2022-01-01T00:00:00Z"
    }
  ],
  "pagination": null
}
```
