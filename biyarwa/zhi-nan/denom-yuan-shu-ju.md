# Denom 元数据

一个 `denom` 是 Biyachain 的`Bank`模块中如何表示代币的方式。这些资产可以用于交易、在交易模块上创建新市场、参与拍卖、转移到其他地址等。

对于开发者和交易者来说，最大的痛点之一就是获取这些 `denoms` 的元数据。元数据包括小数位数(`decimals`)、符号(`symbol`)、名称(`name`)等。

本指南将展示如何直接从 `biyachain-lists` 仓库获取 `denom` 元数据并将其映射到您的 `denom`。您还可以使用这种方法来映射现货和衍生品市场的 `denom's` 元数据。

## Biyachain Lists

`biyachain-lists` 是一个公开的仓库，保存了 Biyachain 上所有代币的元数据。它是该信息的最新和最可靠来源。您可以通过为此仓库创建一个 PR 来提交您的代币信息。确保正确指定字段，特别是 "`denom`" 字段（请阅读[代币标准](../kuai-su-ru-men/dai-bi-biao-zhun/)），该字段应根据代币标准使用相应的 `ibc`、`peggy` 和 `factory` 前缀。

元数据每 30 分钟自动从链上获取新 `denoms`，并重新生成 `json` 文件。

您可以访问 [https://github.com/InjectiveLabs/injective-lists/tree/master/json/tokens](https://github.com/InjectiveLabs/injective-lists/tree/master/json/tokens) 文件夹，基于环境下载元数据。

1. [Mainnet Raw JSON](https://raw.githubusercontent.com/InjectiveLabs/injective-lists/refs/heads/master/json/tokens/mainnet.json)
2. [Testnet Raw JSON](https://github.com/InjectiveLabs/injective-lists/blob/master/json/tokens/testnet.json)

一旦您获得了 JSON 文件，您需要将元数据与特定的 `denom` 映射。\
该元数据的接口如下：

```typescript
export interface Token {
  name: string
  logo: string
  symbol: string
  decimals: number
  coinGeckoId: string
  denom: string
  address: string
  tokenType: string
  tokenVerification: string
}
```

### Bank 余额

假设您获取了某个地址的`Bank`余额（如下例所示，使用 TypeScript），您可以轻松地将其映射到上述 JSON 文件中的元数据。

```typescript
import { config } from "dotenv";
import {
  ChainGrpcBankApi,
  IndexerGrpcAccountPortfolioApi,
} from "@biya-coin/sdk-ts";
import { getNetworkEndpoints, Network } from "@biya-coin/networks";

config();

/** Querying Example */
(async () => {
  const endpoints = getNetworkEndpoints(Network.MainnetSentry);
  const chainGrpcBankApi = new ChainGrpcBankApi(endpoints.grpc);

  const biyachainAddress = "biya...";
  const { balances } = chainGrpcBankApi.fetchBalances(biyachainAddress);

  console.log(bankBalances);

 const metadata = JSON.parse(await readFile("./mainnet.json", "utf8")) as {
    denom: string;
    address: string;
    decimals: string;
    logo: string;
    name: string;
    tokenType: string;
    coinGeckoId: string
  }[];
  const balances = bankBalances.map((balance) => {
    const meta = metadata.find((m) => m.denom === balance.denom);

    return {
      ...balance,
      ...meta,
    };
  }
  
  console.log(balances)
})();
```

现在，您的银行余额包含了所有您需要的元数据（包括小数位(`decimals`)、符号(`symbol`)、名称(`namename`)、logo 等）。

### 现货市场

与银行余额类似，您可以使用相同的方法将现货市场中的代币 `denom` 映射到其元数据。

```typescript
import { config } from "dotenv";
import { IndexerGrpcSpotApi } from "@biya-coin/sdk-ts";
import { getNetworkEndpoints, Network } from "@biya-coin/networks";
import { readFile } from "fs/promises";

config();

/** Querying Example */
(async () => {
  const endpoints = getNetworkEndpoints(Network.Testnet);
  const indexerGrpcSpotApi = new IndexerGrpcSpotApi(endpoints.indexer);

  const markets = await indexerGrpcSpotApi.fetchMarkets();

  console.log(markets);

  const metadata = JSON.parse(await readFile("./mainnet.json", "utf8")) as {
    denom: string;
    address: string;
    decimals: string;
    logo: string;
    name: string;
    tokenType: string;
    coinGeckoId: string;
  }[];
  const marketsWithMetadata = markets.map((market) => {
    const baseTokenMetadata = metadata.find(
      (m) => m.denom === market.baseDenom
    );
    const quoteTokenMetadata = metadata.find(
      (m) => m.denom === market.quoteDenom
    );

    return {
      ...market,
      baseTokenMetadata,
      quoteTokenMetadata,
    };
  });

  console.log(marketsWithMetadata);
})();
```

### 衍生品市场

与`Bank`余额类似，您可以使用相同的方法将衍生品市场中的代币 `denom` 映射到其元数据。

```typescript
import { config } from "dotenv";
import { IndexerGrpcDerivativeApi } from "@biya-coin/sdk-ts";
import { getNetworkEndpoints, Network } from "@biya-coin/networks";
import { readFile } from "fs/promises";

config();

/** Querying Example */
(async () => {
  const endpoints = getNetworkEndpoints(Network.Testnet);
  const indexerGrpcDerivativeApi = new IndexerGrpcDerivativeApi(endpoints.indexer);

  const markets = await indexerGrpcDerivativeApi.fetchMarkets();

  console.log(markets);

  const metadata = JSON.parse(await readFile("./mainnet.json", "utf8")) as {
    denom: string;
    address: string;
    decimals: string;
    logo: string;
    name: string;
    tokenType: string;
    coinGeckoId: string;
  }[];
  const marketsWithMetadata = markets.map((market) => {
    const baseTokenMetadata = metadata.find(
      (m) => m.denom === market.baseDenom
    );

    return {
      ...market,
      quoteTokenMetadata,
    };
  });

  console.log(marketsWithMetadata);
})();
```
