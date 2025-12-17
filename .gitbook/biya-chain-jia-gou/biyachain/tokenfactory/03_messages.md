---
sidebar_position: 3
---

# 消息

在本节中，我们描述 tokenfactory 消息的处理以及相应的状态更新。

## 消息

### CreateDenom

根据代币单位创建者地址、子代币单位和相关元数据（名称、符号、小数位数）创建 `factory/{创建者地址}/{子代币单位}` 的代币单位。子代币单位可以包含 `[a-zA-Z0-9./]`。`allow_admin_burn` 可以设置为 true 以允许管理员从其他地址销毁代币。

```protobuf
message MsgCreateDenom {
  string sender = 1 [ (gogoproto.moretags) = "yaml:\"sender\"" ];
  // subdenom can be up to 44 "alphanumeric" characters long.
  string subdenom = 2 [ (gogoproto.moretags) = "yaml:\"subdenom\"" ];
  string name = 3 [ (gogoproto.moretags) = "yaml:\"name\"" ];
  string symbol = 4 [ (gogoproto.moretags) = "yaml:\"symbol\"" ];
  uint32 decimals = 5 [ (gogoproto.moretags) = "yaml:\"decimals\"" ];
  // true if admins are allowed to burn tokens from other addresses
  bool allow_admin_burn = 6 [ (gogoproto.moretags) = "yaml:\"allow_admin_burn\"" ];}
```

**状态修改：**

* 使用创建者地址的代币单位创建费用向社区池注资，费用在 `Params` 中设置。
* 通过 bank keeper 设置 `DenomMetaData`。
* 为给定的代币单位设置 `AuthorityMetadata`，以存储创建的代币单位 `factory/{创建者地址}/{子代币单位}` 的管理员。管理员自动设置为消息发送者。
* 将代币单位添加到 `CreatorPrefixStore`，其中保存每个创建者创建的代币单位状态。

### Mint

特定代币单位的铸造仅允许当前管理员执行。\
注意，当前管理员默认为代币单位的创建者。

```protobuf
message MsgMint {
  string sender = 1 [ (gogoproto.moretags) = "yaml:\"sender\"" ];
  cosmos.base.v1beta1.Coin amount = 2 [
    (gogoproto.moretags) = "yaml:\"amount\"",
    (gogoproto.nullable) = false
  ];
}
```

**状态修改：**

* 安全检查以下内容
  * 检查代币单位是否通过 `tokenfactory` 模块创建
  * 检查消息发送者是否为代币单位的管理员
* 通过 `bank` 模块为代币单位铸造指定数量的代币

### Burn

特定代币单位的销毁仅允许当前管理员执行。\
注意，当前管理员默认为代币单位的创建者。

```protobuf
message MsgBurn {
  string sender = 1 [ (gogoproto.moretags) = "yaml:\"sender\"" ];
  cosmos.base.v1beta1.Coin amount = 2 [
    (gogoproto.moretags) = "yaml:\"amount\"",
    (gogoproto.nullable) = false
  ];
}
```

**状态修改：**

* 安全检查以下内容
  * 检查代币单位是否通过 `tokenfactory` 模块创建
  * 检查消息发送者是否为代币单位的管理员
* 通过 `bank` 模块为代币单位销毁指定数量的代币

### ChangeAdmin

更改代币单位的管理员。注意，这仅允许由代币单位的当前管理员调用。将管理员地址设置为零地址后，代币持有者仍可以对他们拥有的代币执行 `MsgBurn`。

```protobuf
message MsgChangeAdmin {
  string sender = 1 [ (gogoproto.moretags) = "yaml:\"sender\"" ];
  string denom = 2 [ (gogoproto.moretags) = "yaml:\"denom\"" ];
  string newAdmin = 3 [ (gogoproto.moretags) = "yaml:\"new_admin\"" ];
}
```

### SetDenomMetadata

特定代币单位的元数据设置仅允许代币单位的管理员执行。\
它允许覆盖 bank 模块中的代币单位元数据。如果已启用，管理员还可以禁用管理员销毁功能。

```protobuf
message MsgSetDenomMetadata {
  option (amino.name) = "biyachain/tokenfactory/set-denom-metadata";
  option (cosmos.msg.v1.signer) = "sender";

  string sender = 1 [ (gogoproto.moretags) = "yaml:\"sender\"" ];
  cosmos.bank.v1beta1.Metadata metadata = 2 [
    (gogoproto.moretags) = "yaml:\"metadata\"",
    (gogoproto.nullable) = false
  ];

  message AdminBurnDisabled {
    // true if the admin burn capability should be disabled
    bool should_disable = 1 [ (gogoproto.moretags) = "yaml:\"should_disable\"" ];
  }
  AdminBurnDisabled admin_burn_disabled = 3 [ (gogoproto.moretags) = "yaml:\"admin_burn_disabled\"" ];
}
```

**状态修改：**

* 检查消息发送者是否为代币单位的管理员
* 修改 `AuthorityMetadata` 状态条目以更改代币单位的管理员，并可能禁用管理员销毁功能。

## 对链的期望

链的地址 bech32 前缀最多可以是 16 个字符。

这是因为代币单位具有 128 字节的最大长度（由 SDK 强制执行），\
并且我们将最长子代币单位设置为 44 字节。

代币工厂代币的代币单位是：`factory/{创建者地址}/{子代币单位}`

拆分为子组件，这包括：

* `len(factory) = 7`
* `2 * len("/") = 2`
* `len(longest_subdenom)`
* `len(creator_address) = len(bech32(longest_addr_length, chain_addr_prefix))`

目前最长的地址长度是 `32 字节`。由于 SDK 纠错设置，\
这意味着 `len(bech32(32, chain_addr_prefix)) = len(chain_addr_prefix) + 1 + 58`。\
将所有内容相加，我们得到总长度约束 `128 = 7 + 2 + len(longest_subdenom) + len(longest_chain_addr_prefix) + 1 + 58`。\
因此 `len(longest_subdenom) + len(longest_chain_addr_prefix) = 128 - (7 + 2 + 1 + 58) = 60`。

我们如何在最长子代币单位和最长链地址前缀的最大值之间标准化分配这 60 字节的选择有些随意。\
考虑因素包括：

* 根据 [BIP-0173](https://github.com/bitcoin/bips/blob/master/bip-0173.mediawiki#bech32)\
  对于 32 字节地址（'数据字段'），技术上最长的 HRP 是 31 字节。\
  （来自 encode(data) = 59 字节，最大长度 = 90 字节）
* 子代币单位应至少为 32 字节，以便可以放入哈希值
* 更长的子代币单位对于创建人类可读的代币单位非常有帮助
* 链地址应该更小。迄今为止 cosmos 中最长的 HRP 是 11 字节。（`persistence`）

为了明确起见，目前设置为 `len(longest_subdenom) = 44` 和 `len(longest_chain_addr_prefix) = 16`。

请注意，如果 SDK 将代币单位的最大长度从 128 字节增加，\
这些上限应该增加。

因此，请不要让代码依赖这些最大长度进行解析。
