---
sidebar_position: 1
---

# Distribution

## 概述

这种_简单_的分配机制描述了一种在验证者和委托者之间被动\
分配奖励的功能性方法。请注意，此机制不会像主动奖励分配机制那样精确地\
分配资金，因此将在未来进行升级。

该机制按以下方式运行。收集的奖励在全球范围内汇集并\
被动分配给验证者和委托者。每个验证者都有\
机会向委托者收取代表委托者收集的奖励的佣金。费用直接收集到全球奖励池\
和验证者提案者奖励池中。由于被动会计的性质，\
每当影响奖励分配率的参数发生变化时，\
也必须提取奖励。

* 无论何时提取，都必须提取他们有权获得的\
  最大金额，在池中不留任何东西。
* 无论何时将代币绑定、解绑或重新委托到现有账户，\
  都必须完全提取奖励（因为延迟会计的规则\
  发生变化）。
* 无论何时验证者选择更改奖励的佣金，所有累积的\
  佣金奖励必须同时提取。

上述场景在 `hooks.md` 中涵盖。

此处概述的分配机制用于在验证者和相关委托者之间延迟分配\
以下奖励：

* 要社会分配的多代币费用
* 通胀的质押资产供应
* 验证者对其委托者权益获得的所有奖励的佣金

费用汇集在全局池中。使用的机制允许验证者\
和委托者独立且延迟地提取他们的奖励。

## 缺点

作为延迟计算的一部分，每个委托者持有特定于每个验证者的累积项\
，用于估计他们应得的全球费用池中代币的\
近似公平份额。

```
entitlement = delegator-accumulation / all-delegators-accumulation
```

在每区块有恒定且相等的传入\
奖励代币流的情况下，此分配机制将等于\
主动分配（每区块单独分配给所有委托者）。\
然而，这是不现实的，因此基于传入奖励代币的波动以及其他委托者\
奖励提取的时间，将发生与主动分配的偏差。

