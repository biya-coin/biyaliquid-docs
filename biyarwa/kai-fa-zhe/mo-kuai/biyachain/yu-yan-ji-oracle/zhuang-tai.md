# 状态

## Params

oracle模块参数：

```protobuf
message Params {
  option (gogoproto.equal) = true;

  string pyth_contract = 1;
}
```

## PriceState

PriceState是一个通用类型，用于管理所有oracle类型的累计价格、最新价格及其时间戳。

```protobuf
message PriceState {
    string price = 1 [(gogoproto.customtype) = "cosmossdk.io/math.LegacyDec", (gogoproto.nullable) = false];
    
    string cumulative_price = 2 [(gogoproto.customtype) = "cosmossdk.io/math.LegacyDec", (gogoproto.nullable) = false];
    
    int64 timestamp = 3;
}
```

其中：

* **Price** 表示标准化的小数价格
* **CumulativePrice** 表示自oracle价格源创建以来的累计价格
* **Timestamp** 表示价格状态被中继的区块时间

请注意，**CumulativePrice** 值遵循[Uniswap V2 Oracle](https://uniswap.org/docs/v2/core-concepts/oracles/)设定的约定，并用于允许模块计算两个任意区块时间间隔（t1，t2）之间的时间加权平均价格（TWAP）。

公式：

$\mathrm{TWAP = \frac{CumulativePrice\_2 - CumulativePrice\_1}{Timestamp\_2 - Timestamp\_1\}}$

## Band

给定符号的Band价格数据表示和存储如下：

* **`BandPriceState`**`: 0x01 | []byte(symbol) -> ProtocolBuffer(BandPriceState)`

```protobuf
message BandPriceState {
    string symbol = 1;
    string rate = 2 [(gogoproto.customtype) = "cosmossdk.io/math.Int", (gogoproto.nullable) = false];
    uint64 resolve_time = 3;
    uint64 request_ID = 4;
    PriceState price_state = 5 [(gogoproto.nullable) = false];
}
```

请注意，**Rate** 是从Band链获取的符号的原始USD汇率，经过1e9的缩放（例如，1.42的价格为1420000000），而**PriceState** 存储的是标准化的小数价格（例如，1.42）。

Band中继者通过其地址存储如下：

* **`BandRelayer`**`: 0x02 | RelayerAddr -> []byte{}`

## Band IBC

本节描述了通过IBC连接到Band链以维护价格的所有状态管理。

* **LatestClientID** 用于管理Band IBC数据包的唯一clientID。当发送价格请求数据包到bandchain时，它会增加1。
* **LatestClientID**: 0x32 -> 格式化(LatestClientID)
* **LatestRequestID** 用于管理唯一的`BandIBCOracleRequests`。在创建新的BandIBCOracleRequest时，值会增加1。
* **LatestRequestID**: 0x36 -> 格式化(`LatestRequestID`)

给定符号的Band IBC价格数据存储如下：

* **`BandPriceState`**`: 0x31 | []byte(symbol) -> ProtocolBuffer(BandPriceState)`

```protobuf
message BandPriceState {
  string symbol = 1;
  string rate = 2 [(gogoproto.customtype) = "cosmossdk.io/math.Int", (gogoproto.nullable) = false];
  uint64 resolve_time = 3;
  uint64 request_ID = 4;
  PriceState price_state = 5 [(gogoproto.nullable) = false];
}
```

* 当发送价格请求数据包到bandchain时，**BandIBCCallDataRecord** 存储如下
  * **`CalldataRecord`**`: 0x33 | []byte(ClientId) -> ProtocolBuffer(CalldataRecord)`

```protobuf
message CalldataRecord {
  uint64 client_id = 1;
  bytes calldata = 2;
}
```

* 当治理配置oracle请求发送时，**BandIBCOracleRequest** 存储如下：
  * **`BandOracleRequest`**`: 0x34 | []byte(RequestId) -> ProtocolBuffer(BandOracleRequest)`

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

* **BandIBCParams** 存储如下，并由治理配置：
* **BandIBCParams**: `0x35 -> ProtocolBuffer(BandIBCParams)`

**BandIBCParams** 包含与band链的IBC连接信息。

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

* **`BandIbcEnabled`** 描述了band IBC连接的状态
* **`IbcSourceChannel`**`、`**`IbcVersion`**`、`**`IbcPortId`** 是IBC连接所需的常见参数
* **`IbcRequestInterval`** 描述了在Biyachain链的BeginBlock时自动触发的价格获取请求间隔

## Coinbase

给定符号（"key"）的Coinbase价格数据表示和存储如下：

* **`CoinbasePriceState`**`: 0x21 | []byte(key) -> CoinbasePriceState`

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

关于Coinbase价格oracle的更多详细信息可以在[Coinbase API文档](https://docs.pro.coinbase.com/#oracle)以及这篇解释性[博客文章](https://blog.coinbase.com/introducing-the-coinbase-price-oracle-6d1ee22c7068)中找到。

请注意，**Value** 是从Coinbase获取的原始USD价格数据，经过1e6的缩放（例如，1.42的价格为1420000），而**PriceState** 存储的是标准化的小数价格（例如，1.42）。

## Pricefeed

给定基础报价对的价格源数据表示和存储如下：

* **`PriceFeedInfo`**`: 0x11 + Keccak256Hash(base + quote) -> PriceFeedInfo`

```protobuf
message PriceFeedInfo {
  string base = 1;
  string quote = 2;
}
```

* PriceFeedPriceState: `0x12 + Keccak256Hash(base + quote) -> PriceFeedPriceState`

```protobuf
message PriceFeedState {
  string base = 1;
  string quote = 2;
  PriceState price_state = 3;
  repeated string relayers = 4;
}
```

* PriceFeedRelayer: `0x13 + Keccak256Hash(base + quote) + relayerAddr -> relayerAddr`

## Provider

提供者价格源数据表示和存储如下：

* ProviderInfo: `0x61 + provider + @@@ -> ProviderInfo`

```protobuf
message ProviderInfo {
  string provider = 1;
  repeated string relayers = 2;
}
```

* ProviderIndex: `0x62 + relayerAddress -> provider`
* ProviderPrices: `0x63 + provider + @@@ + symbol -> ProviderPriceState`

```protobuf
message ProviderPriceState {
  string symbol = 1;
  PriceState state = 2;
}
```

## Pyth

Pyth价格数据表示和存储如下：

* PythPriceState: `0x71 + priceID -> PythPriceState`

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

Stork价格数据表示和存储如下：

* StorkPriceState: `0x81 + symbol -> PythPriceState`

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

Stork发布者数据表示和存储如下：

* Publisher: `0x82 + stork_publisher -> publisher`

```protobuf
string stork_publisher
```
