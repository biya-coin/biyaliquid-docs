---
sidebar_position: 1
---

# Staking

## Abstract

本文档指定了 Cosmos SDK 的 Staking 模块，该模块首次在 2016 年 6 月的 [Cosmos 白皮书](https://cosmos.network/about/whitepaper) 中描述。

该模块使基于 Cosmos SDK 的区块链能够支持先进的权益证明（PoS）系统。在这个系统中，链的原生质押代币持有者可以成为验证者，并可以将代币委托给验证者，最终确定系统的有效验证者集合。

该模块用于 Cosmos Hub，这是 Cosmos 网络中的第一个 Hub。

## State

### Pool

Pool 用于跟踪绑定和非绑定代币的供应量（绑定面额）。

### LastTotalPower

LastTotalPower 跟踪在上一个结束区块期间记录的绑定代币总量。前缀为 "Last" 的存储条目必须保持不变，直到 EndBlock。

* LastTotalPower: `0x12 -> ProtocolBuffer(math.Int)`

### ValidatorUpdates

ValidatorUpdates 包含在每个区块结束时返回给 ABCI 的验证者更新。值在每个区块中被覆盖。

* ValidatorUpdates `0x61 -> []abci.ValidatorUpdate`

### UnbondingID

UnbondingID 存储最新解绑操作的 ID。它能够为解绑操作创建唯一 ID，即每次启动新的解绑操作（验证者解绑、解绑委托、重新委托）时，UnbondingID 都会递增。

* UnbondingID: `0x37 -> uint64`

### Params

staking 模块将其参数存储在状态中，前缀为 `0x51`，可以通过治理或具有权限的地址进行更新。

* Params: `0x51 | ProtocolBuffer(Params)`

```protobuf
https://github.com/cosmos/cosmos-sdk/blob/v0.47.0-rc1/proto/cosmos/staking/v1beta1/staking.proto#L310-L333
```

### Validator

验证者可以具有三种状态之一

* `Unbonded`：验证者不在活跃集合中。他们不能签署区块，也不会获得奖励。他们可以接收委托。
* `Bonded`：一旦验证者收到足够的绑定代币，他们会在 [`EndBlock`](staking.md#validator-set-changes) 期间自动加入活跃集合，其状态更新为 `Bonded`。  他们正在签署区块并接收奖励。他们可以接收进一步的委托。他们可能因不当行为而被削减。解绑委托给此验证者的委托者必须等待 UnbondingTime 的持续时间（链特定参数），在此期间，如果源验证者的违规行为发生在代币绑定期间，他们仍然可能因源验证者的违规行为而被削减。
* `Unbonding`：当验证者离开活跃集合时，无论是自愿还是由于削减、监禁或标记为墓碑，所有委托的解绑都会开始。然后所有委托必须等待 UnbondingTime，然后才能将其代币从 `BondedPool` 转移到其账户。

:::warning\
标记为墓碑是永久性的，一旦被标记为墓碑，验证者的共识密钥就不能在发生标记的链中重复使用。\
:::

验证者对象应该主要通过 `OperatorAddr`（验证者操作员的 SDK 验证者地址）存储和访问。每个验证者对象维护两个额外的索引，以满足削减和验证者集合更新所需的查找。还维护第三个特殊索引（`LastValidatorPower`），但它在每个区块中保持恒定，与前两个在区块内镜像验证者记录的索引不同。

* Validators: `0x21 | OperatorAddrLen (1 byte) | OperatorAddr -> ProtocolBuffer(validator)`
* ValidatorsByConsAddr: `0x22 | ConsAddrLen (1 byte) | ConsAddr -> OperatorAddr`
* ValidatorsByPower: `0x23 | BigEndian(ConsensusPower) | OperatorAddrLen (1 byte) | OperatorAddr -> OperatorAddr`
* LastValidatorsPower: `0x11 | OperatorAddrLen (1 byte) | OperatorAddr -> ProtocolBuffer(ConsensusPower)`
* ValidatorsByUnbondingID: `0x38 | UnbondingID -> 0x21 | OperatorAddrLen (1 byte) | OperatorAddr`

`Validators` 是主索引 - 它确保每个操作员只能有一个关联的验证者，该验证者的公钥将来可能会更改。委托者可以参考验证者的不可变操作员，而不必担心更改的公钥。

`ValidatorsByUnbondingID` 是一个额外的索引，可以通过与其当前解绑对应的解绑 ID 来查找验证者。

`ValidatorByConsAddr` 是一个额外的索引，用于查找削减。当 CometBFT 报告证据时，它提供验证者地址，因此需要此映射来查找操作员。请注意，`ConsAddr` 对应于可以从验证者的 `ConsPubKey` 派生的地址。

`ValidatorsByPower` 是一个额外的索引，提供潜在验证者的排序列表，以快速确定当前活跃集合。这里 ConsensusPower 默认为 validator.Tokens/10^6。请注意，`Jailed` 为 true 的所有验证者都不会存储在此索引中。

`LastValidatorsPower` 是一个特殊索引，提供上一个区块的绑定验证者的历史列表。此索引在区块期间保持恒定，但在 [`EndBlock`](staking.md#end-block) 中发生的验证者集合更新过程中更新。

Each validator's state is stored in a `Validator` struct:

```protobuf
https://github.com/cosmos/cosmos-sdk/blob/v0.47.0-rc1/proto/cosmos/staking/v1beta1/staking.proto#L82-L138
```

```protobuf
https://github.com/cosmos/cosmos-sdk/blob/v0.47.0-rc1/proto/cosmos/staking/v1beta1/staking.proto#L26-L80
```

### Delegation

委托通过组合 `DelegatorAddr`（委托者的地址）和 `ValidatorAddr` 来标识。委托在存储中索引如下：

* Delegation: `0x31 | DelegatorAddrLen (1 byte) | DelegatorAddr | ValidatorAddrLen (1 byte) | ValidatorAddr -> ProtocolBuffer(delegation)`

权益持有者可以将代币委托给验证者；在这种情况下，他们的资金保存在 `Delegation` 数据结构中。它由一个委托者拥有，并与一个验证者的份额相关联。交易的发送者是绑定的所有者。

```protobuf
https://github.com/cosmos/cosmos-sdk/blob/v0.47.0-rc1/proto/cosmos/staking/v1beta1/staking.proto#L198-L216
```

#### Delegator Shares

当一个人将代币委托给验证者时，他们会根据动态汇率获得一定数量的委托者份额，该汇率根据委托给验证者的代币总数和迄今为止发行的份额数量计算如下：

`Shares per Token = validator.TotalShares() / validator.Tokens()`

只有收到的份额数量存储在 DelegationEntry 上。当委托者随后解绑时，他们收到的代币数量是根据他们当前持有的份额数量和反向汇率计算的：

`Tokens per Share = validator.Tokens() / validatorShares()`

这些 `Shares` 只是一个会计机制。它们不是可替代资产。这种机制的原因是为了简化围绕削减的会计。不是迭代削减每个委托条目的代币，而是可以削减验证者的总绑定代币，有效地降低每个已发行委托者份额的价值。

### UnbondingDelegation

`Delegation` 中的份额可以解绑，但它们必须在一段时间内作为 `UnbondingDelegation` 存在，如果检测到拜占庭行为，份额可能会减少。

`UnbondingDelegation` 在存储中索引为：

* UnbondingDelegation: `0x32 | DelegatorAddrLen (1 byte) | DelegatorAddr | ValidatorAddrLen (1 byte) | ValidatorAddr -> ProtocolBuffer(unbondingDelegation)`
* UnbondingDelegationsFromValidator: `0x33 | ValidatorAddrLen (1 byte) | ValidatorAddr | DelegatorAddrLen (1 byte) | DelegatorAddr -> nil`
* UnbondingDelegationByUnbondingId: `0x38 | UnbondingId -> 0x32 | DelegatorAddrLen (1 byte) | DelegatorAddr | ValidatorAddrLen (1 byte) | ValidatorAddrUnbondingDelegation` 用于查询，以查找给定委托者的所有解绑委托。

`UnbondingDelegationsFromValidator` 用于削减，以查找与需要削减的给定验证者关联的所有解绑委托。

`UnbondingDelegationByUnbondingId` 是一个额外的索引，可以通过包含的解绑委托条目的解绑 ID 来查找解绑委托。

A UnbondingDelegation object is created every time an unbonding is initiated.

```protobuf
https://github.com/cosmos/cosmos-sdk/blob/v0.47.0-rc1/proto/cosmos/staking/v1beta1/staking.proto#L218-L261
```

### Redelegation

`Delegation` 的绑定代币价值可以立即从源验证者重新委托到不同的验证者（目标验证者）。但是当发生这种情况时，必须在 `Redelegation` 对象中跟踪它们，如果它们的代币对源验证者犯下的拜占庭故障做出了贡献，它们的份额可能会被削减。

`Redelegation` 在存储中索引为：

* Redelegations: `0x34 | DelegatorAddrLen (1 byte) | DelegatorAddr | ValidatorAddrLen (1 byte) | ValidatorSrcAddr | ValidatorDstAddr -> ProtocolBuffer(redelegation)`
* RedelegationsBySrc: `0x35 | ValidatorSrcAddrLen (1 byte) | ValidatorSrcAddr | ValidatorDstAddrLen (1 byte) | ValidatorDstAddr | DelegatorAddrLen (1 byte) | DelegatorAddr -> nil`
* RedelegationsByDst: `0x36 | ValidatorDstAddrLen (1 byte) | ValidatorDstAddr | ValidatorSrcAddrLen (1 byte) | ValidatorSrcAddr | DelegatorAddrLen (1 byte) | DelegatorAddr -> nil`
* RedelegationByUnbondingId: `0x38 | UnbondingId -> 0x34 | DelegatorAddrLen (1 byte) | DelegatorAddr | ValidatorAddrLen (1 byte) | ValidatorSrcAddr | ValidatorDstAddr`

`Redelegations` 用于查询，以查找给定委托者的所有重新委托。

`RedelegationsBySrc` 用于基于 `ValidatorSrcAddr` 的削减。

`RedelegationsByDst` 用于基于 `ValidatorDstAddr` 的削减

这里的第一个映射用于查询，以查找给定委托者的所有重新委托。第二个映射用于基于 `ValidatorSrcAddr` 的削减，而第三个映射用于基于 `ValidatorDstAddr` 的削减。

`RedelegationByUnbondingId` 是一个额外的索引，可以通过包含的重新委托条目的解绑 ID 来查找重新委托。

每次发生重新委托时都会创建一个重新委托对象。为了防止"重新委托跳跃"，在以下情况下可能不会发生重新委托：

* （重新）委托者已经有一个不成熟的重新委托正在进行，目标是一个验证者（我们称它为 `Validator X`）
* 并且，（重新）委托者试图创建一个_新的_重新委托，其中这个新重新委托的源验证者是 `Validator X`。

```protobuf
https://github.com/cosmos/cosmos-sdk/blob/v0.47.0-rc1/proto/cosmos/staking/v1beta1/staking.proto#L263-L308
```

### Queues

所有队列对象都按时间戳排序。任何队列中使用的时间首先转换为 UTC，四舍五入到最近的纳秒，然后排序。使用的可排序时间格式是对 RFC3339Nano 的轻微修改，使用格式字符串 `"2006-01-02T15:04:05.000000000"`。值得注意的是，此格式：

* 右填充所有零
* 删除时区信息（我们已经使用 UTC）

在所有情况下，存储的时间戳表示队列元素的成熟时间。

#### UnbondingDelegationQueue

为了跟踪解绑委托的进度，保留了解绑委托队列。

* UnbondingDelegation: `0x41 | format(time) -> []DVPair`

```protobuf
https://github.com/cosmos/cosmos-sdk/blob/v0.47.0-rc1/proto/cosmos/staking/v1beta1/staking.proto#L162-L172
```

#### RedelegationQueue

为了跟踪重新委托的进度，保留了重新委托队列。

* RedelegationQueue: `0x42 | format(time) -> []DVVTriplet`

```protobuf
https://github.com/cosmos/cosmos-sdk/blob/v0.47.0-rc1/proto/cosmos/staking/v1beta1/staking.proto#L179-L191
```

#### ValidatorQueue

为了跟踪解绑验证者的进度，保留了验证者队列。

* ValidatorQueueTime: `0x43 | format(time) -> []sdk.ValAddress`

每个键存储的对象是验证者操作员地址的数组，可以从中访问验证者对象。通常期望只有一个验证者记录与给定时间戳关联，但可能在队列的同一位置存在多个验证者。

### HistoricalInfo

HistoricalInfo 对象在每个区块存储和修剪，以便 staking keeper 持久化由 staking 模块参数 `HistoricalEntries` 定义的 `n` 个最近的历史信息。

```go
https://github.com/cosmos/cosmos-sdk/blob/v0.47.0-rc1/proto/cosmos/staking/v1beta1/staking.proto#L17-L24
```

在每个 BeginBlock，staking keeper 将在 `HistoricalInfo` 对象中持久化当前 Header 和提交当前区块的验证者。验证者按其地址排序，以确保它们处于确定性顺序。最旧的 HistoricalEntries 将被修剪，以确保只存在参数定义数量的历史条目。

## State Transitions

### Validators

验证者中的状态转换在每个 [`EndBlock`](staking.md#validator-set-changes) 上执行，以检查活跃 `ValidatorSet` 的变化。

验证者可以是 `Unbonded`、`Unbonding` 或 `Bonded`。`Unbonded`和 `Unbonding` 统称为 `Not Bonded`。验证者可以在所有状态之间直接移动，除了从 `Bonded` 到 `Unbonded`。

#### Not bonded to Bonded

当验证者在 `ValidatorPowerIndex` 中的排名超过 `LastValidator` 时，会发生以下转换。

* 将 `validator.Status` 设置为 `Bonded`
* 将 `validator.Tokens` 从 `NotBondedTokens` 发送到 `BondedPool` `ModuleAccount`
* 从 `ValidatorByPowerIndex` 删除现有记录
* 向 `ValidatorByPowerIndex` 添加新的更新记录
* 更新此验证者的 `Validator` 对象
* 如果存在，删除此验证者的任何 `ValidatorQueue` 记录

#### Bonded to Unbonding

当验证者开始解绑过程时，会发生以下操作：

* 将 `validator.Tokens` 从 `BondedPool` 发送到 `NotBondedTokens` `ModuleAccount`
* 将 `validator.Status` 设置为 `Unbonding`
* 从 `ValidatorByPowerIndex` 删除现有记录
* 向 `ValidatorByPowerIndex` 添加新的更新记录
* 更新此验证者的 `Validator` 对象
* 为此验证者插入新的 `ValidatorQueue` 记录

#### Unbonding to Unbonded

当 `ValidatorQueue` 对象从绑定移动到未绑定时，验证者从解绑移动到未绑定

* 更新此验证者的 `Validator` 对象
* 将 `validator.Status` 设置为 `Unbonded`

#### Jail/Unjail

当验证者被监禁时，它实际上从 CometBFT 集合中移除。这个过程也可以逆转。发生以下操作：

* 设置 `Validator.Jailed` 并更新对象
* 如果被监禁，从 `ValidatorByPowerIndex` 删除记录
* 如果解除监禁，向 `ValidatorByPowerIndex` 添加记录

被监禁的验证者不存在于以下任何存储中：

* 权力存储（从共识权力到地址）

### Delegations

#### Delegate

当发生委托时，验证者和委托对象都会受到影响

* 根据委托的代币和验证者的汇率确定委托者的份额
* 从发送账户中移除代币
* 向委托对象添加份额或将其添加到创建的验证者对象
* 添加新的委托者份额并更新 `Validator` 对象
* 根据 `validator.Status` 是否为 `Bonded`，将 `delegation.Amount` 从委托者的账户转移到 `BondedPool` 或 `NotBondedPool` `ModuleAccount`
* 从 `ValidatorByPowerIndex` 删除现有记录
* 向 `ValidatorByPowerIndex` 添加新的更新记录

#### Begin Unbonding

作为解绑和完成解绑状态转换的一部分，可能会调用解绑委托。

* 从委托者中减去解绑的份额
* 将解绑的代币添加到 `UnbondingDelegationEntry`
* 更新委托，如果没有更多份额则删除委托
* 如果委托是验证者的操作员且不再有份额，则触发监禁验证者
* 更新验证者，移除委托者份额和关联的代币
* 如果验证者状态是 `Bonded`，将解绑份额价值的 `Coins` 从 `BondedPool` 转移到 `NotBondedPool` `ModuleAccount`
* 如果验证者未绑定且没有更多委托份额，则删除验证者
* 获取唯一的 `unbondingId` 并将其映射到 `UnbondingDelegationByUnbondingId` 中的 `UnbondingDelegationEntry`
* 调用 `AfterUnbondingInitiated(unbondingId)` 钩子
* 将解绑委托添加到 `UnbondingDelegationQueue`，完成时间设置为 `UnbondingTime`

#### Cancel an `UnbondingDelegation` Entry

当发生 `cancel unbond delegation` 时，`validator`、`delegation` 和 `UnbondingDelegationQueue` 状态都将更新。

* 如果取消解绑委托金额等于 `UnbondingDelegation` 条目 `balance`，则从 `UnbondingDelegationQueue` 删除 `UnbondingDelegation` 条目。
* 如果 `cancel unbonding delegation amount` 小于 `UnbondingDelegation` 条目余额，则 `UnbondingDelegation` 条目将在 `UnbondingDelegationQueue` 中使用新余额更新。
* 取消的 `amount` 被[委托](staking.md#delegations)回原始 `validator`。

#### Complete Unbonding

对于不能立即完成的解委托，当解绑委托队列元素成熟时，会发生以下操作：

* 从 `UnbondingDelegation` 对象中删除条目
* 将代币从 `NotBondedPool` `ModuleAccount` 转移到委托者 `Account`

#### Begin Redelegation

重新委托影响委托、源验证者和目标验证者。

* 从源验证者执行 `unbond` 委托以检索解绑份额的代币价值
* 使用解绑的代币，将它们 `Delegate` 到目标验证者
* 如果 `sourceValidator.Status` 是 `Bonded`，而 `destinationValidator` 不是，  将新委托的代币从 `BondedPool` 转移到 `NotBondedPool` `ModuleAccount`
* 否则，如果 `sourceValidator.Status` 不是 `Bonded`，而 `destinationValidator`  是 `Bonded`，将新委托的代币从 `NotBondedPool` 转移到 `BondedPool` `ModuleAccount`
* 在相关 `Redelegation` 的新条目中记录代币数量

从重新委托开始到完成，委托者处于"伪解绑"状态，仍然可能因在重新委托开始之前发生的违规行为而被削减。

#### Complete Redelegation

当重新委托完成时，会发生以下情况：

* 从 `Redelegation` 对象中删除条目

### Slashing

#### Slash Validator

当验证者被削减时，会发生以下情况：

* 总 `slashAmount` 计算为 `slashFactor`（链参数）\* `TokensFromConsensusPower`，违规时绑定到验证者的代币总数。
* 每个解绑委托和伪解绑重新委托，如果违规发生在解绑或重新委托从验证者开始之前，则按 `initialBalance` 的 `slashFactor` 百分比削减。
* 从重新委托和解绑委托中削减的每个金额从总削减金额中减去。
* 然后根据验证者的状态，从验证者在 `BondedPool` 或 `NonBondedPool` 中的代币中削减 `remaingSlashAmount`。这减少了代币的总供应量。

对于需要提交证据的违规行为（例如双重签名）导致的削减，削减发生在包含证据的区块，而不是违规发生的区块。换句话说，验证者不会追溯削减，只有在被抓住时才会削减。

#### Slash Unbonding Delegation

当验证者被削减时，那些在违规时间之后开始解绑的验证者解绑委托也会被削减。验证者的每个解绑委托中的每个条目按 `slashFactor` 削减。削减的金额从委托的 `InitialBalance` 计算，并设置上限以防止负余额。已完成（或成熟）的解绑不会被削减。

#### Slash Redelegation

当验证者被削减时，所有在违规之后开始的验证者重新委托也会被削减。重新委托按 `slashFactor` 削减。在违规之前开始的重新委托不会被削减。削减的金额从委托的 `InitialBalance` 计算，并设置上限以防止负余额。成熟的重新委托（已完成伪解绑）不会被削减。

### How Shares are calculated

在任何给定时间点，每个验证者都有一定数量的代币 `T`，并发行了一定数量的份额 `S`。每个委托者 `i` 持有一定数量的份额 `S_i`。代币数量是委托给验证者的所有代币的总和，加上奖励，减去削减。

委托者有权获得与其份额比例成比例的底层代币部分。因此，委托者 `i` 有权获得验证者代币的 `T * S_i / S`。

当委托者将新代币委托给验证者时，他们会获得与其贡献成比例的份额。因此，当委托者 `j` 委托 `T_j` 代币时，他们获得 `S_j = S * T_j / T` 份额。代币总数现在是 `T + T_j`，份额总数是 `S + S_j`。`j` 的份额比例与其贡献的总代币比例相同：`(S + S_j) / S = (T + T_j) / T`。

特殊情况是初始委托，当 `T = 0` 和 `S = 0` 时，`T_j / T` 未定义。对于初始委托，委托 `T_j` 代币的委托者 `j` 获得 `S_j = T_j` 份额。因此，没有收到任何奖励且没有被削减的验证者将有 `T = S`。

## Messages

在本节中，我们描述 staking 消息的处理以及状态的相应更新。每个消息指定的所有创建/修改的状态对象都在 [state](staking.md#state) 部分中定义。

### MsgCreateValidator

使用 `MsgCreateValidator` 消息创建验证者。验证者必须通过操作员的初始委托创建。

```protobuf
https://github.com/cosmos/cosmos-sdk/blob/v0.47.0-rc1/proto/cosmos/staking/v1beta1/tx.proto#L20-L21
```

```protobuf
https://github.com/cosmos/cosmos-sdk/blob/v0.47.0-rc1/proto/cosmos/staking/v1beta1/tx.proto#L50-L73
```

如果出现以下情况，此消息预期会失败：

* 已注册具有此操作员地址的另一个验证者
* 已注册具有此公钥的另一个验证者
* 初始自委托代币的面额未指定为绑定面额
* 佣金参数有误，即：
  * `MaxRate` 要么 > 1 要么 < 0
  * 初始 `Rate` 要么为负数要么 > `MaxRate`
  * 初始 `MaxChangeRate` 要么为负数要么 > `MaxRate`
* 描述字段太大

此消息创建并存储适当索引处的 `Validator` 对象。此外，使用初始代币委托代币 `Delegation` 进行自委托。验证者始终以未绑定状态开始，但可能在第一个结束区块中被绑定。

### MsgEditValidator

可以使用 `MsgEditValidator` 消息更新验证者的 `Description`、`CommissionRate`。

```protobuf
https://github.com/cosmos/cosmos-sdk/blob/v0.47.0-rc1/proto/cosmos/staking/v1beta1/tx.proto#L23-L24
```

```protobuf
https://github.com/cosmos/cosmos-sdk/blob/v0.47.0-rc1/proto/cosmos/staking/v1beta1/tx.proto#L78-L97
```

如果出现以下情况，此消息预期会失败：

* 初始 `CommissionRate` 要么为负数要么 > `MaxRate`
* `CommissionRate` 在过去 24 小时内已更新
* `CommissionRate` > `MaxChangeRate`
* 描述字段太大

此消息存储更新的 `Validator` 对象。

### MsgDelegate

在此消息中，委托者提供代币，作为回报，他们收到一定数量的验证者（新创建的）委托者份额，\
这些份额分配给 `Delegation.Shares`。

```protobuf
https://github.com/cosmos/cosmos-sdk/blob/v0.47.0-rc1/proto/cosmos/staking/v1beta1/tx.proto#L26-L28
```

```protobuf
https://github.com/cosmos/cosmos-sdk/blob/v0.47.0-rc1/proto/cosmos/staking/v1beta1/tx.proto#L102-L114
```

如果出现以下情况，此消息预期会失败：

* 验证者不存在
* `Amount` `Coin` 的面额与 `params.BondDenom` 定义的不同
* 汇率无效，意味着验证者没有代币（由于削减）但存在未偿还份额
* 委托金额小于允许的最小委托

如果提供的地址的现有 `Delegation` 对象尚不存在，则作为此消息的一部分创建它，否则更新现有 `Delegation` 以包含新收到的份额。

委托者以当前汇率接收新铸造的份额。汇率是验证者中现有份额数除以当前委托的代币数。

验证者在 `ValidatorByPower` 索引中更新，委托在 `Validators` 索引中的验证者对象中跟踪。

可以委托给被监禁的验证者，唯一的区别是它不会被添加到权力索引中，直到它被解除监禁。

![Delegation sequence](https://raw.githubusercontent.com/cosmos/cosmos-sdk/release/v0.46.x/docs/uml/svg/delegation_sequence.svg)

### MsgUndelegate

`MsgUndelegate` 消息允许委托者从验证者解委托其代币。

```protobuf
https://github.com/cosmos/cosmos-sdk/blob/v0.47.0-rc1/proto/cosmos/staking/v1beta1/tx.proto#L34-L36
```

```protobuf
https://github.com/cosmos/cosmos-sdk/blob/v0.47.0-rc1/proto/cosmos/staking/v1beta1/tx.proto#L140-L152
```

此消息返回包含解委托完成时间的响应：

```protobuf
https://github.com/cosmos/cosmos-sdk/blob/v0.47.0-rc1/proto/cosmos/staking/v1beta1/tx.proto#L154-L158
```

如果出现以下情况，此消息预期会失败：

* 委托不存在
* 验证者不存在
* 委托的份额少于 `Amount` 价值的份额
* 现有 `UnbondingDelegation` 具有 `params.MaxEntries` 定义的最大条目数
* `Amount` 的面额与 `params.BondDenom` 定义的不同

处理此消息时，会发生以下操作：

* 验证者的 `DelegatorShares` 和委托的 `Shares` 都按消息 `SharesAmount` 减少
* 计算份额的代币价值，从验证者持有的代币中移除该数量
* 使用这些移除的代币，如果验证者是：
  * `Bonded` - 将它们添加到 `UnbondingDelegation` 的条目中（如果不存在则创建 `UnbondingDelegation`），完成时间为从当前时间起的完整解绑期。更新池份额以按份额的代币价值减少 BondedTokens 并增加 NotBondedTokens。
  * `Unbonding` - 将它们添加到 `UnbondingDelegation` 的条目中（如果不存在则创建 `UnbondingDelegation`），完成时间与验证者相同（`UnbondingMinTime`）。
  * `Unbonded` - 然后将代币发送到消息 `DelegatorAddr`
* 如果委托中没有更多 `Shares`，则从存储中删除委托对象
  * 在这种情况下，如果委托是验证者的自委托，则也监禁验证者。

![Unbond sequence](https://raw.githubusercontent.com/cosmos/cosmos-sdk/release/v0.46.x/docs/uml/svg/unbond_sequence.svg)

### MsgCancelUnbondingDelegation

`MsgCancelUnbondingDelegation` 消息允许委托者取消 `unbondingDelegation` 条目并委托回先前的验证者。

```protobuf
https://github.com/cosmos/cosmos-sdk/blob/v0.47.0-rc1/proto/cosmos/staking/v1beta1/tx.proto#L38-L42
```

```protobuf
https://github.com/cosmos/cosmos-sdk/blob/v0.47.0-rc1/proto/cosmos/staking/v1beta1/tx.proto#L160-L175
```

如果出现以下情况，此消息预期会失败：

* `unbondingDelegation` 条目已被处理。
* `cancel unbonding delegation` 金额大于 `unbondingDelegation` 条目余额。
* `cancel unbonding delegation` 高度在委托者的 `unbondingDelegationQueue` 中不存在。

处理此消息时，会发生以下操作：

* 如果 `unbondingDelegation` 条目余额为零
  * 在这种情况下，`unbondingDelegation` 条目将从 `unbondingDelegationQueue` 中删除。
  * 否则，`unbondingDelegationQueue` 将使用新的 `unbondingDelegation` 条目余额和初始余额更新
* 验证者的 `DelegatorShares` 和委托的 `Shares` 都按消息 `Amount` 增加。

### MsgBeginRedelegate

重新委托命令允许委托者立即切换验证者。一旦解绑期过去，重新委托会在 EndBlocker 中自动完成。

```protobuf
https://github.com/cosmos/cosmos-sdk/blob/v0.47.0-rc1/proto/cosmos/staking/v1beta1/tx.proto#L30-L32
```

```protobuf
https://github.com/cosmos/cosmos-sdk/blob/v0.47.0-rc1/proto/cosmos/staking/v1beta1/tx.proto#L119-L132
```

此消息返回包含重新委托完成时间的响应：

```protobuf
https://github.com/cosmos/cosmos-sdk/blob/v0.47.0-rc1/proto/cosmos/staking/v1beta1/tx.proto#L133-L138
```

如果出现以下情况，此消息预期会失败：

* 委托不存在
* 源或目标验证者不存在
* 委托的份额少于 `Amount` 价值的份额
* 源验证者有一个未成熟的接收重新委托（即重新委托可能是传递的）
* 现有 `Redelegation` 具有 `params.MaxEntries` 定义的最大条目数
* `Amount` `Coin` 的面额与 `params.BondDenom` 定义的不同

处理此消息时，会发生以下操作：

* 源验证者的 `DelegatorShares` 和委托的 `Shares` 都按消息 `SharesAmount` 减少
* 计算份额的代币价值，从源验证者持有的代币中移除该数量。
* 如果源验证者是：
  * `Bonded` - 向 `Redelegation` 添加条目（如果不存在则创建 `Redelegation`），完成时间为从当前时间起的完整解绑期。更新池份额以按份额的代币价值减少 BondedTokens 并增加 NotBondedTokens（但这可能在下一步中有效逆转）。
  * `Unbonding` - 向 `Redelegation` 添加条目（如果不存在则创建 `Redelegation`），完成时间与验证者相同（`UnbondingMinTime`）。
  * `Unbonded` - 此步骤不需要操作
* 将代币价值委托给目标验证者，可能将代币移回绑定状态。
* 如果源委托中没有更多 `Shares`，则从存储中删除源委托对象
  * 在这种情况下，如果委托是验证者的自委托，则也监禁验证者。

![Begin redelegation sequence](https://raw.githubusercontent.com/cosmos/cosmos-sdk/release/v0.46.x/docs/uml/svg/begin_redelegation_sequence.svg)

### MsgUpdateParams

`MsgUpdateParams` 更新 staking 模块参数。参数通过治理提案更新，其中签名者是 gov 模块账户地址。

```protobuf
https://github.com/cosmos/cosmos-sdk/blob/v0.47.0-rc1/proto/cosmos/staking/v1beta1/tx.proto#L182-L195
```

如果出现以下情况，消息处理可能会失败：

* 签名者不是 staking keeper 中定义的权限（通常是 gov 模块账户）。

## Begin-Block

每次 abci begin block 调用时，历史信息将根据 `HistoricalEntries` 参数存储和修剪。

### Historical Info Tracking

如果 `HistoricalEntries` 参数为 0，则 `BeginBlock` 执行空操作。

否则，最新的历史信息存储在键 `historicalInfoKey|height` 下，而任何早于 `height - HistoricalEntries` 的条目将被删除。在大多数情况下，这导致每个区块修剪单个条目。但是，如果参数 `HistoricalEntries` 已更改为较低值，则存储中将有多个条目必须被修剪。

## End-Block

每次 abci end block 调用时，指定执行更新队列和验证者集合更改的操作。

### Validator Set Changes

staking 验证者集合在此过程中通过在每个区块结束时运行的状态转换更新。作为此过程的一部分，任何更新的验证者也会返回给 CometBFT，以包含在 CometBFT 验证者集合中，该集合负责在共识层验证 CometBFT 消息。操作如下：

* 新验证者集合取自从 `ValidatorsByPower` 索引检索的前 `params.MaxValidators` 数量的验证者
* 将先前的验证者集合与新验证者集合进行比较：
  * 缺失的验证者开始解绑，其 `Tokens` 从 `BondedPool` 转移到 `NotBondedPool` `ModuleAccount`
  * 新验证者立即绑定，其 `Tokens` 从 `NotBondedPool` 转移到 `BondedPool` `ModuleAccount`

在所有情况下，任何离开或进入绑定验证者集合或更改余额并保持在绑定验证者集合内的验证者都会产生更新消息，报告其新的共识权力，该消息被传递回 CometBFT。

`LastTotalPower` 和 `LastValidatorsPower` 保存来自上一个区块结束的总权力和验证者权力的状态，用于检查 `ValidatorsByPower` 和总新权力中发生的变化，这在 `EndBlock` 期间计算。

### Queues

在 staking 中，某些状态转换不是瞬时的，而是在一段时间内发生（通常是解绑期）。当这些transitions are mature certain operations must take place in order to complete the state operation. This is achieved through the use of queues which are checked/processed at the end of each block.

#### Unbonding Validators

When a validator is kicked out of the bonded validator set (either through被监禁，或没有足够的绑定代币）它开始解绑过程，其所有委托也开始解绑（同时仍委托给此验证者）。此时验证者被称为"解绑验证者"，在解绑期过去后，它将成熟成为"未绑定验证者"。

每个区块都要检查验证者队列中是否有成熟的解绑验证者（即完成时间 <= 当前时间且完成高度 <= 当前区块高度）。此时，任何没有剩余委托的成熟验证者都会从状态中删除。对于所有其他仍有剩余委托的成熟解绑验证者，`validator.Status` 从 `types.Unbonding` 切换到 `types.Unbonded`。

解绑操作可以通过外部模块通过 `PutUnbondingOnHold(unbondingId)` 方法暂停。因此，暂停的解绑操作（例如，解绑委托）即使达到成熟也无法完成。对于具有 `unbondingId` 的解绑操作最终完成（在达到成熟后），每次调用 `PutUnbondingOnHold(unbondingId)` 必须与调用 `UnbondingCanComplete(unbondingId)` 匹配。

#### Unbonding Delegations

完成 `UnbondingDelegations` 队列中所有成熟的 `UnbondingDelegations.Entries` 的解绑，使用以下过程：

* 将余额代币转移到委托者的钱包地址
* 从 `UnbondingDelegation.Entries` 中删除成熟条目
* 如果没有剩余条目，则从存储中删除 `UnbondingDelegation` 对象。

#### Redelegations

完成 `Redelegations` 队列中所有成熟的 `Redelegation.Entries` 的解绑，使用以下过程：

* 从 `Redelegation.Entries` 中删除成熟条目
* 如果没有剩余条目，则从存储中删除 `Redelegation` 对象。

## Hooks

其他模块可以注册操作，以便在 staking 中发生某些事件时执行。这些事件可以注册为在 staking 事件之前或之后执行（根据钩子名称）。以下钩子可以在 staking 中注册：

* `AfterValidatorCreated(Context, ValAddress) error`
  * 在创建验证者时调用
* `BeforeValidatorModified(Context, ValAddress) error`
  * 在验证者状态更改时调用
* `AfterValidatorRemoved(Context, ConsAddress, ValAddress) error`
  * 在删除验证者时调用
* `AfterValidatorBonded(Context, ConsAddress, ValAddress) error`
  * 在验证者绑定时调用
* `AfterValidatorBeginUnbonding(Context, ConsAddress, ValAddress) error`
  * 在验证者开始解绑时调用
* `BeforeDelegationCreated(Context, AccAddress, ValAddress) error`
  * 在创建委托时调用
* `BeforeDelegationSharesModified(Context, AccAddress, ValAddress) error`
  * 在委托份额被修改时调用
* `AfterDelegationModified(Context, AccAddress, ValAddress) error`
  * 在创建或修改委托时调用
* `BeforeDelegationRemoved(Context, AccAddress, ValAddress) error`
  * 在删除委托时调用
* `AfterUnbondingInitiated(Context, UnbondingID)`
  * 在启动解绑操作（验证者解绑、解绑委托、重新委托）时调用

## Events

The staking module emits the following events:

### EndBlocker

| Type                   | Attribute Key          | Attribute Value           |
| ---------------------- | ---------------------- | ------------------------- |
| complete\_unbonding    | amount                 | {totalUnbondingAmount}    |
| complete\_unbonding    | validator              | {validatorAddress}        |
| complete\_unbonding    | delegator              | {delegatorAddress}        |
| complete\_redelegation | amount                 | {totalRedelegationAmount} |
| complete\_redelegation | source\_validator      | {srcValidatorAddress}     |
| complete\_redelegation | destination\_validator | {dstValidatorAddress}     |
| complete\_redelegation | delegator              | {delegatorAddress}        |

## Msg's

### MsgCreateValidator

| Type              | Attribute Key | Attribute Value    |
| ----------------- | ------------- | ------------------ |
| create\_validator | validator     | {validatorAddress} |
| create\_validator | amount        | {delegationAmount} |
| message           | module        | staking            |
| message           | action        | create\_validator  |
| message           | sender        | {senderAddress}    |

### MsgEditValidator

| Type            | Attribute Key         | Attribute Value     |
| --------------- | --------------------- | ------------------- |
| edit\_validator | commission\_rate      | {commissionRate}    |
| edit\_validator | min\_self\_delegation | {minSelfDelegation} |
| message         | module                | staking             |
| message         | action                | edit\_validator     |
| message         | sender                | {senderAddress}     |

### MsgDelegate

| Type     | Attribute Key | Attribute Value    |
| -------- | ------------- | ------------------ |
| delegate | validator     | {validatorAddress} |
| delegate | amount        | {delegationAmount} |
| message  | module        | staking            |
| message  | action        | delegate           |
| message  | sender        | {senderAddress}    |

### MsgUndelegate

| Type    | Attribute Key         | Attribute Value    |
| ------- | --------------------- | ------------------ |
| unbond  | validator             | {validatorAddress} |
| unbond  | amount                | {unbondAmount}     |
| unbond  | completion\_time \[0] | {completionTime}   |
| message | module                | staking            |
| message | action                | begin\_unbonding   |
| message | sender                | {senderAddress}    |

* \[0] Time is formatted in the RFC3339 standard

### MsgCancelUnbondingDelegation

| Type                          | Attribute Key    | Attribute Value                   |
| ----------------------------- | ---------------- | --------------------------------- |
| cancel\_unbonding\_delegation | validator        | {validatorAddress}                |
| cancel\_unbonding\_delegation | delegator        | {delegatorAddress}                |
| cancel\_unbonding\_delegation | amount           | {cancelUnbondingDelegationAmount} |
| cancel\_unbonding\_delegation | creation\_height | {unbondingCreationHeight}         |
| message                       | module           | staking                           |
| message                       | action           | cancel\_unbond                    |
| message                       | sender           | {senderAddress}                   |

### MsgBeginRedelegate

| Type       | Attribute Key          | Attribute Value       |
| ---------- | ---------------------- | --------------------- |
| redelegate | source\_validator      | {srcValidatorAddress} |
| redelegate | destination\_validator | {dstValidatorAddress} |
| redelegate | amount                 | {unbondAmount}        |
| redelegate | completion\_time \[0]  | {completionTime}      |
| message    | module                 | staking               |
| message    | action                 | begin\_redelegate     |
| message    | sender                 | {senderAddress}       |

* \[0] Time is formatted in the RFC3339 standard

## Parameters

The staking module contains the following parameters:

| Key               | Type             | Example                |
| ----------------- | ---------------- | ---------------------- |
| UnbondingTime     | string (time ns) | "259200000000000"      |
| MaxValidators     | uint16           | 100                    |
| KeyMaxEntries     | uint16           | 7                      |
| HistoricalEntries | uint16           | 3                      |
| BondDenom         | string           | "stake"                |
| MinCommissionRate | string           | "0.000000000000000000" |

## Client

### CLI

A user can query and interact with the `staking` module using the CLI.

#### Query

The `query` commands allows users to query `staking` state.

```bash
simd query staking --help
```

**delegation**

The `delegation` command allows users to query delegations for an individual delegator on an individual validator.

Usage:

```bash
simd query staking delegation [delegator-addr] [validator-addr] [flags]
```

Example:

```bash
simd query staking delegation cosmos1gghjut3ccd8ay0zduzj64hwre2fxs9ld75ru9p cosmosvaloper1gghjut3ccd8ay0zduzj64hwre2fxs9ldmqhffj
```

Example Output:

```bash
balance:
  amount: "10000000000"
  denom: stake
delegation:
  delegator_address: cosmos1gghjut3ccd8ay0zduzj64hwre2fxs9ld75ru9p
  shares: "10000000000.000000000000000000"
  validator_address: cosmosvaloper1gghjut3ccd8ay0zduzj64hwre2fxs9ldmqhffj
```

**delegations**

The `delegations` command allows users to query delegations for an individual delegator on all validators.

Usage:

```bash
simd query staking delegations [delegator-addr] [flags]
```

Example:

```bash
simd query staking delegations cosmos1gghjut3ccd8ay0zduzj64hwre2fxs9ld75ru9p
```

Example Output:

```bash
delegation_responses:
- balance:
    amount: "10000000000"
    denom: stake
  delegation:
    delegator_address: cosmos1gghjut3ccd8ay0zduzj64hwre2fxs9ld75ru9p
    shares: "10000000000.000000000000000000"
    validator_address: cosmosvaloper1gghjut3ccd8ay0zduzj64hwre2fxs9ldmqhffj
- balance:
    amount: "10000000000"
    denom: stake
  delegation:
    delegator_address: cosmos1gghjut3ccd8ay0zduzj64hwre2fxs9ld75ru9p
    shares: "10000000000.000000000000000000"
    validator_address: cosmosvaloper1x20lytyf6zkcrv5edpkfkn8sz578qg5sqfyqnp
pagination:
  next_key: null
  total: "0"
```

**delegations-to**

The `delegations-to` command allows users to query delegations on an individual validator.

Usage:

```bash
simd query staking delegations-to [validator-addr] [flags]
```

Example:

```bash
simd query staking delegations-to cosmosvaloper1gghjut3ccd8ay0zduzj64hwre2fxs9ldmqhffj
```

Example Output:

```bash
- balance:
    amount: "504000000"
    denom: stake
  delegation:
    delegator_address: cosmos1q2qwwynhv8kh3lu5fkeex4awau9x8fwt45f5cp
    shares: "504000000.000000000000000000"
    validator_address: cosmosvaloper1gghjut3ccd8ay0zduzj64hwre2fxs9ldmqhffj
- balance:
    amount: "78125000000"
    denom: uixo
  delegation:
    delegator_address: cosmos1qvppl3479hw4clahe0kwdlfvf8uvjtcd99m2ca
    shares: "78125000000.000000000000000000"
    validator_address: cosmosvaloper1gghjut3ccd8ay0zduzj64hwre2fxs9ldmqhffj
pagination:
  next_key: null
  total: "0"
```

**historical-info**

The `historical-info` command allows users to query historical information at given height.

Usage:

```bash
simd query staking historical-info [height] [flags]
```

Example:

```bash
simd query staking historical-info 10
```

Example Output:

```bash
header:
  app_hash: Lbx8cXpI868wz8sgp4qPYVrlaKjevR5WP/IjUxwp3oo=
  chain_id: testnet
  consensus_hash: BICRvH3cKD93v7+R1zxE2ljD34qcvIZ0Bdi389qtoi8=
  data_hash: 47DEQpj8HBSa+/TImW+5JCeuQeRkm5NMpJWZG3hSuFU=
  evidence_hash: 47DEQpj8HBSa+/TImW+5JCeuQeRkm5NMpJWZG3hSuFU=
  height: "10"
  last_block_id:
    hash: RFbkpu6pWfSThXxKKl6EZVDnBSm16+U0l0xVjTX08Fk=
    part_set_header:
      hash: vpIvXD4rxD5GM4MXGz0Sad9I7//iVYLzZsEU4BVgWIU=
      total: 1
  last_commit_hash: Ne4uXyx4QtNp4Zx89kf9UK7oG9QVbdB6e7ZwZkhy8K0=
  last_results_hash: 47DEQpj8HBSa+/TImW+5JCeuQeRkm5NMpJWZG3hSuFU=
  next_validators_hash: nGBgKeWBjoxeKFti00CxHsnULORgKY4LiuQwBuUrhCs=
  proposer_address: mMEP2c2IRPLr99LedSRtBg9eONM=
  time: "2021-10-01T06:00:49.785790894Z"
  validators_hash: nGBgKeWBjoxeKFti00CxHsnULORgKY4LiuQwBuUrhCs=
  version:
    app: "0"
    block: "11"
valset:
- commission:
    commission_rates:
      max_change_rate: "0.010000000000000000"
      max_rate: "0.200000000000000000"
      rate: "0.100000000000000000"
    update_time: "2021-10-01T05:52:50.380144238Z"
  consensus_pubkey:
    '@type': /cosmos.crypto.ed25519.PubKey
    key: Auxs3865HpB/EfssYOzfqNhEJjzys2Fo6jD5B8tPgC8=
  delegator_shares: "10000000.000000000000000000"
  description:
    details: ""
    identity: ""
    moniker: myvalidator
    security_contact: ""
    website: ""
  jailed: false
  min_self_delegation: "1"
  operator_address: cosmosvaloper1rne8lgs98p0jqe82sgt0qr4rdn4hgvmgp9ggcc
  status: BOND_STATUS_BONDED
  tokens: "10000000"
  unbonding_height: "0"
  unbonding_time: "1970-01-01T00:00:00Z"
```

**params**

The `params` command allows users to query values set as staking parameters.

Usage:

```bash
simd query staking params [flags]
```

Example:

```bash
simd query staking params
```

Example Output:

```bash
bond_denom: stake
historical_entries: 10000
max_entries: 7
max_validators: 50
unbonding_time: 1814400s
```

**pool**

The `pool` command allows users to query values for amounts stored in the staking pool.

Usage:

```bash
simd q staking pool [flags]
```

Example:

```bash
simd q staking pool
```

Example Output:

```bash
bonded_tokens: "10000000"
not_bonded_tokens: "0"
```

**redelegation**

The `redelegation` command allows users to query a redelegation record based on delegator and a source and destination validator address.

Usage:

```bash
simd query staking redelegation [delegator-addr] [src-validator-addr] [dst-validator-addr] [flags]
```

Example:

```bash
simd query staking redelegation cosmos1gghjut3ccd8ay0zduzj64hwre2fxs9ld75ru9p cosmosvaloper1l2rsakp388kuv9k8qzq6lrm9taddae7fpx59wm cosmosvaloper1gghjut3ccd8ay0zduzj64hwre2fxs9ldmqhffj
```

Example Output:

```bash
pagination: null
redelegation_responses:
- entries:
  - balance: "50000000"
    redelegation_entry:
      completion_time: "2021-10-24T20:33:21.960084845Z"
      creation_height: 2.382847e+06
      initial_balance: "50000000"
      shares_dst: "50000000.000000000000000000"
  - balance: "5000000000"
    redelegation_entry:
      completion_time: "2021-10-25T21:33:54.446846862Z"
      creation_height: 2.397271e+06
      initial_balance: "5000000000"
      shares_dst: "5000000000.000000000000000000"
  redelegation:
    delegator_address: cosmos1gghjut3ccd8ay0zduzj64hwre2fxs9ld75ru9p
    entries: null
    validator_dst_address: cosmosvaloper1l2rsakp388kuv9k8qzq6lrm9taddae7fpx59wm
    validator_src_address: cosmosvaloper1l2rsakp388kuv9k8qzq6lrm9taddae7fpx59wm
```

**redelegations**

The `redelegations` command allows users to query all redelegation records for an individual delegator.

Usage:

```bash
simd query staking redelegations [delegator-addr] [flags]
```

Example:

```bash
simd query staking redelegation cosmos1gghjut3ccd8ay0zduzj64hwre2fxs9ld75ru9p
```

Example Output:

```bash
pagination:
  next_key: null
  total: "0"
redelegation_responses:
- entries:
  - balance: "50000000"
    redelegation_entry:
      completion_time: "2021-10-24T20:33:21.960084845Z"
      creation_height: 2.382847e+06
      initial_balance: "50000000"
      shares_dst: "50000000.000000000000000000"
  - balance: "5000000000"
    redelegation_entry:
      completion_time: "2021-10-25T21:33:54.446846862Z"
      creation_height: 2.397271e+06
      initial_balance: "5000000000"
      shares_dst: "5000000000.000000000000000000"
  redelegation:
    delegator_address: cosmos1gghjut3ccd8ay0zduzj64hwre2fxs9ld75ru9p
    entries: null
    validator_dst_address: cosmosvaloper1uccl5ugxrm7vqlzwqr04pjd320d2fz0z3hc6vm
    validator_src_address: cosmosvaloper1zppjyal5emta5cquje8ndkpz0rs046m7zqxrpp
- entries:
  - balance: "562770000000"
    redelegation_entry:
      completion_time: "2021-10-25T21:42:07.336911677Z"
      creation_height: 2.39735e+06
      initial_balance: "562770000000"
      shares_dst: "562770000000.000000000000000000"
  redelegation:
    delegator_address: cosmos1gghjut3ccd8ay0zduzj64hwre2fxs9ld75ru9p
    entries: null
    validator_dst_address: cosmosvaloper1uccl5ugxrm7vqlzwqr04pjd320d2fz0z3hc6vm
    validator_src_address: cosmosvaloper1zppjyal5emta5cquje8ndkpz0rs046m7zqxrpp
```

**redelegations-from**

The `redelegations-from` command allows users to query delegations that are redelegating _from_ a validator.

Usage:

```bash
simd query staking redelegations-from [validator-addr] [flags]
```

Example:

```bash
simd query staking redelegations-from cosmosvaloper1y4rzzrgl66eyhzt6gse2k7ej3zgwmngeleucjy
```

Example Output:

```bash
pagination:
  next_key: null
  total: "0"
redelegation_responses:
- entries:
  - balance: "50000000"
    redelegation_entry:
      completion_time: "2021-10-24T20:33:21.960084845Z"
      creation_height: 2.382847e+06
      initial_balance: "50000000"
      shares_dst: "50000000.000000000000000000"
  - balance: "5000000000"
    redelegation_entry:
      completion_time: "2021-10-25T21:33:54.446846862Z"
      creation_height: 2.397271e+06
      initial_balance: "5000000000"
      shares_dst: "5000000000.000000000000000000"
  redelegation:
    delegator_address: cosmos1pm6e78p4pgn0da365plzl4t56pxy8hwtqp2mph
    entries: null
    validator_dst_address: cosmosvaloper1uccl5ugxrm7vqlzwqr04pjd320d2fz0z3hc6vm
    validator_src_address: cosmosvaloper1y4rzzrgl66eyhzt6gse2k7ej3zgwmngeleucjy
- entries:
  - balance: "221000000"
    redelegation_entry:
      completion_time: "2021-10-05T21:05:45.669420544Z"
      creation_height: 2.120693e+06
      initial_balance: "221000000"
      shares_dst: "221000000.000000000000000000"
  redelegation:
    delegator_address: cosmos1zqv8qxy2zgn4c58fz8jt8jmhs3d0attcussrf6
    entries: null
    validator_dst_address: cosmosvaloper10mseqwnwtjaqfrwwp2nyrruwmjp6u5jhah4c3y
    validator_src_address: cosmosvaloper1y4rzzrgl66eyhzt6gse2k7ej3zgwmngeleucjy
```

**unbonding-delegation**

The `unbonding-delegation` command allows users to query unbonding delegations for an individual delegator on an individual validator.

Usage:

```bash
simd query staking unbonding-delegation [delegator-addr] [validator-addr] [flags]
```

Example:

```bash
simd query staking unbonding-delegation cosmos1gghjut3ccd8ay0zduzj64hwre2fxs9ld75ru9p cosmosvaloper1gghjut3ccd8ay0zduzj64hwre2fxs9ldmqhffj
```

Example Output:

```bash
delegator_address: cosmos1gghjut3ccd8ay0zduzj64hwre2fxs9ld75ru9p
entries:
- balance: "52000000"
  completion_time: "2021-11-02T11:35:55.391594709Z"
  creation_height: "55078"
  initial_balance: "52000000"
validator_address: cosmosvaloper1gghjut3ccd8ay0zduzj64hwre2fxs9ldmqhffj
```

**unbonding-delegations**

The `unbonding-delegations` command allows users to query all unbonding-delegations records for one delegator.

Usage:

```bash
simd query staking unbonding-delegations [delegator-addr] [flags]
```

Example:

```bash
simd query staking unbonding-delegations cosmos1gghjut3ccd8ay0zduzj64hwre2fxs9ld75ru9p
```

Example Output:

```bash
pagination:
  next_key: null
  total: "0"
unbonding_responses:
- delegator_address: cosmos1gghjut3ccd8ay0zduzj64hwre2fxs9ld75ru9p
  entries:
  - balance: "52000000"
    completion_time: "2021-11-02T11:35:55.391594709Z"
    creation_height: "55078"
    initial_balance: "52000000"
  validator_address: cosmosvaloper1t8ehvswxjfn3ejzkjtntcyrqwvmvuknzmvtaaa

```

**unbonding-delegations-from**

The `unbonding-delegations-from` command allows users to query delegations that are unbonding _from_ a validator.

Usage:

```bash
simd query staking unbonding-delegations-from [validator-addr] [flags]
```

Example:

```bash
simd query staking unbonding-delegations-from cosmosvaloper1gghjut3ccd8ay0zduzj64hwre2fxs9ldmqhffj
```

Example Output:

```bash
pagination:
  next_key: null
  total: "0"
unbonding_responses:
- delegator_address: cosmos1qqq9txnw4c77sdvzx0tkedsafl5s3vk7hn53fn
  entries:
  - balance: "150000000"
    completion_time: "2021-11-01T21:41:13.098141574Z"
    creation_height: "46823"
    initial_balance: "150000000"
  validator_address: cosmosvaloper1gghjut3ccd8ay0zduzj64hwre2fxs9ldmqhffj
- delegator_address: cosmos1peteje73eklqau66mr7h7rmewmt2vt99y24f5z
  entries:
  - balance: "24000000"
    completion_time: "2021-10-31T02:57:18.192280361Z"
    creation_height: "21516"
    initial_balance: "24000000"
  validator_address: cosmosvaloper1gghjut3ccd8ay0zduzj64hwre2fxs9ldmqhffj
```

**validator**

The `validator` command allows users to query details about an individual validator.

Usage:

```bash
simd query staking validator [validator-addr] [flags]
```

Example:

```bash
simd query staking validator cosmosvaloper1gghjut3ccd8ay0zduzj64hwre2fxs9ldmqhffj
```

Example Output:

```bash
commission:
  commission_rates:
    max_change_rate: "0.020000000000000000"
    max_rate: "0.200000000000000000"
    rate: "0.050000000000000000"
  update_time: "2021-10-01T19:24:52.663191049Z"
consensus_pubkey:
  '@type': /cosmos.crypto.ed25519.PubKey
  key: sIiexdJdYWn27+7iUHQJDnkp63gq/rzUq1Y+fxoGjXc=
delegator_shares: "32948270000.000000000000000000"
description:
  details: Witval is the validator arm from Vitwit. Vitwit is into software consulting
    and services business since 2015. We are working closely with Cosmos ecosystem
    since 2018. We are also building tools for the ecosystem, Aneka is our explorer
    for the cosmos ecosystem.
  identity: 51468B615127273A
  moniker: Witval
  security_contact: ""
  website: ""
jailed: false
min_self_delegation: "1"
operator_address: cosmosvaloper1gghjut3ccd8ay0zduzj64hwre2fxs9ldmqhffj
status: BOND_STATUS_BONDED
tokens: "32948270000"
unbonding_height: "0"
unbonding_time: "1970-01-01T00:00:00Z"
```

**validators**

The `validators` command allows users to query details about all validators on a network.

Usage:

```bash
simd query staking validators [flags]
```

Example:

```bash
simd query staking validators
```

Example Output:

```bash
pagination:
  next_key: FPTi7TKAjN63QqZh+BaXn6gBmD5/
  total: "0"
validators:
commission:
  commission_rates:
    max_change_rate: "0.020000000000000000"
    max_rate: "0.200000000000000000"
    rate: "0.050000000000000000"
  update_time: "2021-10-01T19:24:52.663191049Z"
consensus_pubkey:
  '@type': /cosmos.crypto.ed25519.PubKey
  key: sIiexdJdYWn27+7iUHQJDnkp63gq/rzUq1Y+fxoGjXc=
delegator_shares: "32948270000.000000000000000000"
description:
    details: Witval is the validator arm from Vitwit. Vitwit is into software consulting
      and services business since 2015. We are working closely with Cosmos ecosystem
      since 2018. We are also building tools for the ecosystem, Aneka is our explorer
      for the cosmos ecosystem.
    identity: 51468B615127273A
    moniker: Witval
    security_contact: ""
    website: ""
  jailed: false
  min_self_delegation: "1"
  operator_address: cosmosvaloper1gghjut3ccd8ay0zduzj64hwre2fxs9ldmqhffj
  status: BOND_STATUS_BONDED
  tokens: "32948270000"
  unbonding_height: "0"
  unbonding_time: "1970-01-01T00:00:00Z"
- commission:
    commission_rates:
      max_change_rate: "0.100000000000000000"
      max_rate: "0.200000000000000000"
      rate: "0.050000000000000000"
    update_time: "2021-10-04T18:02:21.446645619Z"
  consensus_pubkey:
    '@type': /cosmos.crypto.ed25519.PubKey
    key: GDNpuKDmCg9GnhnsiU4fCWktuGUemjNfvpCZiqoRIYA=
  delegator_shares: "559343421.000000000000000000"
  description:
    details: Noderunners is a professional validator in POS networks. We have a huge
      node running experience, reliable soft and hardware. Our commissions are always
      low, our support to delegators is always full. Stake with us and start receiving
      your Cosmos rewards now!
    identity: 812E82D12FEA3493
    moniker: Noderunners
    security_contact: info@noderunners.biz
    website: http://noderunners.biz
  jailed: false
  min_self_delegation: "1"
  operator_address: cosmosvaloper1q5ku90atkhktze83j9xjaks2p7uruag5zp6wt7
  status: BOND_STATUS_BONDED
  tokens: "559343421"
  unbonding_height: "0"
  unbonding_time: "1970-01-01T00:00:00Z"
```

#### Transactions

The `tx` commands allows users to interact with the `staking` module.

```bash
simd tx staking --help
```

**create-validator**

The command `create-validator` allows users to create new validator initialized with a self-delegation to it.

Usage:

```bash
simd tx staking create-validator [path/to/validator.json] [flags]
```

Example:

```bash
simd tx staking create-validator /path/to/validator.json \
  --chain-id="name_of_chain_id" \
  --gas="auto" \
  --gas-adjustment="1.2" \
  --gas-prices="0.025stake" \
  --from=mykey
```

where `validator.json` contains:

```json
{
  "pubkey": {"@type":"/cosmos.crypto.ed25519.PubKey","key":"BnbwFpeONLqvWqJb3qaUbL5aoIcW3fSuAp9nT3z5f20="},
  "amount": "1000000stake",
  "moniker": "my-moniker",
  "website": "https://myweb.site",
  "security": "security-contact@gmail.com",
  "details": "description of your validator",
  "commission-rate": "0.10",
  "commission-max-rate": "0.20",
  "commission-max-change-rate": "0.01",
  "min-self-delegation": "1"
}
```

and pubkey can be obtained by using `simd tendermint show-validator` command.

**delegate**

The command `delegate` allows users to delegate liquid tokens to a validator.

Usage:

```bash
simd tx staking delegate [validator-addr] [amount] [flags]
```

Example:

```bash
simd tx staking delegate cosmosvaloper1l2rsakp388kuv9k8qzq6lrm9taddae7fpx59wm 1000stake --from mykey
```

**edit-validator**

The command `edit-validator` allows users to edit an existing validator account.

Usage:

```bash
simd tx staking edit-validator [flags]
```

Example:

```bash
simd tx staking edit-validator --moniker "new_moniker_name" --website "new_webiste_url" --from mykey
```

**redelegate**

The command `redelegate` allows users to redelegate illiquid tokens from one validator to another.

Usage:

```bash
simd tx staking redelegate [src-validator-addr] [dst-validator-addr] [amount] [flags]
```

Example:

```bash
simd tx staking redelegate cosmosvaloper1gghjut3ccd8ay0zduzj64hwre2fxs9ldmqhffj cosmosvaloper1l2rsakp388kuv9k8qzq6lrm9taddae7fpx59wm 100stake --from mykey
```

**unbond**

The command `unbond` allows users to unbond shares from a validator.

Usage:

```bash
simd tx staking unbond [validator-addr] [amount] [flags]
```

Example:

```bash
simd tx staking unbond cosmosvaloper1gghjut3ccd8ay0zduzj64hwre2fxs9ldmqhffj 100stake --from mykey
```

**cancel unbond**

The command `cancel-unbond` allow users to cancel the unbonding delegation entry and delegate back to the original validator.

Usage:

```bash
simd tx staking cancel-unbond [validator-addr] [amount] [creation-height]
```

Example:

```bash
simd tx staking cancel-unbond cosmosvaloper1gghjut3ccd8ay0zduzj64hwre2fxs9ldmqhffj 100stake 123123 --from mykey
```

### gRPC

A user can query the `staking` module using gRPC endpoints.

#### Validators

The `Validators` endpoint queries all validators that match the given status.

```bash
cosmos.staking.v1beta1.Query/Validators
```

Example:

```bash
grpcurl -plaintext localhost:9090 cosmos.staking.v1beta1.Query/Validators
```

Example Output:

```bash
{
  "validators": [
    {
      "operatorAddress": "cosmosvaloper1rne8lgs98p0jqe82sgt0qr4rdn4hgvmgp9ggcc",
      "consensusPubkey": {"@type":"/cosmos.crypto.ed25519.PubKey","key":"Auxs3865HpB/EfssYOzfqNhEJjzys2Fo6jD5B8tPgC8="},
      "status": "BOND_STATUS_BONDED",
      "tokens": "10000000",
      "delegatorShares": "10000000000000000000000000",
      "description": {
        "moniker": "myvalidator"
      },
      "unbondingTime": "1970-01-01T00:00:00Z",
      "commission": {
        "commissionRates": {
          "rate": "100000000000000000",
          "maxRate": "200000000000000000",
          "maxChangeRate": "10000000000000000"
        },
        "updateTime": "2021-10-01T05:52:50.380144238Z"
      },
      "minSelfDelegation": "1"
    }
  ],
  "pagination": {
    "total": "1"
  }
}
```

#### Validator

The `Validator` endpoint queries validator information for given validator address.

```bash
cosmos.staking.v1beta1.Query/Validator
```

Example:

```bash
grpcurl -plaintext -d '{"validator_addr":"cosmosvaloper1rne8lgs98p0jqe82sgt0qr4rdn4hgvmgp9ggcc"}' \
localhost:9090 cosmos.staking.v1beta1.Query/Validator
```

Example Output:

```bash
{
  "validator": {
    "operatorAddress": "cosmosvaloper1rne8lgs98p0jqe82sgt0qr4rdn4hgvmgp9ggcc",
    "consensusPubkey": {"@type":"/cosmos.crypto.ed25519.PubKey","key":"Auxs3865HpB/EfssYOzfqNhEJjzys2Fo6jD5B8tPgC8="},
    "status": "BOND_STATUS_BONDED",
    "tokens": "10000000",
    "delegatorShares": "10000000000000000000000000",
    "description": {
      "moniker": "myvalidator"
    },
    "unbondingTime": "1970-01-01T00:00:00Z",
    "commission": {
      "commissionRates": {
        "rate": "100000000000000000",
        "maxRate": "200000000000000000",
        "maxChangeRate": "10000000000000000"
      },
      "updateTime": "2021-10-01T05:52:50.380144238Z"
    },
    "minSelfDelegation": "1"
  }
}
```

#### ValidatorDelegations

The `ValidatorDelegations` endpoint queries delegate information for given validator.

```bash
cosmos.staking.v1beta1.Query/ValidatorDelegations
```

Example:

```bash
grpcurl -plaintext -d '{"validator_addr":"cosmosvaloper1rne8lgs98p0jqe82sgt0qr4rdn4hgvmgp9ggcc"}' \
localhost:9090 cosmos.staking.v1beta1.Query/ValidatorDelegations
```

Example Output:

```bash
{
  "delegationResponses": [
    {
      "delegation": {
        "delegatorAddress": "cosmos1rne8lgs98p0jqe82sgt0qr4rdn4hgvmgy3ua5t",
        "validatorAddress": "cosmosvaloper1rne8lgs98p0jqe82sgt0qr4rdn4hgvmgp9ggcc",
        "shares": "10000000000000000000000000"
      },
      "balance": {
        "denom": "stake",
        "amount": "10000000"
      }
    }
  ],
  "pagination": {
    "total": "1"
  }
}
```

#### ValidatorUnbondingDelegations

The `ValidatorUnbondingDelegations` endpoint queries delegate information for given validator.

```bash
cosmos.staking.v1beta1.Query/ValidatorUnbondingDelegations
```

Example:

```bash
grpcurl -plaintext -d '{"validator_addr":"cosmosvaloper1rne8lgs98p0jqe82sgt0qr4rdn4hgvmgp9ggcc"}' \
localhost:9090 cosmos.staking.v1beta1.Query/ValidatorUnbondingDelegations
```

Example Output:

```bash
{
  "unbonding_responses": [
    {
      "delegator_address": "cosmos1z3pzzw84d6xn00pw9dy3yapqypfde7vg6965fy",
      "validator_address": "cosmosvaloper1rne8lgs98p0jqe82sgt0qr4rdn4hgvmgp9ggcc",
      "entries": [
        {
          "creation_height": "25325",
          "completion_time": "2021-10-31T09:24:36.797320636Z",
          "initial_balance": "20000000",
          "balance": "20000000"
        }
      ]
    },
    {
      "delegator_address": "cosmos1y8nyfvmqh50p6ldpzljk3yrglppdv3t8phju77",
      "validator_address": "cosmosvaloper1rne8lgs98p0jqe82sgt0qr4rdn4hgvmgp9ggcc",
      "entries": [
        {
          "creation_height": "13100",
          "completion_time": "2021-10-30T12:53:02.272266791Z",
          "initial_balance": "1000000",
          "balance": "1000000"
        }
      ]
    },
  ],
  "pagination": {
    "next_key": null,
    "total": "8"
  }
}
```

#### Delegation

The `Delegation` endpoint queries delegate information for given validator delegator pair.

```bash
cosmos.staking.v1beta1.Query/Delegation
```

Example:

```bash
grpcurl -plaintext \
-d '{"delegator_addr": "cosmos1y8nyfvmqh50p6ldpzljk3yrglppdv3t8phju77", validator_addr":"cosmosvaloper1rne8lgs98p0jqe82sgt0qr4rdn4hgvmgp9ggcc"}' \
localhost:9090 cosmos.staking.v1beta1.Query/Delegation
```

Example Output:

```bash
{
  "delegation_response":
  {
    "delegation":
      {
        "delegator_address":"cosmos1y8nyfvmqh50p6ldpzljk3yrglppdv3t8phju77",
        "validator_address":"cosmosvaloper1rne8lgs98p0jqe82sgt0qr4rdn4hgvmgp9ggcc",
        "shares":"25083119936.000000000000000000"
      },
    "balance":
      {
        "denom":"stake",
        "amount":"25083119936"
      }
  }
}
```

#### UnbondingDelegation

The `UnbondingDelegation` endpoint queries unbonding information for given validator delegator.

```bash
cosmos.staking.v1beta1.Query/UnbondingDelegation
```

Example:

```bash
grpcurl -plaintext \
-d '{"delegator_addr": "cosmos1y8nyfvmqh50p6ldpzljk3yrglppdv3t8phju77", validator_addr":"cosmosvaloper1rne8lgs98p0jqe82sgt0qr4rdn4hgvmgp9ggcc"}' \
localhost:9090 cosmos.staking.v1beta1.Query/UnbondingDelegation
```

Example Output:

```bash
{
  "unbond": {
    "delegator_address": "cosmos1y8nyfvmqh50p6ldpzljk3yrglppdv3t8phju77",
    "validator_address": "cosmosvaloper1rne8lgs98p0jqe82sgt0qr4rdn4hgvmgp9ggcc",
    "entries": [
      {
        "creation_height": "136984",
        "completion_time": "2021-11-08T05:38:47.505593891Z",
        "initial_balance": "400000000",
        "balance": "400000000"
      },
      {
        "creation_height": "137005",
        "completion_time": "2021-11-08T05:40:53.526196312Z",
        "initial_balance": "385000000",
        "balance": "385000000"
      }
    ]
  }
}
```

#### DelegatorDelegations

The `DelegatorDelegations` endpoint queries all delegations of a given delegator address.

```bash
cosmos.staking.v1beta1.Query/DelegatorDelegations
```

Example:

```bash
grpcurl -plaintext \
-d '{"delegator_addr": "cosmos1y8nyfvmqh50p6ldpzljk3yrglppdv3t8phju77"}' \
localhost:9090 cosmos.staking.v1beta1.Query/DelegatorDelegations
```

Example Output:

```bash
{
  "delegation_responses": [
    {"delegation":{"delegator_address":"cosmos1y8nyfvmqh50p6ldpzljk3yrglppdv3t8phju77","validator_address":"cosmosvaloper1eh5mwu044gd5ntkkc2xgfg8247mgc56fww3vc8","shares":"25083339023.000000000000000000"},"balance":{"denom":"stake","amount":"25083339023"}}
  ],
  "pagination": {
    "next_key": null,
    "total": "1"
  }
}
```

#### DelegatorUnbondingDelegations

The `DelegatorUnbondingDelegations` endpoint queries all unbonding delegations of a given delegator address.

```bash
cosmos.staking.v1beta1.Query/DelegatorUnbondingDelegations
```

Example:

```bash
grpcurl -plaintext \
-d '{"delegator_addr": "cosmos1y8nyfvmqh50p6ldpzljk3yrglppdv3t8phju77"}' \
localhost:9090 cosmos.staking.v1beta1.Query/DelegatorUnbondingDelegations
```

Example Output:

```bash
{
  "unbonding_responses": [
    {
      "delegator_address": "cosmos1y8nyfvmqh50p6ldpzljk3yrglppdv3t8phju77",
      "validator_address": "cosmosvaloper1sjllsnramtg3ewxqwwrwjxfgc4n4ef9uxyejze",
      "entries": [
        {
          "creation_height": "136984",
          "completion_time": "2021-11-08T05:38:47.505593891Z",
          "initial_balance": "400000000",
          "balance": "400000000"
        },
        {
          "creation_height": "137005",
          "completion_time": "2021-11-08T05:40:53.526196312Z",
          "initial_balance": "385000000",
          "balance": "385000000"
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

#### Redelegations

The `Redelegations` endpoint queries redelegations of given address.

```bash
cosmos.staking.v1beta1.Query/Redelegations
```

Example:

```bash
grpcurl -plaintext \
-d '{"delegator_addr": "cosmos1ld5p7hn43yuh8ht28gm9pfjgj2fctujp2tgwvf", "src_validator_addr" : "cosmosvaloper1j7euyj85fv2jugejrktj540emh9353ltgppc3g", "dst_validator_addr" : "cosmosvaloper1yy3tnegzmkdcm7czzcy3flw5z0zyr9vkkxrfse"}' \
localhost:9090 cosmos.staking.v1beta1.Query/Redelegations
```

Example Output:

```bash
{
  "redelegation_responses": [
    {
      "redelegation": {
        "delegator_address": "cosmos1ld5p7hn43yuh8ht28gm9pfjgj2fctujp2tgwvf",
        "validator_src_address": "cosmosvaloper1j7euyj85fv2jugejrktj540emh9353ltgppc3g",
        "validator_dst_address": "cosmosvaloper1yy3tnegzmkdcm7czzcy3flw5z0zyr9vkkxrfse",
        "entries": null
      },
      "entries": [
        {
          "redelegation_entry": {
            "creation_height": 135932,
            "completion_time": "2021-11-08T03:52:55.299147901Z",
            "initial_balance": "2900000",
            "shares_dst": "2900000.000000000000000000"
          },
          "balance": "2900000"
        }
      ]
    }
  ],
  "pagination": null
}
```

#### DelegatorValidators

The `DelegatorValidators` endpoint queries all validators information for given delegator.

```bash
cosmos.staking.v1beta1.Query/DelegatorValidators
```

Example:

```bash
grpcurl -plaintext \
-d '{"delegator_addr": "cosmos1ld5p7hn43yuh8ht28gm9pfjgj2fctujp2tgwvf"}' \
localhost:9090 cosmos.staking.v1beta1.Query/DelegatorValidators
```

Example Output:

```bash
{
  "validators": [
    {
      "operator_address": "cosmosvaloper1eh5mwu044gd5ntkkc2xgfg8247mgc56fww3vc8",
      "consensus_pubkey": {
        "@type": "/cosmos.crypto.ed25519.PubKey",
        "key": "UPwHWxH1zHJWGOa/m6JB3f5YjHMvPQPkVbDqqi+U7Uw="
      },
      "jailed": false,
      "status": "BOND_STATUS_BONDED",
      "tokens": "347260647559",
      "delegator_shares": "347260647559.000000000000000000",
      "description": {
        "moniker": "BouBouNode",
        "identity": "",
        "website": "https://boubounode.com",
        "security_contact": "",
        "details": "AI-based Validator. #1 AI Validator on Game of Stakes. Fairly priced. Don't trust (humans), verify. Made with BouBou love."
      },
      "unbonding_height": "0",
      "unbonding_time": "1970-01-01T00:00:00Z",
      "commission": {
        "commission_rates": {
          "rate": "0.061000000000000000",
          "max_rate": "0.300000000000000000",
          "max_change_rate": "0.150000000000000000"
        },
        "update_time": "2021-10-01T15:00:00Z"
      },
      "min_self_delegation": "1"
    }
  ],
  "pagination": {
    "next_key": null,
    "total": "1"
  }
}
```

#### DelegatorValidator

The `DelegatorValidator` endpoint queries validator information for given delegator validator

```bash
cosmos.staking.v1beta1.Query/DelegatorValidator
```

Example:

```bash
grpcurl -plaintext \
-d '{"delegator_addr": "cosmos1eh5mwu044gd5ntkkc2xgfg8247mgc56f3n8rr7", "validator_addr": "cosmosvaloper1eh5mwu044gd5ntkkc2xgfg8247mgc56fww3vc8"}' \
localhost:9090 cosmos.staking.v1beta1.Query/DelegatorValidator
```

Example Output:

```bash
{
  "validator": {
    "operator_address": "cosmosvaloper1eh5mwu044gd5ntkkc2xgfg8247mgc56fww3vc8",
    "consensus_pubkey": {
      "@type": "/cosmos.crypto.ed25519.PubKey",
      "key": "UPwHWxH1zHJWGOa/m6JB3f5YjHMvPQPkVbDqqi+U7Uw="
    },
    "jailed": false,
    "status": "BOND_STATUS_BONDED",
    "tokens": "347262754841",
    "delegator_shares": "347262754841.000000000000000000",
    "description": {
      "moniker": "BouBouNode",
      "identity": "",
      "website": "https://boubounode.com",
      "security_contact": "",
      "details": "AI-based Validator. #1 AI Validator on Game of Stakes. Fairly priced. Don't trust (humans), verify. Made with BouBou love."
    },
    "unbonding_height": "0",
    "unbonding_time": "1970-01-01T00:00:00Z",
    "commission": {
      "commission_rates": {
        "rate": "0.061000000000000000",
        "max_rate": "0.300000000000000000",
        "max_change_rate": "0.150000000000000000"
      },
      "update_time": "2021-10-01T15:00:00Z"
    },
    "min_self_delegation": "1"
  }
}
```

#### HistoricalInfo

```bash
cosmos.staking.v1beta1.Query/HistoricalInfo
```

Example:

```bash
grpcurl -plaintext -d '{"height" : 1}' localhost:9090 cosmos.staking.v1beta1.Query/HistoricalInfo
```

Example Output:

```bash
{
  "hist": {
    "header": {
      "version": {
        "block": "11",
        "app": "0"
      },
      "chain_id": "simd-1",
      "height": "140142",
      "time": "2021-10-11T10:56:29.720079569Z",
      "last_block_id": {
        "hash": "9gri/4LLJUBFqioQ3NzZIP9/7YHR9QqaM6B2aJNQA7o=",
        "part_set_header": {
          "total": 1,
          "hash": "Hk1+C864uQkl9+I6Zn7IurBZBKUevqlVtU7VqaZl1tc="
        }
      },
      "last_commit_hash": "VxrcS27GtvGruS3I9+AlpT7udxIT1F0OrRklrVFSSKc=",
      "data_hash": "80BjOrqNYUOkTnmgWyz9AQ8n7SoEmPVi4QmAe8RbQBY=",
      "validators_hash": "95W49n2hw8RWpr1GPTAO5MSPi6w6Wjr3JjjS7AjpBho=",
      "next_validators_hash": "95W49n2hw8RWpr1GPTAO5MSPi6w6Wjr3JjjS7AjpBho=",
      "consensus_hash": "BICRvH3cKD93v7+R1zxE2ljD34qcvIZ0Bdi389qtoi8=",
      "app_hash": "ZZaxnSY3E6Ex5Bvkm+RigYCK82g8SSUL53NymPITeOE=",
      "last_results_hash": "47DEQpj8HBSa+/TImW+5JCeuQeRkm5NMpJWZG3hSuFU=",
      "evidence_hash": "47DEQpj8HBSa+/TImW+5JCeuQeRkm5NMpJWZG3hSuFU=",
      "proposer_address": "aH6dO428B+ItuoqPq70efFHrSMY="
    },
  "valset": [
      {
        "operator_address": "cosmosvaloper196ax4vc0lwpxndu9dyhvca7jhxp70rmcqcnylw",
        "consensus_pubkey": {
          "@type": "/cosmos.crypto.ed25519.PubKey",
          "key": "/O7BtNW0pafwfvomgR4ZnfldwPXiFfJs9mHg3gwfv5Q="
        },
        "jailed": false,
        "status": "BOND_STATUS_BONDED",
        "tokens": "1426045203613",
        "delegator_shares": "1426045203613.000000000000000000",
        "description": {
          "moniker": "SG-1",
          "identity": "48608633F99D1B60",
          "website": "https://sg-1.online",
          "security_contact": "",
          "details": "SG-1 - your favorite validator on Witval. We offer 100% Soft Slash protection."
        },
        "unbonding_height": "0",
        "unbonding_time": "1970-01-01T00:00:00Z",
        "commission": {
          "commission_rates": {
            "rate": "0.037500000000000000",
            "max_rate": "0.200000000000000000",
            "max_change_rate": "0.030000000000000000"
          },
          "update_time": "2021-10-01T15:00:00Z"
        },
        "min_self_delegation": "1"
      }
    ]
  }
}

```

#### Pool

The `Pool` endpoint queries the pool information.

```bash
cosmos.staking.v1beta1.Query/Pool
```

Example:

```bash
grpcurl -plaintext -d localhost:9090 cosmos.staking.v1beta1.Query/Pool
```

Example Output:

```bash
{
  "pool": {
    "not_bonded_tokens": "369054400189",
    "bonded_tokens": "15657192425623"
  }
}
```

#### Params

The `Params` endpoint queries the pool information.

```bash
cosmos.staking.v1beta1.Query/Params
```

Example:

```bash
grpcurl -plaintext localhost:9090 cosmos.staking.v1beta1.Query/Params
```

Example Output:

```bash
{
  "params": {
    "unbondingTime": "1814400s",
    "maxValidators": 100,
    "maxEntries": 7,
    "historicalEntries": 10000,
    "bondDenom": "stake"
  }
}
```

### REST

A user can query the `staking` module using REST endpoints.

#### DelegatorDelegations

The `DelegtaorDelegations` REST endpoint queries all delegations of a given delegator address.

```bash
/cosmos/staking/v1beta1/delegations/{delegatorAddr}
```

Example:

```bash
curl -X GET "http://localhost:1317/cosmos/staking/v1beta1/delegations/cosmos1vcs68xf2tnqes5tg0khr0vyevm40ff6zdxatp5" -H  "accept: application/json"
```

Example Output:

```bash
{
  "delegation_responses": [
    {
      "delegation": {
        "delegator_address": "cosmos1vcs68xf2tnqes5tg0khr0vyevm40ff6zdxatp5",
        "validator_address": "cosmosvaloper1quqxfrxkycr0uzt4yk0d57tcq3zk7srm7sm6r8",
        "shares": "256250000.000000000000000000"
      },
      "balance": {
        "denom": "stake",
        "amount": "256250000"
      }
    },
    {
      "delegation": {
        "delegator_address": "cosmos1vcs68xf2tnqes5tg0khr0vyevm40ff6zdxatp5",
        "validator_address": "cosmosvaloper194v8uwee2fvs2s8fa5k7j03ktwc87h5ym39jfv",
        "shares": "255150000.000000000000000000"
      },
      "balance": {
        "denom": "stake",
        "amount": "255150000"
      }
    }
  ],
  "pagination": {
    "next_key": null,
    "total": "2"
  }
}
```

#### Redelegations

The `Redelegations` REST endpoint queries redelegations of given address.

```bash
/cosmos/staking/v1beta1/delegators/{delegatorAddr}/redelegations
```

Example:

```bash
curl -X GET \
"http://localhost:1317/cosmos/staking/v1beta1/delegators/cosmos1thfntksw0d35n2tkr0k8v54fr8wxtxwxl2c56e/redelegations?srcValidatorAddr=cosmosvaloper1lzhlnpahvznwfv4jmay2tgaha5kmz5qx4cuznf&dstValidatorAddr=cosmosvaloper1vq8tw77kp8lvxq9u3c8eeln9zymn68rng8pgt4" \
-H  "accept: application/json"
```

Example Output:

```bash
{
  "redelegation_responses": [
    {
      "redelegation": {
        "delegator_address": "cosmos1thfntksw0d35n2tkr0k8v54fr8wxtxwxl2c56e",
        "validator_src_address": "cosmosvaloper1lzhlnpahvznwfv4jmay2tgaha5kmz5qx4cuznf",
        "validator_dst_address": "cosmosvaloper1vq8tw77kp8lvxq9u3c8eeln9zymn68rng8pgt4",
        "entries": null
      },
      "entries": [
        {
          "redelegation_entry": {
            "creation_height": 151523,
            "completion_time": "2021-11-09T06:03:25.640682116Z",
            "initial_balance": "200000000",
            "shares_dst": "200000000.000000000000000000"
          },
          "balance": "200000000"
        }
      ]
    }
  ],
  "pagination": null
}
```

#### DelegatorUnbondingDelegations

The `DelegatorUnbondingDelegations` REST endpoint queries all unbonding delegations of a given delegator address.

```bash
/cosmos/staking/v1beta1/delegators/{delegatorAddr}/unbonding_delegations
```

Example:

```bash
curl -X GET \
"http://localhost:1317/cosmos/staking/v1beta1/delegators/cosmos1nxv42u3lv642q0fuzu2qmrku27zgut3n3z7lll/unbonding_delegations" \
-H  "accept: application/json"
```

Example Output:

```bash
{
  "unbonding_responses": [
    {
      "delegator_address": "cosmos1nxv42u3lv642q0fuzu2qmrku27zgut3n3z7lll",
      "validator_address": "cosmosvaloper1e7mvqlz50ch6gw4yjfemsc069wfre4qwmw53kq",
      "entries": [
        {
          "creation_height": "2442278",
          "completion_time": "2021-10-12T10:59:03.797335857Z",
          "initial_balance": "50000000000",
          "balance": "50000000000"
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

#### DelegatorValidators

The `DelegatorValidators` REST endpoint queries all validators information for given delegator address.

```bash
/cosmos/staking/v1beta1/delegators/{delegatorAddr}/validators
```

Example:

```bash
curl -X GET \
"http://localhost:1317/cosmos/staking/v1beta1/delegators/cosmos1xwazl8ftks4gn00y5x3c47auquc62ssune9ppv/validators" \
-H  "accept: application/json"
```

Example Output:

```bash
{
  "validators": [
    {
      "operator_address": "cosmosvaloper1xwazl8ftks4gn00y5x3c47auquc62ssuvynw64",
      "consensus_pubkey": {
        "@type": "/cosmos.crypto.ed25519.PubKey",
        "key": "5v4n3px3PkfNnKflSgepDnsMQR1hiNXnqOC11Y72/PQ="
      },
      "jailed": false,
      "status": "BOND_STATUS_BONDED",
      "tokens": "21592843799",
      "delegator_shares": "21592843799.000000000000000000",
      "description": {
        "moniker": "jabbey",
        "identity": "",
        "website": "https://twitter.com/JoeAbbey",
        "security_contact": "",
        "details": "just another dad in the cosmos"
      },
      "unbonding_height": "0",
      "unbonding_time": "1970-01-01T00:00:00Z",
      "commission": {
        "commission_rates": {
          "rate": "0.100000000000000000",
          "max_rate": "0.200000000000000000",
          "max_change_rate": "0.100000000000000000"
        },
        "update_time": "2021-10-09T19:03:54.984821705Z"
      },
      "min_self_delegation": "1"
    }
  ],
  "pagination": {
    "next_key": null,
    "total": "1"
  }
}
```

#### DelegatorValidator

The `DelegatorValidator` REST endpoint queries validator information for given delegator validator pair.

```bash
/cosmos/staking/v1beta1/delegators/{delegatorAddr}/validators/{validatorAddr}
```

Example:

```bash
curl -X GET \
"http://localhost:1317/cosmos/staking/v1beta1/delegators/cosmos1xwazl8ftks4gn00y5x3c47auquc62ssune9ppv/validators/cosmosvaloper1xwazl8ftks4gn00y5x3c47auquc62ssuvynw64" \
-H  "accept: application/json"
```

Example Output:

```bash
{
  "validator": {
    "operator_address": "cosmosvaloper1xwazl8ftks4gn00y5x3c47auquc62ssuvynw64",
    "consensus_pubkey": {
      "@type": "/cosmos.crypto.ed25519.PubKey",
      "key": "5v4n3px3PkfNnKflSgepDnsMQR1hiNXnqOC11Y72/PQ="
    },
    "jailed": false,
    "status": "BOND_STATUS_BONDED",
    "tokens": "21592843799",
    "delegator_shares": "21592843799.000000000000000000",
    "description": {
      "moniker": "jabbey",
      "identity": "",
      "website": "https://twitter.com/JoeAbbey",
      "security_contact": "",
      "details": "just another dad in the cosmos"
    },
    "unbonding_height": "0",
    "unbonding_time": "1970-01-01T00:00:00Z",
    "commission": {
      "commission_rates": {
        "rate": "0.100000000000000000",
        "max_rate": "0.200000000000000000",
        "max_change_rate": "0.100000000000000000"
      },
      "update_time": "2021-10-09T19:03:54.984821705Z"
    },
    "min_self_delegation": "1"
  }
}
```

#### HistoricalInfo

The `HistoricalInfo` REST endpoint queries the historical information for given height.

```bash
/cosmos/staking/v1beta1/historical_info/{height}
```

Example:

```bash
curl -X GET "http://localhost:1317/cosmos/staking/v1beta1/historical_info/153332" -H  "accept: application/json"
```

Example Output:

```bash
{
  "hist": {
    "header": {
      "version": {
        "block": "11",
        "app": "0"
      },
      "chain_id": "cosmos-1",
      "height": "153332",
      "time": "2021-10-12T09:05:35.062230221Z",
      "last_block_id": {
        "hash": "NX8HevR5khb7H6NGKva+jVz7cyf0skF1CrcY9A0s+d8=",
        "part_set_header": {
          "total": 1,
          "hash": "zLQ2FiKM5tooL3BInt+VVfgzjlBXfq0Hc8Iux/xrhdg="
        }
      },
      "last_commit_hash": "P6IJrK8vSqU3dGEyRHnAFocoDGja0bn9euLuy09s350=",
      "data_hash": "eUd+6acHWrNXYju8Js449RJ99lOYOs16KpqQl4SMrEM=",
      "validators_hash": "mB4pravvMsJKgi+g8aYdSeNlt0kPjnRFyvtAQtaxcfw=",
      "next_validators_hash": "mB4pravvMsJKgi+g8aYdSeNlt0kPjnRFyvtAQtaxcfw=",
      "consensus_hash": "BICRvH3cKD93v7+R1zxE2ljD34qcvIZ0Bdi389qtoi8=",
      "app_hash": "fuELArKRK+CptnZ8tu54h6xEleSWenHNmqC84W866fU=",
      "last_results_hash": "p/BPexV4LxAzlVcPRvW+lomgXb6Yze8YLIQUo/4Kdgc=",
      "evidence_hash": "47DEQpj8HBSa+/TImW+5JCeuQeRkm5NMpJWZG3hSuFU=",
      "proposer_address": "G0MeY8xQx7ooOsni8KE/3R/Ib3Q="
    },
    "valset": [
      {
        "operator_address": "cosmosvaloper196ax4vc0lwpxndu9dyhvca7jhxp70rmcqcnylw",
        "consensus_pubkey": {
          "@type": "/cosmos.crypto.ed25519.PubKey",
          "key": "/O7BtNW0pafwfvomgR4ZnfldwPXiFfJs9mHg3gwfv5Q="
        },
        "jailed": false,
        "status": "BOND_STATUS_BONDED",
        "tokens": "1416521659632",
        "delegator_shares": "1416521659632.000000000000000000",
        "description": {
          "moniker": "SG-1",
          "identity": "48608633F99D1B60",
          "website": "https://sg-1.online",
          "security_contact": "",
          "details": "SG-1 - your favorite validator on cosmos. We offer 100% Soft Slash protection."
        },
        "unbonding_height": "0",
        "unbonding_time": "1970-01-01T00:00:00Z",
        "commission": {
          "commission_rates": {
            "rate": "0.037500000000000000",
            "max_rate": "0.200000000000000000",
            "max_change_rate": "0.030000000000000000"
          },
          "update_time": "2021-10-01T15:00:00Z"
        },
        "min_self_delegation": "1"
      },
      {
        "operator_address": "cosmosvaloper1t8ehvswxjfn3ejzkjtntcyrqwvmvuknzmvtaaa",
        "consensus_pubkey": {
          "@type": "/cosmos.crypto.ed25519.PubKey",
          "key": "uExZyjNLtr2+FFIhNDAMcQ8+yTrqE7ygYTsI7khkA5Y="
        },
        "jailed": false,
        "status": "BOND_STATUS_BONDED",
        "tokens": "1348298958808",
        "delegator_shares": "1348298958808.000000000000000000",
        "description": {
          "moniker": "Cosmostation",
          "identity": "AE4C403A6E7AA1AC",
          "website": "https://www.cosmostation.io",
          "security_contact": "admin@stamper.network",
          "details": "Cosmostation validator node. Delegate your tokens and Start Earning Staking Rewards"
        },
        "unbonding_height": "0",
        "unbonding_time": "1970-01-01T00:00:00Z",
        "commission": {
          "commission_rates": {
            "rate": "0.050000000000000000",
            "max_rate": "1.000000000000000000",
            "max_change_rate": "0.200000000000000000"
          },
          "update_time": "2021-10-01T15:06:38.821314287Z"
        },
        "min_self_delegation": "1"
      }
    ]
  }
}
```

#### Parameters

The `Parameters` REST endpoint queries the staking parameters.

```bash
/cosmos/staking/v1beta1/params
```

Example:

```bash
curl -X GET "http://localhost:1317/cosmos/staking/v1beta1/params" -H  "accept: application/json"
```

Example Output:

```bash
{
  "params": {
    "unbonding_time": "2419200s",
    "max_validators": 100,
    "max_entries": 7,
    "historical_entries": 10000,
    "bond_denom": "stake"
  }
}
```

#### Pool

The `Pool` REST endpoint queries the pool information.

```bash
/cosmos/staking/v1beta1/pool
```

Example:

```bash
curl -X GET "http://localhost:1317/cosmos/staking/v1beta1/pool" -H  "accept: application/json"
```

Example Output:

```bash
{
  "pool": {
    "not_bonded_tokens": "432805737458",
    "bonded_tokens": "15783637712645"
  }
}
```

#### Validators

The `Validators` REST endpoint queries all validators that match the given status.

```bash
/cosmos/staking/v1beta1/validators
```

Example:

```bash
curl -X GET "http://localhost:1317/cosmos/staking/v1beta1/validators" -H  "accept: application/json"
```

Example Output:

```bash
{
  "validators": [
    {
      "operator_address": "cosmosvaloper1q3jsx9dpfhtyqqgetwpe5tmk8f0ms5qywje8tw",
      "consensus_pubkey": {
        "@type": "/cosmos.crypto.ed25519.PubKey",
        "key": "N7BPyek2aKuNZ0N/8YsrqSDhGZmgVaYUBuddY8pwKaE="
      },
      "jailed": false,
      "status": "BOND_STATUS_BONDED",
      "tokens": "383301887799",
      "delegator_shares": "383301887799.000000000000000000",
      "description": {
        "moniker": "SmartNodes",
        "identity": "D372724899D1EDC8",
        "website": "https://smartnodes.co",
        "security_contact": "",
        "details": "Earn Rewards with Crypto Staking & Node Deployment"
      },
      "unbonding_height": "0",
      "unbonding_time": "1970-01-01T00:00:00Z",
      "commission": {
        "commission_rates": {
          "rate": "0.050000000000000000",
          "max_rate": "0.200000000000000000",
          "max_change_rate": "0.100000000000000000"
        },
        "update_time": "2021-10-01T15:51:31.596618510Z"
      },
      "min_self_delegation": "1"
    },
    {
      "operator_address": "cosmosvaloper1q5ku90atkhktze83j9xjaks2p7uruag5zp6wt7",
      "consensus_pubkey": {
        "@type": "/cosmos.crypto.ed25519.PubKey",
        "key": "GDNpuKDmCg9GnhnsiU4fCWktuGUemjNfvpCZiqoRIYA="
      },
      "jailed": false,
      "status": "BOND_STATUS_UNBONDING",
      "tokens": "1017819654",
      "delegator_shares": "1017819654.000000000000000000",
      "description": {
        "moniker": "Noderunners",
        "identity": "812E82D12FEA3493",
        "website": "http://noderunners.biz",
        "security_contact": "info@noderunners.biz",
        "details": "Noderunners is a professional validator in POS networks. We have a huge node running experience, reliable soft and hardware. Our commissions are always low, our support to delegators is always full. Stake with us and start receiving your cosmos rewards now!"
      },
      "unbonding_height": "147302",
      "unbonding_time": "2021-11-08T22:58:53.718662452Z",
      "commission": {
        "commission_rates": {
          "rate": "0.050000000000000000",
          "max_rate": "0.200000000000000000",
          "max_change_rate": "0.100000000000000000"
        },
        "update_time": "2021-10-04T18:02:21.446645619Z"
      },
      "min_self_delegation": "1"
    }
  ],
  "pagination": {
    "next_key": "FONDBFkE4tEEf7yxWWKOD49jC2NK",
    "total": "2"
  }
}
```

#### Validator

The `Validator` REST endpoint queries validator information for given validator address.

```bash
/cosmos/staking/v1beta1/validators/{validatorAddr}
```

Example:

```bash
curl -X GET \
"http://localhost:1317/cosmos/staking/v1beta1/validators/cosmosvaloper16msryt3fqlxtvsy8u5ay7wv2p8mglfg9g70e3q" \
-H  "accept: application/json"
```

Example Output:

```bash
{
  "validator": {
    "operator_address": "cosmosvaloper16msryt3fqlxtvsy8u5ay7wv2p8mglfg9g70e3q",
    "consensus_pubkey": {
      "@type": "/cosmos.crypto.ed25519.PubKey",
      "key": "sIiexdJdYWn27+7iUHQJDnkp63gq/rzUq1Y+fxoGjXc="
    },
    "jailed": false,
    "status": "BOND_STATUS_BONDED",
    "tokens": "33027900000",
    "delegator_shares": "33027900000.000000000000000000",
    "description": {
      "moniker": "Witval",
      "identity": "51468B615127273A",
      "website": "",
      "security_contact": "",
      "details": "Witval is the validator arm from Vitwit. Vitwit is into software consulting and services business since 2015. We are working closely with Cosmos ecosystem since 2018. We are also building tools for the ecosystem, Aneka is our explorer for the cosmos ecosystem."
    },
    "unbonding_height": "0",
    "unbonding_time": "1970-01-01T00:00:00Z",
    "commission": {
      "commission_rates": {
        "rate": "0.050000000000000000",
        "max_rate": "0.200000000000000000",
        "max_change_rate": "0.020000000000000000"
      },
      "update_time": "2021-10-01T19:24:52.663191049Z"
    },
    "min_self_delegation": "1"
  }
}
```

#### ValidatorDelegations

The `ValidatorDelegations` REST endpoint queries delegate information for given validator.

```bash
/cosmos/staking/v1beta1/validators/{validatorAddr}/delegations
```

Example:

```bash
curl -X GET "http://localhost:1317/cosmos/staking/v1beta1/validators/cosmosvaloper16msryt3fqlxtvsy8u5ay7wv2p8mglfg9g70e3q/delegations" -H  "accept: application/json"
```

Example Output:

```bash
{
  "delegation_responses": [
    {
      "delegation": {
        "delegator_address": "cosmos190g5j8aszqhvtg7cprmev8xcxs6csra7xnk3n3",
        "validator_address": "cosmosvaloper16msryt3fqlxtvsy8u5ay7wv2p8mglfg9g70e3q",
        "shares": "31000000000.000000000000000000"
      },
      "balance": {
        "denom": "stake",
        "amount": "31000000000"
      }
    },
    {
      "delegation": {
        "delegator_address": "cosmos1ddle9tczl87gsvmeva3c48nenyng4n56qwq4ee",
        "validator_address": "cosmosvaloper16msryt3fqlxtvsy8u5ay7wv2p8mglfg9g70e3q",
        "shares": "628470000.000000000000000000"
      },
      "balance": {
        "denom": "stake",
        "amount": "628470000"
      }
    },
    {
      "delegation": {
        "delegator_address": "cosmos10fdvkczl76m040smd33lh9xn9j0cf26kk4s2nw",
        "validator_address": "cosmosvaloper16msryt3fqlxtvsy8u5ay7wv2p8mglfg9g70e3q",
        "shares": "838120000.000000000000000000"
      },
      "balance": {
        "denom": "stake",
        "amount": "838120000"
      }
    },
    {
      "delegation": {
        "delegator_address": "cosmos1n8f5fknsv2yt7a8u6nrx30zqy7lu9jfm0t5lq8",
        "validator_address": "cosmosvaloper16msryt3fqlxtvsy8u5ay7wv2p8mglfg9g70e3q",
        "shares": "500000000.000000000000000000"
      },
      "balance": {
        "denom": "stake",
        "amount": "500000000"
      }
    },
    {
      "delegation": {
        "delegator_address": "cosmos16msryt3fqlxtvsy8u5ay7wv2p8mglfg9hrek2e",
        "validator_address": "cosmosvaloper16msryt3fqlxtvsy8u5ay7wv2p8mglfg9g70e3q",
        "shares": "61310000.000000000000000000"
      },
      "balance": {
        "denom": "stake",
        "amount": "61310000"
      }
    }
  ],
  "pagination": {
    "next_key": null,
    "total": "5"
  }
}
```

#### Delegation

The `Delegation` REST endpoint queries delegate information for given validator delegator pair.

```bash
/cosmos/staking/v1beta1/validators/{validatorAddr}/delegations/{delegatorAddr}
```

Example:

```bash
curl -X GET \
"http://localhost:1317/cosmos/staking/v1beta1/validators/cosmosvaloper16msryt3fqlxtvsy8u5ay7wv2p8mglfg9g70e3q/delegations/cosmos1n8f5fknsv2yt7a8u6nrx30zqy7lu9jfm0t5lq8" \
-H  "accept: application/json"
```

Example Output:

```bash
{
  "delegation_response": {
    "delegation": {
      "delegator_address": "cosmos1n8f5fknsv2yt7a8u6nrx30zqy7lu9jfm0t5lq8",
      "validator_address": "cosmosvaloper16msryt3fqlxtvsy8u5ay7wv2p8mglfg9g70e3q",
      "shares": "500000000.000000000000000000"
    },
    "balance": {
      "denom": "stake",
      "amount": "500000000"
    }
  }
}
```

#### UnbondingDelegation

The `UnbondingDelegation` REST endpoint queries unbonding information for given validator delegator pair.

```bash
/cosmos/staking/v1beta1/validators/{validatorAddr}/delegations/{delegatorAddr}/unbonding_delegation
```

Example:

```bash
curl -X GET \
"http://localhost:1317/cosmos/staking/v1beta1/validators/cosmosvaloper13v4spsah85ps4vtrw07vzea37gq5la5gktlkeu/delegations/cosmos1ze2ye5u5k3qdlexvt2e0nn0508p04094ya0qpm/unbonding_delegation" \
-H  "accept: application/json"
```

Example Output:

```bash
{
  "unbond": {
    "delegator_address": "cosmos1ze2ye5u5k3qdlexvt2e0nn0508p04094ya0qpm",
    "validator_address": "cosmosvaloper13v4spsah85ps4vtrw07vzea37gq5la5gktlkeu",
    "entries": [
      {
        "creation_height": "153687",
        "completion_time": "2021-11-09T09:41:18.352401903Z",
        "initial_balance": "525111",
        "balance": "525111"
      }
    ]
  }
}
```

#### ValidatorUnbondingDelegations

The `ValidatorUnbondingDelegations` REST endpoint queries unbonding delegations of a validator.

```bash
/cosmos/staking/v1beta1/validators/{validatorAddr}/unbonding_delegations
```

Example:

```bash
curl -X GET \
"http://localhost:1317/cosmos/staking/v1beta1/validators/cosmosvaloper13v4spsah85ps4vtrw07vzea37gq5la5gktlkeu/unbonding_delegations" \
-H  "accept: application/json"
```

Example Output:

```bash
{
  "unbonding_responses": [
    {
      "delegator_address": "cosmos1q9snn84jfrd9ge8t46kdcggpe58dua82vnj7uy",
      "validator_address": "cosmosvaloper13v4spsah85ps4vtrw07vzea37gq5la5gktlkeu",
      "entries": [
        {
          "creation_height": "90998",
          "completion_time": "2021-11-05T00:14:37.005841058Z",
          "initial_balance": "24000000",
          "balance": "24000000"
        }
      ]
    },
    {
      "delegator_address": "cosmos1qf36e6wmq9h4twhdvs6pyq9qcaeu7ye0s3dqq2",
      "validator_address": "cosmosvaloper13v4spsah85ps4vtrw07vzea37gq5la5gktlkeu",
      "entries": [
        {
          "creation_height": "47478",
          "completion_time": "2021-11-01T22:47:26.714116854Z",
          "initial_balance": "8000000",
          "balance": "8000000"
        }
      ]
    }
  ],
  "pagination": {
    "next_key": null,
    "total": "2"
  }
}
```
