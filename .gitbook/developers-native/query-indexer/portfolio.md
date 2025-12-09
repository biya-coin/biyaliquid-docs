# Portfolio

Example code snippets to query the indexer for portfolio module related data.

## Using gRPC

### Fetch portfolio based on biyaliquid address, such as bank balances and subaccount balances

<pre class="language-ts"><code class="lang-ts"><strong>import { IndexerGrpcAccountPortfolioApi } from '@biya-coin/sdk-ts'
</strong>import { getNetworkEndpoints, Network } from '@biya-coin/networks'

const endpoints = getNetworkEndpoints(Network.Testnet)
const indexerGrpcAccountPortfolioApi = new IndexerGrpcAccountPortfolioApi(
  endpoints.indexer,
)

const biyaliquidAddress = 'biya...'

const portfolio = await indexerGrpcAccountPortfolioApi.fetchAccountPortfolioBalances(
  biyaliquidAddress,
)

console.log(portfolio)
</code></pre>
