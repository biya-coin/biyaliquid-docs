---
sidebar_position: 1
---

# Mint

## 概念

### 铸造机制

铸造机制旨在：

* 允许由市场需求决定的灵活通胀率，目标是特定的绑定权益比率
* 在市场流动性和质押供应量之间实现平衡

为了最好地确定通胀奖励的适当市场利率，使用\
移动变化率。移动变化率机制确保如果\
绑定百分比超过或低于目标绑定百分比，通胀率将\
相应调整以进一步激励或抑制绑定。将目标\
绑定百分比设置为小于 100% 鼓励网络维持一些非质押代币\
，这应该有助于提供一些流动性。

它可以按以下方式分解：

* 如果实际绑定代币百分比低于目标绑定百分比，通胀率将\
  增加直到达到最大值
* 如果维持目标绑定百分比（Cosmos-Hub 中为 67%），则通胀\
  率将保持恒定
* 如果实际绑定代币百分比高于目标绑定百分比，通胀率将\
  减少直到达到最小值

## 状态

### Minter

minter 是保存当前通胀信息的空间。

* Minter: `0x00 -> ProtocolBuffer(minter)`

```protobuf
https://github.com/cosmos/cosmos-sdk/blob/v0.47.0-rc1/proto/cosmos/mint/v1beta1/mint.proto#L10-L24
```

### 参数

mint 模块将其参数存储在状态中，前缀为 `0x01`，\
可以通过治理或具有权限的地址进行更新。

* Params: `mint/params -> legacy_amino(params)`

```protobuf
https://github.com/cosmos/cosmos-sdk/blob/v0.47.0-rc1/proto/cosmos/mint/v1beta1/mint.proto#L26-L59
```

## Begin-Block

在每个区块开始时重新计算铸造参数并支付通胀。

### 通胀率计算

通胀率使用传递给 `NewAppModule` 函数的\
"通胀计算函数"计算。如果未传递函数，则将使用 SDK 的\
默认通胀函数（`NextInflationRate`）。如果需要自定义\
通胀计算逻辑，可以通过定义并\
传递匹配 `InflationCalculationFn` 签名的函数来实现。

```go
type InflationCalculationFn func(ctx sdk.Context, minter Minter, params Params, bondedRatio math.LegacyDec) math.LegacyDec
```

#### NextInflationRate

目标年通胀率在每个区块重新计算。\
通胀也受到速率变化（正或负）的影响，\
取决于与期望比率（67%）的距离。最大速率变化\
可能定义为每年 13%，但是，年通胀被限制\
在 7% 和 20% 之间。

```go
NextInflationRate(params Params, bondedRatio math.LegacyDec) (inflation math.LegacyDec) {
	inflationRateChangePerYear = (1 - bondedRatio/params.GoalBonded) * params.InflationRateChange
	inflationRateChange = inflationRateChangePerYear/blocksPerYr

	// increase the new annual inflation for this next block
	inflation += inflationRateChange
	if inflation > params.InflationMax {
		inflation = params.InflationMax
	}
	if inflation < params.InflationMin {
		inflation = params.InflationMin
	}

	return inflation
}
```

### NextAnnualProvisions

根据当前总供应量和通胀\
率计算年供应量。此参数每个区块计算一次。

```go
NextAnnualProvisions(params Params, totalSupply math.LegacyDec) (provisions math.LegacyDec) {
	return Inflation * totalSupply
```

### BlockProvision

根据当前年供应量计算每个区块生成的供应量。然后由 `mint` 模块的 `ModuleMinterAccount` 铸造供应量，然后转移到 `auth` 的 `FeeCollector` `ModuleAccount`。

```go
BlockProvision(params Params) sdk.Coin {
	provisionAmt = AnnualProvisions/ params.BlocksPerYear
	return sdk.NewCoin(params.MintDenom, provisionAmt.Truncate())
```

## 参数

铸造模块包含以下参数：

| 键                  | 类型            | 示例                    |
| ------------------- | --------------- | ----------------------- |
| MintDenom           | string          | "uatom"                 |
| InflationRateChange | string (dec)    | "0.130000000000000000"   |
| InflationMax        | string (dec)    | "0.200000000000000000"   |
| InflationMin        | string (dec)    | "0.070000000000000000"   |
| GoalBonded          | string (dec)    | "0.670000000000000000"   |
| BlocksPerYear       | string (uint64) | "6311520"                |

