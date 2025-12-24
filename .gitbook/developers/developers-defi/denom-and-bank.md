# 代币单位元数据

`denom` 是代币在 Biya Chain 的 `Bank` 模块中的表示方式。这些资产可用于交易、在交易所模块上创建新市场、参与拍卖、转账到其他地址等。

对于开发者和交易者来说，最大的痛点之一是获取这些 `denoms` 的元数据。这些元数据包括 `decimals`（小数位）、`symbol`（符号）、`name`（名称）等。

本指南展示了如何直接从 `biyachain-lists` 存储库获取 `denom` 元数据并将其映射到您的 `denom`。您还可以使用这种方法为现货和衍生品市场映射 `denoms` 的元数据。

## Biya Chain Lists

`biyachain-lists` 是一个公共存储库，保存 Biya Chain 上所有代币的元数据信息。它是这类特定信息最新和最可靠的来源。您可以通过为此存储库创建 PR 来提交您的代币信息。请务必正确指定字段。特别是，`"denom"` 字段（阅读关于[代币标准](../../users/tokens/)）应根据代币标准具有相应的 `ibc`、`peggy` 和 `factory` 前缀。

链上新 `denoms` 的元数据每 30 分钟自动获取一次，并重新生成 `json` 文件。

您可以前往 [https://github.com/biya-coin/biyachain-lists/tree/master/json/tokens](https://github.com/biya-coin/biyachain-lists/tree/master/json/tokens) 文件夹，根据环境下载元数据：

1. [主网原始 JSON](https://raw.githubusercontent.com/biya-coin/biyachain-lists/refs/heads/master/json/tokens/mainnet.json)
2. [测试网原始 JSON](https://github.com/biya-coin/biyachain-lists/blob/master/json/tokens/testnet.json)

获得 JSON 后，您必须将元数据与特定的 `denom` 映射。

此元数据信息的接口为

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

### 银行余额

假设您获取特定地址的银行余额（如下面使用 TypeScript 的示例所示），您可以轻松地将其映射到上述 JSON 文件中的元数据信息

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

现在，您的银行余额拥有您需要的所有元数据信息（包括 `decimals`、`symbol`、`name`、`logo` 等）。

### 现货市场

与银行余额类似，您可以使用相同的方法将现货市场中的 `denoms` 与其元数据映射。

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

与银行余额类似，您可以使用相同的方法将衍生品市场中的 `denom` 与其元数据映射。

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
