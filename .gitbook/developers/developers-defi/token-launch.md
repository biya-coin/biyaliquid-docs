# 发行代币

Within this document, we'll explain how to launch a token on Biya Chain.

There are two options for launching a token on Biya Chain: bridging an existing token or creating a new token.

## Bridging <a href="#id-3-via-tokenstation" id="id-3-via-tokenstation"></a>

The easiest way to launch a token on Biya Chain is by bridging your existing assets from one of the supported networks that Biya Chain is interoperable with. There are guides in the [Broken link](/broken/pages/5jS9URg21YzbsatmAKpe "mention") sections that you can reference to bridge assets from other networks to Biya Chain.

Once the bridging process is completed, a token will be created on Biya Chain, which you can then use to [market-launch.md](market-launch.md "mention").

## Creating a New Token

You can also create a new token on Biya Chain using the `TokenFactory` module. There are multiple ways on how to achieve this.

### Using Biya Chain Hub <a href="#id-3-via-tokenstation" id="id-3-via-tokenstation"></a>

The [Biya Chain Hub](https://prv.hub.biya.io/token-factory/) web app provides you the ability to create and manage tokens seamlessly, creating a market on Biya Chain's [native orderbook](../../developers-native/biyachain/exchange/), etc.

### Using TokenStation[​](token-launch.md) <a href="#id-3-via-tokenstation" id="id-3-via-tokenstation"></a>

The [TokenStation](https://www.tokenstation.app/) web app provides you the ability to create and manage tokens seamlessly, creating a market on Biya Chain's [native orderbook](../../developers-native/biyachain/exchange/), launching an airdrop, and much more.

### Using DojoSwap[​](token-launch.md#4-via-dojoswap) <a href="#id-4-via-dojoswap" id="id-4-via-dojoswap"></a>

Similar to above, you can utilize [DojoSwap's Market Creation module](https://docs.dojo.trading/introduction/market-creation) to create, manage, and list your token, along with several other useful features.

### Programmatically

#### Using TypeScript

Learn more about [launching a token](../assets/token-create.md).

#### Using Biya Chain CLI

{% hint style="info" %}
You have to have `biyachaind` installed locally before proceeding with this tutorial. You can learn more about it on the [biyachaind](../kai-fa-gong-ju/biyachaind/ "mention")page.
{% endhint %}

Once you have `biyachaind` installed and a key added, you can use the CLI to launch your token:

1. **Create a `TokenFactory` denom**

The fee for creating a factory denom is `0.1 BIYA`.

```bash
biyachaind tx tokenfactory create-denom [subdenom] [name] [symbol] [decimals] --from=YOUR_KEY --chain-id=biyachain-888 --node=https://testnet.tm.biyachain.network:443 --gas-prices=500000000biya --gas 1000000
```

Tokens are namespaced by the creator address to be permissionless and avoid name collision. In the example above, the subdenom is `ak` but the denom naming will be `factory/{creator address}/{subdenom}`.

2. **Submit token metadata**

To get your token visible on Biya Chain dApps, you have to submit its metadata.

```bash
biyachaind tx tokenfactory set-denom-metadata "My Token Description" 'factory/biya17vytdwqczqz72j65saukplrktd4gyfme5agf6c/ak' AKK AKCoin AK '' '' '[
{"denom":"factory/biya17vytdwqczqz72j65saukplrktd4gyfme5agf6c/ak","exponent":0,"aliases":[]},
{"denom":"AKK","exponent":6,"aliases":[]}
]' 6 --from=YOUR_KEY --chain-id=biyachain-888 --node=https://testnet.sentry.tm.biyachain.network:443 --gas-prices=500000000biya --gas 1000000
```

This command expects the following arguments:

<pre class="language-bash"><code class="lang-bash"><strong>biyachaind tx tokenfactory set-denom-metadata [description] [base] [display] [name] [symbol] [uri] [uri-hash] [denom-unit (json)] [decimals]
</strong></code></pre>

3. **Mint tokens**

Once you have created your token and submitted the token metadata, it's time to mint your tokens.

```bash
biyachaind tx tokenfactory mint 1000000factory/biya17vytdwqczqz72j65saukplrktd4gyfme5agf6c/ak --from=gov --chain-id=biyachain-888 --node=https://testnet.sentry.tm.biyachain.network:443 --gas-prices=500000000biya --gas 1000000
```

This command will mint 1 token, assuming your token has 6 decimals.

4. **Burn tokens**

The admin of the token, can also burn the tokens.

```bash
biyachaind tx tokenfactory burn 1000000factory/biya17vytdwqczqz72j65saukplrktd4gyfme5agf6c/ak --from=gov --chain-id=biyachain-888 --node=https://testnet.sentry.tm.biyachain.network:443 --gas-prices=500000000biya --gas 1000000
```

5. **Change admin**

It's recommended once you have minted the initial supply to change admin to the `null` address to make sure that the supply of the token cannot be manipulated. Once again, the admin of the token can mint and burn supply anytime. The `NEW_ADDRESS`, as explained above in most of the cases should be set to `biya1qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqe2hm49`.

```bash
biyachaind tx tokenfactory change-admin factory/biya17vytdwqczqz72j65saukplrktd4gyfme5agf6c/ak NEW_ADDRESS --from=gov --chain-id=biyachain-888 --node=https://testnet.sentry.tm.biyachain.network:443 --gas-prices=500000000biya --gas 1000000
```

{% hint style="info" %}
The examples above are for testnet. If you want to run them on mainnet, do the following changes:

`biyachain-888` > `biyachain-1`

`https://testnet.sentry.tm.biyachain.network:443` > `http://sentry.tm.biyachain.network:443`
{% endhint %}

#### Using Cosmwasm

To create and manage a bank token programmatically via a smart contract, one can use the following messages found in the [`biyachain-cosmwasm`](https://github.com/biya-coin/cw-biyachain/blob/6b2d549ff99912b9b16dbf91a06c83db99b5dace/packages/biyachain-cosmwasm/src/msg.rs#L399-L434) package:

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

Purpose: Creates a message to create a new token denomination using the tokenfactory module.

Parameters:

* `sender`: The address of the account initiating the creation.
* `subdenom`: The sub-denomination identifier for the new token.

Returns: A `CosmosMsg` wrapped in an `BiyachainMsgWrapper`, ready to be sent to the Biya Chain blockchain.

Example:

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

Purpose: Creates a message to set or update metadata for a token.

Parameters:

* `denom`: The denomination identifier of the token.
* `name`: The full name of the token.
* `symbol`: The symbol of the token.
* `decimals`: The number of decimal places the token uses.

Returns: A `CosmosMsg` wrapped in an `BiyachainMsgWrapper`, ready to be sent to the Biya Chain blockchain.

Example:

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

Purpose: Creates a message to mint new tokens. The token must be a tokenfactory token and the sender must be the token admin.

Parameters:

* `sender`: The address of the account initiating the mint operation.
* `amount`: The amount of tokens to mint.
* `mint_to`: The recipient address where the newly minted tokens should be sent.

Returns: A `CosmosMsg` wrapped in an `BiyachainMsgWrapper`, ready to be sent to the Biya Chain blockchain.

Example:

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

Purpose: Creates a message to burn tokens. The token must be a tokenfactory token and the sender must be the token admin.

Parameters:

* `sender`: The address of the account initiating the burn operation.
* `amount`: The amount of tokens to burn.

Returns: A `CosmosMsg` wrapped in an `BiyachainMsgWrapper`, ready to be sent to the Biya Chain blockchain.

Example:

```rust
let burn_message = create_burn_tokens_msg(
    env.contract.address,                                    // Sender's address
    Coin::new(500, "factory/<creator-address>/mytoken"),     // Amount to burn
);
```
