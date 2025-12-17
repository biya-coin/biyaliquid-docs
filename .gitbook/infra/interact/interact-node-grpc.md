# 使用 gRPC 与节点交互

Protobuf 生态系统为不同用例开发了工具，包括从 `*.proto` 文件生成各种语言的代码。这些工具使得客户端可以轻松构建。通常，客户端连接（即传输层）可以轻松插入和替换。让我们探索一种流行的传输方法：gRPC。

由于代码生成库很大程度上取决于您自己的技术栈，我们仅提供两种替代方案：

* `grpcurl` 用于通用调试和测试
* 通过 Go、Python 或 TS 进行程序化交互

## grpcurl

[grpcurl](https://github.com/fullstorydev/grpcurl) 类似于 `curl`，但用于 gRPC。它也可作为 Go 库使用，但我们仅将其用作 CLI 命令进行调试和测试。请按照前面链接中的说明进行安装。

假设您有一个本地节点正在运行（本地网络或连接到实时网络），您应该能够运行以下命令来列出可用的 Protobuf 服务。您可以将 `localhost:9090` 替换为另一个节点的 gRPC 服务器端点，该端点配置在 `app.toml` 中的 `grpc.address` 字段下：

```bash
grpcurl -plaintext localhost:9090 list
```

您应该会看到一个 gRPC 服务列表，例如 `cosmos.bank.v1beta1.Query`。这称为反射，它是一个 Protobuf 端点，返回所有可用端点的描述。每个服务代表不同的 Protobuf 服务，每个服务都公开多个可以查询的 RPC 方法。

为了获取服务的描述，您可以运行以下命令：

```bash
# Service we want to inspect
grpcurl \
    localhost:9090 \
    describe cosmos.bank.v1beta1.Query                  
```

也可以执行 RPC 调用来查询节点信息：

```bash
grpcurl \
    -plaintext
    -d '{"address":"$MY_VALIDATOR"}' \
    localhost:9090 \
    cosmos.bank.v1beta1.Query/AllBalances
```

## 使用 grpcurl 查询历史状态

您还可以通过向查询传递一些 [gRPC 元数据](https://github.com/grpc/grpc-go/blob/master/Documentation/grpc-metadata.md) 来查询历史数据：`x-cosmos-block-height` 元数据应包含要查询的区块。使用上面的 grpcurl，命令如下所示：

```bash
grpcurl \
    -plaintext \
    -H "x-cosmos-block-height: 279256" \
    -d '{"address":"$MY_VALIDATOR"}' \
    localhost:9090 \
    cosmos.bank.v1beta1.Query/AllBalances
```

假设该区块的状态尚未被节点修剪，此查询应返回非空响应。

## 发送交易

使用 gRPC 和 REST 发送交易需要一些额外的步骤：生成交易、签名，最后广播。

您可以在 [transactions](../defi/transactions.md "mention") 中了解更多信息。
