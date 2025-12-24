# 在 CosmWasm 中使用 Biya Chain 模块和查询

本指南全面概述了如何使用 `Any` 消息和查询在 CosmWasm 中与 Biya Chain 的模块和查询进行交互。较旧的 [biyachain-cosmwasm](https://github.com/biya-coin/cw-biyachain/tree/dev/packages/biyachain-cosmwasm) 包依赖于 JSON 编码的消息,不再维护并可能过时。本指南重点介绍使用 protobuf 编码的 `Any` 消息和查询的推荐方法,这种方法更高效且与现代 CosmWasm 标准保持一致。

## CosmWasm 中的 `Any` 消息是什么?

在 CosmWasm 中,`Any` 消息是 `CosmosMsg` 枚举的一部分,允许您发送包装在链支持的 protobuf `Any` 类型中的消息。它们以改进的命名和语法替代了已弃用的 `Stargate` 消息(仍可在 `stargate` 功能标志下使用)。`Any` 消息由 `cosmwasm_2_0` 功能门控,这意味着它们需要运行 CosmWasm 2.0 的链,而 Biya Chain 支持此版本。以下是 `CosmosMsg` 定义的片段:

```rust
pub enum CosmosMsg<T = Empty> {
    // ...
    #[cfg(feature = "cosmwasm_2_0")]
    Any(AnyMsg),
    // ...
}

pub struct AnyMsg {
    pub type_url: String,
    pub value: Binary,
}
```

`type_url` 指定 protobuf 消息类型,`value` 包含序列化的消息数据。

## 为什么使用这种方法?

`biyachain-cosmwasm` 包使用基于 JSON 的消息,效率较低且可能与未来更新不兼容。新的 `Any` 消息方法使用 protobuf 编码,提供更好的性能、类型安全性以及与 CosmWasm 2.0+ 的兼容性。这现在是与 Biya Chain 模块和查询交互的推荐方法。

## 发送消息

要发送消息,您需要创建一个 protobuf 消息,对其进行编码,然后将其包装在 `Any` 消息中。以下是在 Biya Chain 交易所模块上创建现货市场订单的示例。

### 示例:创建现货市场订单

```rust
use cosmwasm_std::{AnyMsg, CosmosMsg, StdResult};
use biyachain_cosmwasm::{BiyachainMsgWrapper, OrderType, SpotMarket};
use biyachain_math::{round_to_min_tick, round_to_nearest_tick, FPDecimal};
use biyachain_std::types::biyachain::exchange::v1beta1 as Exchange;
use prost::Message;

pub fn create_spot_market_order_message(
    price: FPDecimal,
    quantity: FPDecimal,
    order_type: OrderType,
    sender: &str,
    subaccount_id: &str,
    fee_recipient: &str,
    market: &SpotMarket,
) -> StdResult<CosmosMsg<BiyachainMsgWrapper>> {
    let msg = create_spot_market_order(price, quantity, order_type, sender, subaccount_id, fee_recipient, market);

    let mut order_bytes = vec![];
    Exchange::MsgCreateSpotMarketOrder::encode(&msg, &mut order_bytes).unwrap();

    Ok(CosmosMsg::Any(AnyMsg {
        type_url: Exchange::MsgCreateSpotMarketOrder::TYPE_URL.to_string(),
        value: order_bytes.into(),
    }))
}

fn create_spot_market_order(
    price: FPDecimal,
    quantity: FPDecimal,
    order_type: OrderType,
    sender: &str,
    subaccount_id: &str,
    fee_recipient: &str,
    market: &SpotMarket,
) -> Exchange::MsgCreateSpotMarketOrder {
    let rounded_quantity = round_to_min_tick(quantity, market.min_quantity_tick_size);
    let rounded_price = round_to_nearest_tick(price, market.min_price_tick_size);

    Exchange::MsgCreateSpotMarketOrder {
        sender: sender.to_string(),
        order: Some(Exchange::SpotOrder {
            market_id: market.market_id.as_str().into(),
            order_info: Some(Exchange::OrderInfo {
                subaccount_id: subaccount_id.to_string(),
                fee_recipient: fee_recipient.to_string(),
                price: rounded_price.to_string(),
                quantity: rounded_quantity.to_string(),
                cid: "".to_string(),
            }),
            order_type: order_type as i32,
            trigger_price: "".to_string(),
        }),
    }
}
```

**步骤:**

1. 使用订单详细信息构造 `MsgCreateSpotMarketOrder` protobuf 消息。
2. 使用 `prost::Message::encode` 将其编码为字节。
3. 使用正确的 `type_url` 将其包装在 `AnyMsg` 中。
4. 将其作为 `CosmosMsg::Any` 返回。

通过使用适当的 protobuf 消息和 `type_url`,此方法可以适用于其他模块(例如 auction、tokenfactory)。

## 执行查询

查询使用 `QuerierWrapper` 和 `BiyachainQueryWrapper` 执行。您可以使用 `biyachain_std` 中的预构建查询器或发送原始查询。以下是涵盖不同模块的示例。

### 示例:查询现货市场(交易所模块)

```rust
use cosmwasm_std::{to_json_binary, Binary, Deps, StdResult};
use biyachain_cosmwasm::BiyachainQueryWrapper;
use biyachain_std::types::biyachain::exchange::v1beta1::ExchangeQuerier;

pub fn handle_query_spot_market(deps: Deps<BiyachainQueryWrapper>, market_id: &str) -> StdResult<Binary> {
    let querier = ExchangeQuerier::new(&deps.querier);
    to_json_binary(&querier.spot_market(market_id.to_string())?)
}
```

**步骤:**

1. 从 `deps.querier` 创建一个 `ExchangeQuerier`。
2. 使用 `market_id` 调用 `spot_market`。
3. 将响应序列化为 JSON 并将其作为 `Binary` 返回。

### 示例:查询银行参数(银行模块)

```rust
use cosmwasm_std::{to_json_binary, Binary, Deps, StdResult};
use biyachain_cosmwasm::BiyachainQueryWrapper;
use biyachain_std::types::cosmos::bank::v1beta1::BankQuerier;

pub fn handle_query_bank_params(deps: Deps<BiyachainQueryWrapper>) -> StdResult<Binary> {
    let querier = BankQuerier::new(&deps.querier);
    to_json_binary(&querier.params()?)
}
```

**步骤:**

1. 从 `deps.querier` 创建一个 `BankQuerier`。
2. 调用 `params` 以获取银行模块参数。
3. 序列化并返回结果。

## 使用其他模块

相同的原则适用于其他 Biya Chain 模块,如 auction、insurance、oracle、permissions 和 tokenfactory,以及 Cosmos 原生模块。例如:

- **Auction 模块**: 使用 `AuctionQuerier` 进行查询或将 `MsgBid` 编码为 `Any` 消息。
- **Tokenfactory 模块**: 编码 `MsgCreateDenom` 或使用 `TokenFactoryQuerier`。

有关特定消息类型和查询器,请参阅 [biyachain_std](https://github.com/biya-coin/biyachain-rust/tree/dev/packages/biyachain-std)。
