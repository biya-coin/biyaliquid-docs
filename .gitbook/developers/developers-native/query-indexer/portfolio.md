# Portfolio

查询索引器中 portfolio 模块相关数据的示例代码片段。

## 使用 gRPC

### 根据 biyachain 地址获取投资组合，如银行余额和子账户余额

<pre class="language-ts"><code class="lang-ts"><strong>import { IndexerGrpcAccountPortfolioApi } from '@biya-coin/sdk-ts'
</strong>import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const indexerGrpcAccountPortfolioApi = new IndexerGrpcAccountPortfolioApi(
  endpoints.indexer,
)

const biyachainAddress = 'biya...'

const portfolio = await indexerGrpcAccountPortfolioApi.fetchAccountPortfolioBalances(
  biyachainAddress,
)

console.log(portfolio)
</code></pre>
