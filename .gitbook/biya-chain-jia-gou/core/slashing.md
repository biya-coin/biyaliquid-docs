---
sidebar_position: 1
---

# Slashing

## 摘要

本节指定了 Cosmos SDK 的 slashing 模块，该模块实现了2016 年 6 月在 [Cosmos 白皮书](https://cosmos.network/about/whitepaper)中首次概述的功能。

slashing 模块使基于 Cosmos SDK 的区块链能够通过惩罚（"削减"）来阻止任何协议认可的有权益价值的参与者进行可归因的行为。

惩罚可能包括但不限于：

* 销毁其部分权益
* 在一段时间内移除他们对未来区块投票的能力。

此模块将被 Cosmos Hub 使用，Cosmos Hub 是 Cosmos 生态系统中的第一个中心。

## 概念

### 状态

在任何给定时间，状态机中注册有任意数量的验证者。每个区块，前 `MaxValidators`（由 `x/staking` 定义）个未监禁的验证者成为_绑定_状态，这意味着他们可以提议和投票区块。_绑定_的验证者处于_风险中_，这意味着如果他们犯下协议错误，他们的部分或全部权益及其委托者的权益将面临风险。

对于这些验证者中的每一个，我们保留一个 `ValidatorSigningInfo` 记录，其中包含与验证者活跃度和其他违规相关属性的信息。

### 墓碑上限

为了减轻最初可能出现的非恶意协议错误类别的影响，Cosmos Hub 为每个验证者实现一个_墓碑_上限，只允许验证者因双重签名错误被削减一次。例如，如果您错误配置了 HSM 并对一堆旧区块进行双重签名，您只会因第一次双重签名而受到惩罚（然后立即被墓碑化）。这仍然相当昂贵且需要避免，但墓碑上限在一定程度上减轻了无意错误配置的经济影响。

活跃度错误没有上限，因为它们不能相互叠加。活跃度错误在违规发生时立即被"检测"到，验证者立即被监禁，因此他们不可能在不解除监禁的情况下犯下多个活跃度错误。

### 违规时间线

为了说明 `x/slashing` 模块如何通过CometBFT 共识处理提交的证据，请考虑以下示例：

**定义**：

_\[_ : 时间线开始&#xNAN;_]_ : 时间线结束&#xNAN;_&#x43;_<sub>_n_</sub> : 违规 `n` 已犯&#xNAN;_&#x44;_<sub>_n_</sub> : 违规 `n` 被发现&#xNAN;_&#x56;_<sub>_b_</sub> : 验证者绑定&#xNAN;_&#x56;_<sub>_u_</sub> : 验证者解绑

#### 单个双重签名违规

\[----------C<sub>1</sub>----D<sub>1</sub>,V<sub>u</sub>-----]

单个违规被犯下，然后被发现，此时验证者被解绑并因违规被全额削减。

#### 多个双重签名违规

\[----------C<sub>1</sub>--C<sub>2</sub>---C<sub>3</sub>---D<sub>1</sub>,D<sub>2</sub>,D<sub>3</sub>V<sub>u</sub>-----]

多个违规被犯下，然后被发现，此时验证者被监禁并仅因一个违规而被削减。因为验证者也被墓碑化，他们无法重新加入验证者集合。

## 状态

### 签名信息（活跃度）

每个区块都包含验证者对前一区块的一组预提交，称为 CometBFT 提供的 `LastCommitInfo`。只要 `LastCommitInfo` 包含来自总投票权 +2/3 的预提交，它就是有效的。

提案者通过接收与 `LastCommitInfo` 中包含的投票权与 +2/3 之间的差值成比例的额外费用来激励在 CometBFT `LastCommitInfo` 中包含所有验证者的预提交（参见[费用分配](distribution.md#begin-block)）。

```go
type LastCommitInfo struct {
	Round int32
	Votes []VoteInfo
}
```

验证者因在多个区块中未能包含在 `LastCommitInfo` 中而受到惩罚，通过自动监禁、可能被削减和解绑。

关于验证者活跃度的信息通过 `ValidatorSigningInfo` 跟踪。它在存储中的索引如下：

* ValidatorSigningInfo: `0x01 | ConsAddrLen (1 byte) | ConsAddress -> ProtocolBuffer(ValSigningInfo)`
* MissedBlocksBitArray: `0x02 | ConsAddrLen (1 byte) | ConsAddress | LittleEndianUint64(signArrayIndex) -> VarInt(didMiss)` (varint 是一种数字编码格式)

第一个映射允许我们根据验证者的共识地址轻松查找验证者的最近签名信息。

第二个映射（`MissedBlocksBitArray`）充当大小为 `SignedBlocksWindow` 的位数组，告诉我们验证者是否错过了位数组中给定索引的区块。位数组中的索引以小端 uint64 给出。结果是一个取 `0` 或 `1` 的 `varint`，其中 `0` 表示验证者没有错过（已签名）相应的区块，`1` 表示他们错过了区块（未签名）。

请注意，`MissedBlocksBitArray` 不会预先显式初始化。键在我们遍历新绑定验证者的前 `SignedBlocksWindow` 个区块时添加。`SignedBlocksWindow` 参数定义用于跟踪验证者活跃度的滑动窗口的大小（区块数）。

用于跟踪验证者活跃度的存储信息如下：

```protobuf
https://github.com/cosmos/cosmos-sdk/blob/v0.47.0-rc1/proto/cosmos/slashing/v1beta1/slashing.proto#L13-L35
```

### 参数

slashing 模块将其参数存储在状态中，前缀为 `0x00`，可以通过治理或具有权限的地址进行更新。

* Params: `0x00 | ProtocolBuffer(Params)`

```protobuf
https://github.com/cosmos/cosmos-sdk/blob/v0.47.0-rc1/proto/cosmos/slashing/v1beta1/slashing.proto#L37-L59
```

## 消息

在本节中，我们描述 `slashing` 模块的消息处理。

### 解除监禁

如果验证者因停机而自动解绑，并希望重新上线并可能重新加入绑定集合，它必须发送 `MsgUnjail`：

```protobuf
// MsgUnjail is an sdk.Msg used for unjailing a jailed validator, thus returning
// them into the bonded validator set, so they can begin receiving provisions
// and rewards again.
message MsgUnjail {
  string validator_addr = 1;
}
```

以下是 `MsgSrv/Unjail` RPC 的伪代码：

```go
unjail(tx MsgUnjail)
    validator = getValidator(tx.ValidatorAddr)
    if validator == nil
      fail with "No validator found"

    if getSelfDelegation(validator) == 0
      fail with "validator must self delegate before unjailing"

    if !validator.Jailed
      fail with "Validator not jailed, cannot unjail"

    info = GetValidatorSigningInfo(operator)
    if info.Tombstoned
      fail with "Tombstoned validator cannot be unjailed"
    if block time < info.JailedUntil
      fail with "Validator still jailed, cannot unjail until period has expired"

    validator.Jailed = false
    setValidator(validator)

    return
```

如果验证者有足够的权益进入前 `n = MaximumBondedValidators`，它将自动重新绑定，所有仍委托给该验证者的委托者将重新绑定并开始再次收集供应和奖励。

## BeginBlock

### 活跃度跟踪

在每个区块开始时，我们更新每个验证者的 `ValidatorSigningInfo`并检查他们是否在滑动窗口内低于活跃度阈值。此滑动窗口由 `SignedBlocksWindow` 定义，窗口中的索引由验证者 `ValidatorSigningInfo` 中找到的 `IndexOffset` 确定。对于每个处理的区块，无论验证者是否签名，`IndexOffset` 都会递增。一旦确定了索引，`MissedBlocksBitArray` 和 `MissedBlocksCounter` 会相应更新。

最后，为了确定验证者是否低于活跃度阈值，我们获取错过的最大区块数 `maxMissed`，即`SignedBlocksWindow - (MinSignedPerWindow * SignedBlocksWindow)`，以及我们可以确定活跃度的最小高度 `minHeight`。如果当前区块大于 `minHeight` 且验证者的 `MissedBlocksCounter` 大于`maxMissed`，他们将被 `SlashFractionDowntime` 削减，将被监禁`DowntimeJailDuration`，并重置以下值：`MissedBlocksBitArray`、`MissedBlocksCounter` 和 `IndexOffset`。

**注意**：活跃度削减**不会**导致墓碑化。

```go
height := block.Height

for vote in block.LastCommitInfo.Votes {
  signInfo := GetValidatorSigningInfo(vote.Validator.Address)

  // This is a relative index, so we counts blocks the validator SHOULD have
  // signed. We use the 0-value default signing info if not present, except for
  // start height.
  index := signInfo.IndexOffset % SignedBlocksWindow()
  signInfo.IndexOffset++

  // Update MissedBlocksBitArray and MissedBlocksCounter. The MissedBlocksCounter
  // just tracks the sum of MissedBlocksBitArray. That way we avoid needing to
  // read/write the whole array each time.
  missedPrevious := GetValidatorMissedBlockBitArray(vote.Validator.Address, index)
  missed := !signed

  switch {
  case !missedPrevious && missed:
    // array index has changed from not missed to missed, increment counter
    SetValidatorMissedBlockBitArray(vote.Validator.Address, index, true)
    signInfo.MissedBlocksCounter++

  case missedPrevious && !missed:
    // array index has changed from missed to not missed, decrement counter
    SetValidatorMissedBlockBitArray(vote.Validator.Address, index, false)
    signInfo.MissedBlocksCounter--

  default:
    // array index at this index has not changed; no need to update counter
  }

  if missed {
    // emit events...
  }

  minHeight := signInfo.StartHeight + SignedBlocksWindow()
  maxMissed := SignedBlocksWindow() - MinSignedPerWindow()

  // If we are past the minimum height and the validator has missed too many
  // jail and slash them.
  if height > minHeight && signInfo.MissedBlocksCounter > maxMissed {
    validator := ValidatorByConsAddr(vote.Validator.Address)

    // emit events...

    // We need to retrieve the stake distribution which signed the block, so we
    // subtract ValidatorUpdateDelay from the block height, and subtract an
    // additional 1 since this is the LastCommit.
    //
    // Note, that this CAN result in a negative "distributionHeight" up to
    // -ValidatorUpdateDelay-1, i.e. at the end of the pre-genesis block (none) = at the beginning of the genesis block.
    // That's fine since this is just used to filter unbonding delegations & redelegations.
    distributionHeight := height - sdk.ValidatorUpdateDelay - 1

    SlashWithInfractionReason(vote.Validator.Address, distributionHeight, vote.Validator.Power, SlashFractionDowntime(), stakingtypes.Downtime)
    Jail(vote.Validator.Address)

    signInfo.JailedUntil = block.Time.Add(DowntimeJailDuration())

    // We need to reset the counter & array so that the validator won't be
    // immediately slashed for downtime upon rebonding.
    signInfo.MissedBlocksCounter = 0
    signInfo.IndexOffset = 0
    ClearValidatorMissedBlockBitArray(vote.Validator.Address)
  }

  SetValidatorSigningInfo(vote.Validator.Address, signInfo)
}
```

## 钩子

本节包含模块 `hooks` 的描述。钩子是在事件触发时自动执行的操作。

### 质押钩子

slashing 模块实现了 `x/staking` 中定义的 `StakingHooks`，用作验证者信息的记录保存。在应用初始化期间，这些钩子应在 staking 模块结构中注册。

以下钩子影响 slashing 状态：

* `AfterValidatorBonded` 创建如下节所述的 `ValidatorSigningInfo` 实例。
* `AfterValidatorCreated` 存储验证者的共识密钥。
* `AfterValidatorRemoved` 移除验证者的共识密钥。

### 验证者绑定

在新验证者首次成功绑定后，我们为现在绑定的验证者创建一个新的 `ValidatorSigningInfo` 结构，其 `StartHeight` 为当前区块。

如果验证者不在验证者集合中并再次绑定，则设置其新的绑定高度。

```go
onValidatorBonded(address sdk.ValAddress)

  signingInfo, found = GetValidatorSigningInfo(address)
  if !found {
    signingInfo = ValidatorSigningInfo {
      StartHeight         : CurrentHeight,
      IndexOffset         : 0,
      JailedUntil         : time.Unix(0, 0),
      Tombstone           : false,
      MissedBloskCounter  : 0
    } else {
      signingInfo.StartHeight = CurrentHeight
    }

    setValidatorSigningInfo(signingInfo)
  }

  return
```

## 事件

slashing 模块发出以下事件：

### MsgServer

#### MsgUnjail

| 类型    | 属性键   | 属性值            |
| ------- | -------- | ----------------- |
| message | module   | slashing           |
| message | sender   | {validatorAddress} |

### Keeper

### BeginBlocker: HandleValidatorSignature

| 类型  | 属性键   | 属性值                     |
| ----- | -------- | -------------------------- |
| slash | address  | {validatorConsensusAddress} |
| slash | power    | {validatorPower}            |
| slash | reason   | {slashReason}               |
| slash | jailed \[0] | {validatorConsensusAddress} |
| slash | burned coins | {math.Int}                  |

* \[0] 仅在验证者被监禁时包含。

| 类型     | 属性键        | 属性值                     |
| -------- | ------------ | -------------------------- |
| liveness | address      | {validatorConsensusAddress} |
| liveness | missed\_blocks | {missedBlocksCounter}       |
| liveness | height       | {blockHeight}               |

#### Slash

* 与 `HandleValidatorSignature` 的 `"slash"` 事件相同，但没有 `jailed` 属性。

#### Jail

| 类型  | 属性键   | 属性值            |
| ----- | -------- | ----------------- |
| slash | jailed   | {validatorAddress} |

## 质押墓碑

### 摘要

在 `slashing` 模块的当前实现中，当共识引擎通知状态机验证者的共识错误时，验证者被部分削减，并被置于"监禁期"，即他们不被允许重新加入验证者集合的时期。但是，由于共识错误和 ABCI 的性质，违规发生与违规证据到达状态机之间可能存在延迟（这是解绑期存在的主要原因之一）。

> 注意：墓碑概念仅适用于违规发生与证据到达状态机之间存在延迟的错误。例如，验证者双重签名的证据可能需要一段时间才能到达状态机，这是由于不可预测的证据八卦层延迟以及验证者选择性揭示双重签名的能力（例如，向不经常在线的轻客户端）。另一方面，活跃度削减在违规发生时立即被检测到，因此不需要削减期。验证者立即被置于监禁期，他们无法在解除监禁之前犯下另一个活跃度错误。未来，可能有其他类型的拜占庭错误具有延迟（例如，将无效提案的证据作为交易提交）。当实现时，必须决定这些未来类型的拜占庭错误是否会导致墓碑化（如果不是，削减金额将不受削减期限制）。

在当前系统设计中，一旦验证者因共识错误被监禁，在 `JailPeriod` 之后，他们被允许发送交易以 `unjail`自己，从而重新加入验证者集合。

`slashing` 模块的"设计愿望"之一是，如果在证据执行之前发生多个违规（并且验证者被监禁），他们应该只因单个最严重的违规而受到惩罚，而不是累积惩罚。例如，如果事件序列是：

1. 验证者 A 犯下违规 1（价值 30% 削减）
2. 验证者 A 犯下违规 2（价值 40% 削减）
3. 验证者 A 犯下违规 3（价值 35% 削减）
4. 违规 1 的证据到达状态机（验证者被监禁）
5. 违规 2 的证据到达状态机
6. 违规 3 的证据到达状态机

只有违规 2 应该生效其削减，因为它是最高的。这样做是为了在验证者的共识密钥被泄露的情况下，他们只会受到一次惩罚，即使黑客对许多区块进行双重签名。因为，解除监禁必须使用验证者的运营者密钥完成，他们有机会重新保护其共识密钥，然后使用其运营者密钥发出准备就绪的信号。我们将仅跟踪最大违规的这段时间称为"削减期"。

一旦验证者通过解除监禁重新加入，我们开始一个新的削减期；如果他们在解除监禁后犯下新的违规，它会在前一削减期的最严重违规之上累积削减。

但是，虽然违规基于削减期分组，但由于证据可以在违规后最多 `unbondingPeriod` 提交，我们仍然必须允许为之前的削减期提交证据。例如，如果事件序列是：

1. 验证者 A 犯下违规 1（价值 30% 削减）
2. 验证者 A 犯下违规 2（价值 40% 削减）
3. 违规 1 的证据到达状态机（验证者 A 被监禁）
4. 验证者 A 解除监禁

我们现在处于新的削减期，但我们仍然必须为之前的违规敞开大门，因为违规 2 的证据可能仍会到来。随着削减期数量的增加，它会产生更多复杂性，因为我们必须跟踪每个削减期的最高违规金额。

> 注意：目前，根据 `slashing` 模块规范，每次验证者解绑然后重新绑定时都会创建新的削减期。这应该改为监禁/解除监禁。有关详细信息，请参见问题 [#3205](https://github.com/cosmos/cosmos-sdk/issues/3205)。对于本文的其余部分，我将假设我们只在验证者解除监禁时开始新的削减期。

削减期的最大数量是 `len(UnbondingPeriod) / len(JailPeriod)`。Gaia 中 `UnbondingPeriod` 和 `JailPeriod` 的当前默认值分别为 3 周和 2 天。这意味着每个验证者可能同时跟踪多达 11 个削减期。如果我们将 `JailPeriod >= UnbondingPeriod`，我们只需要跟踪 1 个削减期（即不需要跟踪削减期）。

目前，在监禁期实现中，一旦验证者解除监禁，所有委托给他们的委托者（尚未解绑/重新委托离开），与他们一起。鉴于共识安全错误如此严重（远超过活跃度错误），让委托者不"自动重新绑定"到验证者可能是谨慎的。

#### 提案：无限监禁

我们建议将犯下共识安全错误的验证者的"监禁时间"设置为 `infinite`（即墓碑状态）。这实际上将验证者踢出验证者集合，不允许他们重新进入验证者集合。所有他们的委托者（包括运营者本人）必须解绑或重新委托离开。验证者运营者可以创建新的验证者（如果他们愿意），使用新的运营者密钥和共识密钥，但他们必须"重新获得"他们的委托。

实现墓碑系统并摆脱削减期跟踪将使 `slashing` 模块简单得多，特别是因为我们可以移除`staking` 模块使用的 `slashing` 模块中定义的所有钩子（`slashing` 模块仍使用 `staking` 中定义的钩子）。

#### 单一削减金额

可以进行的另一个优化是，如果我们假设 CometBFT 共识的所有 ABCI 错误都在同一级别削减，我们不需要跟踪"最大削减"。一旦发生 ABCI 错误，我们不需要担心比较潜在的未来错误以找到最大值。

目前唯一的 CometBFT ABCI 错误是：

* 不合理的预提交（双重签名）

目前计划在不久的将来包含以下错误：

* 在解绑阶段签署预提交（需要使轻客户端二分法安全）

鉴于这些错误都是可归因的拜占庭错误，我们可能希望同等削减它们，因此我们可以实施上述更改。

> 注意：此更改可能对当前的 CometBFT 共识有意义，但可能不适用于不同的共识算法或可能希望在不同级别惩罚的 CometBFT 未来版本（例如，部分削减）。

## 参数

slashing 模块包含以下参数：

| 键                     | 类型           | 示例                |
| ----------------------- | -------------- | ---------------------- |
| SignedBlocksWindow      | string (int64) | "100"                  |
| MinSignedPerWindow      | string (dec)   | "0.500000000000000000" |
| DowntimeJailDuration    | string (ns)    | "600000000000"         |
| SlashFractionDoubleSign | string (dec)   | "0.050000000000000000" |
| SlashFractionDowntime   | string (dec)   | "0.010000000000000000" |

## CLI

用户可以使用 CLI 查询和与 `slashing` 模块交互。

### 查询

`query` 命令允许用户查询 `slashing` 状态。

```shell
simd query slashing --help
```

#### params

`params` 命令允许用户查询 slashing 模块的创世参数。

```shell
simd query slashing params [flags]
```

示例：

```shell
simd query slashing params
```

示例输出：

```yml
downtime_jail_duration: 600s
min_signed_per_window: "0.500000000000000000"
signed_blocks_window: "100"
slash_fraction_double_sign: "0.050000000000000000"
slash_fraction_downtime: "0.010000000000000000"
```

#### signing-info

`signing-info` 命令允许用户使用共识公钥查询验证者的签名信息。

```shell
simd query slashing signing-infos [flags]
```

示例：

```shell
simd query slashing signing-info '{"@type":"/cosmos.crypto.ed25519.PubKey","key":"Auxs3865HpB/EfssYOzfqNhEJjzys6jD5B6tPgC8="}'

```

示例输出：

```yml
address: cosmosvalcons1nrqsld3aw6lh6t082frdqc84uwxn0t958c
index_offset: "2068"
jailed_until: "1970-01-01T00:00:00Z"
missed_blocks_counter: "0"
start_height: "0"
tombstoned: false
```

#### signing-infos

`signing-infos` 命令允许用户查询所有验证者的签名信息。

```shell
simd query slashing signing-infos [flags]
```

示例：

```shell
simd query slashing signing-infos
```

示例输出：

```yml
info:
- address: cosmosvalcons1nrqsld3aw6lh6t082frdqc84uwxn0t958c
  index_offset: "2075"
  jailed_until: "1970-01-01T00:00:00Z"
  missed_blocks_counter: "0"
  start_height: "0"
  tombstoned: false
pagination:
  next_key: null
  total: "0"
```

### 交易

`tx` 命令允许用户与 `slashing` 模块交互。

```bash
simd tx slashing --help
```

#### unjail

`unjail` 命令允许用户解除因停机而被监禁的验证者的监禁。

```bash
simd tx slashing unjail --from mykey [flags]
```

示例：

```bash
simd tx slashing unjail --from mykey
```

### gRPC

用户可以使用 gRPC 端点查询 `slashing` 模块。

#### Params

`Params` 端点允许用户查询 slashing 模块的参数。

```shell
cosmos.slashing.v1beta1.Query/Params
```

示例：

```shell
grpcurl -plaintext localhost:9090 cosmos.slashing.v1beta1.Query/Params
```

示例输出：

```json
{
  "params": {
    "signedBlocksWindow": "100",
    "minSignedPerWindow": "NTAwMDAwMDAwMDAwMDAwMDAw",
    "downtimeJailDuration": "600s",
    "slashFractionDoubleSign": "NTAwMDAwMDAwMDAwMDAwMDA=",
    "slashFractionDowntime": "MTAwMDAwMDAwMDAwMDAwMDA="
  }
}
```

#### SigningInfo

SigningInfo 查询给定共识地址的签名信息。

```shell
cosmos.slashing.v1beta1.Query/SigningInfo
```

示例：

```shell
grpcurl -plaintext -d '{"cons_address":"cosmosvalcons1nrqsld3aw6lh6t082frdqc84uwxn0t958c"}' localhost:9090 cosmos.slashing.v1beta1.Query/SigningInfo
```

示例输出：

```json
{
  "valSigningInfo": {
    "address": "cosmosvalcons1nrqsld3aw6lh6t082frdqc84uwxn0t958c",
    "indexOffset": "3493",
    "jailedUntil": "1970-01-01T00:00:00Z"
  }
}
```

#### SigningInfos

SigningInfos 查询所有验证者的签名信息。

```shell
cosmos.slashing.v1beta1.Query/SigningInfos
```

示例：

```shell
grpcurl -plaintext localhost:9090 cosmos.slashing.v1beta1.Query/SigningInfos
```

示例输出：

```json
{
  "info": [
    {
      "address": "cosmosvalcons1nrqslkwd3pz096lh6t082frdqc84uwxn0t958c",
      "indexOffset": "2467",
      "jailedUntil": "1970-01-01T00:00:00Z"
    }
  ],
  "pagination": {
    "total": "1"
  }
}
```

### REST

用户可以使用 REST 端点查询 `slashing` 模块。

#### Params

```shell
/cosmos/slashing/v1beta1/params
```

示例：

```shell
curl "localhost:1317/cosmos/slashing/v1beta1/params"
```

示例输出：

```json
{
  "params": {
    "signed_blocks_window": "100",
    "min_signed_per_window": "0.500000000000000000",
    "downtime_jail_duration": "600s",
    "slash_fraction_double_sign": "0.050000000000000000",
    "slash_fraction_downtime": "0.010000000000000000"
}
```

#### signing\_info

```shell
/cosmos/slashing/v1beta1/signing_infos/%s
```

示例：

```shell
curl "localhost:1317/cosmos/slashing/v1beta1/signing_infos/cosmosvalcons1nrqslkwd3pz096lh6t082frdqc84uwxn0t958c"
```

示例输出：

```json
{
  "val_signing_info": {
    "address": "cosmosvalcons1nrqslkwd3pz096lh6t082frdqc84uwxn0t958c",
    "start_height": "0",
    "index_offset": "4184",
    "jailed_until": "1970-01-01T00:00:00Z",
    "tombstoned": false,
    "missed_blocks_counter": "0"
  }
}
```

#### signing\_infos

```shell
/cosmos/slashing/v1beta1/signing_infos
```

示例：

```shell
curl "localhost:1317/cosmos/slashing/v1beta1/signing_infos
```

示例输出：

```json
{
  "info": [
    {
      "address": "cosmosvalcons1nrqslkwd3pz096lh6t082frdqc84uwxn0t958c",
      "start_height": "0",
      "index_offset": "4169",
      "jailed_until": "1970-01-01T00:00:00Z",
      "tombstoned": false,
      "missed_blocks_counter": "0"
    }
  ],
  "pagination": {
    "next_key": null,
    "total": "1"
  }
}
```
