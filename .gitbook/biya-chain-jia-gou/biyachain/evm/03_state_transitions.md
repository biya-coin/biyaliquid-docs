<!--
order: 3
-->

# 状态转换

`x/evm` 模块允许用户提交以太坊交易（`Tx`）并执行其包含的消息，以在给定状态上引发状态转换。

用户客户端提交交易以将其广播到网络。当交易在共识期间被包含在区块中时，它在服务器端执行。我们强烈建议理解 [Tendermint 共识引擎](https://docs.tendermint.com/master/introduction/what-is-tendermint.html#intro-to-abci) 的基础知识，以详细了解状态转换。

## 客户端

::: tip
👉 这基于 `eth_sendTransaction` JSON-RPC
:::

1. 用户通过可用的 JSON-RPC 端点之一使用以太坊兼容客户端或钱包（例如 Metamask、WalletConnect、Ledger 等）提交交易：
 a. eth（公共）命名空间：
     - `eth_sendTransaction`
     - `eth_sendRawTransaction`
 b. personal（私有）命名空间：
     - `personal_sendTransaction`
2. 在使用 `SetTxDefaults` 填充 RPC 交易以用默认值填充缺失的交易参数后，创建 `MsgEthereumTx` 实例
3. 使用 `ValidateBasic()` 验证（无状态）`Tx` 字段
4. 使用与发送者地址关联的密钥和来自 `ChainConfig` 的最新以太坊硬分叉（`London`、`Berlin` 等）对 `Tx` 进行**签名**
5. 使用 Cosmos Config 构建器从消息字段**构建**`Tx`
6. 在[同步模式](https://docs.cosmos.network/master/run-node/txs.html#broadcasting-a-transaction)中**广播**`Tx`，以确保等待 [`CheckTx`](https://docs.tendermint.com/master/introduction/what-is-tendermint.html#intro-to-abci) 执行响应。交易由应用程序使用 `CheckTx()` 进行验证，然后添加到共识引擎的内存池中。
7. JSON-RPC 用户收到包含交易字段的 [`RLP`](https://eth.wiki/en/fundamentals/rlp) 哈希的响应。此哈希与 SDK 交易使用的默认哈希不同，后者计算交易字节的 `sha256` 哈希。

## 服务器端

一旦在共识期间提交了包含 `Tx` 的区块，它就会在服务器端通过一系列 ABCI 消息应用到应用程序。

每个 `Tx` 由应用程序通过调用 [`RunTx`](https://docs.cosmos.network/master/core/baseapp.html#runtx) 处理。在对 `Tx` 中的每个 `sdk.Msg` 进行无状态验证后，`AnteHandler` 确认 `Tx` 是以太坊交易还是 SDK 交易。作为以太坊交易，其包含的消息然后由 `x/evm` 模块处理以更新应用程序的状态。

### AnteHandler

`anteHandler` 为每个交易运行。它检查 `Tx` 是否是以太坊交易，并将其路由到内部 ante 处理器。在这里，`Tx` 使用 EthereumTx 扩展选项进行处理，与普通 Cosmos SDK 交易不同。`antehandler` 为每个 `Tx` 运行一系列选项及其 `AnteHandle` 函数：

- `EthSetUpContextDecorator()` 从 cosmos-sdk 的 SetUpContextDecorator 改编，它通过将 gas 计量器设置为无限来忽略 gas 消耗
- `EthValidateBasicDecorator(evmKeeper)` 验证以太坊类型 Cosmos `Tx` 消息的字段
- `EthSigVerificationDecorator(evmKeeper)` 验证注册的链 ID 与消息上的链 ID 相同，并且签名者地址与消息上定义的地址匹配。它不会为 RecheckTx 跳过，因为它设置了 `From` 地址，这对其他 ante 处理器的工作至关重要。RecheckTx 中的失败将阻止交易被包含到区块中，特别是在 CheckTx 成功的情况下，在这种情况下用户将看不到错误消息。
- `EthAccountVerificationDecorator(ak, bankKeeper, evmKeeper)` 验证发送者余额大于总交易成本。如果账户不存在，即无法在存储中找到，账户将被设置到存储中。如果满足以下条件，此 AnteHandler 装饰器将失败：
    - 任何消息不是 MsgEthereumTx
    - from 地址为空
    - 账户余额低于交易成本
- `EthNonceVerificationDecorator(ak)` 验证交易 nonce 有效且等同于发送者账户的当前 nonce。
- `EthGasConsumeDecorator(evmKeeper)` 验证以太坊交易消息有足够的 gas 来覆盖内在 gas（仅在 CheckTx 期间），并且发送者有足够的余额来支付 gas 成本。交易的内在 gas 是交易在执行之前使用的 gas 数量。gas 是一个常数值加上交易提供的额外数据字节产生的任何成本。如果满足以下条件，此 AnteHandler 装饰器将失败：
    - 交易包含多个消息
    - 消息不是 MsgEthereumTx
    - 找不到发送者账户
    - 交易的 gas 限制低于内在 gas
    - 用户没有足够的余额来扣除交易费用（gas_limit * gas_price）
    - 交易或区块 gas 计量器耗尽 gas
- `CanTransferDecorator(evmKeeper, feeMarketKeeper)` 从消息创建 EVM 并调用 BlockContext CanTransfer 函数以查看地址是否可以执行交易。
- `EthIncrementSenderSequenceDecorator(ak)` 处理增加签名者（即发送者）的序列。如果交易是合约创建，nonce 将在交易执行期间增加，而不是在此 AnteHandler 装饰器内。

选项 `authante.NewMempoolFeeDecorator()`、`authante.NewTxTimeoutHeightDecorator()` 和 `authante.NewValidateMemoDecorator(ak)` 与 Cosmos `Tx` 相同。点击[这里](https://docs.cosmos.network/master/basics/gas-fees.html#antehandler)了解更多关于 `anteHandler` 的信息。

### EVM 模块

通过 `antehandler` 进行身份验证后，`Tx` 中的每个 `sdk.Msg`（在这种情况下是 `MsgEthereumTx`）被传递到 `x/evm` 模块中的消息处理器，并运行以下步骤：

1. 将 `Msg` 转换为以太坊 `Tx` 类型
2. 使用 `EVMConfig` 应用 `Tx` 并尝试执行状态转换，只有在交易不失败的情况下才会持久化（提交）到底层 KVStore：
    1. 确认 `EVMConfig` 已创建
    2. 使用来自 `EVMConfig` 的链配置值创建以太坊签名者
    3. 将以太坊交易哈希设置到（非永久）临时存储中，以便它也可用于 StateDB 函数
    4. 生成新的 EVM 实例
    5. 确认合约创建（`EnableCreate`）和合约执行（`EnableCall`）的 EVM 参数已启用
    6. 应用消息。如果 `To` 地址为 `nil`，使用代码作为部署代码创建新合约。否则使用给定输入作为参数调用给定地址的合约
    7. 计算 evm 操作使用的 gas
3. 如果 `Tx` 应用成功
    1. 执行 EVM `Tx` 后处理钩子。如果钩子返回错误，回滚整个 `Tx`
    2. 根据以太坊 gas 会计规则退还 gas
    3. 使用从交易生成的日志更新区块布隆过滤器值
    4. 为交易字段和交易日志发出 SDK 事件
