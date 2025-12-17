---
sidebar_position: 2
title: 状态
---

# 状态

tokenfactory 模块保持以下主要对象的状态：

## 代币单位权限元数据

* 0x02 + | + denom + | + 0x01 ⇒ `DenomAuthorityMetadata`

## 代币单位创建者

* 0x03 + | + creator + | denom ⇒ denom

```protobuf
// DenomAuthorityMetadata specifies metadata for addresses that have specific
// capabilities over a token factory denom. 
message DenomAuthorityMetadata {
  option (gogoproto.equal) = true;

  // Can be empty for no admin, or a valid biyachain address
  string admin = 1 [ (gogoproto.moretags) = "yaml:\"admin\"" ];

  // true if the admin can burn tokens from other addresses
  bool admin_burn_allowed = 2 [ (gogoproto.moretags) = "yaml:\"admin_burn_allowed\"" ];
}
```

创世状态定义了模块的初始状态，用于设置模块。

```protobuf
// GenesisState defines the tokenfactory module's genesis state.
message GenesisState {
  // params defines the parameters of the module.
  Params params = 1 [ (gogoproto.nullable) = false ];

  repeated GenesisDenom factory_denoms = 2 [
    (gogoproto.moretags) = "yaml:\"factory_denoms\"",
    (gogoproto.nullable) = false
  ];
}

// GenesisDenom defines a tokenfactory denom that is defined within genesis
// state. The structure contains DenomAuthorityMetadata which defines the
// denom's admin.
message GenesisDenom {
  option (gogoproto.equal) = true;

  string denom = 1 [ (gogoproto.moretags) = "yaml:\"denom\"" ];
  DenomAuthorityMetadata authority_metadata = 2 [
    (gogoproto.moretags) = "yaml:\"authority_metadata\"",
    (gogoproto.nullable) = false
  ];
}
```

## 参数

`Params` 是模块范围的配置，存储系统参数并定义 tokenfactory 模块的整体功能。\
此模块可通过治理使用 `gov` 模块原生支持的参数更新提案进行修改。

`ocr` 模块参数存储的结构。

```protobuf
// Params defines the parameters for the tokenfactory module.
message Params {
  repeated cosmos.base.v1beta1.Coin denom_creation_fee = 1 [
    (gogoproto.castrepeated) = "github.com/cosmos/cosmos-sdk/types.Coins",
    (gogoproto.moretags) = "yaml:\"denom_creation_fee\"",
    (gogoproto.nullable) = false
  ];
}

```
