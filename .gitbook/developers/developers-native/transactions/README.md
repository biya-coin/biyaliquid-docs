# 交易

_前置阅读：_ [Cosmos SDK 交易](https://docs.cosmos.network/main/learn/advanced/transactions)

Biya Chain 上的状态更改可以通过交易完成。用户创建交易，签署交易并将其广播到 Biya Chain。

当广播后，只有在每个验证都成功通过（这些验证包括签名验证、参数验证等）后，交易才会被包含在通过共识过程由网络批准的区块中。

### 消息

消息是交易中包含的指令，用于指定用户想要执行的状态更改。每个交易必须至少有一条消息。消息是特定于模块的对象，在它们所属的模块范围内触发状态转换。我们可以在同一个交易中打包多条消息。

有一个抽象类（_MsgBase_），我们从 `@biya-coin/sdk-ts` 导出，每条消息都扩展 `MsgBase` 接口，该接口具有几个映射功能：

* `toData` -> 将消息转换为简单的对象表示，
* `toProto` -> 返回消息的 proto 表示，
* `toDirectSign` -> 将消息转换为 proto 表示，
* `toAmino` -> 将消息转换为 amino 表示 + 类型，
* `toWeb3` -> `toAmino` 的替代方案，区别在于消息路径类型，
* `toEip712Types` -> 为消息生成 EIP712 类型，
* `toEip712` -> 生成消息 EIP712 值
* `toJSON` -> 将消息转换为 JSON 表示，

### 交易上下文

除了消息之外，每个交易都有上下文。这些详细信息包括 `fees`、`accountDetails`、`memo`、`signatures` 等。

### 交易流程

我们想要广播到 Biya Chain 的每个交易都有相同的流程。该流程包括三个步骤：准备、签署和广播交易。



### 主题

| 主题                                             | 描述                                                |
| ------------------------------------------------- | ---------------------------------------------------------- |
| [使用以太坊方法](ethereum.md)        | 准备/签署 EIP712 类型数据然后广播              |
| [使用 Cosmos 方法](cosmos.md) | 准备/签署/广播 Cosmos 交易                 |
| [使用私钥](private-key.md)             | 使用私钥准备/签署/广播 Cosmos 交易 |
| [Web3Gateway 微服务](web3-gateway.md)       | 支持费用委托的微服务               |
| [Msg Broadcaster](msgbroadcaster.md)              | 广播消息的抽象                      |

**可用的消息（和示例）可以在 Wiki 的核心模块部分找到。**
