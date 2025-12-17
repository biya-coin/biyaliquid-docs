---
sidebar_position: 1
---

# 组

## 摘要

以下文档规定了组模块。

该模块允许创建和管理链上多重签名账户，并支持基于可配置决策策略的消息执行投票。

## 目录

* [概念](group.md#concepts)
  * [组](group.md#group)
  * [组策略](group.md#group-policy)
  * [决策策略](group.md#decision-policy)
  * [提案](group.md#proposal)
  * [修剪](group.md#pruning)
* [状态](group.md#state)
  * [组表](group.md#group-table)
  * [组成员表](group.md#group-member-table)
  * [组策略表](group.md#group-policy-table)
  * [提案表](group.md#proposal-table)
  * [投票表](group.md#vote-table)
* [消息服务](group.md#msg-service)
  * [Msg/CreateGroup](group.md#msgcreategroup)
  * [Msg/UpdateGroupMembers](group.md#msgupdategroupmembers)
  * [Msg/UpdateGroupAdmin](group.md#msgupdategroupadmin)
  * [Msg/UpdateGroupMetadata](group.md#msgupdategroupmetadata)
  * [Msg/CreateGroupPolicy](group.md#msgcreategrouppolicy)
  * [Msg/CreateGroupWithPolicy](group.md#msgcreategroupwithpolicy)
  * [Msg/UpdateGroupPolicyAdmin](group.md#msgupdategrouppolicyadmin)
  * [Msg/UpdateGroupPolicyDecisionPolicy](group.md#msgupdategrouppolicydecisionpolicy)
  * [Msg/UpdateGroupPolicyMetadata](group.md#msgupdategrouppolicymetadata)
  * [Msg/SubmitProposal](group.md#msgsubmitproposal)
  * [Msg/WithdrawProposal](group.md#msgwithdrawproposal)
  * [Msg/Vote](group.md#msgvote)
  * [Msg/Exec](group.md#msgexec)
  * [Msg/LeaveGroup](group.md#msgleavegroup)
* [事件](group.md#events)
  * [EventCreateGroup](group.md#eventcreategroup)
  * [EventUpdateGroup](group.md#eventupdategroup)
  * [EventCreateGroupPolicy](group.md#eventcreategrouppolicy)
  * [EventUpdateGroupPolicy](group.md#eventupdategrouppolicy)
  * [EventCreateProposal](group.md#eventcreateproposal)
  * [EventWithdrawProposal](group.md#eventwithdrawproposal)
  * [EventVote](group.md#eventvote)
  * [EventExec](group.md#eventexec)
  * [EventLeaveGroup](group.md#eventleavegroup)
  * [EventProposalPruned](group.md#eventproposalpruned)
* [客户端](group.md#client)
  * [CLI](group.md#cli)
  * [gRPC](group.md#grpc)
  * [REST](group.md#rest)
* [元数据](group.md#metadata)

## 概念

### 组

组只是具有关联权重的账户的聚合。它不是账户，也没有余额。它本身没有任何投票或决策权重。它确实有一个"管理员"，能够添加、删除和更新组中的成员。请注意，组策略账户可以是组的管理员，并且管理员不一定是组的成员。

### 组策略

组策略是与组和决策策略关联的账户。组策略从组中抽象出来，因为单个组可能对不同类型的操作有多个决策策略。将组成员身份管理与决策策略分开管理可以最大限度地减少开销，并保持不同策略之间成员身份的一致性。推荐的模式是为给定组设置一个主组策略，然后创建具有不同决策策略的单独组策略，并使用 `x/authz` 模块将所需权限从主账户委托给那些"子账户"。

### 决策策略

决策策略是组成员可以对提案进行投票的机制，以及根据其统计结果决定提案是否应该通过的规则。

所有决策策略通常都有一个最小执行期和一个最大投票窗口。最小执行期是提案提交后必须经过的最短时间，提案才能被执行，它可以设置为 0。最大投票窗口是提案提交后可以投票的最长时间，之后将进行统计。

链开发者还定义了一个应用程序范围的最大执行期，这是提案投票期结束后允许用户执行提案的最长时间。

当前的组模块附带两个决策策略：阈值和百分比。任何链开发者都可以通过创建自定义决策策略来扩展这两个策略，只要它们遵循 `DecisionPolicy` 接口：

```go
https://github.com/cosmos/cosmos-sdk/blob/v0.47.0-rc1/x/group/types.go#L27-L45
```

#### 阈值决策策略

阈值决策策略定义了必须达到的"是"投票阈值（基于投票者权重的统计），提案才能通过。对于此决策策略，弃权和否决权仅被视为"否"。

此决策策略还有一个 VotingPeriod 窗口和一个 MinExecutionPeriod 窗口。前者定义提案提交后允许成员投票的持续时间，之后进行统计。后者指定提案提交后可以执行提案的最短持续时间。如果设置为 0，则允许在提交时立即执行提案（使用 `TRY_EXEC` 选项）。显然，MinExecutionPeriod 不能大于 VotingPeriod+MaxExecutionPeriod（其中 MaxExecution 是应用程序定义的持续时间，指定投票结束后可以执行提案的窗口）。

#### 百分比决策策略

百分比决策策略类似于阈值决策策略，不同之处在于阈值不是定义为常量权重，而是定义为百分比。它更适合组成员权重可以更新的组，因为百分比阈值保持不变，并且不依赖于这些成员权重的更新方式。

与阈值决策策略相同，百分比决策策略有两个 VotingPeriod 和 MinExecutionPeriod 参数。

### 提案

组的任何成员都可以为组策略账户提交提案以供决定。提案由一组消息组成，如果提案通过，这些消息将被执行，以及与提案关联的任何元数据。

#### 投票

投票时有四个选择 - 是、否、弃权和否决。并非所有决策策略都会考虑这四个选择。投票可以包含一些可选的元数据。在当前实现中，投票窗口在提案提交后立即开始，结束时间由组策略的决策策略定义。

#### 撤回提案

提案可以在投票期结束前的任何时间撤回，可以由组策略的管理员或提案者之一撤回。一旦撤回，它被标记为 `PROPOSAL_STATUS_WITHDRAWN`，并且不再允许对其进行投票或执行。

#### 中止的提案

如果在提案的投票期内更新了组策略，则提案被标记为 `PROPOSAL_STATUS_ABORTED`，并且不再允许对其进行投票或执行。这是因为组策略定义了提案投票和执行的规则，因此如果这些规则在提案的生命周期内发生变化，则提案应被标记为过时。

#### 统计

统计是对提案的所有投票进行计数。它在提案的生命周期中只发生一次，但可以由两个因素触发，以先发生者为准：

* 要么有人尝试执行提案（参见下一节），这可能发生在 `Msg/Exec` 交易上，或者设置了 `Exec` 字段的 `Msg/{SubmitProposal,Vote}` 交易上。当尝试执行提案时，首先进行统计以确保提案通过。
* 或者在 `EndBlock` 上，当提案的投票期刚刚结束时。

如果统计结果通过决策策略的规则，则提案被标记为 `PROPOSAL_STATUS_ACCEPTED`，否则被标记为 `PROPOSAL_STATUS_REJECTED`。无论如何，不再允许投票，统计结果被持久化到提案的 `FinalTallyResult` 状态中。

#### 执行提案

提案只有在统计完成后才会被执行，并且组账户的决策策略根据统计结果允许提案通过。它们由状态 `PROPOSAL_STATUS_ACCEPTED` 标记。执行必须在每个提案的投票期结束后 `MaxExecutionPeriod`（由链开发者设置）的持续时间之前发生。

在当前设计中，提案不会由链自动执行，而是用户必须提交 `Msg/Exec` 交易以尝试根据当前投票和决策策略执行提案。任何用户（不仅仅是组成员）都可以执行已被接受的提案，执行费用由提案执行者支付。也可以使用 `Msg/SubmitProposal` 和 `Msg/Vote` 请求的 `Exec` 字段在创建时或新投票时立即尝试执行提案。在前一种情况下，提案者的签名被视为"是"投票。在这些情况下，如果提案无法执行（即它没有通过决策策略的规则），它仍然会开放供新投票，并且可能稍后被统计和执行。

成功的提案执行将把其 `ExecutorResult` 标记为 `PROPOSAL_EXECUTOR_RESULT_SUCCESS`。提案将在执行后自动修剪。另一方面，失败的提案执行将被标记为 `PROPOSAL_EXECUTOR_RESULT_FAILURE`。这样的提案可以多次重新执行，直到在投票期结束后的 `MaxExecutionPeriod` 后过期。

### 修剪

提案和投票会自动修剪以避免状态膨胀。

投票在以下情况下被修剪：

* 要么在成功统计之后，即统计结果通过决策策略规则的情况，这可以由 `Msg/Exec` 或设置了 `Exec` 字段的 `Msg/{SubmitProposal,Vote}` 触发，
* 要么在 `EndBlock` 上，就在提案的投票期结束后。这也适用于状态为 `aborted` 或 `withdrawn` 的提案。

以先发生者为准。

提案在以下情况下被修剪：

* 在 `EndBlock` 上，提案状态为 `withdrawn` 或 `aborted`，在提案的投票期结束前进行统计，
* 并且在成功执行提案之后，
* 或者在 `EndBlock` 上，就在提案的 `voting_period_end` + `max_execution_period`（定义为应用程序范围的配置）通过之后，

以先发生者为准。

## 状态

`group` 模块使用 `orm` 包，它提供支持主键和二级索引的表存储。`orm` 还定义了 `Sequence`，这是一个基于计数器的持久唯一键生成器，可以与 `Table` 一起使用。

以下是作为 `group` 模块一部分存储的表以及相关的序列和索引列表。

### 组表

`groupTable` 存储 `GroupInfo`：`0x0 | BigEndian(GroupId) -> ProtocolBuffer(GroupInfo)`。

#### groupSeq

`groupSeq` 的值在创建新组时递增，对应于新的 `GroupId`：`0x1 | 0x1 -> BigEndian`。

第二个 `0x1` 对应于 ORM `sequenceStorageKey`。

#### groupByAdminIndex

`groupByAdminIndex` 允许按管理员地址检索组：`0x2 | len([]byte(group.Admin)) | []byte(group.Admin) | BigEndian(GroupId) -> []byte()`。

### 组成员表

`groupMemberTable` 存储 `GroupMember`：`0x10 | BigEndian(GroupId) | []byte(member.Address) -> ProtocolBuffer(GroupMember)`。

`groupMemberTable` 是一个主键表，其 `PrimaryKey` 由 `BigEndian(GroupId) | []byte(member.Address)` 给出，由以下索引使用。

#### groupMemberByGroupIndex

`groupMemberByGroupIndex` 允许按组 id 检索组成员：`0x11 | BigEndian(GroupId) | PrimaryKey -> []byte()`。

#### groupMemberByMemberIndex

`groupMemberByMemberIndex` 允许按成员地址检索组成员：`0x12 | len([]byte(member.Address)) | []byte(member.Address) | PrimaryKey -> []byte()`。

### 组策略表

`groupPolicyTable` 存储 `GroupPolicyInfo`：`0x20 | len([]byte(Address)) | []byte(Address) -> ProtocolBuffer(GroupPolicyInfo)`。

`groupPolicyTable` 是一个主键表，其 `PrimaryKey` 由 `len([]byte(Address)) | []byte(Address)` 给出，由以下索引使用。

#### groupPolicySeq

`groupPolicySeq` 的值在创建新组策略时递增，用于生成新的组策略账户 `Address`：`0x21 | 0x1 -> BigEndian`。

第二个 `0x1` 对应于 ORM `sequenceStorageKey`。

#### groupPolicyByGroupIndex

`groupPolicyByGroupIndex` 允许按组 id 检索组策略：`0x22 | BigEndian(GroupId) | PrimaryKey -> []byte()`。

#### groupPolicyByAdminIndex

`groupPolicyByAdminIndex` 允许按管理员地址检索组策略：`0x23 | len([]byte(Address)) | []byte(Address) | PrimaryKey -> []byte()`。

### 提案表

`proposalTable` 存储 `Proposal`：`0x30 | BigEndian(ProposalId) -> ProtocolBuffer(Proposal)`。

#### proposalSeq

`proposalSeq` 的值在创建新提案时递增，对应于新的 `ProposalId`：`0x31 | 0x1 -> BigEndian`。

第二个 `0x1` 对应于 ORM `sequenceStorageKey`。

#### proposalByGroupPolicyIndex

`proposalByGroupPolicyIndex` 允许按组策略账户地址检索提案：`0x32 | len([]byte(account.Address)) | []byte(account.Address) | BigEndian(ProposalId) -> []byte()`。

#### ProposalsByVotingPeriodEndIndex

`proposalsByVotingPeriodEndIndex` 允许按时间顺序 `voting_period_end` 检索提案：`0x33 | sdk.FormatTimeBytes(proposal.VotingPeriodEnd) | BigEndian(ProposalId) -> []byte()`。

此索引用于在投票期结束时统计提案投票，以及在 `VotingPeriodEnd + MaxExecutionPeriod` 时修剪提案。

### 投票表

`voteTable` 存储 `Vote`：`0x40 | BigEndian(ProposalId) | []byte(voter.Address) -> ProtocolBuffer(Vote)`。

`voteTable` 是一个主键表，其 `PrimaryKey` 由 `BigEndian(ProposalId) | []byte(voter.Address)` 给出，由以下索引使用。

#### voteByProposalIndex

`voteByProposalIndex` 允许按提案 id 检索投票：`0x41 | BigEndian(ProposalId) | PrimaryKey -> []byte()`。

#### voteByVoterIndex

`voteByVoterIndex` 允许按投票者地址检索投票：`0x42 | len([]byte(voter.Address)) | []byte(voter.Address) | PrimaryKey -> []byte()`。

## 消息服务

### Msg/CreateGroup

可以使用 `MsgCreateGroup` 创建新组，它具有管理员地址、成员列表和一些可选的元数据。

元数据有一个最大长度，由应用程序开发者选择，并作为配置传递给组 keeper。

```go
https://github.com/cosmos/cosmos-sdk/blob/v0.47.0-rc1/proto/cosmos/group/v1/tx.proto#L67-L80
```

在以下情况下预期会失败：

* 元数据长度大于 `MaxMetadataLen` 配置
* 成员未正确设置（例如，错误的地址格式、重复或权重为 0）。

### Msg/UpdateGroupMembers

可以使用 `UpdateGroupMembers` 更新组成员。

```go
https://github.com/cosmos/cosmos-sdk/blob/v0.47.0-rc1/proto/cosmos/group/v1/tx.proto#L88-L102
```

在 `MemberUpdates` 列表中，可以通过将其权重设置为 0 来删除现有成员。

在以下情况下预期会失败：

* 签名者不是组的管理员。
* 对于任何关联的组策略，如果其决策策略的 `Validate()` 方法对更新后的组失败。

### Msg/UpdateGroupAdmin

可以使用 `UpdateGroupAdmin` 更新组管理员。

```go
https://github.com/cosmos/cosmos-sdk/blob/v0.47.0-rc1/proto/cosmos/group/v1/tx.proto#L107-L120
```

如果签名者不是组的管理员，预期会失败。

### Msg/UpdateGroupMetadata

可以使用 `UpdateGroupMetadata` 更新组元数据。

```go
https://github.com/cosmos/cosmos-sdk/blob/v0.47.0-rc1/proto/cosmos/group/v1/tx.proto#L125-L138
```

在以下情况下预期会失败：

* 新元数据长度大于 `MaxMetadataLen` 配置。
* 签名者不是组的管理员。

### Msg/CreateGroupPolicy

可以使用 `MsgCreateGroupPolicy` 创建新组策略，它具有管理员地址、组 id、决策策略和一些可选的元数据。

```go
https://github.com/cosmos/cosmos-sdk/blob/v0.47.0-rc1/proto/cosmos/group/v1/tx.proto#L147-L165
```

在以下情况下预期会失败：

* 签名者不是组的管理员。
* 元数据长度大于 `MaxMetadataLen` 配置。
* 决策策略的 `Validate()` 方法对组不通过。

### Msg/CreateGroupWithPolicy

可以使用 `MsgCreateGroupWithPolicy` 创建带策略的新组，它具有管理员地址、成员列表、决策策略、一个 `group_policy_as_admin` 字段（可选地使用组策略地址设置组和组策略管理员）以及组和组策略的一些可选元数据。

```go
https://github.com/cosmos/cosmos-sdk/blob/v0.47.0-rc1/proto/cosmos/group/v1/tx.proto#L191-L215
```

预期会因与 `Msg/CreateGroup` 和 `Msg/CreateGroupPolicy` 相同的原因而失败。

### Msg/UpdateGroupPolicyAdmin

可以使用 `UpdateGroupPolicyAdmin` 更新组策略管理员。

```go
https://github.com/cosmos/cosmos-sdk/blob/v0.47.0-rc1/proto/cosmos/group/v1/tx.proto#L173-L186
```

如果签名者不是组策略的管理员，预期会失败。

### Msg/UpdateGroupPolicyDecisionPolicy

可以使用 `UpdateGroupPolicyDecisionPolicy` 更新决策策略。

```go
https://github.com/cosmos/cosmos-sdk/blob/v0.47.0-rc1/proto/cosmos/group/v1/tx.proto#L226-L241
```

在以下情况下预期会失败：

* 签名者不是组策略的管理员。
* 新决策策略的 `Validate()` 方法对组不通过。

### Msg/UpdateGroupPolicyMetadata

可以使用 `UpdateGroupPolicyMetadata` 更新组策略元数据。

```go
https://github.com/cosmos/cosmos-sdk/blob/v0.47.0-rc1/proto/cosmos/group/v1/tx.proto#L246-L259
```

在以下情况下预期会失败：

* 新元数据长度大于 `MaxMetadataLen` 配置。
* 签名者不是组的管理员。

### Msg/SubmitProposal

可以使用 `MsgSubmitProposal` 创建新提案，它具有组策略账户地址、提案者地址列表、如果提案被接受要执行的消息列表以及一些可选的元数据。\
可以提供可选的 `Exec` 值以在提案创建后立即尝试执行提案。在这种情况下，提案者的签名被视为"是"投票。

```go
https://github.com/cosmos/cosmos-sdk/blob/v0.47.0-rc1/proto/cosmos/group/v1/tx.proto#L281-L315
```

在以下情况下预期会失败：

* 元数据、标题或摘要长度大于 `MaxMetadataLen` 配置。
* 如果任何提案者不是组成员。

### Msg/WithdrawProposal

可以使用 `MsgWithdrawProposal` 撤回提案，它具有一个 `address`（可以是提案者或组策略管理员）和一个 `proposal_id`（必须撤回的提案）。

```go
https://github.com/cosmos/cosmos-sdk/blob/v0.47.0-rc1/proto/cosmos/group/v1/tx.proto#L323-L333
```

在以下情况下预期会失败：

* 签名者既不是组策略管理员也不是提案的提案者。
* 提案已经关闭或中止。

### Msg/Vote

可以使用 `MsgVote` 创建新投票，给定提案 id、投票者地址、选择（是、否、否决或弃权）以及一些可选的元数据。\
可以提供可选的 `Exec` 值以在投票后立即尝试执行提案。

```go
https://github.com/cosmos/cosmos-sdk/blob/v0.47.0-rc1/proto/cosmos/group/v1/tx.proto#L338-L358
```

在以下情况下预期会失败：

* 元数据长度大于 `MaxMetadataLen` 配置。
* 提案不再在投票期内。

### Msg/Exec

可以使用 `MsgExec` 执行提案。

```go
https://github.com/cosmos/cosmos-sdk/blob/v0.47.0-rc1/proto/cosmos/group/v1/tx.proto#L363-L373
```

如果满足以下条件，作为此提案一部分的消息将不会被执行：

* 提案尚未被组策略接受。
* 提案已经成功执行。

### Msg/LeaveGroup

`MsgLeaveGroup` 允许组成员离开组。

```go
https://github.com/cosmos/cosmos-sdk/blob/v0.47.0-rc1/proto/cosmos/group/v1/tx.proto#L381-L391
```

在以下情况下预期会失败：

* 组成员不是组的一部分。
* 对于任何关联的组策略，如果其决策策略的 `Validate()` 方法对更新后的组失败。

## 事件

组模块发出以下事件：

### EventCreateGroup

| 类型                             | 属性键    | 属性值                              |
| -------------------------------- | --------- | ----------------------------------- |
| message                          | action    | /cosmos.group.v1.Msg/CreateGroup    |
| cosmos.group.v1.EventCreateGroup | group\_id | {groupId}                           |

### EventUpdateGroup

| 类型                             | 属性键    | 属性值                                                      |
| -------------------------------- | --------- | ----------------------------------------------------------- |
| message                          | action    | /cosmos.group.v1.Msg/UpdateGroup{Admin\|Metadata\|Members} |
| cosmos.group.v1.EventUpdateGroup | group\_id | {groupId}                                                    |

### EventCreateGroupPolicy

| 类型                                   | 属性键  | 属性值                              |
| -------------------------------------- | ------- | ----------------------------------- |
| message                                | action  | /cosmos.group.v1.Msg/CreateGroupPolicy |
| cosmos.group.v1.EventCreateGroupPolicy | address | {groupPolicyAddress}                 |

### EventUpdateGroupPolicy

| 类型                                   | 属性键  | 属性值                                                              |
| -------------------------------------- | ------- | ------------------------------------------------------------------- |
| message                                | action  | /cosmos.group.v1.Msg/UpdateGroupPolicy{Admin\|Metadata\|DecisionPolicy} |
| cosmos.group.v1.EventUpdateGroupPolicy | address | {groupPolicyAddress}                                                |

### EventCreateProposal

| 类型                                | 属性键      | 属性值                            |
| ----------------------------------- | ----------- | --------------------------------- |
| message                             | action      | /cosmos.group.v1.Msg/CreateProposal |
| cosmos.group.v1.EventCreateProposal | proposal\_id | {proposalId}                      |

### EventWithdrawProposal

| 类型                                  | 属性键      | 属性值                              |
| ------------------------------------- | ----------- | ----------------------------------- |
| message                               | action      | /cosmos.group.v1.Msg/WithdrawProposal |
| cosmos.group.v1.EventWithdrawProposal | proposal\_id | {proposalId}                        |

### EventVote

| 类型                      | 属性键      | 属性值                |
| ------------------------- | ----------- | --------------------- |
| message                   | action      | /cosmos.group.v1.Msg/Vote |
| cosmos.group.v1.EventVote | proposal\_id | {proposalId}          |

## EventExec

| 类型                      | 属性键      | 属性值                |
| ------------------------- | ----------- | --------------------- |
| message                   | action      | /cosmos.group.v1.Msg/Exec |
| cosmos.group.v1.EventExec | proposal\_id | {proposalId}          |
| cosmos.group.v1.EventExec | logs        | {logs\_string}        |

### EventLeaveGroup

| 类型                            | 属性键      | 属性值                    |
| ------------------------------- | ----------- | ------------------------- |
| message                         | action      | /cosmos.group.v1.Msg/LeaveGroup |
| cosmos.group.v1.EventLeaveGroup | proposal\_id | {proposalId}              |
| cosmos.group.v1.EventLeaveGroup | address     | {address}                 |

### EventProposalPruned

| 类型                                | 属性键      | 属性值                    |
| ----------------------------------- | ----------- | ------------------------- |
| message                             | action      | /cosmos.group.v1.Msg/LeaveGroup |
| cosmos.group.v1.EventProposalPruned | proposal\_id | {proposalId}              |
| cosmos.group.v1.EventProposalPruned | status      | {ProposalStatus}          |
| cosmos.group.v1.EventProposalPruned | tally\_result | {TallyResult}            |

## Client

### CLI

A user can query and interact with the `group` module using the CLI.

#### Query

The `query` commands allow users to query `group` state.

```bash
simd query group --help
```

**group-info**

The `group-info` command allows users to query for group info by given group id.

```bash
simd query group group-info [id] [flags]
```

Example:

```bash
simd query group group-info 1
```

Example Output:

```bash
admin: cosmos1..
group_id: "1"
metadata: AQ==
total_weight: "3"
version: "1"
```

**group-policy-info**

The `group-policy-info` command allows users to query for group policy info by account address of group policy .

```bash
simd query group group-policy-info [group-policy-account] [flags]
```

Example:

```bash
simd query group group-policy-info cosmos1..
```

Example Output:

```bash
address: cosmos1..
admin: cosmos1..
decision_policy:
  '@type': /cosmos.group.v1.ThresholdDecisionPolicy
  threshold: "1"
  windows:
      min_execution_period: 0s
      voting_period: 432000s
group_id: "1"
metadata: AQ==
version: "1"
```

**group-members**

The `group-members` command allows users to query for group members by group id with pagination flags.

```bash
simd query group group-members [id] [flags]
```

Example:

```bash
simd query group group-members 1
```

Example Output:

```bash
members:
- group_id: "1"
  member:
    address: cosmos1..
    metadata: AQ==
    weight: "2"
- group_id: "1"
  member:
    address: cosmos1..
    metadata: AQ==
    weight: "1"
pagination:
  next_key: null
  total: "2"
```

**groups-by-admin**

The `groups-by-admin` command allows users to query for groups by admin account address with pagination flags.

```bash
simd query group groups-by-admin [admin] [flags]
```

Example:

```bash
simd query group groups-by-admin cosmos1..
```

Example Output:

```bash
groups:
- admin: cosmos1..
  group_id: "1"
  metadata: AQ==
  total_weight: "3"
  version: "1"
- admin: cosmos1..
  group_id: "2"
  metadata: AQ==
  total_weight: "3"
  version: "1"
pagination:
  next_key: null
  total: "2"
```

**group-policies-by-group**

The `group-policies-by-group` command allows users to query for group policies by group id with pagination flags.

```bash
simd query group group-policies-by-group [group-id] [flags]
```

Example:

```bash
simd query group group-policies-by-group 1
```

Example Output:

```bash
group_policies:
- address: cosmos1..
  admin: cosmos1..
  decision_policy:
    '@type': /cosmos.group.v1.ThresholdDecisionPolicy
    threshold: "1"
    windows:
      min_execution_period: 0s
      voting_period: 432000s
  group_id: "1"
  metadata: AQ==
  version: "1"
- address: cosmos1..
  admin: cosmos1..
  decision_policy:
    '@type': /cosmos.group.v1.ThresholdDecisionPolicy
    threshold: "1"
    windows:
      min_execution_period: 0s
      voting_period: 432000s
  group_id: "1"
  metadata: AQ==
  version: "1"
pagination:
  next_key: null
  total: "2"
```

**group-policies-by-admin**

The `group-policies-by-admin` command allows users to query for group policies by admin account address with pagination flags.

```bash
simd query group group-policies-by-admin [admin] [flags]
```

Example:

```bash
simd query group group-policies-by-admin cosmos1..
```

Example Output:

```bash
group_policies:
- address: cosmos1..
  admin: cosmos1..
  decision_policy:
    '@type': /cosmos.group.v1.ThresholdDecisionPolicy
    threshold: "1"
    windows:
      min_execution_period: 0s
      voting_period: 432000s
  group_id: "1"
  metadata: AQ==
  version: "1"
- address: cosmos1..
  admin: cosmos1..
  decision_policy:
    '@type': /cosmos.group.v1.ThresholdDecisionPolicy
    threshold: "1"
    windows:
      min_execution_period: 0s
      voting_period: 432000s
  group_id: "1"
  metadata: AQ==
  version: "1"
pagination:
  next_key: null
  total: "2"
```

**proposal**

The `proposal` command allows users to query for proposal by id.

```bash
simd query group proposal [id] [flags]
```

Example:

```bash
simd query group proposal 1
```

Example Output:

```bash
proposal:
  address: cosmos1..
  executor_result: EXECUTOR_RESULT_NOT_RUN
  group_policy_version: "1"
  group_version: "1"
  metadata: AQ==
  msgs:
  - '@type': /cosmos.bank.v1beta1.MsgSend
    amount:
    - amount: "100000000"
      denom: stake
    from_address: cosmos1..
    to_address: cosmos1..
  proposal_id: "1"
  proposers:
  - cosmos1..
  result: RESULT_UNFINALIZED
  status: STATUS_SUBMITTED
  submitted_at: "2021-12-17T07:06:26.310638964Z"
  windows:
    min_execution_period: 0s
    voting_period: 432000s
  vote_state:
    abstain_count: "0"
    no_count: "0"
    veto_count: "0"
    yes_count: "0"
  summary: "Summary"
  title: "Title"
```

**proposals-by-group-policy**

The `proposals-by-group-policy` command allows users to query for proposals by account address of group policy with pagination flags.

```bash
simd query group proposals-by-group-policy [group-policy-account] [flags]
```

Example:

```bash
simd query group proposals-by-group-policy cosmos1..
```

Example Output:

```bash
pagination:
  next_key: null
  total: "1"
proposals:
- address: cosmos1..
  executor_result: EXECUTOR_RESULT_NOT_RUN
  group_policy_version: "1"
  group_version: "1"
  metadata: AQ==
  msgs:
  - '@type': /cosmos.bank.v1beta1.MsgSend
    amount:
    - amount: "100000000"
      denom: stake
    from_address: cosmos1..
    to_address: cosmos1..
  proposal_id: "1"
  proposers:
  - cosmos1..
  result: RESULT_UNFINALIZED
  status: STATUS_SUBMITTED
  submitted_at: "2021-12-17T07:06:26.310638964Z"
  windows:
    min_execution_period: 0s
    voting_period: 432000s
  vote_state:
    abstain_count: "0"
    no_count: "0"
    veto_count: "0"
    yes_count: "0"
  summary: "Summary"
  title: "Title"
```

**vote**

The `vote` command allows users to query for vote by proposal id and voter account address.

```bash
simd query group vote [proposal-id] [voter] [flags]
```

Example:

```bash
simd query group vote 1 cosmos1..
```

Example Output:

```bash
vote:
  choice: CHOICE_YES
  metadata: AQ==
  proposal_id: "1"
  submitted_at: "2021-12-17T08:05:02.490164009Z"
  voter: cosmos1..
```

**votes-by-proposal**

The `votes-by-proposal` command allows users to query for votes by proposal id with pagination flags.

```bash
simd query group votes-by-proposal [proposal-id] [flags]
```

Example:

```bash
simd query group votes-by-proposal 1
```

Example Output:

```bash
pagination:
  next_key: null
  total: "1"
votes:
- choice: CHOICE_YES
  metadata: AQ==
  proposal_id: "1"
  submitted_at: "2021-12-17T08:05:02.490164009Z"
  voter: cosmos1..
```

**votes-by-voter**

The `votes-by-voter` command allows users to query for votes by voter account address with pagination flags.

```bash
simd query group votes-by-voter [voter] [flags]
```

Example:

```bash
simd query group votes-by-voter cosmos1..
```

Example Output:

```bash
pagination:
  next_key: null
  total: "1"
votes:
- choice: CHOICE_YES
  metadata: AQ==
  proposal_id: "1"
  submitted_at: "2021-12-17T08:05:02.490164009Z"
  voter: cosmos1..
```

### Transactions

The `tx` commands allow users to interact with the `group` module.

```bash
simd tx group --help
```

#### create-group

The `create-group` command allows users to create a group which is an aggregation of member accounts with associated weights and\
an administrator account.

```bash
simd tx group create-group [admin] [metadata] [members-json-file]
```

Example:

```bash
simd tx group create-group cosmos1.. "AQ==" members.json
```

#### update-group-admin

The `update-group-admin` command allows users to update a group's admin.

```bash
simd tx group update-group-admin [admin] [group-id] [new-admin] [flags]
```

Example:

```bash
simd tx group update-group-admin cosmos1.. 1 cosmos1..
```

#### update-group-members

The `update-group-members` command allows users to update a group's members.

```bash
simd tx group update-group-members [admin] [group-id] [members-json-file] [flags]
```

Example:

```bash
simd tx group update-group-members cosmos1.. 1 members.json
```

#### update-group-metadata

The `update-group-metadata` command allows users to update a group's metadata.

```bash
simd tx group update-group-metadata [admin] [group-id] [metadata] [flags]
```

Example:

```bash
simd tx group update-group-metadata cosmos1.. 1 "AQ=="
```

#### create-group-policy

The `create-group-policy` command allows users to create a group policy which is an account associated with a group and a decision policy.

```bash
simd tx group create-group-policy [admin] [group-id] [metadata] [decision-policy] [flags]
```

Example:

```bash
simd tx group create-group-policy cosmos1.. 1 "AQ==" '{"@type":"/cosmos.group.v1.ThresholdDecisionPolicy", "threshold":"1", "windows": {"voting_period": "120h", "min_execution_period": "0s"}}'
```

#### create-group-with-policy

The `create-group-with-policy` command allows users to create a group which is an aggregation of member accounts with associated weights and an administrator account with decision policy. If the `--group-policy-as-admin` flag is set to `true`, the group policy address becomes the group and group policy admin.

```bash
simd tx group create-group-with-policy [admin] [group-metadata] [group-policy-metadata] [members-json-file] [decision-policy] [flags]
```

Example:

```bash
simd tx group create-group-with-policy cosmos1.. "AQ==" "AQ==" members.json '{"@type":"/cosmos.group.v1.ThresholdDecisionPolicy", "threshold":"1", "windows": {"voting_period": "120h", "min_execution_period": "0s"}}'
```

#### update-group-policy-admin

The `update-group-policy-admin` command allows users to update a group policy admin.

```bash
simd tx group update-group-policy-admin [admin] [group-policy-account] [new-admin] [flags]
```

Example:

```bash
simd tx group update-group-policy-admin cosmos1.. cosmos1.. cosmos1..
```

#### update-group-policy-metadata

The `update-group-policy-metadata` command allows users to update a group policy metadata.

```bash
simd tx group update-group-policy-metadata [admin] [group-policy-account] [new-metadata] [flags]
```

Example:

```bash
simd tx group update-group-policy-metadata cosmos1.. cosmos1.. "AQ=="
```

#### update-group-policy-decision-policy

The `update-group-policy-decision-policy` command allows users to update a group policy's decision policy.

```bash
simd  tx group update-group-policy-decision-policy [admin] [group-policy-account] [decision-policy] [flags]
```

Example:

```bash
simd tx group update-group-policy-decision-policy cosmos1.. cosmos1.. '{"@type":"/cosmos.group.v1.ThresholdDecisionPolicy", "threshold":"2", "windows": {"voting_period": "120h", "min_execution_period": "0s"}}'
```

#### submit-proposal

The `submit-proposal` command allows users to submit a new proposal.

```bash
simd tx group submit-proposal [group-policy-account] [proposer[,proposer]*] [msg_tx_json_file] [metadata] [flags]
```

Example:

```bash
simd tx group submit-proposal cosmos1.. cosmos1.. msg_tx.json "AQ=="
```

#### withdraw-proposal

The `withdraw-proposal` command allows users to withdraw a proposal.

```bash
simd tx group withdraw-proposal [proposal-id] [group-policy-admin-or-proposer]
```

Example:

```bash
simd tx group withdraw-proposal 1 cosmos1..
```

#### vote

The `vote` command allows users to vote on a proposal.

```bash
simd tx group vote proposal-id] [voter] [choice] [metadata] [flags]
```

Example:

```bash
simd tx group vote 1 cosmos1.. CHOICE_YES "AQ=="
```

#### exec

The `exec` command allows users to execute a proposal.

```bash
simd tx group exec [proposal-id] [flags]
```

Example:

```bash
simd tx group exec 1
```

#### leave-group

The `leave-group` command allows group member to leave the group.

```bash
simd tx group leave-group [member-address] [group-id]
```

Example:

```bash
simd tx group leave-group cosmos1... 1
```

### gRPC

A user can query the `group` module using gRPC endpoints.

#### GroupInfo

The `GroupInfo` endpoint allows users to query for group info by given group id.

```bash
cosmos.group.v1.Query/GroupInfo
```

Example:

```bash
grpcurl -plaintext \
    -d '{"group_id":1}' localhost:9090 cosmos.group.v1.Query/GroupInfo
```

Example Output:

```bash
{
  "info": {
    "groupId": "1",
    "admin": "cosmos1..",
    "metadata": "AQ==",
    "version": "1",
    "totalWeight": "3"
  }
}
```

#### GroupPolicyInfo

The `GroupPolicyInfo` endpoint allows users to query for group policy info by account address of group policy.

```bash
cosmos.group.v1.Query/GroupPolicyInfo
```

Example:

```bash
grpcurl -plaintext \
    -d '{"address":"cosmos1.."}'  localhost:9090 cosmos.group.v1.Query/GroupPolicyInfo
```

Example Output:

```bash
{
  "info": {
    "address": "cosmos1..",
    "groupId": "1",
    "admin": "cosmos1..",
    "version": "1",
    "decisionPolicy": {"@type":"/cosmos.group.v1.ThresholdDecisionPolicy","threshold":"1","windows": {"voting_period": "120h", "min_execution_period": "0s"}},
  }
}
```

#### GroupMembers

The `GroupMembers` endpoint allows users to query for group members by group id with pagination flags.

```bash
cosmos.group.v1.Query/GroupMembers
```

Example:

```bash
grpcurl -plaintext \
    -d '{"group_id":"1"}'  localhost:9090 cosmos.group.v1.Query/GroupMembers
```

Example Output:

```bash
{
  "members": [
    {
      "groupId": "1",
      "member": {
        "address": "cosmos1..",
        "weight": "1"
      }
    },
    {
      "groupId": "1",
      "member": {
        "address": "cosmos1..",
        "weight": "2"
      }
    }
  ],
  "pagination": {
    "total": "2"
  }
}
```

#### GroupsByAdmin

The `GroupsByAdmin` endpoint allows users to query for groups by admin account address with pagination flags.

```bash
cosmos.group.v1.Query/GroupsByAdmin
```

Example:

```bash
grpcurl -plaintext \
    -d '{"admin":"cosmos1.."}'  localhost:9090 cosmos.group.v1.Query/GroupsByAdmin
```

Example Output:

```bash
{
  "groups": [
    {
      "groupId": "1",
      "admin": "cosmos1..",
      "metadata": "AQ==",
      "version": "1",
      "totalWeight": "3"
    },
    {
      "groupId": "2",
      "admin": "cosmos1..",
      "metadata": "AQ==",
      "version": "1",
      "totalWeight": "3"
    }
  ],
  "pagination": {
    "total": "2"
  }
}
```

#### GroupPoliciesByGroup

The `GroupPoliciesByGroup` endpoint allows users to query for group policies by group id with pagination flags.

```bash
cosmos.group.v1.Query/GroupPoliciesByGroup
```

Example:

```bash
grpcurl -plaintext \
    -d '{"group_id":"1"}'  localhost:9090 cosmos.group.v1.Query/GroupPoliciesByGroup
```

Example Output:

```bash
{
  "GroupPolicies": [
    {
      "address": "cosmos1..",
      "groupId": "1",
      "admin": "cosmos1..",
      "version": "1",
      "decisionPolicy": {"@type":"/cosmos.group.v1.ThresholdDecisionPolicy","threshold":"1","windows":{"voting_period": "120h", "min_execution_period": "0s"}},
    },
    {
      "address": "cosmos1..",
      "groupId": "1",
      "admin": "cosmos1..",
      "version": "1",
      "decisionPolicy": {"@type":"/cosmos.group.v1.ThresholdDecisionPolicy","threshold":"1","windows":{"voting_period": "120h", "min_execution_period": "0s"}},
    }
  ],
  "pagination": {
    "total": "2"
  }
}
```

#### GroupPoliciesByAdmin

The `GroupPoliciesByAdmin` endpoint allows users to query for group policies by admin account address with pagination flags.

```bash
cosmos.group.v1.Query/GroupPoliciesByAdmin
```

Example:

```bash
grpcurl -plaintext \
    -d '{"admin":"cosmos1.."}'  localhost:9090 cosmos.group.v1.Query/GroupPoliciesByAdmin
```

Example Output:

```bash
{
  "GroupPolicies": [
    {
      "address": "cosmos1..",
      "groupId": "1",
      "admin": "cosmos1..",
      "version": "1",
      "decisionPolicy": {"@type":"/cosmos.group.v1.ThresholdDecisionPolicy","threshold":"1","windows":{"voting_period": "120h", "min_execution_period": "0s"}},
    },
    {
      "address": "cosmos1..",
      "groupId": "1",
      "admin": "cosmos1..",
      "version": "1",
      "decisionPolicy": {"@type":"/cosmos.group.v1.ThresholdDecisionPolicy","threshold":"1","windows":{"voting_period": "120h", "min_execution_period": "0s"}},
    }
  ],
  "pagination": {
    "total": "2"
  }
}
```

#### Proposal

The `Proposal` endpoint allows users to query for proposal by id.

```bash
cosmos.group.v1.Query/Proposal
```

Example:

```bash
grpcurl -plaintext \
    -d '{"proposal_id":"1"}'  localhost:9090 cosmos.group.v1.Query/Proposal
```

Example Output:

```bash
{
  "proposal": {
    "proposalId": "1",
    "address": "cosmos1..",
    "proposers": [
      "cosmos1.."
    ],
    "submittedAt": "2021-12-17T07:06:26.310638964Z",
    "groupVersion": "1",
    "GroupPolicyVersion": "1",
    "status": "STATUS_SUBMITTED",
    "result": "RESULT_UNFINALIZED",
    "voteState": {
      "yesCount": "0",
      "noCount": "0",
      "abstainCount": "0",
      "vetoCount": "0"
    },
    "windows": {
      "min_execution_period": "0s",
      "voting_period": "432000s"
    },
    "executorResult": "EXECUTOR_RESULT_NOT_RUN",
    "messages": [
      {"@type":"/cosmos.bank.v1beta1.MsgSend","amount":[{"denom":"stake","amount":"100000000"}],"fromAddress":"cosmos1..","toAddress":"cosmos1.."}
    ],
    "title": "Title",
    "summary": "Summary",
  }
}
```

#### ProposalsByGroupPolicy

The `ProposalsByGroupPolicy` endpoint allows users to query for proposals by account address of group policy with pagination flags.

```bash
cosmos.group.v1.Query/ProposalsByGroupPolicy
```

Example:

```bash
grpcurl -plaintext \
    -d '{"address":"cosmos1.."}'  localhost:9090 cosmos.group.v1.Query/ProposalsByGroupPolicy
```

Example Output:

```bash
{
  "proposals": [
    {
      "proposalId": "1",
      "address": "cosmos1..",
      "proposers": [
        "cosmos1.."
      ],
      "submittedAt": "2021-12-17T08:03:27.099649352Z",
      "groupVersion": "1",
      "GroupPolicyVersion": "1",
      "status": "STATUS_CLOSED",
      "result": "RESULT_ACCEPTED",
      "voteState": {
        "yesCount": "1",
        "noCount": "0",
        "abstainCount": "0",
        "vetoCount": "0"
      },
      "windows": {
        "min_execution_period": "0s",
        "voting_period": "432000s"
      },
      "executorResult": "EXECUTOR_RESULT_NOT_RUN",
      "messages": [
        {"@type":"/cosmos.bank.v1beta1.MsgSend","amount":[{"denom":"stake","amount":"100000000"}],"fromAddress":"cosmos1..","toAddress":"cosmos1.."}
      ],
      "title": "Title",
      "summary": "Summary",
    }
  ],
  "pagination": {
    "total": "1"
  }
}
```

#### VoteByProposalVoter

The `VoteByProposalVoter` endpoint allows users to query for vote by proposal id and voter account address.

```bash
cosmos.group.v1.Query/VoteByProposalVoter
```

Example:

```bash
grpcurl -plaintext \
    -d '{"proposal_id":"1","voter":"cosmos1.."}'  localhost:9090 cosmos.group.v1.Query/VoteByProposalVoter
```

Example Output:

```bash
{
  "vote": {
    "proposalId": "1",
    "voter": "cosmos1..",
    "choice": "CHOICE_YES",
    "submittedAt": "2021-12-17T08:05:02.490164009Z"
  }
}
```

#### VotesByProposal

The `VotesByProposal` endpoint allows users to query for votes by proposal id with pagination flags.

```bash
cosmos.group.v1.Query/VotesByProposal
```

Example:

```bash
grpcurl -plaintext \
    -d '{"proposal_id":"1"}'  localhost:9090 cosmos.group.v1.Query/VotesByProposal
```

Example Output:

```bash
{
  "votes": [
    {
      "proposalId": "1",
      "voter": "cosmos1..",
      "choice": "CHOICE_YES",
      "submittedAt": "2021-12-17T08:05:02.490164009Z"
    }
  ],
  "pagination": {
    "total": "1"
  }
}
```

#### VotesByVoter

The `VotesByVoter` endpoint allows users to query for votes by voter account address with pagination flags.

```bash
cosmos.group.v1.Query/VotesByVoter
```

Example:

```bash
grpcurl -plaintext \
    -d '{"voter":"cosmos1.."}'  localhost:9090 cosmos.group.v1.Query/VotesByVoter
```

Example Output:

```bash
{
  "votes": [
    {
      "proposalId": "1",
      "voter": "cosmos1..",
      "choice": "CHOICE_YES",
      "submittedAt": "2021-12-17T08:05:02.490164009Z"
    }
  ],
  "pagination": {
    "total": "1"
  }
}
```

### REST

A user can query the `group` module using REST endpoints.

#### GroupInfo

The `GroupInfo` endpoint allows users to query for group info by given group id.

```bash
/cosmos/group/v1/group_info/{group_id}
```

Example:

```bash
curl localhost:1317/cosmos/group/v1/group_info/1
```

Example Output:

```bash
{
  "info": {
    "id": "1",
    "admin": "cosmos1..",
    "metadata": "AQ==",
    "version": "1",
    "total_weight": "3"
  }
}
```

#### GroupPolicyInfo

The `GroupPolicyInfo` endpoint allows users to query for group policy info by account address of group policy.

```bash
/cosmos/group/v1/group_policy_info/{address}
```

Example:

```bash
curl localhost:1317/cosmos/group/v1/group_policy_info/cosmos1..
```

Example Output:

```bash
{
  "info": {
    "address": "cosmos1..",
    "group_id": "1",
    "admin": "cosmos1..",
    "metadata": "AQ==",
    "version": "1",
    "decision_policy": {
      "@type": "/cosmos.group.v1.ThresholdDecisionPolicy",
      "threshold": "1",
      "windows": {
        "voting_period": "120h",
        "min_execution_period": "0s"
      }
    },
  }
}
```

#### GroupMembers

The `GroupMembers` endpoint allows users to query for group members by group id with pagination flags.

```bash
/cosmos/group/v1/group_members/{group_id}
```

Example:

```bash
curl localhost:1317/cosmos/group/v1/group_members/1
```

Example Output:

```bash
{
  "members": [
    {
      "group_id": "1",
      "member": {
        "address": "cosmos1..",
        "weight": "1",
        "metadata": "AQ=="
      }
    },
    {
      "group_id": "1",
      "member": {
        "address": "cosmos1..",
        "weight": "2",
        "metadata": "AQ=="
    }
  ],
  "pagination": {
    "next_key": null,
    "total": "2"
  }
}
```

#### GroupsByAdmin

The `GroupsByAdmin` endpoint allows users to query for groups by admin account address with pagination flags.

```bash
/cosmos/group/v1/groups_by_admin/{admin}
```

Example:

```bash
curl localhost:1317/cosmos/group/v1/groups_by_admin/cosmos1..
```

Example Output:

```bash
{
  "groups": [
    {
      "id": "1",
      "admin": "cosmos1..",
      "metadata": "AQ==",
      "version": "1",
      "total_weight": "3"
    },
    {
      "id": "2",
      "admin": "cosmos1..",
      "metadata": "AQ==",
      "version": "1",
      "total_weight": "3"
    }
  ],
  "pagination": {
    "next_key": null,
    "total": "2"
  }
}
```

#### GroupPoliciesByGroup

The `GroupPoliciesByGroup` endpoint allows users to query for group policies by group id with pagination flags.

```bash
/cosmos/group/v1/group_policies_by_group/{group_id}
```

Example:

```bash
curl localhost:1317/cosmos/group/v1/group_policies_by_group/1
```

Example Output:

```bash
{
  "group_policies": [
    {
      "address": "cosmos1..",
      "group_id": "1",
      "admin": "cosmos1..",
      "metadata": "AQ==",
      "version": "1",
      "decision_policy": {
        "@type": "/cosmos.group.v1.ThresholdDecisionPolicy",
        "threshold": "1",
        "windows": {
          "voting_period": "120h",
          "min_execution_period": "0s"
      }
      },
    },
    {
      "address": "cosmos1..",
      "group_id": "1",
      "admin": "cosmos1..",
      "metadata": "AQ==",
      "version": "1",
      "decision_policy": {
        "@type": "/cosmos.group.v1.ThresholdDecisionPolicy",
        "threshold": "1",
        "windows": {
          "voting_period": "120h",
          "min_execution_period": "0s"
      }
      },
    }
  ],
  "pagination": {
    "next_key": null,
    "total": "2"
  }
}
```

#### GroupPoliciesByAdmin

The `GroupPoliciesByAdmin` endpoint allows users to query for group policies by admin account address with pagination flags.

```bash
/cosmos/group/v1/group_policies_by_admin/{admin}
```

Example:

```bash
curl localhost:1317/cosmos/group/v1/group_policies_by_admin/cosmos1..
```

Example Output:

```bash
{
  "group_policies": [
    {
      "address": "cosmos1..",
      "group_id": "1",
      "admin": "cosmos1..",
      "metadata": "AQ==",
      "version": "1",
      "decision_policy": {
        "@type": "/cosmos.group.v1.ThresholdDecisionPolicy",
        "threshold": "1",
        "windows": {
          "voting_period": "120h",
          "min_execution_period": "0s"
      } 
      },
    },
    {
      "address": "cosmos1..",
      "group_id": "1",
      "admin": "cosmos1..",
      "metadata": "AQ==",
      "version": "1",
      "decision_policy": {
        "@type": "/cosmos.group.v1.ThresholdDecisionPolicy",
        "threshold": "1",
        "windows": {
          "voting_period": "120h",
          "min_execution_period": "0s"
      }
      },
    }
  ],
  "pagination": {
    "next_key": null,
    "total": "2"
  }
```

#### Proposal

The `Proposal` endpoint allows users to query for proposal by id.

```bash
/cosmos/group/v1/proposal/{proposal_id}
```

Example:

```bash
curl localhost:1317/cosmos/group/v1/proposal/1
```

Example Output:

```bash
{
  "proposal": {
    "proposal_id": "1",
    "address": "cosmos1..",
    "metadata": "AQ==",
    "proposers": [
      "cosmos1.."
    ],
    "submitted_at": "2021-12-17T07:06:26.310638964Z",
    "group_version": "1",
    "group_policy_version": "1",
    "status": "STATUS_SUBMITTED",
    "result": "RESULT_UNFINALIZED",
    "vote_state": {
      "yes_count": "0",
      "no_count": "0",
      "abstain_count": "0",
      "veto_count": "0"
    },
    "windows": {
      "min_execution_period": "0s",
      "voting_period": "432000s"
    },
    "executor_result": "EXECUTOR_RESULT_NOT_RUN",
    "messages": [
      {
        "@type": "/cosmos.bank.v1beta1.MsgSend",
        "from_address": "cosmos1..",
        "to_address": "cosmos1..",
        "amount": [
          {
            "denom": "stake",
            "amount": "100000000"
          }
        ]
      }
    ],
    "title": "Title",
    "summary": "Summary",
  }
}
```

#### ProposalsByGroupPolicy

The `ProposalsByGroupPolicy` endpoint allows users to query for proposals by account address of group policy with pagination flags.

```bash
/cosmos/group/v1/proposals_by_group_policy/{address}
```

Example:

```bash
curl localhost:1317/cosmos/group/v1/proposals_by_group_policy/cosmos1..
```

Example Output:

```bash
{
  "proposals": [
    {
      "id": "1",
      "group_policy_address": "cosmos1..",
      "metadata": "AQ==",
      "proposers": [
        "cosmos1.."
      ],
      "submit_time": "2021-12-17T08:03:27.099649352Z",
      "group_version": "1",
      "group_policy_version": "1",
      "status": "STATUS_CLOSED",
      "result": "RESULT_ACCEPTED",
      "vote_state": {
        "yes_count": "1",
        "no_count": "0",
        "abstain_count": "0",
        "veto_count": "0"
      },
      "windows": {
        "min_execution_period": "0s",
        "voting_period": "432000s"
      },
      "executor_result": "EXECUTOR_RESULT_NOT_RUN",
      "messages": [
        {
          "@type": "/cosmos.bank.v1beta1.MsgSend",
          "from_address": "cosmos1..",
          "to_address": "cosmos1..",
          "amount": [
            {
              "denom": "stake",
              "amount": "100000000"
            }
          ]
        }
      ]
    }
  ],
  "pagination": {
    "next_key": null,
    "total": "1"
  }
}
```

#### VoteByProposalVoter

The `VoteByProposalVoter` endpoint allows users to query for vote by proposal id and voter account address.

```bash
/cosmos/group/v1/vote_by_proposal_voter/{proposal_id}/{voter}
```

Example:

```bash
curl localhost:1317/cosmos/group/v1beta1/vote_by_proposal_voter/1/cosmos1..
```

Example Output:

```bash
{
  "vote": {
    "proposal_id": "1",
    "voter": "cosmos1..",
    "choice": "CHOICE_YES",
    "metadata": "AQ==",
    "submitted_at": "2021-12-17T08:05:02.490164009Z"
  }
}
```

#### VotesByProposal

The `VotesByProposal` endpoint allows users to query for votes by proposal id with pagination flags.

```bash
/cosmos/group/v1/votes_by_proposal/{proposal_id}
```

Example:

```bash
curl localhost:1317/cosmos/group/v1/votes_by_proposal/1
```

Example Output:

```bash
{
  "votes": [
    {
      "proposal_id": "1",
      "voter": "cosmos1..",
      "option": "CHOICE_YES",
      "metadata": "AQ==",
      "submit_time": "2021-12-17T08:05:02.490164009Z"
    }
  ],
  "pagination": {
    "next_key": null,
    "total": "1"
  }
}
```

#### VotesByVoter

The `VotesByVoter` endpoint allows users to query for votes by voter account address with pagination flags.

```bash
/cosmos/group/v1/votes_by_voter/{voter}
```

Example:

```bash
curl localhost:1317/cosmos/group/v1/votes_by_voter/cosmos1..
```

Example Output:

```bash
{
  "votes": [
    {
      "proposal_id": "1",
      "voter": "cosmos1..",
      "choice": "CHOICE_YES",
      "metadata": "AQ==",
      "submitted_at": "2021-12-17T08:05:02.490164009Z"
    }
  ],
  "pagination": {
    "next_key": null,
    "total": "1"
  }
}
```

## 元数据

组模块有四个元数据位置，用户可以在其中提供有关他们正在执行的链上操作的进一步上下文。默认情况下，所有元数据字段都有一个 255 字符长度的字段，元数据可以以 json 格式存储，根据所需的数据量，可以存储在链上或链下。在这里，我们提供 json 结构的建议以及数据应存储的位置。在制定这些建议时有两个重要因素。首先，group 和 gov 模块彼此一致，请注意所有组提出的提案数量可能相当大。其次，客户端应用程序（如区块浏览器和治理界面）对跨链元数据结构的一致性有信心。

### 提案

位置：链下，作为存储在 IPFS 上的 json 对象（镜像 [gov proposal](gov.md#metadata)）

```json
{
  "title": "",
  "authors": [""],
  "summary": "",
  "details": "",
  "proposal_forum_url": "",
  "vote_option_context": "",
}
```

:::note\
`authors` 字段是一个字符串数组，这是为了允许在元数据中列出多个作者。\
在 v0.46 中，`authors` 字段是一个逗号分隔的字符串。鼓励前端支持两种格式以保持向后兼容性。\
:::

### 投票

位置：链上，作为 json，限制在 255 个字符内（镜像 [gov vote](gov.md#metadata)）

```json
{
  "justification": "",
}
```

### 组

位置：链下，作为存储在 IPFS 上的 json 对象

```json
{
  "name": "",
  "description": "",
  "group_website_url": "",
  "group_forum_url": "",
}
```

### 决策策略

位置：链上，作为 json，限制在 255 个字符内

```json
{
  "name": "",
  "description": "",
}
```
