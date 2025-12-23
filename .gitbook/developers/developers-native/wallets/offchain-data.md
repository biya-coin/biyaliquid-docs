# 链外（任意）数据

在本页面上，我们将提供一个示例，说明如何根据 Cosmos 上的 [ADR-036](https://docs.cosmos.network/main/build/architecture/adr-036-arbitrary-signature) 规范签署和验证任意数据。

{% hint style="info" %}
您可以使用 `@biya-coin/sdk-ts` 中的 `generateArbitrarySignDoc` 函数生成与 ADR-36 兼容的 `signDoc`。然后，您可以使用它在浏览器钱包或 CLI 环境中进行签名/验证。确保您使用的是最新的软件包版本。
{% endhint %}

#### 使用浏览器钱包（如 Keplr）签署和验证

```typescript

(async () => {
  const message = "离线签名消息示例";
  const signer = 'biya1...'
  const chainId = 'biyachain-1'
  
  // 签署任意数据
  const signature = await window.keplr.signArbitrary(chainId, signer, message)
  
  // 验证任意数据
  const result = await window.keplr.verifyArbitrary(chainId, signer, message, signature)
  
  if (result) {
    console.log("签名有效");
  }
})();
```

#### 在 CLI 环境中使用 PrivateKey 签署和验证

```typescript
import { config } from "dotenv";
import { PrivateKey, generateArbitrarySignDoc } from "@biya-coin/sdk-ts";

config();

(async () => {
  const { privateKey } = PrivateKey.generate();
  const biyachainAddress = privateKey.toBech32();
  const publicKey = privateKey.toPublicKey();
  
  const message = "离线签名消息示例";
  const { signDocBuff } = generateArbitrarySignDoc(message, biyachainAddress);

  const signature = await privateKey.sign(signDocBuff);
  const signatureInHex = Buffer.from(signature).toString("hex");

  if (
    PrivateKey.verifyArbitrarySignature({
      signature: signatureInHex,
      signDoc: signDocBuff,
      publicKey: publicKey.toHex(),
    })
  ) {
    console.log("签名有效");
  }
})();

```
