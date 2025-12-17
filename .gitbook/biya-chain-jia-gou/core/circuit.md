# Circuit

## 概念

断路器（Circuit Breaker）是一个模块，旨在避免链在存在漏洞时需要停止/关闭，而是允许禁用特定消息或所有消息。在运行链时，如果它是应用特定的，那么链的停止影响较小，但如果链上构建了应用程序，则停止会因对应用程序的干扰而代价高昂。

断路器的工作原理是：一个地址或一组地址有权阻止消息被执行和/或包含在内存池中。任何具有权限的地址都能够重置该消息的断路器。

交易在两个点进行检查并可能被拒绝：

* 在 `CircuitBreakerDecorator` [ante handler](https://docs.cosmos.network/main/learn/advanced/baseapp#antehandler) 中：

```go
https://github.com/cosmos/cosmos-sdk/blob/x/circuit/v0.1.0/x/circuit/ante/circuit.go#L27-L41
```

* 通过 [消息路由器检查](https://docs.cosmos.network/main/learn/advanced/baseapp#msg-service-router)：

```go
https://github.com/cosmos/cosmos-sdk/blob/v0.50.1/baseapp/msg_service_router.go#L104-L115
```

:::note\
`CircuitBreakerDecorator` 适用于大多数用例，但[不检查交易内部消息](https://docs.cosmos.network/main/learn/beginner/tx-lifecycle#antehandler)。因此某些交易（例如 `x/authz` 交易或某些 `x/gov` 交易）可能会通过 ante handler。**这不会影响断路器**，因为消息路由器检查仍会使交易失败。\
这种权衡是为了避免在 `x/circuit` 模块中引入更多依赖。如果链希望这样做，可以重新定义 `CircuitBreakerDecorator` 来检查内部消息。\
:::

# Circuit

## 概念

断路器（Circuit Breaker）是一个模块，旨在避免链在存在漏洞时需要停止/关闭，而是允许禁用特定消息或所有消息。在运行链时，如果它是应用特定的，那么链的停止影响较小，但如果链上构建了应用程序，则停止会因对应用程序的干扰而代价高昂。

断路器的工作原理是：一个地址或一组地址有权阻止消息被执行和/或包含在内存池中。任何具有权限的地址都能够重置该消息的断路器。

交易在两个点进行检查并可能被拒绝：

* 在 `CircuitBreakerDecorator` [ante handler](https://docs.cosmos.network/main/learn/advanced/baseapp#antehandler) 中：

```go
https://github.com/cosmos/cosmos-sdk/blob/x/circuit/v0.1.0/x/circuit/ante/circuit.go#L27-L41
```

* 通过 [消息路由器检查](https://docs.cosmos.network/main/learn/advanced/baseapp#msg-service-router)：

```go
https://github.com/cosmos/cosmos-sdk/blob/v0.50.1/baseapp/msg_service_router.go#L104-L115
```

:::note\
`CircuitBreakerDecorator` 适用于大多数用例，但[不检查交易内部消息](https://docs.cosmos.network/main/learn/beginner/tx-lifecycle#antehandler)。因此某些交易（例如 `x/authz` 交易或某些 `x/gov` 交易）可能会通过 ante handler。**这不会影响断路器**，因为消息路由器检查仍会使交易失败。\
这种权衡是为了避免在 `x/circuit` 模块中引入更多依赖。如果链希望这样做，可以重新定义 `CircuitBreakerDecorator` 来检查内部消息。\
:::

## 状态

### 账户

* AccountPermissions `0x1 | account_address -> ProtocolBuffer(CircuitBreakerPermissions)`

```go
type level int32

const (
    // LEVEL_NONE_UNSPECIFIED indicates that the account will have no circuit
    // breaker permissions.
    LEVEL_NONE_UNSPECIFIED = iota
    // LEVEL_SOME_MSGS indicates that the account will have permission to
    // trip or reset the circuit breaker for some Msg type URLs. If this level
    // is chosen, a non-empty list of Msg type URLs must be provided in
    // limit_type_urls.
    LEVEL_SOME_MSGS
    // LEVEL_ALL_MSGS indicates that the account can trip or reset the circuit
    // breaker for Msg's of all type URLs.
    LEVEL_ALL_MSGS 
    // LEVEL_SUPER_ADMIN indicates that the account can take all circuit breaker
    // actions and can grant permissions to other accounts.
    LEVEL_SUPER_ADMIN
)

type Access struct {
	level int32 
	msgs []string // if full permission, msgs can be empty
}
```

### 禁用列表

已禁用的类型 URL 列表。

* DisableList `0x2 | msg_type_url -> []byte{}`

## 状态转换

### 授权

授权由模块权限（默认治理模块账户）或任何具有 `LEVEL_SUPER_ADMIN` 的账户调用，以授予另一个账户禁用/启用消息的权限。可以授予三个权限级别。`LEVEL_SOME_MSGS` 限制可以禁用的消息数量。`LEVEL_ALL_MSGS` 允许禁用所有消息。`LEVEL_SUPER_ADMIN` 允许账户执行所有断路器操作，包括授权和撤销其他账户的权限。

```protobuf
  // AuthorizeCircuitBreaker allows a super-admin to grant (or revoke) another
  // account's circuit breaker permissions.
  rpc AuthorizeCircuitBreaker(MsgAuthorizeCircuitBreaker) returns (MsgAuthorizeCircuitBreakerResponse);
```

### 触发

触发由授权账户调用，以禁用特定 msgURL 的消息执行。如果为空，所有消息将被禁用。

```protobuf
  // TripCircuitBreaker pauses processing of Msg's in the state machine.
  rpc TripCircuitBreaker(MsgTripCircuitBreaker) returns (MsgTripCircuitBreakerResponse);
```

### 重置

重置由授权账户调用，以启用先前禁用消息的特定 msgURL 的执行。如果为空，所有禁用的消息将被启用。

```protobuf
  // ResetCircuitBreaker resumes processing of Msg's in the state machine that
  // have been been paused using TripCircuitBreaker.
  rpc ResetCircuitBreaker(MsgResetCircuitBreaker) returns (MsgResetCircuitBreakerResponse);
```

## 消息

### MsgAuthorizeCircuitBreaker

```protobuf
https://github.com/cosmos/cosmos-sdk/blob/main/proto/cosmos/circuit/v1/tx.proto#L25-L75
```

如果出现以下情况，此消息应失败：

* 授权者不是具有权限级别 `LEVEL_SUPER_ADMIN` 的账户或模块权限

### MsgTripCircuitBreaker

```protobuf
https://github.com/cosmos/cosmos-sdk/blob/main/proto/cosmos/circuit/v1/tx.proto#L77-L93
```

如果出现以下情况，此消息应失败：

* 如果签名者没有能够禁用指定类型 URL 消息的权限级别

### MsgResetCircuitBreaker

```protobuf
https://github.com/cosmos/cosmos-sdk/blob/main/proto/cosmos/circuit/v1/tx.proto#L95-109
```

如果出现以下情况，此消息应失败：

* 如果类型 URL 未被禁用

## 事件 - 列出并描述事件标签

circuit 模块发出以下事件：

### 消息事件

#### MsgAuthorizeCircuitBreaker

| 类型    | 属性键      | 属性值                  |
| ------- | ----------- | ----------------------- |
| string  | granter     | {granterAddress}        |
| string  | grantee     | {granteeAddress}        |
| string  | permission  | {granteePermissions}    |
| message | module      | circuit                 |
| message | action      | authorize\_circuit\_breaker |

#### MsgTripCircuitBreaker

| 类型      | 属性键    | 属性值              |
| --------- | --------- | ------------------- |
| string    | authority | {authorityAddress}  |
| \[]string | msg\_urls | \[]string{msg\_urls} |
| message   | module    | circuit             |
| message   | action    | trip\_circuit\_breaker |

#### ResetCircuitBreaker

| 类型      | 属性键    | 属性值               |
| --------- | --------- | -------------------- |
| string    | authority | {authorityAddress}   |
| \[]string | msg\_urls | \[]string{msg\_urls} |
| message   | module    | circuit              |
| message   | action    | reset\_circuit\_breaker |

## 键 - 列出 circuit 模块使用的键前缀

* `AccountPermissionPrefix` - `0x01`
* `DisableListPrefix` - `0x02`

## 客户端 - 列出并描述 CLI 命令以及 gRPC 和 REST 端点
