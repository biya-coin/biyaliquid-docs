# 测试网水龙头集成

如果您想在 dApp 中集成测试网水龙头，您只需要向 `` `https://jsbqfdd4yk.execute-api.us-east-1.amazonaws.com/v1/faucet` `` 发送一个 `POST` 请求，并将 `{ address: biya1...}` 作为 `POST` 请求的主体。该地址随后会被存储在队列中，队列每 5 到 10 分钟处理一次。

以下是示例代码片段：\


```typescript
import { HttpClient } from "@biya-coin/utils"

const LAMBDA_API = "https://jsbqfdd4yk.execute-api.us-east-1.amazonaws.com/v1"
const client = new HttpClient(LAMBDA_API);

client
  .post("faucet", { address: "biya1...." })
  .then((response: any) => {
    alert("success, your address is in the queue");
  })
  .catch((e: any) => {
    alert("Something happened - " + e.message);
  })
  .finally(() => {
    //
  });
```
