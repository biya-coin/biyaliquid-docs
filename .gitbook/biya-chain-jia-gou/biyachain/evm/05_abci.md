<!--
order: 5
-->

# ABCI

应用程序区块链接口（ABCI）允许应用程序与 Tendermint 共识引擎交互。应用程序与 Tendermint 维护多个独立的 ABCI 连接。与 `x/evm` 最相关的是[提交时的共识连接](https://docs.tendermint.com/v0.35/spec/abci/apps.html#consensus-connection)。此连接负责区块执行并调用函数 `InitChain`（包含 `InitGenesis`）、`BeginBlock`、`DeliverTx`、`EndBlock`、`Commit`。`InitChain` 仅在首次启动新区块链时调用，`DeliverTx` 为区块中的每个交易调用。

## InitGenesis

`InitGenesis` 通过将 `GenesisState` 字段设置到存储中来初始化 EVM 模块创世状态。特别是它设置参数和创世账户（状态和代码）。

## ExportGenesis

`ExportGenesis` ABCI 函数导出 EVM 模块的创世状态。特别是，它检索所有账户及其字节码、余额和存储、交易日志以及 EVM 参数和链配置。

## BeginBlock

EVM 模块 `BeginBlock` 逻辑在处理来自交易的状态转换之前执行。此函数的主要目标是：

- 为当前区块设置上下文，以便在 EVM 状态转换期间调用 `StateDB` 函数之一时，区块头、存储、gas 计量器等可用于 `Keeper`。
- 设置 EIP155 `ChainID` 编号（从完整链 ID 获取），以防在 `InitChain` 期间之前未设置

## EndBlock

EVM 模块 `EndBlock` 逻辑在执行来自交易的所有状态转换之后发生。此函数的主要目标是：

- 发出区块布隆事件
    - 这是为了 Web3 兼容性，因为以太坊区块头包含此类型作为字段。JSON-RPC 服务使用此事件查询从 Tendermint 区块头构造以太坊区块头。
    - 从临时存储获取区块布隆过滤器值，然后发出