## 事件

铸造模块发出以下事件：

### BeginBlocker

| 类型 | 属性键           | 属性值            |
| ---- | ---------------- | ----------------- |
| mint | bonded\_ratio    | {bondedRatio}     |
| mint | inflation        | {inflation}       |
| mint | annual\_provisions | {annualProvisions} |
| mint | amount           | {amount}          |

## 客户端

### CLI

用户可以使用 CLI 查询和与 `mint` 模块交互。

#### 查询

`query` 命令允许用户查询 `mint` 状态。

```shell
simd query mint --help
```

**annual-provisions**

`annual-provisions` 命令允许用户查询当前铸造年供应量值

```shell
simd query mint annual-provisions [flags]
```

示例：

```shell
simd query mint annual-provisions
```

示例输出：

```shell
22268504368893.612100895088410693
```

**inflation**

`inflation` 命令允许用户查询当前铸造通胀值

```shell
simd query mint inflation [flags]
```

示例：

```shell
simd query mint inflation
```

示例输出：

```shell
0.199200302563256955
```

**params**

`params` 命令允许用户查询当前铸造参数

```shell
simd query mint params [flags]
```

示例：

```yml
blocks_per_year: "4360000"
goal_bonded: "0.670000000000000000"
inflation_max: "0.200000000000000000"
inflation_min: "0.070000000000000000"
inflation_rate_change: "0.130000000000000000"
mint_denom: stake
```

### gRPC

用户可以使用 gRPC 端点查询 `mint` 模块。

#### AnnualProvisions

`AnnualProvisions` 端点允许用户查询当前铸造年供应量值

```shell
/cosmos.mint.v1beta1.Query/AnnualProvisions
```

示例：

```shell
grpcurl -plaintext localhost:9090 cosmos.mint.v1beta1.Query/AnnualProvisions
```

示例输出：

```json
{
  "annualProvisions": "1432452520532626265712995618"
}
```

#### Inflation

`Inflation` 端点允许用户查询当前铸造通胀值

```shell
/cosmos.mint.v1beta1.Query/Inflation
```

示例：

```shell
grpcurl -plaintext localhost:9090 cosmos.mint.v1beta1.Query/Inflation
```

示例输出：

```json
{
  "inflation": "130197115720711261"
}
```

#### Params

`Params` 端点允许用户查询当前铸造参数

```shell
/cosmos.mint.v1beta1.Query/Params
```

示例：

```shell
grpcurl -plaintext localhost:9090 cosmos.mint.v1beta1.Query/Params
```

示例输出：

```json
{
  "params": {
    "mintDenom": "stake",
    "inflationRateChange": "130000000000000000",
    "inflationMax": "200000000000000000",
    "inflationMin": "70000000000000000",
    "goalBonded": "670000000000000000",
    "blocksPerYear": "6311520"
  }
}
```

### REST

用户可以使用 REST 端点查询 `mint` 模块。

#### annual-provisions

```shell
/cosmos/mint/v1beta1/annual_provisions
```

示例：

```shell
curl "localhost:1317/cosmos/mint/v1beta1/annual_provisions"
```

示例输出：

```json
{
  "annualProvisions": "1432452520532626265712995618"
}
```

#### inflation

```shell
/cosmos/mint/v1beta1/inflation
```

示例：

```shell
curl "localhost:1317/cosmos/mint/v1beta1/inflation"
```

示例输出：

```json
{
  "inflation": "130197115720711261"
}
```

#### params

```shell
/cosmos/mint/v1beta1/params
```

示例：

```shell
curl "localhost:1317/cosmos/mint/v1beta1/params"
```

示例输出：

```json
{
  "params": {
    "mintDenom": "stake",
    "inflationRateChange": "130000000000000000",
    "inflationMax": "200000000000000000",
    "inflationMin": "70000000000000000",
    "goalBonded": "670000000000000000",
    "blocksPerYear": "6311520"
  }
}
```
