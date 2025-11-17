# 发布代币

在本文中，我们将解释如何在Injective上启动一个代币。\
在 Biyachain 上启动代币有两种选择：桥接现有代币或创建新代币。

## 桥接 <a href="#id-3-via-tokenstation" id="id-3-via-tokenstation"></a>

在 Biyachain 上启动代币的最简单方法是通过桥接来自 Biyachain 支持的互操作网络中的现有资产。你可以参考[桥接](qiao-jie.md)中的指南，了解如何将资产从其他网络桥接到 Biyachain。\
一旦桥接过程完成，代币将在 Biyachain 上创建，你就可以使用它来[发布市场](fa-bu-shi-chang.md)。

## 创建一个新的代币

你也可以使用`TokenFactory`模块在 Biyachain 上创建一个新代币。有多种方式可以实现这一目标。

### 使用 Biyachain Hub <a href="#id-3-via-tokenstation" id="id-3-via-tokenstation"></a>

[Biyachain Hub](https://hub.injective.network/token-factory/) web 应用程序让你能够轻松创建和管理代币，在 Biyachain 的[原生订单簿](../kai-fa-zhe/mo-kuai/biyachain/jiao-yi-suo-exchange.md)上创建市场等。

### 使用 TokenStation[​](https://docs.injective.network/develop/guides/token-launch/#3-via-tokenstation) <a href="#id-3-via-tokenstation" id="id-3-via-tokenstation"></a>

[TokenStation](https://www.tokenstation.app) web 应用程序让你能够轻松创建和管理代币，在 Biyachain 的[原生订单簿](../kai-fa-zhe/mo-kuai/biyachain/jiao-yi-suo-exchange.md)上创建市场，启动空投等功能。

### 使用 DojoSwap[​](https://docs.injective.network/develop/guides/token-launch/#4-via-dojoswap) <a href="#id-4-via-dojoswap" id="id-4-via-dojoswap"></a>

类似于上述，你可以使用 [DojoSwap 的市场创建模块](https://docs.dojo.trading/introduction/market-creation)来创建、管理和列出你的代币，以及其他一些有用的功能。

### 通过编程

**使用 TypeScript**

你可以学些更多关于发布代币的内容在 [TypeScript 文档](https://docs.ts.injective.network/getting-started/assets/creating-tokens)。

**使用 Biyachain CLI**

{% hint style="info" %}
在继续本教程之前，您必须先在本地安装 `biyachiand`。您可以在节点部分的[快速入门](../kuai-su-ru-men/)页面上了解更多信息。
{% endhint %}

一旦您安装了 `biyachaind` 并添加了密钥，您可以使用 CLI 启动您的代币：

1. **创建一个 `TokenFactory` denom**

创建工厂 denom 的费用为 `0.1 BIYA`。

```bash
biyachaind tx tokenfactory create-denom [subdenom] [name] [symbol] [decimals] --from=YOUR_KEY --chain-id=biyachain-888 --node=https://testnet.tm.biyachain.network:443 --gas-prices=500000000inj --gas 1000000
```

代币按创建者地址命名空间进行管理，以实现无需许可并避免名称冲突。在上述示例中，subdenom 是 `ak`，但 denom 的命名方式将是 `factory/{creator address}/{subdenom}`。

2. **提交代币元数据**

要使您的代币在 Biyachain dApp 上可见，您必须提交其元数据。

```bash
biyachaind tx tokenfactory set-denom-metadata "My Token Description" 'factory/biya17vytdwqczqz72j65saukplrktd4gyfme5agf6c/ak' AKK AKCoin AK '' '' '[
{"denom":"factory/biya17vytdwqczqz72j65saukplrktd4gyfme5agf6c/ak","exponent":0,"aliases":[]},
{"denom":"AKK","exponent":6,"aliases":[]}
]' 6 --from=YOUR_KEY --chain-id=biyachain-888 --node=https://testnet.sentry.tm.biyachain.network:443 --gas-prices=500000000inj --gas 1000000
```

这条指令参数如下：

<pre class="language-bash"><code class="lang-bash"><strong>biyachaind tx tokenfactory set-denom-metadata [description] [base] [display] [name] [symbol] [uri] [uri-hash] [denom-unit (json)] [decimals]
</strong></code></pre>

3. 铸造代币

一旦您创建了代币并提交了代币元数据，就可以开始铸造您的代币了。

```bash
biyachaind tx tokenfactory mint 1000000factory/biya17vytdwqczqz72j65saukplrktd4gyfme5agf6c/ak --from=gov --chain-id=biyachain-888 --node=https://testnet.sentry.tm.biyachain.network:443 --gas-prices=500000000biya --gas 1000000
```

此命令将铸造1个代币，假设您的代币有6个小数位。

4. **销毁代币**

代币的管理者，也可以销毁代币。

```bash
biyachaind tx tokenfactory burn 1000000factory/biya17vytdwqczqz72j65saukplrktd4gyfme5agf6c/ak --from=gov --chain-id=biyachain-888 --node=https://testnet.sentry.tm.biyachain.network:443 --gas-prices=500000000biya --gas 1000000
```

5. **更换管理者**

一旦铸造了初始供应量，建议将管理员更改为`null`地址，以确保代币的供应量无法被篡改。再次强调，代币的管理员可以随时铸造和销毁供应量。`NEW_ADDRESS`，如上所述，在大多数情况下应设置为 biya`1qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqe2hm49`。

```bash
biyachaind tx tokenfactory change-admin factory/biya17vytdwqczqz72j65saukplrktd4gyfme5agf6c/ak NEW_ADDRESS --from=gov --chain-id=biyachain-888 --node=https://testnet.sentry.tm.biyachain.network:443 --gas-prices=500000000biya --gas 1000000
```

{% hint style="info" %}
以上示例适用于测试网。如果您想在主网上运行，请进行以下更改：

`biyachain-888` > `biyachain-1`

`https://testnet.sentry.tm.biyachain.network:443` > `http://sentry.tm.biyachain.network:443`
{% endhint %}

**使用 Cosmwasm**

要通过智能合约以编程方式创建和管理银行代币，可以使用以下在 [`biyachain-cosmwasm`](https://github.com/InjectiveLabs/cw-injective/blob/6b2d549ff99912b9b16dbf91a06c83db99b5dace/packages/injective-cosmwasm/src/msg.rs#L399-L434)包中找到的消息：

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

目的：创建一个消息，用于通过 tokenfactory 模块创建一个新的denomination。

参数：

* `sender`：发起创建的账户地址。
* `subdenom`：新代币的sub-denomination标识符。

返回：一个包装在 `BiyachainMsgWrapper` 中的 `CosmosMsg`，准备发送到 Biyachain 区块链。

示例：

```rust
let new_denom_message = create_new_denom_msg(
    env.contract.address,  // Sender's address
    "mytoken".to_string(), // Sub-denomination identifier
);
```

**`create_set_token_metadata_msg`**

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

目的：创建一个消息，用于设置或更新代币的元数据。

参数：

* `denom`：代币的denomination标识符。
* `name`：代币的完整名称。
* `symbol`：代币的符号。
* `decimals`：代币使用的十进制位数。
* 返回：一个包装在 `BiyachainMsgWrapper` 中的 `CosmosMsg`，准备发送到 Biyachain 区块链。

示例：

```rust
let metadata_message = create_set_token_metadata_msg(
    "mytoken".to_string(),         // Denomination identifier
    "My Custom Token".to_string(), // Full name
    "MYT".to_string(),             // Symbol
    18,                            // Number of decimals
);
```

**`create_mint_tokens_msg`**

```rust
pub fn create_mint_tokens_msg(sender: Addr, amount: Coin, mint_to: String) -> CosmosMsg<BiyachainMsgWrapper> {
    BiyachainMsgWrapper {
        route: BiyachainRoute::Tokenfactory,
        msg_data: BiyachainMsg::Mint { sender, amount, mint_to },
    }
    .into()
}
```

目的：创建一个消息，用于铸造新代币。该代币必须是 TokenFactory 代币，且发送者必须是代币管理员。

参数：

* `sender`：发起铸币操作的账户地址。
* `amount`：要铸造的代币数量。
* `mint_to`：接收新铸造代币的地址。

返回：一个包装在 `BiyachainMsgWrapper` 中的 `CosmosMsg`，准备发送到 Biyachain 区块链。

示例：

```rust
let mint_message = create_mint_tokens_msg(
    env.contract.address,                                   // Sender's address
    Coin::new(1000, "factory/<creator-address>/mytoken"),   // Amount to mint
    "inj1...".to_string(),                                  // Recipient's address
);
```

**`create_burn_tokens_msg`**

```rust
pub fn create_burn_tokens_msg(sender: Addr, amount: Coin) -> CosmosMsg<BiyachainMsgWrapper> {
    BiyachainMsgWrapper {
        route: BiyachainRoute::Tokenfactory,
        msg_data: BiyachainMsg::Burn { sender, amount },
    }
    .into()
}
```

目的：创建一个消息，用于销毁代币。该代币必须是 TokenFactory 代币，且发送者必须是代币管理员。

参数：

* `sender`：发起销毁操作的账户地址。
* `amount`：要销毁的代币数量。

返回：一个包装在 `BiyachainMsgWrapper` 中的 `CosmosMsg`，准备发送到 Biyachain 区块链。

示例：

```rust
let burn_message = create_burn_tokens_msg(
    env.contract.address,                                    // Sender's address
    Coin::new(500, "factory/<creator-address>/mytoken"),     // Amount to burn
);
```