如果您碰巧知道传入奖励即将显著增加，\
您有动力在此事件之后才提取，增加\
您现有 _accum_ 的价值。有关更多详细信息，请参见 [#2764](https://github.com/cosmos/cosmos-sdk/issues/2764)。

## 对质押的影响

在 BPoS 中，对 Atom 供应收取佣金，同时允许 Atom 供应\
自动绑定（直接分配给验证者的绑定权益）是\
有问题的。从根本上说，这两种机制是相互\
排斥的。如果佣金和自动绑定机制同时\
应用于质押代币，则任何验证者与其委托者之间的\
质押代币分配将随每个区块而变化。这需要\
为每个区块的每个委托记录进行计算 -\
这被认为是计算昂贵的。

总之，我们只能有 Atom 佣金和未绑定的 atoms\
供应或没有 Atom 佣金的绑定 atom 供应，我们选择\
实现前者。希望重新绑定其供应的利益相关者可以选择\
设置脚本以定期提取和重新绑定奖励。

## 目录

* [概念](distribution.md#concepts)
* [状态](distribution.md#state)
  * [费用池](distribution.md#feepool)
  * [验证者分配](distribution.md#validator-distribution)
  * [委托分配](distribution.md#delegation-distribution)
  * [参数](distribution.md#params)
* [Begin Block](distribution.md#begin-block)
* [消息](distribution.md#messages)
* [钩子](distribution.md#hooks)
* [事件](distribution.md#events)
* [参数](distribution.md#parameters)
* [客户端](distribution.md#client)
  * [CLI](distribution.md#cli)
  * [gRPC](distribution.md#grpc)

## 概念

在权益证明（PoS）区块链中，从交易费用获得的奖励支付给验证者。费用分配模块公平地将奖励分配给验证者的组成委托者。

奖励按周期计算。每次验证者的委托发生变化时，周期都会更新，例如，当验证者收到新委托时。\
然后可以通过获取委托开始前周期的总奖励，减去当前总奖励来计算单个验证者的奖励。\
要了解更多信息，请参见 [F1 费用分配论文](https://github.com/cosmos/cosmos-sdk/tree/main/docs/spec/fee_distribution/f1_fee_distr.pdf)。

验证者的佣金在验证者被移除或验证者请求提取时支付。\
佣金在每个 `BeginBlock` 操作中计算和递增，以更新累积的费用金额。

委托者的奖励在委托更改或移除时分配，或请求提取时分配。\
在分配奖励之前，应用在当前委托期间发生的对验证者的所有削减。

### F1 费用分配中的引用计数

在 F1 费用分配中，委托者收到的奖励在其委托被提取时计算。此计算必须读取从他们委托时结束的周期到为提取创建的最终周期，奖励总和除以代币份额的项。

此外，由于削减会改变委托将拥有的代币数量（但我们延迟计算这一点，\
仅在委托者取消委托时），我们必须分别计算在委托者委托和提取奖励之间发生的任何削减\
之前/之后的周期的奖励。因此，削减与\
委托一样，引用由削减事件结束的周期。

对于不再被任何委托\
或任何削减引用的周期，所有存储的历史奖励记录因此可以安全地移除，因为它们永远不会被读取（未来的委托和未来的\
削减将始终引用未来的周期）。这是通过跟踪\
每个历史奖励存储条目的 `ReferenceCount` 来实现的。每次创建可能需要引用历史记录的新对象（委托或削减）\
时，引用计数递增。\
每次删除先前需要引用历史记录的对象时，引用\
计数递减。如果引用计数达到零，则删除历史记录。

## 状态

### 费用池

所有全局跟踪的分配参数都存储在 `FeePool` 中。奖励被收集并添加到奖励池中，\
并从这里分配给验证者/委托者。

请注意，奖励池持有小数代币（`DecCoins`），以允许\
从通胀等操作中接收代币的小数部分。\
当从池中分配代币时，它们被截断回 `sdk.Coins`，这是非小数的。

* FeePool: `0x00 -> ProtocolBuffer(FeePool)`

```go
// coins with decimal
type DecCoins []DecCoin

type DecCoin struct {
    Amount math.LegacyDec
    Denom  string
}
```

```protobuf
https://github.com/cosmos/cosmos-sdk/blob/v0.47.0-rc1/proto/cosmos/distribution/v1beta1/distribution.proto#L116-L123
```

### 验证者分配

相关验证者的验证者分配信息在以下每次更新：

1. 验证者的委托金额更新时，
2. 任何委托者从验证者提取时，或
3. 验证者提取其佣金时。

* ValidatorDistInfo: `0x02 | ValOperatorAddrLen (1 byte) | ValOperatorAddr -> ProtocolBuffer(validatorDistribution)`

```go
type ValidatorDistInfo struct {
    OperatorAddress     sdk.AccAddress
    SelfBondRewards     sdkmath.DecCoins
    ValidatorCommission types.ValidatorAccumulatedCommission
}
```

### 委托分配

每个委托分配只需要记录它最后\
提取费用的高度。因为委托必须在每次其\
属性更改（即绑定代币等）时提取费用，其属性将保持恒定\
，委托者的_累积_因子可以通过被动计算得知\
，只需知道最后提取的高度及其当前属性。

* DelegationDistInfo: `0x02 | DelegatorAddrLen (1 byte) | DelegatorAddr | ValOperatorAddrLen (1 byte) | ValOperatorAddr -> ProtocolBuffer(delegatorDist)`

```go
type DelegationDistInfo struct {
    WithdrawalHeight int64    // last time this delegation withdrew rewards
}
```

### 参数

distribution 模块将其参数存储在状态中，前缀为 `0x09`，\
可以通过治理或具有权限的地址进行更新。

* Params: `0x09 | ProtocolBuffer(Params)`

```protobuf
https://github.com/cosmos/cosmos-sdk/blob/v0.47.0-rc1/proto/cosmos/distribution/v1beta1/distribution.proto#L12-L42
```

## Begin Block

在每个 `BeginBlock`，上一区块收到的所有费用都转移到\
distribution `ModuleAccount` 账户。当委托者或验证者\
提取他们的奖励时，它们从 `ModuleAccount` 中取出。在 begin\
block 期间，对收集的费用不同索赔的更新如下：

* 收取储备社区税。
* 其余部分按投票权按比例分配给所有绑定的验证者

### 分配方案

有关参数的描述，请参见[参数](distribution.md#params)。

设 `fees` 为上一区块收集的总费用，包括\
对权益的通胀奖励。所有费用在区块期间收集在特定模块\
账户中。在 `BeginBlock` 期间，它们被发送到 `"distribution"` `ModuleAccount`。不会发生其他代币发送。相反，\
每个账户有权获得的奖励被存储，可以通过消息 `FundCommunityPool`、`WithdrawValidatorCommission` 和 `WithdrawDelegatorReward`\
触发提取。

#### 对社区池的奖励

社区池获得 `community_tax * fees`，加上验证者获得奖励后\
始终向下舍入到最近整数值的任何剩余零头。

#### 对验证者的奖励

提案者不获得额外奖励。所有费用在所有\
绑定的验证者之间分配，包括提案者，按他们的共识权力比例分配。

```
powFrac = validator power / total bonded validator power
voteMul = 1 - community_tax
```

所有验证者获得 `fees * voteMul * powFrac`。

#### 对委托者的奖励

每个验证者的奖励分配给其委托者。验证者还\
有一个自委托，在\
分配计算中像常规委托一样处理。

验证者设置佣金率。佣金率是灵活的，但每个\
验证者设置最大比率和最大每日增加。这些最大值不能超过，并保护委托者免受验证者佣金率突然增加的影响，以防止验证者拿走所有奖励。

运营者有权获得的未付奖励存储在 `ValidatorAccumulatedCommission` 中，而委托者有权\
获得的奖励存储在 `ValidatorCurrentRewards` 中。[F1 费用分配方案](distribution.md#concepts)用于计算每个委托者的奖励，因为他们\
提取或更新他们的委托，因此不在 `BeginBlock` 中处理。

#### 分配示例

对于此分配示例，底层共识引擎按\
其相对于整个绑定权力的权力比例选择区块提案者。

所有验证者在在其提议的\
区块中包含预提交方面表现相同。然后保持 `(包含的预提交) / (总绑定验证者权力)`\
恒定，以便验证者的摊销区块奖励是总奖励的 `(验证者权力 / 总绑定权力) * (1 - 社区税率)`。\
因此，单个委托者的奖励是：

```
(delegator proportion of the validator power / validator power) * (validator power / total bonded power)
  * (1 - community tax rate) * (1 - validator commission rate)
= (delegator proportion of the validator power / total bonded power) * (1 -
community tax rate) * (1 - validator commission rate)
```

## 消息

### MsgSetWithdrawAddress

默认情况下，提取地址是委托者地址。要更改其提取地址，委托者必须发送 `MsgSetWithdrawAddress` 消息。\
只有在参数 `WithdrawAddrEnabled` 设置为 `true` 时才能更改提取地址。

提取地址不能是任何模块账户。这些账户通过在初始化时添加到 distribution keeper 的 `blockedAddrs` 数组来阻止成为提取地址。

响应：

```protobuf
https://github.com/cosmos/cosmos-sdk/blob/v0.47.0-rc1/proto/cosmos/distribution/v1beta1/tx.proto#L49-L60
```

```go
func (k Keeper) SetWithdrawAddr(ctx context.Context, delegatorAddr sdk.AccAddress, withdrawAddr sdk.AccAddress) error
	if k.blockedAddrs[withdrawAddr.String()] {
		fail with "`{withdrawAddr}` is not allowed to receive external funds"
	}

	if !k.GetWithdrawAddrEnabled(ctx) {
		fail with `ErrSetWithdrawAddrDisabled`
	}

	k.SetDelegatorWithdrawAddr(ctx, delegatorAddr, withdrawAddr)
```

### MsgWithdrawDelegatorReward

委托者可以提取其奖励。\
在 distribution 模块内部，此交易同时移除先前的委托及其相关奖励，就像委托者简单地开始相同价值的新委托一样。\
奖励立即从 distribution `ModuleAccount` 发送到提取地址。\
任何余数（截断的小数）都发送到社区池。\
委托的起始高度设置为当前验证者周期，并且先前周期的引用计数递减。\
提取的金额从验证者的 `ValidatorOutstandingRewards` 变量中扣除。

在 F1 分配中，总奖励按验证者周期计算，委托者按其在该验证者中的权益比例获得这些奖励的一部分。\
在基本 F1 中，所有委托者在两个周期之间有权获得的总奖励按以下方式计算。\
设 `R(X)` 为到周期 `X` 为止的总累积奖励除以当时质押的代币。委托者分配是 `R(X) * delegator_stake`。\
那么所有委托者在周期 `A` 和 `B` 之间质押的奖励是 `(R(B) - R(A)) * total stake`。\
但是，这些计算的奖励不考虑削减。

考虑削减需要迭代。\
设 `F(X)` 为验证者在周期 `X` 发生的削减事件中被削减的分数。\
如果验证者在周期 `P1, ..., PN` 被削减，其中 `A < P1`，`PN < B`，distribution 模块计算单个委托者的奖励 `T(A, B)`，如下：

```go
stake := initial stake
rewards := 0
previous := A
for P in P1, ..., PN`:
    rewards = (R(P) - previous) * stake
    stake = stake * F(P)
    previous = P
rewards = rewards + (R(B) - R(PN)) * stake
```

历史奖励通过回放所有削减然后逐步衰减委托者的权益来追溯计算。\
最终计算的权益等同于委托中的实际质押代币，由于舍入误差存在误差范围。

响应：

```protobuf
https://github.com/cosmos/cosmos-sdk/blob/v0.47.0-rc1/proto/cosmos/distribution/v1beta1/tx.proto#L66-L77
```

### WithdrawValidatorCommission

验证者可以发送 WithdrawValidatorCommission 消息以提取其累积的佣金。\
佣金在每个区块的 `BeginBlock` 期间计算，因此提取不需要迭代。\
提取的金额从验证者的 `ValidatorOutstandingRewards` 变量中扣除。\
只能发送整数金额。如果累积的奖励有小数，金额在发送提取之前被截断，余数留待稍后提取。

### FundCommunityPool

此消息将代币直接从发送者发送到社区池。

如果无法将金额从发送者转移到 distribution 模块账户，交易将失败。

```go
func (k Keeper) FundCommunityPool(ctx context.Context, amount sdk.Coins, sender sdk.AccAddress) error {
  if err := k.bankKeeper.SendCoinsFromAccountToModule(ctx, sender, types.ModuleName, amount); err != nil {
    return err
  }

  feePool, err := k.FeePool.Get(ctx)
  if err != nil {
    return err
  }

  feePool.CommunityPool = feePool.CommunityPool.Add(sdk.NewDecCoinsFromCoins(amount...)...)
	
  if err := k.FeePool.Set(ctx, feePool); err != nil {
    return err
  }

  return nil
}
```

### 通用分配操作

这些操作在许多不同的消息期间发生。

#### 初始化委托

每次委托更改时，都会提取奖励并重新初始化委托。\
初始化委托会递增验证者周期并跟踪委托的起始周期。

```go
// initialize starting info for a new delegation
func (k Keeper) initializeDelegation(ctx context.Context, val sdk.ValAddress, del sdk.AccAddress) {
    // period has already been incremented - we want to store the period ended by this delegation action
    previousPeriod := k.GetValidatorCurrentRewards(ctx, val).Period - 1

	// increment reference count for the period we're going to track
	k.incrementReferenceCount(ctx, val, previousPeriod)

	validator := k.stakingKeeper.Validator(ctx, val)
	delegation := k.stakingKeeper.Delegation(ctx, del, val)

	// calculate delegation stake in tokens
	// we don't store directly, so multiply delegation shares * (tokens per share)
	// note: necessary to truncate so we don't allow withdrawing more rewards than owed
	stake := validator.TokensFromSharesTruncated(delegation.GetShares())
	k.SetDelegatorStartingInfo(ctx, val, del, types.NewDelegatorStartingInfo(previousPeriod, stake, uint64(ctx.BlockHeight())))
}
```

### MsgUpdateParams

Distribution 模块参数可以通过 `MsgUpdateParams` 更新，可以使用治理提案完成，签名者将始终是 gov 模块账户地址。

```protobuf
https://github.com/cosmos/cosmos-sdk/blob/v0.47.0-rc1/proto/cosmos/distribution/v1beta1/tx.proto#L133-L147
```

如果出现以下情况，消息处理可能失败：

* 签名者不是 gov 模块账户地址。

## 钩子

可由此模块调用和从此模块调用的可用钩子。

### 创建或修改委托分配

* 触发者：`staking.MsgDelegate`、`staking.MsgBeginRedelegate`、`staking.MsgUndelegate`

#### 之前

* 委托奖励被提取到委托者的提取地址。\
  奖励包括当前周期并排除起始周期。
* 验证者周期递增。\
  验证者周期递增是因为验证者的权力和份额分配可能已更改。
* 委托者起始周期的引用计数递减。

#### 之后

委托的起始高度设置为前一周期。\
由于 `Before`-hook，此周期是委托者获得奖励的最后一个周期。

### 验证者创建

* 触发者：`staking.MsgCreateValidator`

创建验证者时，初始化以下验证者变量：

* 历史奖励
* 当前累积奖励
* 累积佣金
* 总未付奖励
* 周期

默认情况下，除周期设置为 `1` 外，所有值都设置为 `0`。

### 验证者移除

* 触发者：`staking.RemoveValidator`

未付佣金发送到验证者的自委托提取地址。\
剩余的委托者奖励发送到社区费用池。

注意：验证者只有在没有剩余委托时才会被移除。\
那时，所有未付的委托者奖励都将被提取。\
任何剩余的奖励都是零头金额。

### 验证者被削减

* 触发者：`staking.Slash`
* 当前验证者周期引用计数递增。\
  引用计数递增是因为削减事件已创建对它的引用。
* 验证者周期递增。
* 削减事件被存储以供以后使用。\
  削减事件将在计算委托者奖励时被引用。

## 事件

distribution 模块发出以下事件：

### BeginBlocker

| 类型             | 属性键   | 属性值            |
| ---------------- | -------- | ----------------- |
| proposer\_reward | validator | {validatorAddress} |
| proposer\_reward | reward  | {proposerReward}   |
| commission       | amount  | {commissionAmount} |
| commission       | validator | {validatorAddress} |
| rewards          | amount  | {rewardAmount}     |
| rewards          | validator | {validatorAddress} |

### 处理器

#### MsgSetWithdrawAddress

| 类型                   | 属性键           | 属性值            |
| ---------------------- | ---------------- | ----------------- |
| set\_withdraw\_address | withdraw\_address | {withdrawAddress}      |
| message                | module           | distribution           |
| message                | action           | set\_withdraw\_address |
| message                | sender           | {senderAddress}        |

#### MsgWithdrawDelegatorReward

| 类型              | 属性键   | 属性值                 |
| ----------------- | -------- | ---------------------- |
| withdraw\_rewards | amount   | {rewardAmount}              |
| withdraw\_rewards | validator | {validatorAddress}          |
| message           | module   | distribution                |
| message           | action   | withdraw\_delegator\_reward |
| message           | sender   | {senderAddress}             |

#### MsgWithdrawValidatorCommission

| 类型                 | 属性键   | 属性值                     |
| -------------------- | -------- | -------------------------- |
| withdraw\_commission | amount   | {commissionAmount}              |
| message              | module   | distribution                    |
| message              | action   | withdraw\_validator\_commission |
| message              | sender   | {senderAddress}                 |

## 参数

distribution 模块包含以下参数：

| 键                  | 类型         | 示例                     |
| ------------------- | ------------ | ------------------------ |
| communitytax        | string (dec) | "0.020000000000000000" \[0] |
| withdrawaddrenabled | bool         | true                        |

* \[0] `communitytax` 必须为正数且不能超过 1.00。
* `baseproposerreward` 和 `bonusproposerreward` 是在 v0.47 中已弃用且不再使用的参数。

:::note\
储备池是通过 `CommunityTax` 收集的用于治理的资金池。\
目前在 Cosmos SDK 中，由 CommunityTax 收集的代币被计入但不可花费。\
:::

## 客户端

## CLI

用户可以使用 CLI 查询和与 `distribution` 模块交互。

#### 查询

`query` 命令允许用户查询 `distribution` 状态。

```shell
simd query distribution --help
```

**commission**

`commission` 命令允许用户通过地址查询验证者佣金奖励。

```shell
simd query distribution commission [address] [flags]
```

示例：

```shell
simd query distribution commission cosmosvaloper1...
```

示例输出：

```yml
commission:
- amount: "1000000.000000000000000000"
  denom: stake
```

**community-pool**

`community-pool` 命令允许用户查询社区池内的所有代币余额。

```shell
simd query distribution community-pool [flags]
```

示例：

```shell
simd query distribution community-pool
```

示例输出：

```yml
pool:
- amount: "1000000.000000000000000000"
  denom: stake
```

**params**

`params` 命令允许用户查询 `distribution` 模块的参数。

```shell
simd query distribution params [flags]
```

示例：

```shell
simd query distribution params
```

示例输出：

```yml
base_proposer_reward: "0.000000000000000000"
bonus_proposer_reward: "0.000000000000000000"
community_tax: "0.020000000000000000"
withdraw_addr_enabled: true
```

**rewards**

`rewards` 命令允许用户查询委托者奖励。用户可以选择包含验证者地址以查询从特定验证者获得的奖励。

```shell
simd query distribution rewards [delegator-addr] [validator-addr] [flags]
```

示例：

```shell
simd query distribution rewards cosmos1...
```

示例输出：

```yml
rewards:
- reward:
  - amount: "1000000.000000000000000000"
    denom: stake
  validator_address: cosmosvaloper1..
total:
- amount: "1000000.000000000000000000"
  denom: stake
```

**slashes**

`slashes` 命令允许用户查询给定区块范围的所有削减。

```shell
simd query distribution slashes [validator] [start-height] [end-height] [flags]
```

示例：

```shell
simd query distribution slashes cosmosvaloper1... 1 1000
```

示例输出：

```yml
pagination:
  next_key: null
  total: "0"
slashes:
- validator_period: 20,
  fraction: "0.009999999999999999"
```

**validator-outstanding-rewards**

`validator-outstanding-rewards` 命令允许用户查询验证者及其所有委托的所有未付（未提取）奖励。

```shell
simd query distribution validator-outstanding-rewards [validator] [flags]
```

示例：

```shell
simd query distribution validator-outstanding-rewards cosmosvaloper1...
```

示例输出：

```yml
rewards:
- amount: "1000000.000000000000000000"
  denom: stake
```

**validator-distribution-info**

`validator-distribution-info` 命令允许用户查询验证者的验证者佣金和自委托奖励。

````shell
simd query distribution validator-distribution-info cosmosvaloper1...
```

示例输出：

```yml
commission:
- amount: "100000.000000000000000000"
  denom: stake
operator_address: cosmosvaloper1...
self_bond_rewards:
- amount: "100000.000000000000000000"
  denom: stake
```

#### 交易

`tx` 命令允许用户与 `distribution` 模块交互。

```shell
simd tx distribution --help
```

##### fund-community-pool

`fund-community-pool` 命令允许用户向社区池发送资金。

```shell
simd tx distribution fund-community-pool [amount] [flags]
```

示例：

```shell
simd tx distribution fund-community-pool 100stake --from cosmos1...
```

##### set-withdraw-addr

`set-withdraw-addr` 命令允许用户设置与委托者地址关联的奖励提取地址。

```shell
simd tx distribution set-withdraw-addr [withdraw-addr] [flags]
```

示例：

```shell
simd tx distribution set-withdraw-addr cosmos1... --from cosmos1...
```

##### withdraw-all-rewards

`withdraw-all-rewards` 命令允许用户提取委托者的所有奖励。

```shell
simd tx distribution withdraw-all-rewards [flags]
```

示例：

```shell
simd tx distribution withdraw-all-rewards --from cosmos1...
```

##### withdraw-rewards

`withdraw-rewards` 命令允许用户从给定委托地址提取所有奖励，\
如果给定的委托地址是验证者运营者并且用户提供 `--commission` 标志，则可以选择提取验证者佣金。

```shell
simd tx distribution withdraw-rewards [validator-addr] [flags]
```

示例：

```shell
simd tx distribution withdraw-rewards cosmosvaloper1... --from cosmos1... --commission
```

### gRPC

用户可以使用 gRPC 端点查询 `distribution` 模块。

#### Params

`Params` 端点允许用户查询 `distribution` 模块的参数。

示例：

```shell
grpcurl -plaintext \
    localhost:9090 \
    cosmos.distribution.v1beta1.Query/Params
```

示例输出：

```json
{
  "params": {
    "communityTax": "20000000000000000",
    "baseProposerReward": "00000000000000000",
    "bonusProposerReward": "00000000000000000",
    "withdrawAddrEnabled": true
  }
}
```

#### ValidatorDistributionInfo

`ValidatorDistributionInfo` 查询验证者的验证者佣金和自委托奖励。

示例：

```shell
grpcurl -plaintext \
    -d '{"validator_address":"cosmosvalop1..."}' \
    localhost:9090 \
    cosmos.distribution.v1beta1.Query/ValidatorDistributionInfo
```

示例输出：

```json
{
  "commission": {
    "commission": [
      {
        "denom": "stake",
        "amount": "1000000000000000"
      }
    ]
  },
  "self_bond_rewards": [
    {
      "denom": "stake",
      "amount": "1000000000000000"
    }
  ],
  "validator_address": "cosmosvalop1..."
}
```

#### ValidatorOutstandingRewards

`ValidatorOutstandingRewards` 端点允许用户查询验证者地址的奖励。

示例：

```shell
grpcurl -plaintext \
    -d '{"validator_address":"cosmosvalop1.."}' \
    localhost:9090 \
    cosmos.distribution.v1beta1.Query/ValidatorOutstandingRewards
```

示例输出：

```json
{
  "rewards": {
    "rewards": [
      {
        "denom": "stake",
        "amount": "1000000000000000"
      }
    ]
  }
}
```

#### ValidatorCommission

`ValidatorCommission` 端点允许用户查询验证者的累积佣金。

示例：

```shell
grpcurl -plaintext \
    -d '{"validator_address":"cosmosvalop1.."}' \
    localhost:9090 \
    cosmos.distribution.v1beta1.Query/ValidatorCommission
```

示例输出：

```json
{
  "commission": {
    "commission": [
      {
        "denom": "stake",
        "amount": "1000000000000000"
      }
    ]
  }
}
```

#### ValidatorSlashes

`ValidatorSlashes` 端点允许用户查询验证者的削减事件。

示例：

```shell
grpcurl -plaintext \
    -d '{"validator_address":"cosmosvalop1.."}' \
    localhost:9090 \
    cosmos.distribution.v1beta1.Query/ValidatorSlashes
```

示例输出：

```json
{
  "slashes": [
    {
      "validator_period": "20",
      "fraction": "0.009999999999999999"
    }
  ],
  "pagination": {
    "total": "1"
  }
}
```

#### DelegationRewards

`DelegationRewards` 端点允许用户查询委托累积的总奖励。

示例：

```shell
grpcurl -plaintext \
    -d '{"delegator_address":"cosmos1...","validator_address":"cosmosvalop1..."}' \
    localhost:9090 \
    cosmos.distribution.v1beta1.Query/DelegationRewards
```

示例输出：

```json
{
  "rewards": [
    {
      "denom": "stake",
      "amount": "1000000000000000"
    }
  ]
}
```

#### DelegationTotalRewards

`DelegationTotalRewards` 端点允许用户查询每个验证者累积的总奖励。

示例：

```shell
grpcurl -plaintext \
    -d '{"delegator_address":"cosmos1..."}' \
    localhost:9090 \
    cosmos.distribution.v1beta1.Query/DelegationTotalRewards
```

示例输出：

```json
{
  "rewards": [
    {
      "validatorAddress": "cosmosvaloper1...",
      "reward": [
        {
          "denom": "stake",
          "amount": "1000000000000000"
        }
      ]
    }
  ],
  "total": [
    {
      "denom": "stake",
      "amount": "1000000000000000"
    }
  ]
}
```

#### DelegatorValidators

`DelegatorValidators` 端点允许用户查询给定委托者的所有验证者。

示例：

```shell
grpcurl -plaintext \
    -d '{"delegator_address":"cosmos1..."}' \
    localhost:9090 \
    cosmos.distribution.v1beta1.Query/DelegatorValidators
```

示例输出：

```json
{
  "validators": ["cosmosvaloper1..."]
}
```

#### DelegatorWithdrawAddress

`DelegatorWithdrawAddress` 端点允许用户查询委托者的提取地址。

示例：

```shell
grpcurl -plaintext \
    -d '{"delegator_address":"cosmos1..."}' \
    localhost:9090 \
    cosmos.distribution.v1beta1.Query/DelegatorWithdrawAddress
```

示例输出：

```json
{
  "withdrawAddress": "cosmos1..."
}
```

#### CommunityPool

`CommunityPool` 端点允许用户查询社区池代币。

示例：

```shell
grpcurl -plaintext \
    localhost:9090 \
    cosmos.distribution.v1beta1.Query/CommunityPool
```

示例输出：

```json
{
  "pool": [
    {
      "denom": "stake",
      "amount": "1000000000000000000"
    }
  ]
}
```
