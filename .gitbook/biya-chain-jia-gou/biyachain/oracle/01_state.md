---
sidebar_position: 1
title: 状态
---

# 状态

## Params
oracle 模块参数。 
```protobuf
message Params {
  option (gogoproto.equal) = true;

  string pyth_contract = 1;
}
```


## PriceState

PriceState 是用于管理所有 oracle 类型的累积价格和最新价格以及时间戳的通用类型。

```protobuf
message PriceState {
    string price = 1 [(gogoproto.customtype) = "cosmossdk.io/math.LegacyDec", (gogoproto.nullable) = false];
    
    string cumulative_price = 2 [(gogoproto.customtype) = "cosmossdk.io/math.LegacyDec", (gogoproto.nullable) = false];
    
    int64 timestamp = 3;
}
```

其中

- `Price` 表示标准化的十进制价格
- `CumulativePrice` 表示自 oracle 价格源创建开始以来给定 oracle 价格源的累积价格。
- `Timestamp` 表示中继价格状态的区块时间。

请注意，`CumulativePrice` 值遵循 [Uniswap V2 Oracle](https://uniswap.org/docs/v2/core-concepts/oracles/) 设定的约定，用于允许模块计算两个任意区块时间间隔（t1，t2）之间的时间加权平均价格（TWAP）。

$\mathrm{TWAP = \frac{CumulativePrice_2 - CumulativePrice_1}{Timestamp_2 - Timestamp_1}}$

## Band

给定符号的 Band 价格数据表示和存储如下：

- BandPriceState: `0x01 | []byte(symbol) -> ProtocolBuffer(BandPriceState)`

```protobuf
message BandPriceState {
    string symbol = 1;
    string rate = 2 [(gogoproto.customtype) = "cosmossdk.io/math.Int", (gogoproto.nullable) = false];
    uint64 resolve_time = 3;
    uint64 request_ID = 4;
    PriceState price_state = 5 [(gogoproto.nullable) = false];
}
```

请注意，`Rate` 是从 Band 链获得的 `Symbol` 的原始 USD 汇率，已按 1e9 缩放（例如，价格为 1.42 则为 1420000000），而 PriceState 具有标准化的十进制价格（例如 1.42）。

Band 中继者按其地址存储如下。

- BandRelayer: `0x02 | RelayerAddr -> []byte{}`

## Band IBC

本节描述通过 IBC 连接到 Band 链以维护价格的所有状态管理。

- LatestClientID 用于管理 band IBC 数据包的唯一 clientID。向 bandchain 发送价格请求数据包时，它增加 1。

* LatestClientID: `0x32 -> Formated(LatestClientID)`

- LatestRequestID 用于管理唯一的 `BandIBCOracleRequests`。创建新的 `BandIBCOracleRequest` 时增加 1。

* LatestRequestID: `0x36 -> Formated(LatestRequestID)`

- 给定符号的 Band IBC 价格数据存储如下：

* BandPriceState: `0x31 | []byte(symbol) -> ProtocolBuffer(BandPriceState)`

```protobuf
message BandPriceState {
  string symbol = 1;
  string rate = 2 [(gogoproto.customtype) = "cosmossdk.io/math.Int", (gogoproto.nullable) = false];
  uint64 resolve_time = 3;
  uint64 request_ID = 4;
  PriceState price_state = 5 [(gogoproto.nullable) = false];
}
```

- 向 bandchain 发送价格请求数据包时，BandIBCCallDataRecord 存储如下：

* CalldataRecord: `0x33 | []byte(ClientId) -> ProtocolBuffer(CalldataRecord)`

```protobuf
message CalldataRecord {
  uint64 client_id = 1;
  bytes calldata = 2;
}
```

- 当治理配置要发送的 oracle 请求时，BandIBCOracleRequest 存储如下：

* BandOracleRequest: `0x34 | []byte(RequestId) -> ProtocolBuffer(BandOracleRequest)`

```protobuf
message BandOracleRequest {
  // Unique Identifier for band ibc oracle request
  uint64 request_id = 1;

  // OracleScriptID is the unique identifier of the oracle script to be executed.
  int64 oracle_script_id = 2;

  // Symbols is the list of symbols to prepare in the calldata
  repeated string symbols = 3;

  // AskCount is the number of validators that are requested to respond to this
  // oracle request. Higher value means more security, at a higher gas cost.
  uint64 ask_count = 4;

  // MinCount is the minimum number of validators necessary for the request to
  // proceed to the execution phase. Higher value means more security, at the
  // cost of liveness.
  uint64 min_count = 5;

  // FeeLimit is the maximum tokens that will be paid to all data source providers.
  repeated cosmos.base.v1beta1.Coin fee_limit = 6 [(gogoproto.nullable) = false, (gogoproto.castrepeated) = "github.com/cosmos/cosmos-sdk/types.Coins"];

  // PrepareGas is amount of gas to pay to prepare raw requests
  uint64 prepare_gas = 7;
  // ExecuteGas is amount of gas to reserve for executing
  uint64 execute_gas = 8;
}
```

- BandIBCParams 存储如下，由治理配置：

* BandIBCParams: `0x35 -> ProtocolBuffer(BandIBCParams)`

`BandIBCParams` 包含与 band 链的 IBC 连接信息。

```protobuf
message BandIBCParams {
  // true if Band IBC should be enabled
  bool band_ibc_enabled = 1;
  // block request interval to send Band IBC prices
  int64 ibc_request_interval = 2;
  // band IBC source channel
  string ibc_source_channel = 3;
  // band IBC version
  string ibc_version = 4;
  // band IBC portID
  string ibc_port_id = 5;
}
```

注意：

1. `BandIbcEnabled` 描述 band ibc 连接的状态
2. `IbcSourceChannel`、`IbcVersion`、`IbcPortId` 是 IBC 连接所需的通用参数。
3. `IbcRequestInterval` 描述在 beginblocker 上在 biyachain 链上自动触发的自动价格获取请求间隔。

## Coinbase

给定符号（"key"）的 Coinbase 价格数据表示和存储如下：

- CoinbasePriceState: `0x21 | []byte(key) -> CoinbasePriceState`

```protobuf
message CoinbasePriceState {
  // kind should always be "prices"
  string kind = 1;
  // timestamp of the when the price was signed by coinbase
  uint64 timestamp = 2;
  // the symbol of the price, e.g. BTC
  string key = 3;
  // the value of the price scaled by 1e6
  uint64 value = 4;
  // the price state
  PriceState price_state = 5 [(gogoproto.nullable) = false];
}
```

有关 Coinbase 价格预言机的更多详细信息，可以在 [Coinbase API 文档](https://docs.pro.coinbase.com/#oracle) 以及这篇解释性[博客文章](https://blog.coinbase.com/introducing-the-coinbase-price-oracle-6d1ee22c7068)中找到。

请注意，`Value` 是从 Coinbase 获得的原始 USD 价格数据，已按 1e6 缩放（例如，价格为 1.42 则为 1420000），而 PriceState 具有标准化的十进制价格（例如 1.42）。

## Pricefeed

给定基础报价对的 Pricefeed 价格数据表示和存储如下：

- PriceFeedInfo: `0x11 + Keccak256Hash(base + quote) -> PriceFeedInfo`

```protobuf
message PriceFeedInfo {
  string base = 1;
  string quote = 2;
}
```

- PriceFeedPriceState: `0x12 + Keccak256Hash(base + quote) -> PriceFeedPriceState`

```protobuf
message PriceFeedState {
  string base = 1;
  string quote = 2;
  PriceState price_state = 3;
  repeated string relayers = 4;
}
```

- PriceFeedRelayer: `0x13 + Keccak256Hash(base + quote) + relayerAddr -> relayerAddr`

## Provider 
Provider 价格源表示和存储如下：

- ProviderInfo: `0x61 + provider + @@@ -> ProviderInfo`
```protobuf
message ProviderInfo {
  string provider = 1;
  repeated string relayers = 2;
}
```

- ProviderIndex: `0x62 + relayerAddress -> provider`

- ProviderPrices: `0x63 + provider + @@@ + symbol -> ProviderPriceState`
```protobuf
message ProviderPriceState {
  string symbol = 1;
  PriceState state = 2;
}
```

## Pyth

Pyth 价格表示和存储如下：
- PythPriceState: `0x71 + priceID -> PythPriceState`
```protobuf
message PythPriceState {
  bytes price_id = 1;
  string ema_price = 2 [(gogoproto.customtype) = "cosmossdk.io/math.LegacyDec", (gogoproto.nullable) = false];
  string ema_conf = 3 [(gogoproto.customtype) = "cosmossdk.io/math.LegacyDec", (gogoproto.nullable) = false];
  string conf = 4 [(gogoproto.customtype) = "cosmossdk.io/math.LegacyDec", (gogoproto.nullable) = false];
  uint64 publish_time = 5;
  PriceState price_state = 6 [(gogoproto.nullable) = false];
}
```

## Stork

Stork 价格表示和存储如下：
- StorkPriceState: `0x81 + symbol -> PythPriceState`
```protobuf
message StorkPriceState {
  // timestamp of the when the price was signed by stork
  uint64 timestamp = 1;
  // the symbol of the price, e.g. BTC
  string symbol = 2;
  // the value of the price scaled by 1e18
  string value = 3 [
    (gogoproto.customtype) = "cosmossdk.io/math.LegacyDec",
    (gogoproto.nullable) = false
  ];
  // the price state
  PriceState price_state = 5 [ (gogoproto.nullable) = false ];
}
```

Stork publishers are represented and stored as follows:
- Publisher: `0x82 + stork_publisher -> publisher`

```protobuf
string stork_publisher
```