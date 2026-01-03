# 转换地址

在本文档中，我们将概述一些如何在不同格式和派生路径之间转换地址的示例。

### 转换 Hex <> Bech32 地址

正如我们在[wallet](../../users/wallet/ "mention")部分提到的，Biya Chain 地址与 Ethereum 地址兼容。您可以轻松地在两种格式之间进行转换。

### 使用 TypeScript

您可以使用 `@biya-coin/sdk-ts` 包中的实用函数轻松地在 Biya Chain 地址和 Ethereum 地址之间进行转换：

```typescript
import { getBiyachainAddress, getEthereumAddress } from '@biya-coin/sdk-ts'

const biyachainAddress = 'biya1...'
const ethereumAddress = '0x..'

console.log('从 Ethereum 地址获取 Biya Chain 地址 => ', getBiyachainAddress(ethereumAddress))
console.log('从 Biya Chain 地址获取 Ethereum 地址 => ', getEthereumAddress(biyachainAddress))
```

### **将 Cosmos 地址转换为 Biya Chain 地址**

由于 Biya Chain 的派生路径与默认的 Cosmos 派生路径不同，您需要账户的 `publicKey` 才能将 Cosmos `publicAddress` 转换为 Biya Chain 地址。

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
    console.log("未找到公钥");
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
更多示例可以在[钱包账户](../../users/accounts.md)中找到。
{% endhint %}
