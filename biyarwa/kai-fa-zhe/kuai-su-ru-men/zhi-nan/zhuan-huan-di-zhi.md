# 转换地址

在本文档中，我们将概述一些示例，展示如何在不同格式和衍生路径之间转换地址。

### 转换 Hex <> Bech32 地址

正如我们在前面的 [钱包](https://biyaliquid.gitbook.io/biyaliquid-docs/kuai-su-ru-men/qian-bao)章节中提到的，Injective 地址与 Ethereum 地址是兼容的。你可以轻松地在这两种格式之间进行转换。

### 使用 TypeScript

你可以通过使用 `@biya-coin/sdk-ts` 包中的工具函数轻松地在 Biyachain 地址和 Ethereum 地址之间进行转换：

```typescript
import { getInjectiveAddress, getEthereumAddress } from '@biya-coin/sdk-ts'

const biyachainAddress = 'biya1...'
const ethereumAddress = '0x..'

console.log('Biyachain address from Ethereum address => ', getBiyachainAddress(ethereumAddress))
console.log('Ethereum address from Biyachain address => ', getEthereumAddress(biyachainAddress))
```

### **转换 Cosmos 地址 为 Biyachain 地址**

由于 Biyachain 使用的派生路径不同于默认的 Cosmos 派生路径，因此你需要账户的 publicKey 才能将 Cosmos publicAddress 转换为 Biyachain 地址。

### 使用 TypeScript

```typescript
import { config } from "dotenv";
import { ChainRestAuthApi, PublicKey } from "@biya-coin/sdk-ts";

config();

(async () => {
  const chainApi = new ChainRestAuthApi(
    "https://rest.cosmos.directory/cosmoshub"
  );

  const cosmosAddress = "cosmos1..";
  const account = await chainApi.fetchCosmosAccount(cosmosAddress);

  if (!account.pub_key?.key) {
    console.log("No public key found");
    return;
  }

  console.log(
    "biyachainAddress",
    PublicKey.fromBase64(account.pub_key.key || "")
      .toAddress()
      .toBech32()
  );
})();
```

{% hint style="info" %}
更多示例可以在 [TypeScript 文档](https://docs.ts.injective.network/wallet/wallet-accounts)中找到。
{% endhint %}
