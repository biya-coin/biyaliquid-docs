<!--
order: 1
-->

# 概念

## EVM

以太坊虚拟机（EVM）是一个计算引擎，可以被视为由数千台运行以太坊客户端的连接计算机（节点）维护的单一实体。作为虚拟机（[VM](https://en.wikipedia.org/wiki/Virtual_machine)），EVM 负责确定性地计算状态变化，无论其环境（硬件和操作系统）如何。这意味着每个节点在给定相同的起始状态和交易（tx）时必须得到完全相同的结果。

EVM 被认为是以太坊协议中处理[智能合约](https://ethereum.org/en/developers/docs/smart-contracts/)部署和执行的部分。为了明确区分：

* 以太坊协议描述了一个区块链，其中所有以太坊账户和智能合约都存在于其中。它在链中的任何给定区块只有一个规范状态（一个数据结构，保存所有账户）。
* 然而，EVM 是定义从区块到区块计算新有效状态规则的[状态机](https://en.wikipedia.org/wiki/Finite-state_machine)。它是一个隔离的运行时，这意味着在 EVM 内部运行的代码无法访问网络、文件系统或其他进程（不是外部 API）。

`x/evm` 模块将 EVM 实现为 Cosmos SDK 模块。它允许用户通过提交以太坊交易并在给定状态上执行其包含的消息来与 EVM 交互，以引发状态转换。

### 状态

以太坊状态是一个数据结构，实现为 [Merkle Patricia Trie](https://en.wikipedia.org/wiki/Merkle_tree)，保存链上的所有账户。EVM 对此数据结构进行更改，产生具有不同状态根的新状态。因此，以太坊可以被视为一个状态链，通过使用 EVM 在区块中执行交易，从一个状态转换到另一个状态。一个新的交易区块可以通过其区块头（父哈希、区块号、时间戳、随机数、收据等）来描述。

### 账户

在给定地址的状态中可以存储两种类型的账户：

* **外部拥有账户（EOA）**：具有 nonce（交易计数器）和余额
* **智能合约**：具有 nonce、余额、（不可变的）代码哈希、存储根（另一个 Merkle Patricia Trie）

智能合约就像区块链上的常规账户一样，另外还以以太坊特定的二进制格式存储可执行代码，称为 **EVM 字节码**。它们通常用以太坊高级语言（如 Solidity）编写，编译为 EVM 字节码，并通过使用以太坊客户端提交交易部署在区块链上。

### 架构

EVM 作为基于堆栈的机器运行。它的主要架构组件包括：

* 虚拟 ROM：处理交易时将合约代码拉入此只读内存
* 机器状态（易失性）：随着 EVM 运行而改变，在处理每个交易后被清除
  * 程序计数器（PC）
  * Gas：跟踪使用了多少 gas
  * 堆栈和内存：计算状态变化
* 访问账户存储（持久性）

### 使用智能合约的状态转换

通常智能合约公开一个公共 ABI，这是用户可以与合约交互的支持方式列表。要与合约交互并引发状态转换，用户将提交一个携带任意数量 gas 的交易和一个根据 ABI 格式化的数据负载，指定交互类型和任何附加参数。当收到交易时，EVM 使用交易负载执行智能合约的 EVM 字节码。

### 执行 EVM 字节码

合约的 EVM 字节码由基本操作（加法、乘法、存储等）组成，称为 **操作码**。每个操作码执行都需要 gas，需要用交易支付。因此，EVM 被认为是准图灵完备的，因为它允许任意计算，但合约执行期间的计算量限制为交易中提供的 gas 数量。每个操作码的 [**gas 成本**](https://www.evm.codes/) 反映了在实际计算机硬件上运行这些操作的成本（例如 `ADD = 3gas` 和 `SSTORE = 100gas`）。要计算交易的 gas 消耗，gas 成本乘以 **gas 价格**，这可能会根据当时网络的需求而变化。如果网络负载很重，您可能需要支付更高的 gas 价格才能执行交易。如果达到 gas 限制（gas 耗尽异常），则不会应用对以太坊状态的任何更改，除了发送者的 nonce 增加和余额减少以支付浪费 EVM 时间的费用。

智能合约也可以调用其他智能合约。每次调用新合约都会创建 EVM 的新实例（包括新的堆栈和内存）。每次调用都将沙箱状态传递给下一个 EVM。如果 gas 耗尽，所有状态更改都会被丢弃。否则它们会被保留。

进一步阅读，请参考：

* [EVM](https://eth.wiki/concepts/evm/evm)
* [EVM 架构](https://cypherpunks-core.github.io/ethereumbook/13evm.html#evm_architecture)
* [什么是以太坊](https://ethdocs.org/en/latest/introduction/what-is-ethereum.html#what-is-ethereum)
* [操作码](https://www.ethervm.io/)

## Ethermint 作为 Geth 实现

Ethermint 是[以太坊协议的 Golang 实现](https://geth.ethereum.org/docs/getting-started)（Geth）作为 Cosmos SDK 模块的实现。Geth 包括 EVM 的实现来计算状态转换。查看 [go-ethereum 源代码](https://github.com/ethereum/go-ethereum/blob/master/core/vm/instructions.go) 以了解 EVM 操作码是如何实现的。就像 Geth 可以作为以太坊节点运行一样，Ethermint 可以作为节点运行，使用 EVM 计算状态转换。Ethermint 支持 Geth 的标准 [以太坊 JSON-RPC API](https://ethereum.org/en/developers/docs/apis/json-rpc/)，以便与 Web3 和 EVM 兼容。

### JSON-RPC

JSON-RPC 是一种无状态、轻量级的远程过程调用（RPC）协议。主要此规范定义了几个数据结构及其处理规则。它在传输方面是不可知的，因为概念可以在同一进程内、通过套接字、通过 HTTP 或在许多各种消息传递环境中使用。它使用 JSON（RFC 4627）作为数据格式。

#### JSON-RPC 示例：`eth_call`

JSON-RPC 方法 [`eth_call`](https://ethereum.org/en/developers/docs/apis/json-rpc/#eth_call) 允许您对合约执行消息。通常，您需要向 Geth 节点发送交易以将其包含在内存池中，然后节点之间相互传播，最终交易被包含在区块中并被执行。但是 `eth_call` 允许您向合约发送数据并查看会发生什么，而无需提交交易。

在 Geth 实现中，调用端点大致经过以下步骤：

1. `eth_call` 请求被转换为使用 `eth` 命名空间调用 `func (s *PublicBlockchainAPI) Call()` 函数
2. [`Call()`](https://github.com/ethereum/go-ethereum/blob/master/internal/ethapi/api.go#L982) 被给定交易参数、要调用的区块以及修改状态的可选覆盖。然后它调用 `DoCall()`
3. [`DoCall()`](https://github.com/ethereum/go-ethereum/blob/d575a2d3bc76dfbdefdd68b6cffff115542faf75/internal/ethapi/api.go#L891) 将参数转换为 `ethtypes.message`，实例化 EVM 并使用 `core.ApplyMessage` 应用消息
4. [`ApplyMessage()`](https://github.com/ethereum/go-ethereum/blob/d575a2d3bc76dfbdefdd68b6cffff115542faf75/core/state_transition.go#L180) 调用状态转换 `TransitionDb()`
5. [`TransitionDb()`](https://github.com/ethereum/go-ethereum/blob/d575a2d3bc76dfbdefdd68b6cffff115542faf75/core/state_transition.go#L275) 要么 `Create()` 新合约，要么 `Call()` 合约
6. [`evm.Call()`](https://github.com/ethereum/go-ethereum/blob/d575a2d3bc76dfbdefdd68b6cffff115542faf75/core/vm/evm.go#L168) 运行解释器 `evm.interpreter.Run()` 来执行消息。如果执行失败，状态会恢复到执行前拍摄的快照，并消耗 gas。
7. [`Run()`](https://github.com/ethereum/go-ethereum/blob/d575a2d3bc76dfbdefdd68b6cffff115542faf75/core/vm/interpreter.go#L116) 执行循环来执行操作码。

Biya Chain 的实现类似，并使用 Cosmos SDK 中包含的 gRPC 查询客户端：

1. `eth_call` 请求被转换为使用 `eth` 命名空间调用 `func (e *PublicAPI) Call` 函数
2. [`Call()`](https://github.com/biya-coin/biyachain-core/biyachain-chain/blob/main/rpc/namespaces/ethereum/eth/api.go#L639) 调用 `doCall()`
3. [`doCall()`](https://github.com/biya-coin/biyachain-core/biyachain-chain/blob/main/rpc/namespaces/ethereum/eth/api.go#L656) 将参数转换为 `EthCallRequest` 并使用 evm 模块的查询客户端调用 `EthCall()`。
4. [`EthCall()`](https://github.com/biya-coin/biyachain-core/biyachain-chain/blob/main/x/evm/keeper/grpc_query.go#L212) 将参数转换为 `ethtypes.message` 并调用 `ApplyMessageWithConfig()`
5. [`ApplyMessageWithConfig()`](https://github.com/biya-coin/biyachain-core/biyachain-chain/blob/d5598932a7f06158b7a5e3aa031bbc94eaaae32c/x/evm/keeper/state_transition.go#L341) 实例化 EVM 并使用 Geth 实现 `Create()` 新合约或 `Call()` 合约。

### StateDB

来自 [go-ethereum](https://github.com/ethereum/go-ethereum/blob/master/core/vm/interface.go) 的 `StateDB` 接口表示用于完整状态查询的 EVM 数据库。EVM 状态转换通过此接口启用，在 `x/evm` 模块中由 `Keeper` 实现。此接口的实现使 Ethermint 与 EVM 兼容。

## 共识引擎

使用 `x/evm` 模块的应用程序通过应用程序区块链接口（ABCI）与 Tendermint Core 共识引擎交互。应用程序和 Tendermint Core 一起形成运行完整区块链的程序，并将业务逻辑与去中心化数据存储相结合。

提交给 `x/evm` 模块的以太坊交易在执行并更改应用程序状态之前参与此共识过程。我们鼓励理解 [Tendermint 共识引擎](https://docs.tendermint.com/master/introduction/what-is-tendermint.html#intro-to-abci) 的基础知识，以便详细了解状态转换。

## 交易日志

在每个 `x/evm` 交易上，结果包含来自状态机执行的以太坊 `Log`，这些日志由 JSON-RPC Web3 服务器用于过滤查询和处理 EVM 钩子。

交易日志在交易执行期间存储在临时存储中，然后在交易处理完成后通过 cosmos 事件发出。它们可以通过 gRPC 和 JSON-RPC 查询。

## 区块布隆过滤器

布隆是每个区块的布隆过滤器值（以字节为单位），可用于过滤查询。区块布隆值存储在临时存储中，然后在 `EndBlock` 处理期间通过 cosmos 事件发出。它们可以通过 gRPC 和 JSON-RPC 查询。

::: tip
👉 **注意**：由于它们不存储在状态上，交易日志和区块布隆在升级后不会持久化。用户必须在升级后使用归档节点才能获取旧链事件。
:::
