# Txfees

Biya Chain 的 txfees 模块提供了支持 EIP-1559 费用市场所需的功能。

EIP-1559 引入了根据网络拥堵情况自动调整的"基础费用"。当网络活动增加时，基础费用增加；当活动减少时，基础费用减少。与简单的首价拍卖模型相比，这创建了一个更可预测和高效的费用市场。

更多详情，请参阅官方 EIP-1559 规范：https://eips.ethereum.org/EIPS/eip-1559

## 模块参数

txfees 模块的参数控制交易接受规则和 EIP-1559 费用市场行为。这些参数可以通过治理进行更新。

### 交易控制参数

这些参数定义了始终强制执行的基本交易验证规则，无论是否启用 EIP-1559 费用市场（`Mempool1559Enabled`）。它们通过设置交易特征的硬限制并为高 gas 交易实施双层费用系统，提供第一道防网络垃圾邮件的防线。

当 `Mempool1559Enabled` 为 false 时，这些是用于交易验证的唯一参数。当为 true 时，在执行 EIP-1559 费用市场规则之前执行这些检查。

#### MaxGasWantedPerTx
- 类型：`uint64`
- 默认值：`30,000,000`
- 描述：每笔交易允许的最大 gas。gas 限制高于此值的交易将被内存池拒绝。

#### HighGasTxThreshold
- 类型：`uint64`
- 默认值：`2,500,000`
- 描述：超过此阈值时，交易被视为"高 gas"交易。当交易的 gas 超过此阈值时，必须至少支付 `MinGasPriceForHighGasTx` 作为 gas 价格。

#### MinGasPriceForHighGasTx
- 类型：`sdk.Dec`
- 默认值：`0`
- 描述：高 gas 交易所需的最低 gas 价格。超过 `HighGasTxThreshold` 的交易必须至少具有此 gas 价格才能被接受进入内存池。

### 费用市场参数

这些参数控制动态 EIP-1559 费用市场行为，仅在 `Mempool1559Enabled` 为 true 时激活。它们确定基础费用如何响应网络拥堵进行调整，设置费用调整的界限，并定义目标区块利用率。

当 `Mempool1559Enabled` 为 false 时，这些参数（除了 `MinGasPrice`）不会被使用，交易只需要满足基本交易控制要求。当为 true 时，交易还必须满足 EIP-1559 费用市场规则，包括提供 gas 价格 ≥ 当前基础费用。

注意：`MinGasPrice` 始终作为最低 gas 价格强制执行，无论是否启用 EIP-1559。

#### Mempool1559Enabled
- 类型：`bool`
- 默认值：`false`
- 描述：在内存池中启用 EIP-1559 风格的自适应费用市场。启用后，基础费用会根据网络拥堵情况自动调整。

#### MinGasPrice
- 类型：`sdk.Dec`
- 默认值：`160,000,000` (BIYA)
- 描述：允许的最低基础费用。基础费用不能低于此值，为交易费用提供价格下限。

#### DefaultBaseFeeMultiplier
- 类型：`sdk.Dec`
- 默认值：`1.5`
- 描述：应用于 `MinGasPrice` 以计算默认基础费用的乘数。默认基础费用（`MinGasPrice` * `DefaultBaseFeeMultiplier`）在每个重置间隔重置费用市场时使用。

#### MaxBaseFeeMultiplier
- 类型：`sdk.Dec`
- 默认值：`1000`
- 描述：应用于 `MinGasPrice` 以计算允许的最大基础费用的最大乘数。这可以防止费用变得过高。

#### ResetInterval
- 类型：`int64`
- 默认值：`36,000`（区块数，约 8 小时）
- 描述：基础费用重置为默认基础费用的间隔。这可以防止长期费用漂移，并确保定期重置到已知基线。

#### MaxBlockChangeRate
- 类型：`sdk.Dec`
- 默认值：`0.1` (10%)
- 描述：每个区块基础费用可以改变的最大速率。这限制了区块之间的费用波动性。
- 计算：基础费用调整使用以下公式：
  ```
  baseFeeMultiplier = 1 + (gasUsed - targetGas) / targetGas * maxChangeRate
  newBaseFee = currentBaseFee * baseFeeMultiplier
  ```
  其中：
  - `gasUsed` 是区块中消耗的总 gas
  - `targetGas` 由 `TargetBlockSpacePercentRate` * 区块 gas 限制确定
  - `maxChangeRate` 是 0.1 (10%)
- 影响：
  - 当区块已满（gasUsed = 区块 gas 限制）时：基础费用增加约 6%
  - 当区块为空（gasUsed = 0）时：基础费用减少 10%
  - 当 gasUsed = targetGas 时：基础费用不变
  - 不对称的变化速率（6% 上升 vs 10% 下降）有助于费用在拥堵后更快恢复
- 交易处理：
  - 在 CheckTx 中：新交易必须提供 gas 价格 ≥ 当前基础费用才能被接受
  - 在 RecheckTx 中：
    - 对于低基础费用（≤ 4x MinGasPrice）：gas 价格 < 当前基础费用 / 2 的交易被移除
    - 对于高基础费用（> 4x MinGasPrice）：gas 价格 < 当前基础费用 / 2.3 的交易被移除
  - 这种双阈值方法有助于在正常操作期间保持网络稳定性，同时在拥堵期间允许更快恢复

#### TargetBlockSpacePercentRate
- 类型：`sdk.Dec`
- 默认值：`0.625` (62.5%)
- 描述：应该使用的区块 gas 限制的目标百分比。当实际使用超过此目标时，基础费用增加。当使用低于目标时，基础费用减少。

### 费用重新检查参数

