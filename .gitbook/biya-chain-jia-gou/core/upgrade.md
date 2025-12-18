---
sidebar_position: 1
---

# Upgrade

## Abstract

`x/upgrade` 是一个 Cosmos SDK 模块的实现，它有助于顺利地将运行中的 Cosmos 链升级到新的（破坏性）软件版本。它通过提供一个 `PreBlocker` 钩子来实现这一点，该钩子可以防止区块链状态机在达到预定义的升级区块高度后继续运行。

该模块并不规定治理如何决定进行升级，而只是提供安全协调升级的机制。如果没有软件升级支持，升级运行中的链是有风险的，因为所有验证者都需要在流程中的完全相同点暂停其状态机。如果操作不当，可能会出现难以恢复的状态不一致。

## Concepts

### Plan

`x/upgrade` 模块定义了一个 `Plan` 类型，用于安排实时升级的发生。`Plan` 可以在特定的区块高度进行调度。一旦（冻结的）发布候选版本以及相应的升级 `Handler`（见下文）达成一致，就会创建一个 `Plan`，其中 `Plan` 的 `Name` 对应于一个特定的 `Handler`。通常，`Plan` 通过治理提案流程创建，如果投票通过，将被调度。`Plan` 的 `Info` 可能包含有关升级的各种元数据，通常是特定于应用程序的升级信息，要包含在链上，例如验证者可以自动升级到的 git commit。

```go
type Plan struct {
  Name   string
  Height int64
  Info   string
}
```

#### Sidecar Process

