---
sidebar_position: 1
---

# 治理

## 摘要

本文档规定了 Cosmos SDK 的治理模块，该模块首次在 2016 年 6 月的 [Cosmos 白皮书](https://cosmos.network/about/whitepaper)中描述。

该模块使基于 Cosmos SDK 的区块链能够支持链上治理系统。在该系统中，链的原生质押代币持有者可以按照 1 代币 1 票的原则对提案进行投票。以下是该模块目前支持的功能列表：

* **提案提交：** 用户可以提交带押金的提案。一旦达到最低押金，提案进入投票期。最低押金可以通过在押金期内从不同用户（包括提案者）收集押金来达到。
* **投票：** 参与者可以对达到 MinDeposit 并进入投票期的提案进行投票。
* **继承和惩罚：** 如果委托者自己不投票，他们将继承其验证者的投票。
* **提取押金：** 在提案上存入押金的用户，如果提案被接受或拒绝，可以收回押金。如果提案被否决，或从未进入投票期（在押金期内未达到最低押金），押金将被销毁。

该模块在 Cosmos Hub（也称为 [gaia](https://github.com/cosmos/gaia)）上使用。未来可能添加的功能在[未来改进](gov.md#future-improvements)中描述。

## 目录

以下规范使用 _ATOM_ 作为原生质押代币。该模块可以通过将 _ATOM_ 替换为链的原生质押代币来适配任何权益证明区块链。

* [概念](gov.md#concepts)
  * [提案提交](gov.md#proposal-submission)
  * [押金](gov.md#deposit)
  * [投票](gov.md#vote)
  * [软件升级](gov.md#software-upgrade)
* [状态](gov.md#state)
  * [提案](gov.md#proposals)
  * [参数和基础类型](gov.md#parameters-and-base-types)
  * [押金](gov.md#deposit-1)
  * [ValidatorGovInfo](gov.md#validatorgovinfo)
  * [存储](gov.md#stores)
  * [提案处理队列](gov.md#proposal-processing-queue)
  * [遗留提案](gov.md#legacy-proposal)
* [消息](gov.md#messages)
  * [提案提交](gov.md#proposal-submission-1)
  * [押金](gov.md#deposit-2)
  * [投票](gov.md#vote-1)
* [事件](gov.md#events)
  * [EndBlocker](gov.md#endblocker)
  * [处理器](gov.md#handlers)
* [参数](gov.md#parameters)
* [客户端](gov.md#client)
  * [CLI](gov.md#cli)
  * [gRPC](gov.md#grpc)
  * [REST](gov.md#rest)
* [元数据](gov.md#metadata)
  * [提案](gov.md#proposal-3)
  * [投票](gov.md#vote-5)
* [未来改进](gov.md#future-improvements)

## 概念

_免责声明：这是正在进行的工作。机制可能会发生变化。_

治理过程分为以下几个步骤：

* **提案提交：** 提案通过押金提交到区块链。
* **投票：** 一旦押金达到某个值（`MinDeposit`），提案被确认并开始投票。已绑定的 Atom 持有者可以发送 `TxGovVote` 交易对提案进行投票。
* **执行：** 经过一段时间后，投票被统计，根据结果，提案中的消息将被执行。

### 提案提交

#### 提交提案的权利

每个账户都可以通过发送 `MsgSubmitProposal` 交易来提交提案。一旦提案被提交，它由其唯一的 `proposalID` 标识。

#### 提案消息

提案包含一个 `sdk.Msg` 数组，如果提案通过，这些消息将自动执行。消息由治理 `ModuleAccount` 本身执行。像 `x/upgrade` 这样希望只允许治理执行某些消息的模块，应该在相应的消息服务器中添加白名单，授予治理模块在达到法定人数后执行消息的权利。治理模块使用 `MsgServiceRouter` 检查这些消息是否正确构造并具有相应的执行路径，但不执行完整的有效性检查。

### 押金

为了防止垃圾信息，提案必须使用 `MinDeposit` 参数定义的代币提交押金。

当提交提案时，必须附带押金，押金必须严格为正数，但可以低于 `MinDeposit`。提交者不需要自己支付全部押金。新创建的提案存储在_非活跃提案队列_中，并一直保留在那里，直到其押金超过 `MinDeposit`。其他代币持有者可以通过发送 `Deposit` 交易来增加提案的押金。如果提案在押金结束时间（不再接受押金的时间）之前未达到 `MinDeposit`，提案将被销毁：提案将从状态中移除，押金将被销毁（参见 x/gov `EndBlocker`）。当提案押金在押金结束时间之前超过 `MinDeposit` 阈值（即使在提案提交期间），提案将被移动到_活跃提案队列_，投票期将开始。

押金由治理 `ModuleAccount` 保管，直到提案最终确定（通过或拒绝）。

#### 押金退还和销毁

当提案最终确定时，押金中的代币根据提案的最终统计结果被退还或销毁：

* 如果提案被批准或拒绝但_未_被否决，每笔押金将自动退还给相应的存款人（从治理 `ModuleAccount` 转移）。
* 当提案被超过 1/3 的投票否决时，押金将从治理 `ModuleAccount` 中销毁，提案信息及其押金信息将从状态中移除。
* 所有退还或销毁的押金都从状态中移除。在销毁或退还押金时会发出事件。

### 投票

#### 参与者

_参与者_是有权对提案进行投票的用户。在 Cosmos Hub 上，参与者是已绑定的 Atom 持有者。未绑定的 Atom 持有者和其他用户没有参与治理的权利。但是，他们可以提交提案并在提案上存入押金。

请注意，当_参与者_同时拥有已绑定和未绑定的 Atoms 时，他们的投票权仅根据其已绑定的 Atom 持有量计算。

#### 投票期

一旦提案达到 `MinDeposit`，它立即进入`投票期`。我们将`投票期`定义为投票开始和投票结束之间的时间间隔。`投票期`的初始值为 2 周。

#### 选项集

提案的选项集是指参与者在投票时可以选择的一组选项。

初始选项集包括以下选项：

* `Yes`（是）
* `No`（否）
* `NoWithVeto`（否决）
* `Abstain`（弃权）

`NoWithVeto` 计为 `No`，但也会添加一个 `Veto` 投票。`Abstain` 选项允许投票者表示他们不打算投票支持或反对提案，但接受投票结果。

_注意：从 UI 的角度来看，对于紧急提案，我们也许应该添加一个"不紧急"选项，该选项会投出 `NoWithVeto` 投票。_

#### 加权投票

[ADR-037](https://github.com/cosmos/cosmos-sdk/blob/main/docs/architecture/adr-037-gov-split-vote.md) 引入了加权投票功能，允许质押者将其投票分成多个投票选项。例如，它可以使用 70% 的投票权投票"是"，使用 30% 的投票权投票"否"。

拥有该地址的实体通常可能不是单个个人。例如，一家公司可能有不同的利益相关者，他们希望以不同的方式投票，因此允许他们分割投票权是有意义的。目前，他们无法进行"透传投票"并给予用户对其代币的投票权。但是，通过这个系统，交易所可以对其用户进行投票偏好调查，然后根据调查结果按比例在链上投票。

为了在链上表示加权投票，我们使用以下 Protobuf 消息。

```protobuf
https://github.com/cosmos/cosmos-sdk/blob/v0.47.0-rc1/proto/cosmos/gov/v1beta1/gov.proto#L34-L47
```

```protobuf
https://github.com/cosmos/cosmos-sdk/blob/v0.47.0-rc1/proto/cosmos/gov/v1beta1/gov.proto#L181-L201
```

为了使加权投票有效，`options` 字段不得包含重复的投票选项，并且所有选项的权重之和必须等于 1。

### 法定人数

法定人数定义为提案结果有效所需的最低投票权百分比。

### 快速提案

提案可以被加速，使提案默认使用更短的投票持续时间和更高的统计阈值。如果快速提案在较短投票持续时间内未能达到阈值，则快速提案将转换为常规提案，并在常规投票条件下重新开始投票。

#### 阈值

阈值定义为提案被接受所需的最低 `Yes` 投票比例（不包括 `Abstain` 投票）。

最初，阈值设置为 `Yes` 投票的 50%，不包括 `Abstain` 投票。如果超过 1/3 的投票是 `NoWithVeto` 投票，则存在否决的可能性。请注意，这两个值都来自链上参数 `TallyParams`，可以通过治理进行修改。这意味着提案在以下情况下被接受：

* 存在已绑定的代币。
* 已达到法定人数。
* `Abstain` 投票的比例低于 1/1。
* `NoWithVeto` 投票的比例低于 1/3，包括 `Abstain` 投票。
* 在投票期结束时，`Yes` 投票的比例（不包括 `Abstain` 投票）超过 1/2。

对于快速提案，默认情况下，阈值高于_常规提案_，即 66.7%。

#### 继承

如果委托者不投票，它将继承其验证者的投票。

* 如果委托者在验证者之前投票，它将不会继承验证者的投票。
* 如果委托者在验证者之后投票，它将用自己的投票覆盖验证者的投票。如果提案很紧急，投票可能在委托者有机会做出反应并覆盖其验证者的投票之前就结束了。这不是问题，因为提案在投票期结束时统计需要超过总投票权的 2/3 才能通过。因为只要 1/3 + 1 的验证权就可以合谋审查交易，所以对于超过此阈值的范围，已经假设不存在合谋。

#### 验证者不投票的惩罚

目前，验证者不会因未能投票而受到惩罚。

#### 治理地址

将来，我们可能会添加只能签署来自某些模块的交易的有权限密钥。对于 MVP，`治理地址`将是账户创建时生成的主要验证者地址。该地址对应于与负责签署共识消息的 CometBFT PrivKey 不同的 PrivKey。因此，验证者不必使用敏感的 CometBFT PrivKey 签署治理交易。

#### 可销毁参数

有三个参数定义提案的押金是否应该被销毁或退还给存款人。

* `BurnVoteVeto` 如果提案被否决，则销毁提案押金。
* `BurnVoteQuorum` 如果投票未达到法定人数，则销毁提案押金。
* `BurnProposalDepositPrevote` 如果提案未进入投票阶段，则销毁提案押金。

> 注意：这些参数可以通过治理进行修改。

## 状态

### 宪法

`Constitution` 在创世状态中找到。它是一个字符串字段，旨在用于描述特定区块链的目的及其预期规范。以下是宪法字段可以如何使用的一些示例：

* 定义链的目的，为其未来发展奠定基础
* 为委托者设定期望
* 为验证者设定期望
* 定义链与"现实世界"实体的关系，如基金会或公司

由于这更像是一个社会功能而不是技术功能，我们现在将讨论一些在创世宪法中可能有用的项目：

* 治理存在哪些限制（如果有的话）？
  * 社区是否可以削减他们不再希望存在的大户钱包？（参见：Juno 提案 4 和 16）
  * 治理是否可以"社会性削减"使用未经批准的 MEV 的验证者？（参见：commonwealth.im/osmosis）
  * 在经济紧急情况下，验证者应该做什么？
    * 2022 年 5 月的 Terra 崩溃，看到验证者选择运行一个包含未经治理批准的代码的新二进制文件，因为治理代币已经被通胀到一文不值。
* 链的具体目的是什么？
  * 最好的例子是 Cosmos hub，不同的创始团体对网络的目的有不同的解释。

这个创世条目"constitution"不是为现有链设计的，现有链应该使用其治理系统来批准宪法。相反，这是为新链设计的。它将使验证者在运行其节点时对目的和期望有更清晰的认识。同样，对于社区成员来说，宪法将让他们了解可以从"链团队"和验证者那里期望什么。

这个宪法被设计为不可变的，并且只放在创世中，尽管随着时间的推移，通过向 cosmos-sdk 提交允许通过治理修改宪法的拉取请求，这可能会改变。希望修改其原始宪法的社区应该使用治理机制和"信号提案"来做到这一点。

**Cosmos 链宪法的理想使用场景**

作为链开发者，您决定希望为您的关键用户群体提供清晰度：

* 验证者
* 代币持有者
* 开发者（您自己）

您使用宪法在创世中不可变地存储一些 Markdown，这样当出现困难问题时，宪法可以为社区提供指导。

### 提案

`Proposal` 对象用于统计投票并通常跟踪提案的状态。它们包含一个任意的 `sdk.Msg` 数组，治理模块将尝试解析这些消息，如果提案通过，则执行它们。`Proposal` 由唯一 id 标识，并包含一系列时间戳：`submit_time`、`deposit_end_time`、`voting_start_time`、`voting_end_time`，这些时间戳跟踪提案的生命周期。

```protobuf
https://github.com/cosmos/cosmos-sdk/blob/v0.47.0-rc1/proto/cosmos/gov/v1/gov.proto#L51-L99
```

提案通常不仅需要一组消息来解释其目的，还需要一些更大的理由，并允许感兴趣的参与者讨论和辩论提案。在大多数情况下，**鼓励拥有支持链上治理过程的链下系统**。为了适应这一点，提案包含一个特殊的 **`metadata`** 字段，一个字符串，可用于为提案添加上下文。`metadata` 字段允许网络自定义使用，但是，期望该字段包含 URL 或使用 [IPFS](https://docs.ipfs.io/concepts/content-addressing/) 等系统的某种形式的 CID。为了支持跨网络的互操作性，SDK 建议 `metadata` 表示以下 `JSON` 模板：

```json
{
  "title": "...",
  "description": "...",
  "forum": "...", // 讨论平台的链接（例如 Discord）
  "other": "..." // 任何不对应其他字段的额外数据
}
```

这使得客户端更容易支持多个网络。

元数据有一个最大长度，由应用程序开发者选择，并作为配置传递给 gov keeper。SDK 中的默认最大长度为 255 个字符。

#### 编写使用治理的模块

链或各个模块的许多方面，您可能希望使用治理来执行，例如更改各种参数。这非常简单。首先，写出您的消息类型和 `MsgServer` 实现。向 keeper 添加一个 `authority` 字段，该字段将在构造函数中使用治理模块账户填充：`govKeeper.GetGovernanceAccount().GetAddress()`。然后对于 `msg_server.go` 中的方法，对消息执行检查，确保签名者匹配 `authority`。这将防止任何用户执行该消息。

### 参数和基础类型

`Parameters` 定义了投票运行的规则。在任何给定时间只能有一个活动参数集。如果治理想要更改参数集，无论是修改值还是添加/删除参数字段，都必须创建新的参数集，并使之前的参数集变为非活动状态。

#### DepositParams

```protobuf
https://github.com/cosmos/cosmos-sdk/blob/v0.47.0-rc1/proto/cosmos/gov/v1/gov.proto#L152-L162
```

#### VotingParams

```protobuf
https://github.com/cosmos/cosmos-sdk/blob/v0.47.0-rc1/proto/cosmos/gov/v1/gov.proto#L164-L168
```

#### TallyParams

```protobuf
https://github.com/cosmos/cosmos-sdk/blob/v0.47.0-rc1/proto/cosmos/gov/v1/gov.proto#L170-L182
```

参数存储在全局 `GlobalParams` KVStore 中。

此外，我们引入一些基本类型：

```go
type Vote byte

const (
    VoteYes         = 0x1
    VoteNo          = 0x2
    VoteNoWithVeto  = 0x3
    VoteAbstain     = 0x4
)

type ProposalType  string

const (
    ProposalTypePlainText       = "Text"
    ProposalTypeSoftwareUpgrade = "SoftwareUpgrade"
)

type ProposalStatus byte


const (
    StatusNil           ProposalStatus = 0x00
    StatusDepositPeriod ProposalStatus = 0x01  // 提案已提交。参与者可以存入押金但不能投票
    StatusVotingPeriod  ProposalStatus = 0x02  // 已达到 MinDeposit，参与者可以投票
    StatusPassed        ProposalStatus = 0x03  // 提案已通过并成功执行
    StatusRejected      ProposalStatus = 0x04  // 提案已被拒绝
    StatusFailed        ProposalStatus = 0x05  // 提案已通过但执行失败
)
```

### 押金

```protobuf
https://github.com/cosmos/cosmos-sdk/blob/v0.47.0-rc1/proto/cosmos/gov/v1/gov.proto#L38-L49
```

### ValidatorGovInfo

此类型在统计时用于临时映射

```go
  type ValidatorGovInfo struct {
    Minus     sdk.Dec
    Vote      Vote
  }
```

## 存储

:::note\
存储是多存储中的 KVStore。查找存储的键是列表中的第一个参数\
:::

我们将使用一个 KVStore `Governance` 来存储四个映射：

* 从 `proposalID|'proposal'` 到 `Proposal` 的映射。
* 从 `proposalID|'addresses'|address` 到 `Vote` 的映射。此映射允许我们通过对 `proposalID:addresses` 进行范围查询来查询所有对提案投票的地址及其投票。
* 从 `ParamsKey|'Params'` 到 `Params` 的映射。此映射允许查询所有 x/gov 参数。
* 从 `VotingPeriodProposalKeyPrefix|proposalID` 到单个字节的映射。这允许我们以非常低的 gas 成本知道提案是否在投票期内。

为了伪代码的目的，以下是我们将用于在存储中读取或写入的两个函数：

* `load(StoreKey, Key)`：在多存储中位于键 `StoreKey` 的存储中检索存储在键 `Key` 处的项目
* `store(StoreKey, Key, value)`：在多存储中位于键 `StoreKey` 的存储中在键 `Key` 处写入值 `Value`

### 提案处理队列

**存储：**

* `ProposalProcessingQueue`：一个队列 `queue[proposalID]`，包含所有达到 `MinDeposit` 的提案的 `ProposalIDs`。在每个 `EndBlock` 期间，所有已达到投票期结束的提案都会被处理。为了处理已完成的提案，应用程序统计投票，计算每个验证者的投票，并检查验证者集中的每个验证者是否都已投票。如果提案被接受，押金将被退还。最后，执行提案内容 `Handler`。

以下是 `ProposalProcessingQueue` 的伪代码：

```go
  in EndBlock do

    for finishedProposalID in GetAllFinishedProposalIDs(block.Time)
      proposal = load(Governance, <proposalID|'proposal'>) // proposal 是一个常量键

      validators = Keeper.getAllValidators()
      tmpValMap := map(sdk.AccAddress)ValidatorGovInfo

      // 将映射初始化为 0。这是验证者投票中将被其委托者投票覆盖的份额数量
      for each validator in validators
        tmpValMap(validator.OperatorAddr).Minus = 0

      // 统计
      voterIterator = rangeQuery(Governance, <proposalID|'addresses'>) //返回所有对提案投票的地址
      for each (voterAddress, vote) in voterIterator
        delegations = stakingKeeper.getDelegations(voterAddress) // 获取当前投票者的所有委托

        for each delegation in delegations
          // 确保 delegation.Shares 不包括正在解绑的份额
          tmpValMap(delegation.ValidatorAddr).Minus += delegation.Shares
          proposal.updateTally(vote, delegation.Shares)

        _, isVal = stakingKeeper.getValidator(voterAddress)
        if (isVal)
          tmpValMap(voterAddress).Vote = vote

      tallyingParam = load(GlobalParams, 'TallyingParam')

      // 如果验证者投票，更新统计
      for each validator in validators
        if tmpValMap(validator).HasVoted
          proposal.updateTally(tmpValMap(validator).Vote, (validator.TotalShares - tmpValMap(validator).Minus))



      // 检查提案是被接受还是被拒绝
      totalNonAbstain := proposal.YesVotes + proposal.NoVotes + proposal.NoWithVetoVotes
      if (proposal.Votes.YesVotes/totalNonAbstain > tallyingParam.Threshold AND proposal.Votes.NoWithVetoVotes/totalNonAbstain  < tallyingParam.Veto)
        //  提案在投票期结束时被接受
        //  退还押金（未投票者已受到惩罚）
        for each (amount, depositor) in proposal.Deposits
          depositor.AtomBalance += amount

        stateWriter, err := proposal.Handler()
        if err != nil
            // 提案通过但在状态执行期间失败
            proposal.CurrentStatus = ProposalStatusFailed
         else
            // 提案通过且状态已持久化
            proposal.CurrentStatus = ProposalStatusAccepted
            stateWriter.save()
      else
        // 提案被拒绝
        proposal.CurrentStatus = ProposalStatusRejected

      store(Governance, <proposalID|'proposal'>, proposal)
```

### 遗留提案

:::warning\
遗留提案已弃用。通过授予治理模块执行消息的权利来使用新的提案流程。\
:::

遗留提案是治理提案的旧实现。与可以包含任何消息的提案相反，遗留提案允许提交一组预定义的提案。这些提案由其类型定义，并由在 gov v1beta1 路由器中注册的处理器处理。

有关如何提交提案的更多信息，请参见[客户端部分](gov.md#client)。

## 消息

### 提案提交

任何账户都可以通过 `MsgSubmitProposal` 交易提交提案。

```protobuf
https://github.com/cosmos/cosmos-sdk/blob/v0.47.0-rc1/proto/cosmos/gov/v1/tx.proto#L42-L69
```

传递给 `MsgSubmitProposal` 消息的 `messages` 字段的所有 `sdk.Msgs` 必须在应用程序的 `MsgServiceRouter` 中注册。这些消息中的每一个都必须有一个签名者，即 gov 模块账户。最后，元数据长度不得大于传递给 gov keeper 的 `maxMetadataLen` 配置。`initialDeposit` 必须严格为正数，并符合 `MinDeposit` 参数接受的代币类型。

**状态修改：**

* 生成新的 `proposalID`
* 创建新的 `Proposal`
* 初始化 `Proposal` 的属性
* 将发送者的余额减少 `InitialDeposit`
* 如果达到 `MinDeposit`：
  * 将 `proposalID` 推入 `ProposalProcessingQueue`
* 将 `InitialDeposit` 从 `Proposer` 转移到治理 `ModuleAccount`

### 押金

一旦提案被提交，如果 `Proposal.TotalDeposit < ActiveParam.MinDeposit`，Atom 持有者可以发送 `MsgDeposit` 交易来增加提案的押金。

押金在以下情况下被接受：

* 提案存在
* 提案不在投票期内
* 存入的代币符合 `MinDeposit` 参数接受的代币类型

```protobuf
https://github.com/cosmos/cosmos-sdk/blob/v0.47.0-rc1/proto/cosmos/gov/v1/tx.proto#L134-L147
```

**状态修改：**

* 将发送者的余额减少 `deposit`
* 在 `proposal.Deposits` 中添加发送者的 `deposit`
* 将 `proposal.TotalDeposit` 增加发送者的 `deposit`
* 如果达到 `MinDeposit`：
  * 将 `proposalID` 推入 `ProposalProcessingQueueEnd`
* 将 `Deposit` 从 `proposer` 转移到治理 `ModuleAccount`

### 投票

一旦达到 `ActiveParam.MinDeposit`，投票期开始。从那时起，已绑定的 Atom 持有者能够发送 `MsgVote` 交易来对提案进行投票。

```protobuf
https://github.com/cosmos/cosmos-sdk/blob/v0.47.0-rc1/proto/cosmos/gov/v1/tx.proto#L92-L108
```

**状态修改：**

* 记录发送者的 `Vote`

:::note\
此消息的 Gas 成本必须考虑在 EndBlocker 中未来对投票的统计。\
:::

## 事件

治理模块发出以下事件：

### EndBlocker

| 类型               | 属性键         | 属性值           |
| ------------------ | -------------- | ---------------- |
| inactive\_proposal | proposal\_id   | {proposalID}     |
| inactive\_proposal | proposal\_result | {proposalResult} |
| active\_proposal   | proposal\_id   | {proposalID}     |
| active\_proposal   | proposal\_result | {proposalResult} |

### 处理器

#### MsgSubmitProposal

| 类型                  | 属性键             | 属性值           |
| --------------------- | ------------------ | ---------------- |
| submit\_proposal      | proposal\_id       | {proposalID}     |
| submit\_proposal \[0] | voting\_period\_start | {proposalID}     |
| proposal\_deposit     | amount             | {depositAmount}  |
| proposal\_deposit     | proposal\_id       | {proposalID}     |
| message               | module             | governance       |
| message               | action             | submit\_proposal |
| message               | sender             | {senderAddress}  |

* \[0] 仅在提交期间投票期开始时发出的事件。

#### MsgVote

| 类型           | 属性键      | 属性值        |
| -------------- | ----------- | ------------- |
| proposal\_vote | option      | {voteOption}  |
| proposal\_vote | proposal\_id | {proposalID}  |
| message        | module      | governance    |
| message        | action      | vote          |
| message        | sender      | {senderAddress} |

#### MsgVoteWeighted

| 类型           | 属性键      | 属性值              |
| -------------- | ----------- | ------------------- |
| proposal\_vote | option      | {weightedVoteOptions} |
| proposal\_vote | proposal\_id | {proposalID}        |
| message        | module      | governance          |
| message        | action      | vote                |
| message        | sender      | {senderAddress}     |

#### MsgDeposit

| 类型                   | 属性键             | 属性值          |
| ---------------------- | ------------------ | -------------- |
| proposal\_deposit      | amount             | {depositAmount} |
| proposal\_deposit      | proposal\_id       | {proposalID}   |
| proposal\_deposit \[0] | voting\_period\_start | {proposalID}   |
| message                | module             | governance     |
| message                | action             | deposit        |
| message                | sender             | {senderAddress} |

* \[0] 仅在提交期间投票期开始时发出的事件。

## 参数

治理模块包含以下参数：

| 键                              | 类型             | 示例                                      |
| -------------------------------- | ---------------- | ----------------------------------------- |
| min\_deposit                     | array (coins)    | \[{"denom":"uatom","amount":"10000000"}] |
| max\_deposit\_period             | string (time ns) | "172800000000000" (17280s)               |
| voting\_period                   | string (time ns) | "172800000000000" (17280s)               |
| quorum                           | string (dec)     | "0.334000000000000000"                   |
| threshold                        | string (dec)     | "0.500000000000000000"                   |
| veto                             | string (dec)     | "0.334000000000000000"                   |
| expedited\_threshold             | string (time ns) | "0.667000000000000000"                   |
| expedited\_voting\_period        | string (time ns) | "86400000000000" (8600s)                 |
| expedited\_min\_deposit          | array (coins)    | \[{"denom":"uatom","amount":"50000000"}] |
| burn\_proposal\_deposit\_prevote | bool             | false                                    |
| burn\_vote\_quorum               | bool             | false                                    |
| burn\_vote\_veto                 | bool             | true                                     |
| min\_initial\_deposit\_ratio     | string           | "0.1"                                    |

**注意**：治理模块包含的参数是对象，与其他模块不同。如果只想更改参数的子集，只需要包含它们，而不需要包含整个参数对象结构。

## 客户端

### CLI

用户可以使用 CLI 查询和与 `gov` 模块交互。

#### 查询

`query` 命令允许用户查询 `gov` 状态。

```bash
simd query gov --help
```

**deposit**

`deposit` 命令允许用户查询给定提案中给定存款人的押金。

```bash
simd query gov deposit [proposal-id] [depositer-addr] [flags]
```

示例：

```bash
simd query gov deposit 1 cosmos1..
```

示例输出：

```bash
amount:
- amount: "100"
  denom: stake
depositor: cosmos1..
proposal_id: "1"
```

**deposits**

`deposits` 命令允许用户查询给定提案的所有押金。

```bash
simd query gov deposits [proposal-id] [flags]
```

示例：

```bash
simd query gov deposits 1
```

示例输出：

```bash
deposits:
- amount:
  - amount: "100"
    denom: stake
  depositor: cosmos1..
  proposal_id: "1"
pagination:
  next_key: null
  total: "0"
```

**param**

`param` 命令允许用户查询 `gov` 模块的给定参数。

```bash
simd query gov param [param-type] [flags]
```

示例：

```bash
simd query gov param voting
```

示例输出：

```bash
voting_period: "172800000000000"
```

**params**

`params` 命令允许用户查询 `gov` 模块的所有参数。

```bash
simd query gov params [flags]
```

Example:

```bash
simd query gov params
```

Example Output:

```bash
deposit_params:
  max_deposit_period: 172800s
  min_deposit:
  - amount: "10000000"
    denom: stake
params:
  expedited_min_deposit:
  - amount: "50000000"
    denom: stake
  expedited_threshold: "0.670000000000000000"
  expedited_voting_period: 86400s
  max_deposit_period: 172800s
  min_deposit:
  - amount: "10000000"
    denom: stake
  min_initial_deposit_ratio: "0.000000000000000000"
  proposal_cancel_burn_rate: "0.500000000000000000"
  quorum: "0.334000000000000000"
  threshold: "0.500000000000000000"
  veto_threshold: "0.334000000000000000"
  voting_period: 172800s
tally_params:
  quorum: "0.334000000000000000"
  threshold: "0.500000000000000000"
  veto_threshold: "0.334000000000000000"
voting_params:
  voting_period: 172800s
```

**proposal**

The `proposal` command allows users to query a given proposal.

```bash
simd query gov proposal [proposal-id] [flags]
```

Example:

```bash
simd query gov proposal 1
```

Example Output:

```bash
deposit_end_time: "2022-03-30T11:50:20.819676256Z"
final_tally_result:
  abstain_count: "0"
  no_count: "0"
  no_with_veto_count: "0"
  yes_count: "0"
id: "1"
messages:
- '@type': /cosmos.bank.v1beta1.MsgSend
  amount:
  - amount: "10"
    denom: stake
  from_address: cosmos1..
  to_address: cosmos1..
metadata: AQ==
status: PROPOSAL_STATUS_DEPOSIT_PERIOD
submit_time: "2022-03-28T11:50:20.819676256Z"
total_deposit:
- amount: "10"
  denom: stake
voting_end_time: null
voting_start_time: null
```

**proposals**

The `proposals` command allows users to query all proposals with optional filters.

```bash
simd query gov proposals [flags]
```

Example:

```bash
simd query gov proposals
```

Example Output:

```bash
pagination:
  next_key: null
  total: "0"
proposals:
- deposit_end_time: "2022-03-30T11:50:20.819676256Z"
  final_tally_result:
    abstain_count: "0"
    no_count: "0"
    no_with_veto_count: "0"
    yes_count: "0"
  id: "1"
  messages:
  - '@type': /cosmos.bank.v1beta1.MsgSend
    amount:
    - amount: "10"
      denom: stake
    from_address: cosmos1..
    to_address: cosmos1..
  metadata: AQ==
  status: PROPOSAL_STATUS_DEPOSIT_PERIOD
  submit_time: "2022-03-28T11:50:20.819676256Z"
  total_deposit:
  - amount: "10"
    denom: stake
  voting_end_time: null
  voting_start_time: null
- deposit_end_time: "2022-03-30T14:02:41.165025015Z"
  final_tally_result:
    abstain_count: "0"
    no_count: "0"
    no_with_veto_count: "0"
    yes_count: "0"
  id: "2"
  messages:
  - '@type': /cosmos.bank.v1beta1.MsgSend
    amount:
    - amount: "10"
      denom: stake
    from_address: cosmos1..
    to_address: cosmos1..
  metadata: AQ==
  status: PROPOSAL_STATUS_DEPOSIT_PERIOD
  submit_time: "2022-03-28T14:02:41.165025015Z"
  total_deposit:
  - amount: "10"
    denom: stake
  voting_end_time: null
  voting_start_time: null
```

**proposer**

The `proposer` command allows users to query the proposer for a given proposal.

```bash
simd query gov proposer [proposal-id] [flags]
```

Example:

```bash
simd query gov proposer 1
```

Example Output:

```bash
proposal_id: "1"
proposer: cosmos1..
```

**tally**

The `tally` command allows users to query the tally of a given proposal vote.

```bash
simd query gov tally [proposal-id] [flags]
```

Example:

```bash
simd query gov tally 1
```

Example Output:

```bash
abstain: "0"
"no": "0"
no_with_veto: "0"
"yes": "1"
```

**vote**

The `vote` command allows users to query a vote for a given proposal.

```bash
simd query gov vote [proposal-id] [voter-addr] [flags]
```

Example:

```bash
simd query gov vote 1 cosmos1..
```

Example Output:

```bash
option: VOTE_OPTION_YES
options:
- option: VOTE_OPTION_YES
  weight: "1.000000000000000000"
proposal_id: "1"
voter: cosmos1..
```

**votes**

The `votes` command allows users to query all votes for a given proposal.

```bash
simd query gov votes [proposal-id] [flags]
```

Example:

```bash
simd query gov votes 1
```

Example Output:

```bash
pagination:
  next_key: null
  total: "0"
votes:
- option: VOTE_OPTION_YES
  options:
  - option: VOTE_OPTION_YES
    weight: "1.000000000000000000"
  proposal_id: "1"
  voter: cosmos1..
```

#### 交易

`tx` 命令允许用户与 `gov` 模块交互。

```bash
simd tx gov --help
```

**deposit**

`deposit` 命令允许用户为给定提案存入代币。

```bash
simd tx gov deposit [proposal-id] [deposit] [flags]
```

示例：

```bash
simd tx gov deposit 1 10000000stake --from cosmos1..
```

**draft-proposal**

`draft-proposal` 命令允许用户起草任何类型的提案。\
该命令返回一个 `draft_proposal.json`，在完成后由 `submit-proposal` 使用。\
`draft_metadata.json` 旨在上传到 [IPFS](gov.md#metadata)。

```bash
simd tx gov draft-proposal
```

**submit-proposal**

`submit-proposal` 命令允许用户提交治理提案以及一些消息和元数据。\
消息、元数据和押金在 JSON 文件中定义。

```bash
simd tx gov submit-proposal [path-to-proposal-json] [flags]
```

示例：

```bash
simd tx gov submit-proposal /path/to/proposal.json --from cosmos1..
```

其中 `proposal.json` 包含：

```json
{
  "messages": [
    {
      "@type": "/cosmos.bank.v1beta1.MsgSend",
      "from_address": "cosmos1...", // gov 模块地址
      "to_address": "cosmos1...",
      "amount":[{"denom": "stake","amount": "10"}]
    }
  ],
  "metadata": "AQ==",
  "deposit": "10stake",
  "title": "提案标题",
  "summary": "提案摘要"
}
```

:::note\
默认情况下，元数据、摘要和标题都限制为 255 个字符，这可以由应用程序开发者覆盖。\
:::

:::tip\
当未指定元数据时，标题限制为 255 个字符，摘要限制为标题长度的 40 倍。\
:::

**submit-legacy-proposal**

`submit-legacy-proposal` 命令允许用户提交治理遗留提案以及初始押金。

```bash
simd tx gov submit-legacy-proposal [command] [flags]
```

示例：

```bash
simd tx gov submit-legacy-proposal --title="Test Proposal" --description="testing" --type="Text" --deposit="100000000stake" --from cosmos1..
```

示例（`param-change`）：

```bash
simd tx gov submit-legacy-proposal param-change proposal.json --from cosmos1..
```

```json
{
  "title": "Test Proposal",
  "description": "testing, testing, 1, 2, 3",
  "changes": [
    {
      "subspace": "staking",
      "key": "MaxValidators",
      "value": 100
    }
  ],
  "deposit": "10000000stake"
}
```

#### cancel-proposal

一旦提案被取消，从提案的押金中，`deposits * proposal_cancel_ratio` 将被销毁或发送到 `ProposalCancelDest` 地址，如果 `ProposalCancelDest` 为空，则押金将被销毁。`remaining deposits` 将发送给存款人。

```bash
simd tx gov cancel-proposal [proposal-id] [flags]
```

示例：

```bash
simd tx gov cancel-proposal 1 --from cosmos1...
```

**vote**

`vote` 命令允许用户提交对给定治理提案的投票。

```bash
simd tx gov vote [command] [flags]
```

示例：

```bash
simd tx gov vote 1 yes --from cosmos1..
```

**weighted-vote**

`weighted-vote` 命令允许用户提交对给定治理提案的加权投票。

```bash
simd tx gov weighted-vote [proposal-id] [weighted-options] [flags]
```

示例：

```bash
simd tx gov weighted-vote 1 yes=0.5,no=0.5 --from cosmos1..
```

### gRPC

用户可以使用 gRPC 端点查询 `gov` 模块。

#### Proposal

`Proposal` 端点允许用户查询给定提案。

Using legacy v1beta1:

```bash
cosmos.gov.v1beta1.Query/Proposal
```

Example:

```bash
grpcurl -plaintext \
    -d '{"proposal_id":"1"}' \
    localhost:9090 \
    cosmos.gov.v1beta1.Query/Proposal
```

Example Output:

```bash
{
  "proposal": {
    "proposalId": "1",
    "content": {"@type":"/cosmos.gov.v1beta1.TextProposal","description":"testing, testing, 1, 2, 3","title":"Test Proposal"},
    "status": "PROPOSAL_STATUS_VOTING_PERIOD",
    "finalTallyResult": {
      "yes": "0",
      "abstain": "0",
      "no": "0",
      "noWithVeto": "0"
    },
    "submitTime": "2021-09-16T19:40:08.712440474Z",
    "depositEndTime": "2021-09-18T19:40:08.712440474Z",
    "totalDeposit": [
      {
        "denom": "stake",
        "amount": "10000000"
      }
    ],
    "votingStartTime": "2021-09-16T19:40:08.712440474Z",
    "votingEndTime": "2021-09-18T19:40:08.712440474Z",
    "title": "Test Proposal",
    "summary": "testing, testing, 1, 2, 3"
  }
}
```

Using v1:

```bash
cosmos.gov.v1.Query/Proposal
```

Example:

```bash
grpcurl -plaintext \
    -d '{"proposal_id":"1"}' \
    localhost:9090 \
    cosmos.gov.v1.Query/Proposal
```

Example Output:

```bash
{
  "proposal": {
    "id": "1",
    "messages": [
      {"@type":"/cosmos.bank.v1beta1.MsgSend","amount":[{"denom":"stake","amount":"10"}],"fromAddress":"cosmos1..","toAddress":"cosmos1.."}
    ],
    "status": "PROPOSAL_STATUS_VOTING_PERIOD",
    "finalTallyResult": {
      "yesCount": "0",
      "abstainCount": "0",
      "noCount": "0",
      "noWithVetoCount": "0"
    },
    "submitTime": "2022-03-28T11:50:20.819676256Z",
    "depositEndTime": "2022-03-30T11:50:20.819676256Z",
    "totalDeposit": [
      {
        "denom": "stake",
        "amount": "10000000"
      }
    ],
    "votingStartTime": "2022-03-28T14:25:26.644857113Z",
    "votingEndTime": "2022-03-30T14:25:26.644857113Z",
    "metadata": "AQ==",
    "title": "Test Proposal",
    "summary": "testing, testing, 1, 2, 3"
  }
}
```

#### Proposals

The `Proposals` endpoint allows users to query all proposals with optional filters.

Using legacy v1beta1:

```bash
cosmos.gov.v1beta1.Query/Proposals
```

Example:

```bash
grpcurl -plaintext \
    localhost:9090 \
    cosmos.gov.v1beta1.Query/Proposals
```

Example Output:

```bash
{
  "proposals": [
    {
      "proposalId": "1",
      "status": "PROPOSAL_STATUS_VOTING_PERIOD",
      "finalTallyResult": {
        "yes": "0",
        "abstain": "0",
        "no": "0",
        "noWithVeto": "0"
      },
      "submitTime": "2022-03-28T11:50:20.819676256Z",
      "depositEndTime": "2022-03-30T11:50:20.819676256Z",
      "totalDeposit": [
        {
          "denom": "stake",
          "amount": "10000000010"
        }
      ],
      "votingStartTime": "2022-03-28T14:25:26.644857113Z",
      "votingEndTime": "2022-03-30T14:25:26.644857113Z"
    },
    {
      "proposalId": "2",
      "status": "PROPOSAL_STATUS_DEPOSIT_PERIOD",
      "finalTallyResult": {
        "yes": "0",
        "abstain": "0",
        "no": "0",
        "noWithVeto": "0"
      },
      "submitTime": "2022-03-28T14:02:41.165025015Z",
      "depositEndTime": "2022-03-30T14:02:41.165025015Z",
      "totalDeposit": [
        {
          "denom": "stake",
          "amount": "10"
        }
      ],
      "votingStartTime": "0001-01-01T00:00:00Z",
      "votingEndTime": "0001-01-01T00:00:00Z"
    }
  ],
  "pagination": {
    "total": "2"
  }
}

```

Using v1:

```bash
cosmos.gov.v1.Query/Proposals
```

Example:

```bash
grpcurl -plaintext \
    localhost:9090 \
    cosmos.gov.v1.Query/Proposals
```

Example Output:

```bash
{
  "proposals": [
    {
      "id": "1",
      "messages": [
        {"@type":"/cosmos.bank.v1beta1.MsgSend","amount":[{"denom":"stake","amount":"10"}],"fromAddress":"cosmos1..","toAddress":"cosmos1.."}
      ],
      "status": "PROPOSAL_STATUS_VOTING_PERIOD",
      "finalTallyResult": {
        "yesCount": "0",
        "abstainCount": "0",
        "noCount": "0",
        "noWithVetoCount": "0"
      },
      "submitTime": "2022-03-28T11:50:20.819676256Z",
      "depositEndTime": "2022-03-30T11:50:20.819676256Z",
      "totalDeposit": [
        {
          "denom": "stake",
          "amount": "10000000010"
        }
      ],
      "votingStartTime": "2022-03-28T14:25:26.644857113Z",
      "votingEndTime": "2022-03-30T14:25:26.644857113Z",
      "metadata": "AQ==",
      "title": "Proposal Title",
      "summary": "Proposal Summary"
    },
    {
      "id": "2",
      "messages": [
        {"@type":"/cosmos.bank.v1beta1.MsgSend","amount":[{"denom":"stake","amount":"10"}],"fromAddress":"cosmos1..","toAddress":"cosmos1.."}
      ],
      "status": "PROPOSAL_STATUS_DEPOSIT_PERIOD",
      "finalTallyResult": {
        "yesCount": "0",
        "abstainCount": "0",
        "noCount": "0",
        "noWithVetoCount": "0"
      },
      "submitTime": "2022-03-28T14:02:41.165025015Z",
      "depositEndTime": "2022-03-30T14:02:41.165025015Z",
      "totalDeposit": [
        {
          "denom": "stake",
          "amount": "10"
        }
      ],
      "metadata": "AQ==",
      "title": "Proposal Title",
      "summary": "Proposal Summary"
    }
  ],
  "pagination": {
    "total": "2"
  }
}
```

#### Vote

The `Vote` endpoint allows users to query a vote for a given proposal.

Using legacy v1beta1:

```bash
cosmos.gov.v1beta1.Query/Vote
```

Example:

```bash
grpcurl -plaintext \
    -d '{"proposal_id":"1","voter":"cosmos1.."}' \
    localhost:9090 \
    cosmos.gov.v1beta1.Query/Vote
```

Example Output:

```bash
{
  "vote": {
    "proposalId": "1",
    "voter": "cosmos1..",
    "option": "VOTE_OPTION_YES",
    "options": [
      {
        "option": "VOTE_OPTION_YES",
        "weight": "1000000000000000000"
      }
    ]
  }
}
```

Using v1:

```bash
cosmos.gov.v1.Query/Vote
```

Example:

```bash
grpcurl -plaintext \
    -d '{"proposal_id":"1","voter":"cosmos1.."}' \
    localhost:9090 \
    cosmos.gov.v1.Query/Vote
```

Example Output:

```bash
{
  "vote": {
    "proposalId": "1",
    "voter": "cosmos1..",
    "option": "VOTE_OPTION_YES",
    "options": [
      {
        "option": "VOTE_OPTION_YES",
        "weight": "1.000000000000000000"
      }
    ]
  }
}
```

#### Votes

The `Votes` endpoint allows users to query all votes for a given proposal.

Using legacy v1beta1:

```bash
cosmos.gov.v1beta1.Query/Votes
```

Example:

```bash
grpcurl -plaintext \
    -d '{"proposal_id":"1"}' \
    localhost:9090 \
    cosmos.gov.v1beta1.Query/Votes
```

Example Output:

```bash
{
  "votes": [
    {
      "proposalId": "1",
      "voter": "cosmos1..",
      "options": [
        {
          "option": "VOTE_OPTION_YES",
          "weight": "1000000000000000000"
        }
      ]
    }
  ],
  "pagination": {
    "total": "1"
  }
}
```

Using v1:

```bash
cosmos.gov.v1.Query/Votes
```

Example:

```bash
grpcurl -plaintext \
    -d '{"proposal_id":"1"}' \
    localhost:9090 \
    cosmos.gov.v1.Query/Votes
```

Example Output:

```bash
{
  "votes": [
    {
      "proposalId": "1",
      "voter": "cosmos1..",
      "options": [
        {
          "option": "VOTE_OPTION_YES",
          "weight": "1.000000000000000000"
        }
      ]
    }
  ],
  "pagination": {
    "total": "1"
  }
}
```

#### Params

The `Params` endpoint allows users to query all parameters for the `gov` module.

Using legacy v1beta1:

```bash
cosmos.gov.v1beta1.Query/Params
```

Example:

```bash
grpcurl -plaintext \
    -d '{"params_type":"voting"}' \
    localhost:9090 \
    cosmos.gov.v1beta1.Query/Params
```

Example Output:

```bash
{
  "votingParams": {
    "votingPeriod": "172800s"
  },
  "depositParams": {
    "maxDepositPeriod": "0s"
  },
  "tallyParams": {
    "quorum": "MA==",
    "threshold": "MA==",
    "vetoThreshold": "MA=="
  }
}
```

Using v1:

```bash
cosmos.gov.v1.Query/Params
```

Example:

```bash
grpcurl -plaintext \
    -d '{"params_type":"voting"}' \
    localhost:9090 \
    cosmos.gov.v1.Query/Params
```

Example Output:

```bash
{
  "votingParams": {
    "votingPeriod": "172800s"
  }
}
```

#### Deposit

The `Deposit` endpoint allows users to query a deposit for a given proposal from a given depositor.

Using legacy v1beta1:

```bash
cosmos.gov.v1beta1.Query/Deposit
```

Example:

```bash
grpcurl -plaintext \
    '{"proposal_id":"1","depositor":"cosmos1.."}' \
    localhost:9090 \
    cosmos.gov.v1beta1.Query/Deposit
```

Example Output:

```bash
{
  "deposit": {
    "proposalId": "1",
    "depositor": "cosmos1..",
    "amount": [
      {
        "denom": "stake",
        "amount": "10000000"
      }
    ]
  }
}
```

Using v1:

```bash
cosmos.gov.v1.Query/Deposit
```

Example:

```bash
grpcurl -plaintext \
    '{"proposal_id":"1","depositor":"cosmos1.."}' \
    localhost:9090 \
    cosmos.gov.v1.Query/Deposit
```

Example Output:

```bash
{
  "deposit": {
    "proposalId": "1",
    "depositor": "cosmos1..",
    "amount": [
      {
        "denom": "stake",
        "amount": "10000000"
      }
    ]
  }
}
```

#### deposits

The `Deposits` endpoint allows users to query all deposits for a given proposal.

Using legacy v1beta1:

```bash
cosmos.gov.v1beta1.Query/Deposits
```

Example:

```bash
grpcurl -plaintext \
    -d '{"proposal_id":"1"}' \
    localhost:9090 \
    cosmos.gov.v1beta1.Query/Deposits
```

Example Output:

```bash
{
  "deposits": [
    {
      "proposalId": "1",
      "depositor": "cosmos1..",
      "amount": [
        {
          "denom": "stake",
          "amount": "10000000"
        }
      ]
    }
  ],
  "pagination": {
    "total": "1"
  }
}
```

Using v1:

```bash
cosmos.gov.v1.Query/Deposits
```

Example:

```bash
grpcurl -plaintext \
    -d '{"proposal_id":"1"}' \
    localhost:9090 \
    cosmos.gov.v1.Query/Deposits
```

Example Output:

```bash
{
  "deposits": [
    {
      "proposalId": "1",
      "depositor": "cosmos1..",
      "amount": [
        {
          "denom": "stake",
          "amount": "10000000"
        }
      ]
    }
  ],
  "pagination": {
    "total": "1"
  }
}
```

#### TallyResult

The `TallyResult` endpoint allows users to query the tally of a given proposal.

Using legacy v1beta1:

```bash
cosmos.gov.v1beta1.Query/TallyResult
```

Example:

```bash
grpcurl -plaintext \
    -d '{"proposal_id":"1"}' \
    localhost:9090 \
    cosmos.gov.v1beta1.Query/TallyResult
```

Example Output:

```bash
{
  "tally": {
    "yes": "1000000",
    "abstain": "0",
    "no": "0",
    "noWithVeto": "0"
  }
}
```

Using v1:

```bash
cosmos.gov.v1.Query/TallyResult
```

Example:

```bash
grpcurl -plaintext \
    -d '{"proposal_id":"1"}' \
    localhost:9090 \
    cosmos.gov.v1.Query/TallyResult
```

Example Output:

```bash
{
  "tally": {
    "yes": "1000000",
    "abstain": "0",
    "no": "0",
    "noWithVeto": "0"
  }
}
```

### REST

用户可以使用 REST 端点查询 `gov` 模块。

#### proposal

`proposals` 端点允许用户查询给定提案。

Using legacy v1beta1:

```bash
/cosmos/gov/v1beta1/proposals/{proposal_id}
```

Example:

```bash
curl localhost:1317/cosmos/gov/v1beta1/proposals/1
```

Example Output:

```bash
{
  "proposal": {
    "proposal_id": "1",
    "content": null,
    "status": "PROPOSAL_STATUS_VOTING_PERIOD",
    "final_tally_result": {
      "yes": "0",
      "abstain": "0",
      "no": "0",
      "no_with_veto": "0"
    },
    "submit_time": "2022-03-28T11:50:20.819676256Z",
    "deposit_end_time": "2022-03-30T11:50:20.819676256Z",
    "total_deposit": [
      {
        "denom": "stake",
        "amount": "10000000010"
      }
    ],
    "voting_start_time": "2022-03-28T14:25:26.644857113Z",
    "voting_end_time": "2022-03-30T14:25:26.644857113Z"
  }
}
```

Using v1:

```bash
/cosmos/gov/v1/proposals/{proposal_id}
```

Example:

```bash
curl localhost:1317/cosmos/gov/v1/proposals/1
```

Example Output:

```bash
{
  "proposal": {
    "id": "1",
    "messages": [
      {
        "@type": "/cosmos.bank.v1beta1.MsgSend",
        "from_address": "cosmos1..",
        "to_address": "cosmos1..",
        "amount": [
          {
            "denom": "stake",
            "amount": "10"
          }
        ]
      }
    ],
    "status": "PROPOSAL_STATUS_VOTING_PERIOD",
    "final_tally_result": {
      "yes_count": "0",
      "abstain_count": "0",
      "no_count": "0",
      "no_with_veto_count": "0"
    },
    "submit_time": "2022-03-28T11:50:20.819676256Z",
    "deposit_end_time": "2022-03-30T11:50:20.819676256Z",
    "total_deposit": [
      {
        "denom": "stake",
        "amount": "10000000"
      }
    ],
    "voting_start_time": "2022-03-28T14:25:26.644857113Z",
    "voting_end_time": "2022-03-30T14:25:26.644857113Z",
    "metadata": "AQ==",
    "title": "Proposal Title",
    "summary": "Proposal Summary"
  }
}
```

#### proposals

The `proposals` endpoint also allows users to query all proposals with optional filters.

Using legacy v1beta1:

```bash
/cosmos/gov/v1beta1/proposals
```

Example:

```bash
curl localhost:1317/cosmos/gov/v1beta1/proposals
```

Example Output:

```bash
{
  "proposals": [
    {
      "proposal_id": "1",
      "content": null,
      "status": "PROPOSAL_STATUS_VOTING_PERIOD",
      "final_tally_result": {
        "yes": "0",
        "abstain": "0",
        "no": "0",
        "no_with_veto": "0"
      },
      "submit_time": "2022-03-28T11:50:20.819676256Z",
      "deposit_end_time": "2022-03-30T11:50:20.819676256Z",
      "total_deposit": [
        {
          "denom": "stake",
          "amount": "10000000"
        }
      ],
      "voting_start_time": "2022-03-28T14:25:26.644857113Z",
      "voting_end_time": "2022-03-30T14:25:26.644857113Z"
    },
    {
      "proposal_id": "2",
      "content": null,
      "status": "PROPOSAL_STATUS_DEPOSIT_PERIOD",
      "final_tally_result": {
        "yes": "0",
        "abstain": "0",
        "no": "0",
        "no_with_veto": "0"
      },
      "submit_time": "2022-03-28T14:02:41.165025015Z",
      "deposit_end_time": "2022-03-30T14:02:41.165025015Z",
      "total_deposit": [
        {
          "denom": "stake",
          "amount": "10"
        }
      ],
      "voting_start_time": "0001-01-01T00:00:00Z",
      "voting_end_time": "0001-01-01T00:00:00Z"
    }
  ],
  "pagination": {
    "next_key": null,
    "total": "2"
  }
}
```

Using v1:

```bash
/cosmos/gov/v1/proposals
```

Example:

```bash
curl localhost:1317/cosmos/gov/v1/proposals
```

Example Output:

```bash
{
  "proposals": [
    {
      "id": "1",
      "messages": [
        {
          "@type": "/cosmos.bank.v1beta1.MsgSend",
          "from_address": "cosmos1..",
          "to_address": "cosmos1..",
          "amount": [
            {
              "denom": "stake",
              "amount": "10"
            }
          ]
        }
      ],
      "status": "PROPOSAL_STATUS_VOTING_PERIOD",
      "final_tally_result": {
        "yes_count": "0",
        "abstain_count": "0",
        "no_count": "0",
        "no_with_veto_count": "0"
      },
      "submit_time": "2022-03-28T11:50:20.819676256Z",
      "deposit_end_time": "2022-03-30T11:50:20.819676256Z",
      "total_deposit": [
        {
          "denom": "stake",
          "amount": "10000000010"
        }
      ],
      "voting_start_time": "2022-03-28T14:25:26.644857113Z",
      "voting_end_time": "2022-03-30T14:25:26.644857113Z",
      "metadata": "AQ==",
      "title": "Proposal Title",
      "summary": "Proposal Summary"
    },
    {
      "id": "2",
      "messages": [
        {
          "@type": "/cosmos.bank.v1beta1.MsgSend",
          "from_address": "cosmos1..",
          "to_address": "cosmos1..",
          "amount": [
            {
              "denom": "stake",
              "amount": "10"
            }
          ]
        }
      ],
      "status": "PROPOSAL_STATUS_DEPOSIT_PERIOD",
      "final_tally_result": {
        "yes_count": "0",
        "abstain_count": "0",
        "no_count": "0",
        "no_with_veto_count": "0"
      },
      "submit_time": "2022-03-28T14:02:41.165025015Z",
      "deposit_end_time": "2022-03-30T14:02:41.165025015Z",
      "total_deposit": [
        {
          "denom": "stake",
          "amount": "10"
        }
      ],
      "voting_start_time": null,
      "voting_end_time": null,
      "metadata": "AQ==",
      "title": "Proposal Title",
      "summary": "Proposal Summary"
    }
  ],
  "pagination": {
    "next_key": null,
    "total": "2"
  }
}
```

#### voter vote

The `votes` endpoint allows users to query a vote for a given proposal.

Using legacy v1beta1:

```bash
/cosmos/gov/v1beta1/proposals/{proposal_id}/votes/{voter}
```

Example:

```bash
curl localhost:1317/cosmos/gov/v1beta1/proposals/1/votes/cosmos1..
```

Example Output:

```bash
{
  "vote": {
    "proposal_id": "1",
    "voter": "cosmos1..",
    "option": "VOTE_OPTION_YES",
    "options": [
      {
        "option": "VOTE_OPTION_YES",
        "weight": "1.000000000000000000"
      }
    ]
  }
}
```

Using v1:

```bash
/cosmos/gov/v1/proposals/{proposal_id}/votes/{voter}
```

Example:

```bash
curl localhost:1317/cosmos/gov/v1/proposals/1/votes/cosmos1..
```

Example Output:

```bash
{
  "vote": {
    "proposal_id": "1",
    "voter": "cosmos1..",
    "options": [
      {
        "option": "VOTE_OPTION_YES",
        "weight": "1.000000000000000000"
      }
    ],
    "metadata": ""
  }
}
```

#### votes

The `votes` endpoint allows users to query all votes for a given proposal.

Using legacy v1beta1:

```bash
/cosmos/gov/v1beta1/proposals/{proposal_id}/votes
```

Example:

```bash
curl localhost:1317/cosmos/gov/v1beta1/proposals/1/votes
```

Example Output:

```bash
{
  "votes": [
    {
      "proposal_id": "1",
      "voter": "cosmos1..",
      "option": "VOTE_OPTION_YES",
      "options": [
        {
          "option": "VOTE_OPTION_YES",
          "weight": "1.000000000000000000"
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

Using v1:

```bash
/cosmos/gov/v1/proposals/{proposal_id}/votes
```

Example:

```bash
curl localhost:1317/cosmos/gov/v1/proposals/1/votes
```

Example Output:

```bash
{
  "votes": [
    {
      "proposal_id": "1",
      "voter": "cosmos1..",
      "options": [
        {
          "option": "VOTE_OPTION_YES",
          "weight": "1.000000000000000000"
        }
      ],
      "metadata": ""
    }
  ],
  "pagination": {
    "next_key": null,
    "total": "1"
  }
}
```

#### params

The `params` endpoint allows users to query all parameters for the `gov` module.

Using legacy v1beta1:

```bash
/cosmos/gov/v1beta1/params/{params_type}
```

Example:

```bash
curl localhost:1317/cosmos/gov/v1beta1/params/voting
```

Example Output:

```bash
{
  "voting_params": {
    "voting_period": "172800s"
  },
  "deposit_params": {
    "min_deposit": [
    ],
    "max_deposit_period": "0s"
  },
  "tally_params": {
    "quorum": "0.000000000000000000",
    "threshold": "0.000000000000000000",
    "veto_threshold": "0.000000000000000000"
  }
}
```

Using v1:

```bash
/cosmos/gov/v1/params/{params_type}
```

Example:

```bash
curl localhost:1317/cosmos/gov/v1/params/voting
```

Example Output:

```bash
{
  "voting_params": {
    "voting_period": "172800s"
  },
  "deposit_params": {
    "min_deposit": [
    ],
    "max_deposit_period": "0s"
  },
  "tally_params": {
    "quorum": "0.000000000000000000",
    "threshold": "0.000000000000000000",
    "veto_threshold": "0.000000000000000000"
  }
}
```

#### deposits

The `deposits` endpoint allows users to query a deposit for a given proposal from a given depositor.

Using legacy v1beta1:

```bash
/cosmos/gov/v1beta1/proposals/{proposal_id}/deposits/{depositor}
```

Example:

```bash
curl localhost:1317/cosmos/gov/v1beta1/proposals/1/deposits/cosmos1..
```

Example Output:

```bash
{
  "deposit": {
    "proposal_id": "1",
    "depositor": "cosmos1..",
    "amount": [
      {
        "denom": "stake",
        "amount": "10000000"
      }
    ]
  }
}
```

Using v1:

```bash
/cosmos/gov/v1/proposals/{proposal_id}/deposits/{depositor}
```

Example:

```bash
curl localhost:1317/cosmos/gov/v1/proposals/1/deposits/cosmos1..
```

Example Output:

```bash
{
  "deposit": {
    "proposal_id": "1",
    "depositor": "cosmos1..",
    "amount": [
      {
        "denom": "stake",
        "amount": "10000000"
      }
    ]
  }
}
```

#### proposal deposits

The `deposits` endpoint allows users to query all deposits for a given proposal.

Using legacy v1beta1:

```bash
/cosmos/gov/v1beta1/proposals/{proposal_id}/deposits
```

Example:

```bash
curl localhost:1317/cosmos/gov/v1beta1/proposals/1/deposits
```

Example Output:

```bash
{
  "deposits": [
    {
      "proposal_id": "1",
      "depositor": "cosmos1..",
      "amount": [
        {
          "denom": "stake",
          "amount": "10000000"
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

Using v1:

```bash
/cosmos/gov/v1/proposals/{proposal_id}/deposits
```

Example:

```bash
curl localhost:1317/cosmos/gov/v1/proposals/1/deposits
```

Example Output:

```bash
{
  "deposits": [
    {
      "proposal_id": "1",
      "depositor": "cosmos1..",
      "amount": [
        {
          "denom": "stake",
          "amount": "10000000"
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

#### tally

The `tally` endpoint allows users to query the tally of a given proposal.

Using legacy v1beta1:

```bash
/cosmos/gov/v1beta1/proposals/{proposal_id}/tally
```

Example:

```bash
curl localhost:1317/cosmos/gov/v1beta1/proposals/1/tally
```

Example Output:

```bash
{
  "tally": {
    "yes": "1000000",
    "abstain": "0",
    "no": "0",
    "no_with_veto": "0"
  }
}
```

Using v1:

```bash
/cosmos/gov/v1/proposals/{proposal_id}/tally
```

Example:

```bash
curl localhost:1317/cosmos/gov/v1/proposals/1/tally
```

Example Output:

```bash
{
  "tally": {
    "yes": "1000000",
    "abstain": "0",
    "no": "0",
    "no_with_veto": "0"
  }
}
```

## 元数据

gov 模块有两个元数据位置，用户可以在其中提供有关他们正在执行的链上操作的进一步上下文。默认情况下，所有元数据字段都有一个 255 字符长度的字段，元数据可以以 json 格式存储，根据所需的数据量，可以存储在链上或链下。在这里，我们提供 json 结构的建议以及数据应存储的位置。在制定这些建议时有两个重要因素。首先，gov 和 group 模块彼此一致，请注意所有组提出的提案数量可能相当大。其次，客户端应用程序（如区块浏览器和治理界面）对跨链元数据结构的一致性有信心。

### 提案

位置：链下，作为存储在 IPFS 上的 json 对象（镜像 [group proposal](group.md#metadata)）

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

位置：链上，作为 json，限制在 255 个字符内（镜像 [group vote](group.md#metadata)）

```json
{
  "justification": "",
}
```

## 未来改进

当前文档仅描述了治理模块的最小可行产品。未来的改进可能包括：

* **`BountyProposals`：** 如果被接受，`BountyProposal` 会创建一个开放的赏金。`BountyProposal` 指定完成时将给予多少 Atoms。这些 Atoms 将从 `reserve pool` 中取出。在 `BountyProposal` 被治理接受后，任何人都可以提交带有代码的 `SoftwareUpgradeProposal` 来领取赏金。请注意，一旦 `BountyProposal` 被接受，`reserve pool` 中的相应资金将被锁定，以便始终可以支付。为了将 `SoftwareUpgradeProposal` 链接到开放的赏金，`SoftwareUpgradeProposal` 的提交者将使用 `Proposal.LinkedProposal` 属性。如果链接到开放赏金的 `SoftwareUpgradeProposal` 被治理接受，预留的资金将自动转移给提交者。
* **复杂委托：** 委托者可以选择除其验证者之外的其他代表。最终，代表链总是会以验证者结束，但委托者可以在继承其验证者的投票之前继承其选择的代表的投票。换句话说，只有当他们的其他指定代表没有投票时，他们才会继承其验证者的投票。
* **更好的提案审查流程：** `proposal.Deposit` 将有两个部分，一个用于反垃圾邮件（与 MVP 中相同），另一个用于奖励第三方审计员。
