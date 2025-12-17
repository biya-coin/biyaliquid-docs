---
sidebar_position: 1
---

# Evidence

* [概念](evidence.md#concepts)
* [状态](evidence.md#state)
* [消息](evidence.md#messages)
* [事件](evidence.md#events)
* [参数](evidence.md#parameters)
* [BeginBlock](evidence.md#beginblock)
* [客户端](evidence.md#client)
  * [CLI](evidence.md#cli)
  * [REST](evidence.md#rest)
  * [gRPC](evidence.md#grpc)

## 摘要

`x/evidence` 是 Cosmos SDK 模块的实现，根据 [ADR 009](https://github.com/cosmos/cosmos-sdk/blob/main/docs/architecture/adr-009-evidence-module.md)，\
它允许提交和处理任意的不当行为证据，例如\
双重签名和反事实签名。

evidence 模块不同于标准的证据处理，后者通常期望\
底层共识引擎（例如 CometBFT）在发现时自动提交证据，\
它通过允许客户端和外部链直接提交更复杂的证据来实现这一点。

所有具体的证据类型必须实现 `Evidence` 接口契约。提交的\
`Evidence` 首先通过 evidence 模块的 `Router` 路由，在其中它尝试\
为该特定 `Evidence` 类型找到相应的已注册 `Handler`。\
每个 `Evidence` 类型必须在 evidence 模块的\
keeper 中注册一个 `Handler`，才能成功路由和执行。

每个相应的处理器还必须满足 `Handler` 接口契约。给定\
`Evidence` 类型的 `Handler` 可以执行任何任意状态转换，\
例如削减、监禁和标记为墓碑。

## 概念

### 证据

提交到 `x/evidence` 模块的任何具体证据类型都必须满足下面概述的\
`Evidence` 契约。并非所有具体的证据类型都会以相同的方式满足\
此契约，某些数据可能对某些\
类型的证据完全不相关。还创建了一个额外的 `ValidatorEvidence`，它扩展了 `Evidence`，\
用于定义针对恶意验证者的证据契约。

```go
// Evidence defines the contract which concrete evidence types of misbehavior
// must implement.
type Evidence interface {
	proto.Message

	Route() string
	String() string
	Hash() []byte
	ValidateBasic() error

	// Height at which the infraction occurred
	GetHeight() int64
}

// ValidatorEvidence extends Evidence interface to define contract
// for evidence against malicious validators
type ValidatorEvidence interface {
	Evidence

	// The consensus address of the malicious validator at time of infraction
	GetConsensusAddress() sdk.ConsAddress

	// The total power of the malicious validator at time of infraction
	GetValidatorPower() int64

	// The total validator set power at time of infraction
	GetTotalPower() int64
}
```

### 注册和处理

`x/evidence` 模块必须首先了解它预期\
处理的所有证据类型。这是通过将 `Evidence`\
契约中的 `Route` 方法注册到称为 `Router`（如下定义）的对象来实现的。`Router` 接受\
`Evidence` 并尝试通过 `Route` 方法为 `Evidence`\
找到相应的 `Handler`。

```go
type Router interface {
  AddRoute(r string, h Handler) Router
  HasRoute(r string) bool
  GetRoute(path string) Handler
  Seal()
  Sealed() bool
}
```

`Handler`（如下定义）负责执行处理 `Evidence` 的\
全部业务逻辑。这通常包括验证\
证据，通过 `ValidateBasic` 进行无状态检查，以及通过提供给\
`Handler` 的任何 keepers 进行有状态检查。此外，`Handler` 还可以执行\
诸如削减和监禁验证者等功能。由\
`Handler` 处理的所有 `Evidence` 都应该被持久化。

```go
// Handler defines an agnostic Evidence handler. The handler is responsible
// for executing all corresponding business logic necessary for verifying the
// evidence as valid. In addition, the Handler may execute any necessary
// slashing and potential jailing.
type Handler func(context.Context, Evidence) error
```

## 状态

目前，`x/evidence` 模块仅在状态中存储有效提交的 `Evidence`。\
证据状态也存储在 `x/evidence` 模块的 `GenesisState` 中并导出。

```protobuf
// GenesisState defines the evidence module's genesis state.
message GenesisState {
  // evidence defines all the evidence at genesis.
  repeated google.protobuf.Any evidence = 1;
}

```

所有 `Evidence` 都通过使用前缀 `0x00`（`KeyPrefixEvidence`）的前缀 `KVStore` 检索和存储。

## 消息

### MsgSubmitEvidence

证据通过 `MsgSubmitEvidence` 消息提交：

```protobuf
// MsgSubmitEvidence represents a message that supports submitting arbitrary
// Evidence of misbehavior such as equivocation or counterfactual signing.
message MsgSubmitEvidence {
  string              submitter = 1;
  google.protobuf.Any evidence  = 2;
}
```

注意，`MsgSubmitEvidence` 消息的 `Evidence` 必须在 `x/evidence` 模块的 `Router` 中注册相应的\
`Handler`，才能被正确处理\
和路由。

假设 `Evidence` 已注册相应的 `Handler`，它按以下方式处理：

```go
func SubmitEvidence(ctx Context, evidence Evidence) error {
  if _, err := GetEvidence(ctx, evidence.Hash()); err == nil {
    return errorsmod.Wrap(types.ErrEvidenceExists, strings.ToUpper(hex.EncodeToString(evidence.Hash())))
  }
  if !router.HasRoute(evidence.Route()) {
    return errorsmod.Wrap(types.ErrNoEvidenceHandlerExists, evidence.Route())
  }

  handler := router.GetRoute(evidence.Route())
  if err := handler(ctx, evidence); err != nil {
    return errorsmod.Wrap(types.ErrInvalidEvidence, err.Error())
  }

  ctx.EventManager().EmitEvent(
		sdk.NewEvent(
			types.EventTypeSubmitEvidence,
			sdk.NewAttribute(types.AttributeKeyEvidenceHash, strings.ToUpper(hex.EncodeToString(evidence.Hash()))),
		),
	)

  SetEvidence(ctx, evidence)
  return nil
}
```

首先，必须不存在完全相同类型的有效提交 `Evidence`。\
其次，`Evidence` 被路由到 `Handler` 并执行。最后，\
如果在处理 `Evidence` 时没有错误，则发出事件并将其持久化到状态。

## 事件

`x/evidence` 模块发出以下事件：

### 处理器

#### MsgSubmitEvidence

| 类型             | 属性键        | 属性值          |
| ---------------- | ------------ | --------------- |
| submit\_evidence | evidence\_hash | {evidenceHash}   |
| message          | module       | evidence         |
| message          | sender       | {senderAddress}  |
| message          | action       | submit\_evidence |

## 参数

evidence 模块不包含任何参数。

## BeginBlock

### 证据处理

CometBFT 区块可以包含[证据](https://github.com/cometbft/cometbft/blob/main/spec/abci/abci%2B%2B_basic_concepts.md#evidence)，指示验证者是否实施了恶意行为。相关信息在 `abci.RequestBeginBlock` 中作为 ABCI 证据转发给应用，以便相应地惩罚验证者。

#### 双重签名

Cosmos SDK 在 ABCI `BeginBlock` 内处理两种类型的证据：

* `DuplicateVoteEvidence`，
* `LightClientAttackEvidence`。

evidence 模块以相同方式处理这两种证据类型。首先，Cosmos SDK 使用 `Equivocation` 作为具体类型，将 CometBFT 具体证据类型转换为 SDK `Evidence` 接口。

```protobuf
https://github.com/cosmos/cosmos-sdk/blob/v0.47.0-rc1/proto/cosmos/evidence/v1beta1/evidence.proto#L12-L32
```

对于在 `block` 中提交的某些 `Equivocation` 要有效，它必须满足：

`Evidence.Timestamp >= block.Timestamp - MaxEvidenceAge`

其中：

* `Evidence.Timestamp` 是高度 `Evidence.Height` 处区块中的时间戳
* `block.Timestamp` 是当前区块时间戳。

如果有效的 `Equivocation` 证据包含在区块中，验证者的权益\
会被 `x/slashing` 模块定义的 `SlashFractionDoubleSign` 削减（slash），\
削减的是违规发生时的权益，而不是发现证据时的权益。\
我们希望"跟随权益"，即，导致违规的权益\
应该被削减，即使它后来被重新委托或开始解绑。

此外，验证者被永久监禁并标记为墓碑，使该\
验证者永远无法重新进入验证者集合。

`Equivocation` 证据按以下方式处理：

```go
https://github.com/cosmos/cosmos-sdk/blob/v0.47.0-rc1/x/evidence/keeper/infraction.go#L26-L140
```

**注意：** 削减、监禁和标记为墓碑的调用通过 `x/slashing` 模块\
委托，该模块发出信息性事件并最终将调用委托给 `x/staking` 模块。有关\
削减和监禁的文档，请参见[状态转换](staking.md#state-transitions)。

## 客户端

### CLI

用户可以使用 CLI 查询和与 `evidence` 模块交互。

#### 查询

`query` 命令允许用户查询 `evidence` 状态。

```bash
simd query evidence --help
```

#### evidence

`evidence` 命令允许用户列出所有证据或按哈希查询证据。

用法：

```bash
simd query evidence evidence [flags]
```

按哈希查询证据

示例：

```bash
simd query evidence evidence "DF0C23E8634E480F84B9D5674A7CDC9816466DEC28A3358F73260F68D28D7660"
```

示例输出：

```bash
evidence:
  consensus_address: cosmosvalcons1ntk8eualewuprz0gamh8hnvcem2nrcdsgz563h
  height: 11
  power: 100
  time: "2021-10-20T16:08:38.194017624Z"
```

获取所有证据

示例：

```bash
simd query evidence list
```

示例输出：

```bash
evidence:
  consensus_address: cosmosvalcons1ntk8eualewuprz0gamh8hnvcem2nrcdsgz563h
  height: 11
  power: 100
  time: "2021-10-20T16:08:38.194017624Z"
pagination:
  next_key: null
  total: "1"
```

### REST

用户可以使用 REST 端点查询 `evidence` 模块。

#### Evidence

按哈希获取证据

```bash
/cosmos/evidence/v1beta1/evidence/{hash}
```

示例：

```bash
curl -X GET "http://localhost:1317/cosmos/evidence/v1beta1/evidence/DF0C23E8634E480F84B9D5674A7CDC9816466DEC28A3358F73260F68D28D7660"
```

示例输出：

```bash
{
  "evidence": {
    "consensus_address": "cosmosvalcons1ntk8eualewuprz0gamh8hnvcem2nrcdsgz563h",
    "height": "11",
    "power": "100",
    "time": "2021-10-20T16:08:38.194017624Z"
  }
}
```

#### All evidence

获取所有证据

```bash
/cosmos/evidence/v1beta1/evidence
```

示例：

```bash
curl -X GET "http://localhost:1317/cosmos/evidence/v1beta1/evidence"
```

示例输出：

```bash
{
  "evidence": [
    {
      "consensus_address": "cosmosvalcons1ntk8eualewuprz0gamh8hnvcem2nrcdsgz563h",
      "height": "11",
      "power": "100",
      "time": "2021-10-20T16:08:38.194017624Z"
    }
  ],
  "pagination": {
    "total": "1"
  }
}
```

### gRPC

用户可以使用 gRPC 端点查询 `evidence` 模块。

#### Evidence

按哈希获取证据

```bash
cosmos.evidence.v1beta1.Query/Evidence
```

示例：

```bash
grpcurl -plaintext -d '{"evidence_hash":"DF0C23E8634E480F84B9D5674A7CDC9816466DEC28A3358F73260F68D28D7660"}' localhost:9090 cosmos.evidence.v1beta1.Query/Evidence
```

示例输出：

```bash
{
  "evidence": {
    "consensus_address": "cosmosvalcons1ntk8eualewuprz0gamh8hnvcem2nrcdsgz563h",
    "height": "11",
    "power": "100",
    "time": "2021-10-20T16:08:38.194017624Z"
  }
}
```

#### All evidence

获取所有证据

```bash
cosmos.evidence.v1beta1.Query/AllEvidence
```

示例：

```bash
grpcurl -plaintext localhost:9090 cosmos.evidence.v1beta1.Query/AllEvidence
```

示例输出：

```bash
{
  "evidence": [
    {
      "consensus_address": "cosmosvalcons1ntk8eualewuprz0gamh8hnvcem2nrcdsgz563h",
      "height": "11",
      "power": "100",
      "time": "2021-10-20T16:08:38.194017624Z"
    }
  ],
  "pagination": {
    "total": "1"
  }
}
```
