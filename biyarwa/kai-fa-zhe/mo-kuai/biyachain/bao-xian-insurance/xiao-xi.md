# 消息

本节描述了交易消息的处理流程及其对状态的相应更新。每条消息创建或修改的状态对象均在“[状态](https://app.gitbook.com/o/LzWvewxXUBLXQT4cTrrj/s/anhfn6E9s6UH5ZfZcrlA/~/changes/1/kai-fa-zhe/modules/injective/insurance/02_state_transitions/~/overview)”部分定义。

## Msg/CreateInsuranceFund

`MsgCreateInsuranceFund` 定义了用于为衍生品市场创建保险基金的消息。

```protobuf
// MsgCreateInsuranceFund a message to create an insurance fund for a derivative market.
message MsgCreateInsuranceFund {
  option (gogoproto.equal) = false;
  option (gogoproto.goproto_getters) = false;
  // Creator of the insurance fund.
  string sender = 1;
  // Ticker for the derivative market.
  string ticker = 2;
  // Coin denom to use for the market quote denom
  string quote_denom = 3;
  // Oracle base currency
  string oracle_base = 4;
  // Oracle quote currency
  string oracle_quote = 5;
  // Oracle type
  biyachain.oracle.v1beta1.OracleType oracle_type = 6;
  // Expiration time of the market. Should be -1 for perpetual markets.
  int64 expiry = 7;
  // Initial deposit of the insurance fund
  cosmos.base.v1beta1.Coin initial_deposit = 8 [(gogoproto.nullable) = false];
}
```

字段描述

* Sender 字段描述了保险基金的创建者。
* Ticker、QuoteDenom、OracleBase、OracleQuote、OracleType、Expiry 字段描述了与保险基金对应的衍生品市场信息。
* InitialDeposit 指定了用于承保保险基金的初始存款金额。

免责声明：在创建保险基金时，基金本身将保留一小部分份额（1%）（协议拥有的流动性）。建议首次认购金额为 1 美元。

此功能的背后动机是避免在承保基金时出现潜在的舍入问题。例如，如果没有协议拥有的流动性，原始基金创建者如果取出大部分份额，仅留下少量份额，份额代币的价值可能会与原始价值大幅偏离。下一个承保者将不得不提供更大金额的存款，尽管他们获得的份额数量相同。

## Msg/Underwrite

`MsgUnderwrite` 定义了用于承保保险基金的消息。

```protobuf
// MsgUnderwrite defines a message for depositing coins to underwrite an insurance fund
message MsgUnderwrite {
  option (gogoproto.equal) = false;
  option (gogoproto.goproto_getters) = false;
  // Address of the underwriter.
  string sender = 1;
  // MarketID of the insurance fund.
  string market_id = 2;
  // Amount of quote_denom to underwrite the insurance fund.
  cosmos.base.v1beta1.Coin deposit = 3 [(gogoproto.nullable) = false];
}
```

字段描述

* Sender 字段描述了保险基金的承保人。
* MarketId 字段描述了与保险基金关联的衍生品市场 ID。
* Deposit 字段描述了要添加到保险基金的存款金额。

## Msg/RequestRedemption

`MsgRequestRedemption` 定义了用于向保险基金请求赎回的消息。

```protobuf
// MsgRequestRedemption defines a message for requesting a redemption of the sender's insurance fund tokens
message MsgRequestRedemption {
  option (gogoproto.equal) = false;
  option (gogoproto.goproto_getters) = false;
  // Address of the underwriter requesting a redemption.
  string sender = 1;
  // MarketID of the insurance fund.
  string market_id = 2;
  // Insurance fund share token amount to be redeemed.
  cosmos.base.v1beta1.Coin amount = 3 [(gogoproto.nullable) = false];
}
```

字段描述

* Sender 字段描述了保险基金的赎回请求者。
* MarketId 字段描述了与保险基金关联的衍生品市场 ID。
* Amount 字段描述了要赎回的份额代币数量。
