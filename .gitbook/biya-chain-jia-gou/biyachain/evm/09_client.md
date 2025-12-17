<!--
order: 9
-->

# 客户端

用户可以使用 CLI、JSON-RPC、gRPC 或 REST 查询和与 `evm` 模块交互。

## CLI

下面列出了使用 `x/evm` 模块添加的 `biyachaind` 命令列表。您可以使用 `biyachaind -h` 命令获取完整列表。

### 查询

`query` 命令允许用户查询 `evm` 状态。

**`code`**

允许用户查询给定地址的智能合约代码。

```go
biyachaind query evm code ADDRESS [flags]
```

```bash
# 示例
$ biyachaind query evm code 0x7bf7b17da59880d9bcca24915679668db75f9397

# 输出
code: "0xef616c92f3cfc9e92dc270d6acff9cea213cecc7020a76ee4395af09bdceb4837a1ebdb5735e11e7d3adb6104e0c3ac55180b4ddf5e54d022cc5e8837f6a4f971b"
```

**`storage`**

允许用户查询给定键和高度的账户存储。

```bash
biyachaind query evm storage ADDRESS KEY [flags]
```

```bash
# 示例
$ biyachaind query evm storage 0x0f54f47bf9b8e317b214ccd6a7c3e38b893cd7f0 0 --height 0

# 输出
value: "0x0000000000000000000000000000000000000000000000000000000000000000"
```

### 交易

`tx` 命令允许用户与 `evm` 模块交互。

**`raw`**

允许用户从原始以太坊交易构建 cosmos 交易。

```bash
biyachaind tx evm raw TX_HEX [flags]
```

```bash
# 示例
$ biyachaind tx evm raw 0xf9ff74c86aefeb5f6019d77280bbb44fb695b4d45cfe97e6eed7acd62905f4a85034d5c68ed25a2e7a8eeb9baf1b84

# 输出
value: "0x0000000000000000000000000000000000000000000000000000000000000000"
```

## JSON-RPC

有关 Ethermint 上支持的 JSON-RPC 方法和命名空间的概述，请参阅 [https://docs.biyachain.zone/basics/json_rpc.html](https://docs.biyachain.zone/basics/json_rpc.html)

## gRPC

### 查询

| 动词   | 方法                                               | 描述                                                                |
| ------ | ---------------------------------------------------- | -------------------------------------------------------------------------- |
| `gRPC` | `biyachain.evm.v1.Query/Account`                     | 获取以太坊账户                                                    |
| `gRPC` | `biyachain.evm.v1.Query/CosmosAccount`               | 获取以太坊账户的 Cosmos 地址                                   |
| `gRPC` | `biyachain.evm.v1.Query/ValidatorAccount`            | 从验证者共识地址获取以太坊账户               |
| `gRPC` | `biyachain.evm.v1.Query/Balance`                     | 获取单个 EthAccount 的 EVM 代币单位余额。         |
| `gRPC` | `biyachain.evm.v1.Query/Storage`                     | 获取单个账户的所有代币余额                          |
| `gRPC` | `biyachain.evm.v1.Query/Code`                        | 获取单个账户的所有代币余额                          |
| `gRPC` | `biyachain.evm.v1.Query/Params`                      | 获取 x/evm 模块的参数                                         |
| `gRPC` | `biyachain.evm.v1.Query/EthCall`                     | 实现 eth_call rpc api                                            |
| `gRPC` | `biyachain.evm.v1.Query/EstimateGas`                 | 实现 eth_estimateGas rpc api                                     |
| `gRPC` | `biyachain.evm.v1.Query/TraceTx`                     | 实现 debug_traceTransaction rpc api                              |
| `gRPC` | `biyachain.evm.v1.Query/TraceBlock`                  | 实现 debug_traceBlockByNumber 和 debug_traceBlockByHash rpc api |
| `GET`  | `/biyachain/evm/v1/account/{address}`                | 获取以太坊账户                                                    |
| `GET`  | `/biyachain/evm/v1/cosmos_account/{address}`         | 获取以太坊账户的 Cosmos 地址                                   |
| `GET`  | `/biyachain/evm/v1/validator_account/{cons_address}` | 从验证者共识地址获取以太坊账户               |
| `GET`  | `/biyachain/evm/v1/balances/{address}`               | 获取单个 EthAccount 的 EVM 代币单位余额。         |
| `GET`  | `/biyachain/evm/v1/storage/{address}/{key}`          | 获取单个账户的所有代币余额                          |
| `GET`  | `/biyachain/evm/v1/codes/{address}`                  | 获取单个账户的所有代币余额                          |
| `GET`  | `/biyachain/evm/v1/params`                           | 获取 x/evm 模块的参数                                         |
| `GET`  | `/biyachain/evm/v1/eth_call`                         | 实现 eth_call rpc api                                            |
| `GET`  | `/biyachain/evm/v1/estimate_gas`                     | 实现 eth_estimateGas rpc api                                     |
| `GET`  | `/biyachain/evm/v1/trace_tx`                         | 实现 debug_traceTransaction rpc api                              |
| `GET`  | `/biyachain/evm/v1/trace_block`                      | 实现 debug_traceBlockByNumber 和 debug_traceBlockByHash rpc api |

### 交易

| 动词   | 方法                            | 描述                     |
| ------ | --------------------------------- | ------------------------------- |
| `gRPC` | `biyachain.evm.v1.Msg/EthereumTx` | 提交以太坊交易 |
| `POST` | `/biyachain/evm/v1/ethereum_tx`   | 提交以太坊交易 |
