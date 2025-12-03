# 消息

## MsgRelayBandRates

授权的Band中继者可以通过`MsgRelayBandRates`消息中继多个符号的价格源数据。注册的处理程序遍历`MsgRelayBandRates`中存在的所有符号，并为每个符号创建/更新`BandPriceState`。

```protobuf
message MsgRelayBandRates {
  string relayer = 1;
  repeated string symbols = 2;
  repeated uint64 rates = 3;
  repeated uint64 resolve_times = 4;
  repeated uint64 requestIDs = 5;
}
```

如果中继者不是授权的Band中继者，此消息预期会失败。

## MsgRelayCoinbaseMessages

Coinbase提供者的中继者可以使用`MsgRelayCoinbaseMessages`消息发送价格数据。\
每个Coinbase消息通过Coinbase oracle地址`0xfCEAdAFab14d46e20144F48824d0C09B1a03F2BC`提供的签名进行身份验证，从而允许任何人提交`MsgRelayCoinbaseMessages`。

```protobuf
message MsgRelayCoinbaseMessages {
  option (gogoproto.equal) = false;
  option (gogoproto.goproto_getters) = false;
  string sender = 1;

  repeated bytes messages = 2;
  repeated bytes signatures = 3;
}
```

如果签名验证失败，或者提交的时间戳比最后一次提交的Coinbase价格更旧，则此消息预期会失败。

## MsgRelayPriceFeedPrice

价格源提供者的中继者可以使用`MsgRelayPriceFeedPrice`消息发送价格源数据。

```protobuf
// MsgRelayPriceFeedPrice defines a SDK message for setting a price through the pricefeed oracle.
message MsgRelayPriceFeedPrice {
  option (gogoproto.equal) = false;
  option (gogoproto.goproto_getters) = false;
  string sender = 1;

  repeated string base = 2;
  repeated string quote = 3;

  // price defines the price of the oracle base and quote
  repeated string price = 4 [
    (gogoproto.customtype) = "cosmossdk.io/math.LegacyDec",
    (gogoproto.nullable) = false
  ];
}
```

如果中继者（发送者）不是给定基础报价对的授权价格源中继者，或者价格大于10000000，则此消息预期会失败。

## MsgRequestBandIBCRates

```
MsgRequestBandIBCRates 是一条消息，用于即时广播请求到bandchain。// MsgRequestBandIBCRates defines a SDK message for requesting data from BandChain using IBC.
```

```protobuf
message MsgRequestBandIBCRates {
  option (gogoproto.equal) = false;
  option (gogoproto.goproto_getters) = false;

  string sender = 1;
  uint64 request_id = 2;

}
```

任何人都可以广播此消息，无需特定授权。处理程序会检查`BandIbcEnabled`标志是否为`true`，如果是，则继续发送请求。

## MsgRelayPythPrices

`MsgRelayPythPrices` 是一条消息，用于将Pyth合约的价格中继到oracle模块。

```protobuf
// MsgRelayPythPrices defines a SDK message for updating Pyth prices
message MsgRelayPythPrices {
  option (gogoproto.equal) = false;
  option (gogoproto.goproto_getters) = false;

  string sender = 1;
  repeated PriceAttestation price_attestations = 2;
}

message PriceAttestation {
  string product_id = 1;
  bytes price_id = 2;
  int64 price = 3;
  uint64 conf = 4;
  int32 expo = 5;
  int64 ema_price = 6;
  uint64 ema_conf = 7;
  PythStatus status = 8;
  uint32 num_publishers = 9;
  uint32 max_num_publishers = 10;
  int64 attestation_time = 11;
  int64 publish_time = 12;
}

enum PythStatus {
  // The price feed is not currently updating for an unknown reason.
  Unknown = 0;
  // The price feed is updating as expected.
  Trading = 1;
  // The price feed is not currently updating because trading in the product has been halted.
  Halted = 2;
  // The price feed is not currently updating because an auction is setting the price.
  Auction = 3;
}
```

如果中继者（发送者）与oracle模块参数中定义的Pyth合约地址不匹配，则此消息预期会失败。

## MsgRelayStorkPrices

`MsgRelayStorkPrices` 是一条消息，用于将Stork合约的价格中继到oracle模块。

```protobuf
// MsgRelayStorkPrices defines a SDK message for relaying price message from Stork API.
message MsgRelayStorkPrices {
  option (gogoproto.equal) = false;
  option (gogoproto.goproto_getters) = false;
  option (cosmos.msg.v1.signer) = "sender";

  string sender = 1;
  repeated AssetPair asset_pairs = 2;
}

message AssetPair {
  string asset_id = 1;
  repeated SignedPriceOfAssetPair signed_prices = 2;
}

message SignedPriceOfAssetPair {
  string publisher_key = 1;
  uint64 timestamp = 2;
  string price = 3 [
    (gogoproto.customtype) = "cosmossdk.io/math.LegacyDec",
    (gogoproto.nullable) = false
  ];
  bytes signature = 4;
}
```

如果发生以下情况，则此消息预期会失败：

* 中继者（发送者）不是授权的oracle发布者，或者`assetId`在提供的资产对中不是唯一的
* 对`SignedPriceOfAssetPair`的ECDSA签名验证失败
* 时间戳之间的差值超过`MaxStorkTimestampIntervalNano`（500毫秒）

## MsgRelayProviderPrices

特定提供者的中继者可以使用`MsgRelayProviderPrices`消息发送价格源数据。

```protobuf
// MsgRelayProviderPrice defines a SDK message for setting a price through the provider oracle.
message MsgRelayProviderPrices {
  option (amino.name) = "oracle/MsgRelayProviderPrices";
  option (gogoproto.equal) = false;
  option (gogoproto.goproto_getters) = false;
  option (cosmos.msg.v1.signer) = "sender";

  string sender = 1;
  string provider = 2;
  repeated string symbols = 3;
  repeated string prices = 4 [
    (gogoproto.customtype) = "cosmossdk.io/math.LegacyDec",
    (gogoproto.nullable) = false
  ];
}
```

如果中继者（发送者）不是给定基础报价对的授权价格源中继者，或者价格大于10000000，则此消息预期会失败。
