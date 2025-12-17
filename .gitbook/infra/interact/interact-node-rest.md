# 使用 REST 端点与节点交互

Cosmos SDK 上的所有 gRPC 服务都通过 gRPC-gateway 提供更便捷的基于 REST 的查询。URL 路径格式基于 Protobuf 服务方法的完全限定名称，但可能包含小的自定义，以使最终 URL 看起来更符合习惯。例如，`cosmos.bank.v1beta1.Query/AllBalances` 方法的 REST 端点是 `GET /cosmos/bank/v1beta1/balances/{address}`。请求参数作为查询参数传递。

以下示例假设您使用 REST 端点与本地私有网络中的节点交互。您可以将域名更改为公共网络。

作为一个具体示例，用于查询余额的 `curl` 命令是：

```bash
curl \
    -X GET \
    -H "Content-Type: application/json" \
    http://localhost:1317/cosmos/bank/v1beta1/balances/$MY_VALIDATOR
```

请确保将 `localhost:1317` 替换为您节点的 REST 端点，该端点配置在 `api.address` 字段下。

所有可用 REST 端点的列表可作为 Swagger 规范文件提供；可以在 `localhost:1317/swagger` 查看。请确保在 `app.toml` 文件中将 `api.swagger` 字段设置为 true。

## 使用 REST 查询历史状态

使用 HTTP 头 `x-cosmos-block-height` 查询历史状态。例如，curl 命令如下所示：

```bash
curl \
    -X GET \
    -H "Content-Type: application/json" \
    -H "x-cosmos-block-height: 279256" \
    http://localhost:1317/cosmos/bank/v1beta1/balances/$MY_VALIDATOR
```

假设该区块的状态尚未被节点修剪，此查询应返回非空响应。

## 跨域资源共享 (CORS)

默认情况下不启用 [CORS 策略](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS) 以帮助提高安全性。如果您想使用 rest-server，我们建议您提供反向代理。这可以使用 [nginx](https://www.nginx.com/) 完成。出于测试和开发目的，`app.toml` 中有一个 `enabled-unsafe-cors` 字段。

## 发送交易

使用 gRPC 和 REST 发送交易需要一些额外的步骤：生成交易、签名，最后广播。

您可以在 [transactions](../defi/transactions.md "mention") 中了解更多信息。
