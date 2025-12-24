# 发行代币

在本文档中，我们将解释如何在 Biya Chain 上发行代币。

在 Biya Chain 上发行代币有两种选择：桥接现有代币或创建新代币。

## 桥接 <a href="#id-3-via-tokenstation" id="id-3-via-tokenstation"></a>

在 Biya Chain 上发行代币最简单的方法是从 Biya Chain 可互操作的支持网络之一桥接您的现有资产。您可以参考 [Broken link](/broken/pages/5jS9URg21YzbsatmAKpe "mention") 部分的指南，将资产从其他网络桥接到 Biya Chain。

桥接过程完成后，将在 Biya Chain 上创建一个代币，然后您可以使用它来[发行市场](market-launch.md "mention")。

## 创建新代币

您还可以使用 `TokenFactory` 模块在 Biya Chain 上创建新代币。有多种方法可以实现这一点。

### 使用 Biya Chain Hub <a href="#id-3-via-tokenstation" id="id-3-via-tokenstation"></a>

[Biya Chain Hub](https://prv.hub.biya.io/token-factory/) 网页应用为您提供无缝创建和管理代币的能力，在 Biya Chain 的[原生订单簿](../../developers-native/biyachain/exchange/)上创建市场等。

### 使用 TokenStation[​](token-launch.md) <a href="#id-3-via-tokenstation" id="id-3-via-tokenstation"></a>

[TokenStation](https://www.tokenstation.app/) 网页应用为您提供无缝创建和管理代币的能力，在 Biya Chain 的[原生订单簿](../../developers-native/biyachain/exchange/)上创建市场、启动空投等等。

### 使用 DojoSwap[​](token-launch.md#4-via-dojoswap) <a href="#id-4-via-dojoswap" id="id-4-via-dojoswap"></a>

与上述类似，您可以利用 [DojoSwap 的市场创建模块](https://docs.dojo.trading/introduction/market-creation)来创建、管理和列出您的代币，以及其他几个有用的功能。

### 以编程方式

#### 使用 TypeScript

了解更多关于[发行代币](../assets/token-create.md)的信息。

#### 使用 Biya Chain CLI

{% hint style="info" %}
在继续本教程之前，您必须在本地安装 `biyachaind`。您可以在 [biyachaind](../kai-fa-gong-ju/biyachaind/ "mention") 页面了解更多信息。
{% endhint %}

安装 `biyachaind` 并添加密钥后，您可以使用 CLI 发行代币：

1. **创建 `TokenFactory` 面额**

创建工厂面额的费用为 `0.1 BIYA`。

```bash
biyachaind tx tokenfactory create-denom [subdenom] [name] [symbol] [decimals] --from=YOUR_KEY --chain-id=biyachain-888 --node=https://testnet.tm.biyachain.network:443 --gas-prices=500000000biya --gas 1000000
```

代币按创建者地址进行命名空间划分，以实现无需许可并避免名称冲突。在上面的示例中，子面额是 `ak`，但面额命名将是 `factory/{creator address}/{subdenom}`。

2. **提交代币元数据**

要使您的代币在 Biya Chain dApps 上可见，您必须提交其元数据。

```bash
biyachaind tx tokenfactory set-denom-metadata "My Token Description" 'factory/biya17vytdwqczqz72j65saukplrktd4gyfme5agf6c/ak' AKK AKCoin AK '' '' '[
{"denom":"factory/biya17vytdwqczqz72j65saukplrktd4gyfme5agf6c/ak","exponent":0,"aliases":[]},
{"denom":"AKK","exponent":6,"aliases":[]}
]' 6 --from=YOUR_KEY --chain-id=biyachain-888 --node=https://testnet.sentry.tm.biyachain.network:443 --gas-prices=500000000biya --gas 1000000
```

此命令需要以下参数：

<pre class="language-bash"><code class="lang-bash"><strong>biyachaind tx tokenfactory set-denom-metadata [description] [base] [display] [name] [symbol] [uri] [uri-hash] [denom-unit (json)] [decimals]
</strong></code></pre>

3. **铸造代币**

创建代币并提交代币元数据后，就可以铸造代币了。

```bash
biyachaind tx tokenfactory mint 1000000factory/biya17vytdwqczqz72j65saukplrktd4gyfme5agf6c/ak --from=gov --chain-id=biyachain-888 --node=https://testnet.sentry.tm.biyachain.network:443 --gas-prices=500000000biya --gas 1000000
```

此命令将铸造 1 个代币，假设您的代币有 6 位小数。

4. **销毁代币**

代币的管理员也可以销毁代币。

```bash
biyachaind tx tokenfactory burn 1000000factory/biya17vytdwqczqz72j65saukplrktd4gyfme5agf6c/ak --from=gov --chain-id=biyachain-888 --node=https://testnet.sentry.tm.biyachain.network:443 --gas-prices=500000000biya --gas 1000000
```

5. **更改管理员**

建议在铸造初始供应量后将管理员更改为 `null` 地址，以确保代币供应量不会被操纵。再次强调，代币的管理员可以随时铸造和销毁供应量。如上所述，在大多数情况下，`NEW_ADDRESS` 应设置为 `biya1qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqe2hm49`。

```bash
biyachaind tx tokenfactory change-admin factory/biya17vytdwqczqz72j65saukplrktd4gyfme5agf6c/ak NEW_ADDRESS --from=gov --chain-id=biyachain-888 --node=https://testnet.sentry.tm.biyachain.network:443 --gas-prices=500000000biya --gas 1000000
```

{% hint style="info" %}
以上示例适用于测试网。如果您想在主网上运行它们，请进行以下更改：

`biyachain-888` > `biyachain-1`

`https://testnet.sentry.tm.biyachain.network:443` > `http://sentry.tm.biyachain.network:443`
{% endhint %}

#### 使用 Cosmwasm

要通过智能合约以编程方式创建和管理银行代币，可以使用 [`biyachain-cosmwasm`](https://github.com/biya-coin/cw-biyachain/blob/6b2d549ff99912b9b16dbf91a06c83db99b5dace/packages/biyachain-cosmwasm/src/msg.rs#L399-L434) 包中的以下消息：

\
`create_new_denom_msg`

```rust
pub fn create_new_denom_msg(sender: String, subdenom: String) -> CosmosMsg<BiyachainMsgWrapper> {
    BiyachainMsgWrapper {
        route: BiyachainRoute::Tokenfactory,
        msg_data: BiyachainMsg::CreateDenom { sender, subdenom },
    }
    .into()
}
```

目的：创建一条消息，使用 tokenfactory 模块创建新的代币面额。

参数：

* `sender`：发起创建的账户地址。
* `subdenom`：新代币的子面额标识符。

返回：包装在 `BiyachainMsgWrapper` 中的 `CosmosMsg`，准备发送到 Biya Chain 区块链。

示例：

```rust
let new_denom_message = create_new_denom_msg(
    env.contract.address,  // Sender's address
    "mytoken".to_string(), // Sub-denomination identifier
);
```

#### `create_set_token_metadata_msg`

```rust
pub fn create_set_token_metadata_msg(denom: String, name: String, symbol: String, decimals: u8) -> CosmosMsg<BiyachainMsgWrapper> {
    BiyachainMsgWrapper {
        route: BiyachainRoute::Tokenfactory,
        msg_data: BiyachainMsg::SetTokenMetadata {
            denom,
            name,
            symbol,
            decimals,
        },
    }
    .into()
}
```

目的：创建一条消息来设置或更新代币的元数据。

参数：

* `denom`：代币的面额标识符。
* `name`：代币的全名。
* `symbol`：代币的符号。
* `decimals`：代币使用的小数位数。

返回：包装在 `BiyachainMsgWrapper` 中的 `CosmosMsg`，准备发送到 Biya Chain 区块链。

示例：

```rust
let metadata_message = create_set_token_metadata_msg(
    "mytoken".to_string(),         // Denomination identifier
    "My Custom Token".to_string(), // Full name
    "MYT".to_string(),             // Symbol
    18,                            // Number of decimals
);
```

#### `create_mint_tokens_msg`

```rust
pub fn create_mint_tokens_msg(sender: Addr, amount: Coin, mint_to: String) -> CosmosMsg<BiyachainMsgWrapper> {
    BiyachainMsgWrapper {
        route: BiyachainRoute::Tokenfactory,
        msg_data: BiyachainMsg::Mint { sender, amount, mint_to },
    }
    .into()
}
```

目的：创建一条消息来铸造新代币。代币必须是 tokenfactory 代币，发送者必须是代币管理员。

参数：

* `sender`：发起铸造操作的账户地址。
* `amount`：要铸造的代币数量。
* `mint_to`：新铸造代币应发送到的接收者地址。

返回：包装在 `BiyachainMsgWrapper` 中的 `CosmosMsg`，准备发送到 Biya Chain 区块链。

示例：

```rust
let mint_message = create_mint_tokens_msg(
    env.contract.address,                                   // Sender's address
    Coin::new(1000, "factory/<creator-address>/mytoken"),   // Amount to mint
    "biya1...".to_string(),                                  // Recipient's address
);
```

#### `create_burn_tokens_msg`

```rust
pub fn create_burn_tokens_msg(sender: Addr, amount: Coin) -> CosmosMsg<BiyachainMsgWrapper> {
    BiyachainMsgWrapper {
        route: BiyachainRoute::Tokenfactory,
        msg_data: BiyachainMsg::Burn { sender, amount },
    }
    .into()
}
```

目的：创建一条消息来销毁代币。代币必须是 tokenfactory 代币，发送者必须是代币管理员。

参数：

* `sender`：发起销毁操作的账户地址。
* `amount`：要销毁的代币数量。

返回：包装在 `BiyachainMsgWrapper` 中的 `CosmosMsg`，准备发送到 Biya Chain 区块链。

示例：

```rust
let burn_message = create_burn_tokens_msg(
    env.contract.address,                                    // Sender's address
    Coin::new(500, "factory/<creator-address>/mytoken"),     // Amount to burn
);
```
