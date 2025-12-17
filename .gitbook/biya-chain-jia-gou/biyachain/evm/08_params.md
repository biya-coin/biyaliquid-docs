<!--
order: 8
-->

# 参数

evm 模块包含以下参数：

## Params

| 键            | 类型        | 默认值   |
| -------------- | ----------- |-----------------|
| `EVMDenom`     | string      | `"biya"`         |
| `EnableCreate` | bool        | `true`          |
| `EnableCall`   | bool        | `true`          |
| `ExtraEIPs`    | []int       | TBD             |
| `ChainConfig`  | ChainConfig | 参见 ChainConfig |

## EVM 代币单位

evm 代币单位参数定义用于 EVM 状态转换和 EVM 消息 gas 消耗的代币单位。

例如，在以太坊上，`evm_denom` 将是 `ETH`。为了与以太坊保持一致，Biya Chain 使用 Atto 作为其基础代币单位。本质上，1（atto）biya 等于 `1x10⁻¹⁸ BIYA`，与以太坊的代币单位一致，其中 1 wei 等于 1x10⁻¹⁸ ETH。就精度而言，`BIYA` 和 `ETH` 共享相同的值，即 `1 BIYA = 10^18 biya` 和 `1 ETH = 10^18 wei`。

## 启用创建

启用创建参数切换使用 `vm.Create` 函数的状态转换。当参数被禁用时，它将阻止所有合约创建功能。

## 启用转账

启用转账切换使用 `vm.Call` 函数的状态转换。当参数被禁用时，它将阻止账户之间的转账和执行智能合约调用。

## 额外 EIPs

额外 EIP 参数定义了可在以太坊 VM `Config` 上激活的以太坊改进提案（**[EIPs](https://ethereum.org/en/eips/)**）集合，这些提案应用自定义跳转表。

::: tip
注意：其中一些 EIP 已经由链配置启用，具体取决于硬分叉编号。
:::

支持的可激活 EIP 包括：

- **[EIP 1344](https://eips.ethereum.org/EIPS/eip-1344)**
- **[EIP 1884](https://eips.ethereum.org/EIPS/eip-1884)**
- **[EIP 2200](https://eips.ethereum.org/EIPS/eip-2200)**
- **[EIP 2315](https://eips.ethereum.org/EIPS/eip-2315)**
- **[EIP 2929](https://eips.ethereum.org/EIPS/eip-2929)**
- **[EIP 3198](https://eips.ethereum.org/EIPS/eip-3198)**
- **[EIP 3529](https://eips.ethereum.org/EIPS/eip-3529)**

## 链配置

`ChainConfig` 是一个 protobuf 包装类型，包含与 go-ethereum `ChainConfig` 参数相同的字段，但使用 `*sdk.Int` 类型而不是 `*big.Int`。

默认情况下，除 `ConstantinopleBlock` 之外的所有区块配置字段在创世时（高度 0）启用。

### ChainConfig 默认值

| 名称                | 默认值                                                        |
| ------------------- | -------------------------------------------------------------------- |
| HomesteadBlock      | 0                                                                    |
| DAOForkBlock        | 0                                                                    |
| DAOForkSupport      | `true`                                                               |
| EIP150Block         | 0                                                                    |
| EIP150Hash          | `0x0000000000000000000000000000000000000000000000000000000000000000` |
| EIP155Block         | 0                                                                    |
| EIP158Block         | 0                                                                    |
| ByzantiumBlock      | 0                                                                    |
| ConstantinopleBlock | 0                                                                    |
| PetersburgBlock     | 0                                                                    |
| IstanbulBlock       | 0                                                                    |
| MuirGlacierBlock    | 0                                                                    |
| BerlinBlock         | 0                                                                    |
| LondonBlock         | 0                                                                    |
| ArrowGlacierBlock   | 0                                                                    |
| GrayGlacierBlock    | 0                                                                    |
| MergeNetsplitBlock  | 0                                                                    |
| ShanghaiTime        | 0                                                                    |
| CancunTime          | 0                                                                    |
| PragueTime          | 0                                                                    |