如果运行应用程序二进制的操作员还运行一个 sidecar 进程来协助自动下载和升级二进制文件，`Info` 允许此过程无缝进行。该工具是 [Cosmovisor](https://github.com/cosmos/cosmos-sdk/tree/main/tools/cosmovisor#readme)。

### Handler

`x/upgrade` 模块有助于从主版本 X 升级到主版本 Y。为了实现这一点，节点操作员必须首先将其当前二进制文件升级到具有新版本 Y 的相应 `Handler` 的新二进制文件。假设该版本已经过充分测试并获得社区的广泛批准。此 `Handler` 定义了在新二进制文件 Y 成功运行链之前需要发生的状态迁移。自然地，此 `Handler` 是特定于应用程序的，而不是在每个模块的基础上定义的。注册 `Handler` 是通过应用程序中的 `Keeper#SetUpgradeHandler` 完成的。

```go
type UpgradeHandler func(Context, Plan, VersionMap) (VersionMap, error)
```

在每次 `EndBlock` 执行期间，`x/upgrade` 模块检查是否存在应该执行的 `Plan`（在该高度调度）。如果是，则执行相应的 `Handler`。如果 `Plan` 预期执行但没有注册 `Handler`，或者二进制文件升级过早，节点将优雅地 panic 并退出。

### StoreLoader

`x/upgrade` 模块还促进作为升级一部分的存储迁移。`StoreLoader` 设置在新二进制文件成功运行链之前需要发生的迁移。此 `StoreLoader` 也是特定于应用程序的，而不是在每个模块的基础上定义的。注册此 `StoreLoader` 是通过应用程序中的 `app#SetStoreLoader` 完成的。

```go
func UpgradeStoreLoader (upgradeHeight int64, storeUpgrades *store.StoreUpgrades) baseapp.StoreLoader
```

如果有计划的升级并且达到升级高度，旧二进制文件会在 panic 之前将 `Plan` 写入磁盘。

此信息对于确保 `StoreUpgrades` 在正确的高度和预期的升级时顺利进行至关重要。它消除了新二进制文件在每次重启时多次执行 `StoreUpgrades` 的可能性。此外，如果在同一高度计划了多个升级，`Name` 将确保这些 `StoreUpgrades` 仅在计划的升级处理程序中发生。

### Proposal

通常，`Plan` 通过治理通过包含 `MsgSoftwareUpgrade` 消息的提案提出并提交。此提案遵循标准治理流程。如果提案通过，针对特定 `Handler` 的 `Plan` 将被持久化并调度。可以通过在新提案中更新 `Plan.Height` 来延迟或加快升级。

```protobuf
https://github.com/cosmos/cosmos-sdk/blob/v0.47.0-rc1/proto/cosmos/upgrade/v1beta1/tx.proto#L29-L41
```

#### Cancelling Upgrade Proposals

升级提案可以被取消。存在一个启用治理的 `MsgCancelUpgrade` 消息类型，可以嵌入到提案中，进行投票，如果通过，将删除计划的升级 `Plan`。当然，这要求在升级本身之前很久就知道升级是一个坏主意，以便有时间进行投票。

```protobuf
https://github.com/cosmos/cosmos-sdk/blob/v0.47.0-rc1/proto/cosmos/upgrade/v1beta1/tx.proto#L48-L57
```

如果需要这种可能性，升级高度应该是从升级提案开始时的 `2 * (VotingPeriod + DepositPeriod) + (SafetyDelta)`。`SafetyDelta` 是从升级提案成功到意识到这是一个坏主意（由于外部社会共识）之间的可用时间。

`MsgCancelUpgrade` 提案也可以在原始 `MsgSoftwareUpgrade` 提案仍在投票时提出，只要 `VotingPeriod` 在 `MsgSoftwareUpgrade` 提案之后结束。

## State

`x/upgrade` 模块的内部状态相对最小且简单。状态包含当前活动的升级 `Plan`（如果存在），通过键 `0x0`，以及如果 `Plan` 被标记为"完成"，通过键 `0x1`。状态包含应用程序中所有应用模块的共识版本。版本存储为大端 `uint64`，可以通过前缀 `0x2` 后跟类型为 `string` 的相应模块名称来访问。状态维护一个 `Protocol Version`，可以通过键 `0x3` 访问。

* Plan: `0x0 -> Plan`
* Done: `0x1 | byte(plan name) -> BigEndian(Block Height)`
* ConsensusVersion: `0x2 | byte(module name) -> BigEndian(Module Consensus Version)`
* ProtocolVersion: `0x3 -> BigEndian(Protocol Version)`

`x/upgrade` 模块不包含创世状态。

## Events

`x/upgrade` 本身不会发出任何事件。所有与提案相关的事件都通过 `x/gov` 模块发出。

## Client

### CLI

用户可以使用 CLI 查询和与 `upgrade` 模块交互。

#### Query

`query` 命令允许用户查询 `upgrade` 状态。

```bash
simd query upgrade --help
```

**applied**

`applied` 命令允许用户查询完成升级应用的区块高度的区块头。

```bash
simd query upgrade applied [upgrade-name] [flags]
```

如果升级名称先前在链上执行过，这将返回应用它的区块的区块头。这有助于客户端确定哪个二进制文件在给定区块范围内有效，以及更多上下文来理解过去的迁移。

Example:

```bash
simd query upgrade applied "test-upgrade"
```

Example Output:

```bash
"block_id": {
    "hash": "A769136351786B9034A5F196DC53F7E50FCEB53B48FA0786E1BFC45A0BB646B5",
    "parts": {
      "total": 1,
      "hash": "B13CBD23011C7480E6F11BE4594EE316548648E6A666B3575409F8F16EC6939E"
    }
  },
  "block_size": "7213",
  "header": {
    "version": {
      "block": "11"
    },
    "chain_id": "testnet-2",
    "height": "455200",
    "time": "2021-04-10T04:37:57.085493838Z",
    "last_block_id": {
      "hash": "0E8AD9309C2DC411DF98217AF59E044A0E1CCEAE7C0338417A70338DF50F4783",
      "parts": {
        "total": 1,
        "hash": "8FE572A48CD10BC2CBB02653CA04CA247A0F6830FF19DC972F64D339A355E77D"
      }
    },
    "last_commit_hash": "DE890239416A19E6164C2076B837CC1D7F7822FC214F305616725F11D2533140",
    "data_hash": "E3B0C44298FC1C149AFBF4C8996FB92427AE41E4649B934CA495991B7852B855",
    "validators_hash": "A31047ADE54AE9072EE2A12FF260A8990BA4C39F903EAF5636B50D58DBA72582",
    "next_validators_hash": "A31047ADE54AE9072EE2A12FF260A8990BA4C39F903EAF5636B50D58DBA72582",
    "consensus_hash": "048091BC7DDC283F77BFBF91D73C44DA58C3DF8A9CBC867405D8B7F3DAADA22F",
    "app_hash": "28ECC486AFC332BA6CC976706DBDE87E7D32441375E3F10FD084CD4BAF0DA021",
    "last_results_hash": "E3B0C44298FC1C149AFBF4C8996FB92427AE41E4649B934CA495991B7852B855",
    "evidence_hash": "E3B0C44298FC1C149AFBF4C8996FB92427AE41E4649B934CA495991B7852B855",
    "proposer_address": "2ABC4854B1A1C5AA8403C4EA853A81ACA901CC76"
  },
  "num_txs": "0"
}
```

**module versions**

`module_versions` 命令获取模块名称及其各自共识版本的列表。

在命令后跟特定的模块名称将仅返回该模块的信息。

```bash
simd query upgrade module_versions [optional module_name] [flags]
```

Example:

```bash
simd query upgrade module_versions
```

Example Output:

```bash
module_versions:
- name: auth
  version: "2"
- name: authz
  version: "1"
- name: bank
  version: "2"
- name: crisis
  version: "1"
- name: distribution
  version: "2"
- name: evidence
  version: "1"
- name: feegrant
  version: "1"
- name: genutil
  version: "1"
- name: gov
  version: "2"
- name: ibc
  version: "2"
- name: mint
  version: "1"
- name: params
  version: "1"
- name: slashing
  version: "2"
- name: staking
  version: "2"
- name: transfer
  version: "1"
- name: upgrade
  version: "1"
- name: vesting
  version: "1"
```

Example:

```bash
regen query upgrade module_versions ibc
```

Example Output:

```bash
module_versions:
- name: ibc
  version: "2"
```

**plan**

`plan` 命令获取当前计划的升级计划（如果存在）。

```bash
regen query upgrade plan [flags]
```

Example:

```bash
simd query upgrade plan
```

Example Output:

```bash
height: "130"
info: ""
name: test-upgrade
time: "0001-01-01T00:00:00Z"
upgraded_client_state: null
```

#### Transactions

升级模块支持以下交易：

* `software-proposal` - 提交升级提案：

```bash
simd tx upgrade software-upgrade v2 --title="Test Proposal" --summary="testing" --deposit="100000000stake" --upgrade-height 1000000 \
--upgrade-info '{ "binaries": { "linux/amd64":"https://example.com/simd.zip?checksum=sha256:aec070645fe53ee3b3763059376134f058cc337247c978add178b6ccdfb0019f" } }' --from cosmos1..
```

* `cancel-software-upgrade` - cancels a previously submitted upgrade proposal:

```bash
simd tx upgrade cancel-software-upgrade --title="Test Proposal" --summary="testing" --deposit="100000000stake" --from cosmos1..
```

### REST

用户可以使用 REST 端点查询 `upgrade` 模块。

#### Applied Plan

`AppliedPlan` 按名称查询先前应用的升级计划。

```bash
/cosmos/upgrade/v1beta1/applied_plan/{name}
```

示例：

```bash
curl -X GET "http://localhost:1317/cosmos/upgrade/v1beta1/applied_plan/v2.0-upgrade" -H "accept: application/json"
```

示例输出：

```bash
{
  "height": "30"
}
```

#### Current Plan

`CurrentPlan` 查询当前升级计划。

```bash
/cosmos/upgrade/v1beta1/current_plan
```

示例：

```bash
curl -X GET "http://localhost:1317/cosmos/upgrade/v1beta1/current_plan" -H "accept: application/json"
```

示例输出：

```bash
{
  "plan": "v2.1-upgrade"
}
```

#### Module versions

`ModuleVersions` 从状态查询模块版本列表。

```bash
/cosmos/upgrade/v1beta1/module_versions
```

示例：

```bash
curl -X GET "http://localhost:1317/cosmos/upgrade/v1beta1/module_versions" -H "accept: application/json"
```

示例输出：

```bash
{
  "module_versions": [
    {
      "name": "auth",
      "version": "2"
    },
    {
      "name": "authz",
      "version": "1"
    },
    {
      "name": "bank",
      "version": "2"
    },
    {
      "name": "crisis",
      "version": "1"
    },
    {
      "name": "distribution",
      "version": "2"
    },
    {
      "name": "evidence",
      "version": "1"
    },
    {
      "name": "feegrant",
      "version": "1"
    },
    {
      "name": "genutil",
      "version": "1"
    },
    {
      "name": "gov",
      "version": "2"
    },
    {
      "name": "ibc",
      "version": "2"
    },
    {
      "name": "mint",
      "version": "1"
    },
    {
      "name": "params",
      "version": "1"
    },
    {
      "name": "slashing",
      "version": "2"
    },
    {
      "name": "staking",
      "version": "2"
    },
    {
      "name": "transfer",
      "version": "1"
    },
    {
      "name": "upgrade",
      "version": "1"
    },
    {
      "name": "vesting",
      "version": "1"
    }
  ]
}
```

### gRPC

用户可以使用 gRPC 端点查询 `upgrade` 模块。

#### Applied Plan

`AppliedPlan` 按名称查询先前应用的升级计划。

```bash
cosmos.upgrade.v1beta1.Query/AppliedPlan
```

示例：

```bash
grpcurl -plaintext \
    -d '{"name":"v2.0-upgrade"}' \
    localhost:9090 \
    cosmos.upgrade.v1beta1.Query/AppliedPlan
```

示例输出：

```bash
{
  "height": "30"
}
```

#### Current Plan

`CurrentPlan` 查询当前升级计划。

```bash
cosmos.upgrade.v1beta1.Query/CurrentPlan
```

示例：

```bash
grpcurl -plaintext localhost:9090 cosmos.slashing.v1beta1.Query/CurrentPlan
```

示例输出：

```bash
{
  "plan": "v2.1-upgrade"
}
```

#### Module versions

`ModuleVersions` 从状态查询模块版本列表。

```bash
cosmos.upgrade.v1beta1.Query/ModuleVersions
```

示例：

```bash
grpcurl -plaintext localhost:9090 cosmos.slashing.v1beta1.Query/ModuleVersions
```

示例输出：

```bash
{
  "module_versions": [
    {
      "name": "auth",
      "version": "2"
    },
    {
      "name": "authz",
      "version": "1"
    },
    {
      "name": "bank",
      "version": "2"
    },
    {
      "name": "crisis",
      "version": "1"
    },
    {
      "name": "distribution",
      "version": "2"
    },
    {
      "name": "evidence",
      "version": "1"
    },
    {
      "name": "feegrant",
      "version": "1"
    },
    {
      "name": "genutil",
      "version": "1"
    },
    {
      "name": "gov",
      "version": "2"
    },
    {
      "name": "ibc",
      "version": "2"
    },
    {
      "name": "mint",
      "version": "1"
    },
    {
      "name": "params",
      "version": "1"
    },
    {
      "name": "slashing",
      "version": "2"
    },
    {
      "name": "staking",
      "version": "2"
    },
    {
      "name": "transfer",
      "version": "1"
    },
    {
      "name": "upgrade",
      "version": "1"
    },
    {
      "name": "vesting",
      "version": "1"
    }
  ]
}
```

## 资源

学习更多关于 `x/upgrade` 模块的（外部）资源列表。

* [Cosmos 开发系列：Cosmos 区块链升级](https://medium.com/web3-surfers/cosmos-dev-series-cosmos-sdk-based-blockchain-upgrade-b5e99181554c) - 详细解释软件升级工作原理的博客文章。
