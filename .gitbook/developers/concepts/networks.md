# 网络

{% hint style="warning" %}
最新的公共端点可以在[这里](https://docs.biyachain.network/develop/public-endpoints/#mainnet)找到。我们<mark style="color:red;">**不建议**</mark>在具有高使用量/流量的应用程序的生产环境中使用它们。有成千上万的开发者使用公共基础设施，我们无法保证 100% 的正常运行时间和可靠性。\
\
如果您仍然选择使用**公共**网络，可以使用 `@biya-coin/networks` 包中的 `Network.{Mainnet|Testnet}Sentry`。
{% endhint %}

在 Biya Chain 上构建 dApps 需要接入不同的环境和网络，以便您可以轻松测试您的 dApp。作为 `biyachain-ts` monorepo 的一部分，我们有 `@biya-coin/networks` 包，允许开发者轻松访问预定义的环境以连接到 Biya Chain 的不同部分。

此包导出了两个关键函数：

* `export function getNetworkEndpoints(network: Network): NetworkEndpoints`
* `export function getEndpointsForNetwork(network: Network): OldNetworkEndpoints`
* `export function getNetworkInfo(network: Network): ChainInfo`

第一个函数 `getNetworkEndpoints` 返回一组预定义的端点，开发者可以根据需要使用。以下是此函数返回的接口：

```ts
export type NetworkEndpoints = {
  indexer: string // the grpc-web port of the indexer API service
  grpc: string // the grpc-web port of the sentry node
  rest: string // the REST endpoint of the sentry node
  rpc?: string // the REST endpoint of the Tendermint RPC
}

/** @deprecated */
export type OldNetworkEndpoints = {
  exchangeApi: string // @deprecated - the grpc-web port of the exchange API service
  indexerApi: string // the grpc-web port of the indexer API service
  sentryGrpcApi: string // the grpc-web port of the sentry node
  sentryHttpApi: string // the REST endpoint of the sentry node
  tendermintApi?: string // the REST endpoint of the Tendermint RPC
  chronosApi?: string // the REST endpoint of the chronos API service
  exchangeWeb3GatewayApi?: string // the grpc-web port of the web3-gateway service API
}
```

让我们解释这些端点及其含义：

* `indexer` 是 [**grpc-web**](https://github.com/grpc/grpc-web) 端点，我们可以使用它连接到 `exchange/indexer` 服务，该服务监听来自链的事件，处理事件，并将数据存储到 MongoDB 中，这样提供数据比直接从链本身查询更容易且性能更高，
* `grpc` 是 [**grpc-web**](https://github.com/grpc/grpc-web) 端点，我们可以使用它连接到哨兵节点。哨兵节点是链的只读（和轻量）版本，我们可以使用它直接从链查询数据。
* `rest` 是 REST 端点，我们可以使用它连接到哨兵节点。
* `rpc` 是 REST 端点，我们可以使用它连接到 Tendermint RPC，

`getNetworkInfo` 导出这些端点以及我们想要的 `Network` 的 `chainId` 和默认 `fee`。

{% hint style="info" %}
将 TypeScript SDK 与您的基础设施（端点）一起使用意味着您必须在服务器中设置 `grpc-web` 代理。要了解更多信息，请参考[此文档](https://github.com/grpc/grpc-web?tab=readme-ov-file#2-run-the-server-and-proxy)。
{% endhint %}