这些参数控制内存池交易驱逐机制，仅在 `Mempool1559Enabled` 为 true 时相关。它们确定何时应从内存池中移除现有交易，因为基础费用会发生变化，实施双阈值方法，平衡网络稳定性和拥堵恢复。

当 `Mempool1559Enabled` 为 false 时，内存池中的交易不会根据变化的基础费用重新检查。当为 true 时，这些参数与费用市场参数协同工作，通过确保交易在网络条件变化时保持经济可行性来维护内存池健康。

重新检查机制对低基础费用和高基础费用场景使用不同的阈值：
- 在低基础费用条件下：专注于网络稳定性，采用更保守的驱逐规则
- 在高基础费用条件下：优先考虑从拥堵中快速恢复，采用更激进的驱逐

#### RecheckFeeLowBaseFee
- 类型：`sdk.Dec`
- 默认值：`3.0`
- 描述：当基础费用较低（≤ 4x MinGasPrice）时，交易必须至少具有当前基础费用的 1/3 才能保留在内存池中。在较低费用水平下，这种更保守的乘数有助于通过防止交易过快驱逐来保持网络稳定性。如果检测到垃圾邮件交易，从基础费用超过垃圾邮件成本到这些交易从内存池中驱逐大约需要 19 个区块。

#### RecheckFeeHighBaseFee
- 类型：`sdk.Dec`
- 默认值：`2.3`
- 描述：当基础费用较高（> 4x MinGasPrice）时，交易必须至少具有当前基础费用的 1/2.3 才能保留在内存池中。

#### RecheckFeeBaseFeeThresholdMultiplier
- 类型：`sdk.Dec`
- 默认值：`4.0`
- 描述：应用于 `MinGasPrice` 以确定用于重新检查目的的高基础费用和低基础费用制度之间阈值的乘数。阈值是 `MinGasPrice` * `RecheckFeeBaseFeeThresholdMultiplier`。

## 修改模块参数

txfees 模块参数可以通过治理提案进行修改。这确保了这些关键参数的更改得到社区的批准。以下是修改这些参数的方法：

### 通过治理提案

可以使用包装在治理提案中的 `MsgUpdateParams` 交易来更新参数。提案必须由治理模块账户提交。

更新多个参数的示例：
```json
{
  "title": "更新 Txfees 参数",
  "description": "调整费用市场参数以改善拥堵期间的网络性能",
  "messages": [
    {
      "@type": "/biyachain.txfees.v1beta1.MsgUpdateParams",
      "authority": "biya10d07y265gmmuvt4z0w9aw880jnsr700jvss730",  // 治理模块账户
      "params": {
        "max_gas_wanted_per_tx": "100000000",             // 将每笔交易的最大 gas 增加到 100M
        "min_gas_price": "200000000",                     // 将最低 gas 价格增加到 200M BIYA
        "default_base_fee_multiplier": "2.0",             // 将默认乘数增加到 2.0
        "max_block_change_rate": "0.15",                  // 将最大变化率增加到 15%
        "target_block_space_percent_rate": "0.75",        // 将目标利用率增加到 75%
        "recheck_fee_low_base_fee": "3.5",               // 增加低基础费用重新检查阈值
        // ... 其他参数保持不变 ...
      }
    }
  ],
  "deposit": "1000000000000000000biya"  // 示例存款
}
```

### 参数验证

更新参数时：
1. 必须在更新消息中提供所有参数（未更改的参数应保持其当前值）
2. 在应用之前验证参数：
   - 数值必须为正数
   - 乘数和速率必须是有效的小数
   - 阈值必须保持逻辑关系（例如，`MinGasPrice` ≤ 默认基础费用 ≤ 最大基础费用）

### 查询当前参数

您可以使用 gRPC 端点查询当前参数值：
```bash
/biyachain/txfees/v1beta1/params
```

您也可以使用 CLI 查询当前 EIP-1559 基础费用：
```bash
biyachaind query txfees base-fee
```

### 查询当前基础费用

可以通过多个接口查询当前 EIP-1559 基础费用：

#### CLI
```bash
biyachaind query txfees base-fee
```

#### gRPC
可以使用 `GetEipBaseFee` RPC 方法查询基础费用：

```protobuf
// 请求
message QueryEipBaseFeeRequest {
}

// 响应
message QueryEipBaseFeeResponse {
  EipBaseFee base_fee = 1;
}

message EipBaseFee {
  string base_fee = 1 [(gogoproto.customtype) = "cosmossdk.io/math.LegacyDec", (gogoproto.nullable) = false];
}
```

使用 `grpcurl` 的示例：
```bash
grpcurl -plaintext localhost:9090 biyachain.txfees.v1beta1.Query/GetEipBaseFee

# 与 IBC 中继器和钱包兼容的 Osmosis 风格路径
grpcurl -plaintext localhost:9090 osmosis.txfees.v1beta1.Query/GetEipBaseFee
```



服务定义：
```protobuf
service Query {
  // 返回当前费用市场 EIP 基础费用
  rpc GetEipBaseFee(QueryEipBaseFeeRequest) returns (QueryEipBaseFeeResponse) {
    option (google.api.http).get = "/biyachain/txfees/v1beta1/cur_eip_base_fee";
  }
}
```

#### gRPC-Gateway (REST)
```bash
curl -X GET "http://localhost:1317/biyachain/txfees/v1beta1/cur_eip_base_fee"
```

#### 响应格式
响应将包含以 BIYA 为单位的当前基础费用。示例：
```json
{
  "base_fee": {
    "base_fee": "160000000"
  }
}
```

注意：基础费用以十进制字符串形式返回。当 `Mempool1559Enabled` 为 false 时，这将返回 `MinGasPrice` 值。
