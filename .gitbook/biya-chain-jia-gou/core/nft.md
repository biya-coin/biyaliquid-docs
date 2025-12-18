---
sidebar_position: 1
---

# NFT

## 摘要

`x/nft` 是 Cosmos SDK 模块的实现，根据 [ADR 43](https://github.com/cosmos/cosmos-sdk/blob/main/docs/architecture/adr-043-nft-module.md)，它允许您创建 NFT 分类、创建 NFT、转移 NFT、更新 NFT，并通过集成该模块支持各种查询。它完全兼容 ERC721 规范。

## 概念

### 类别

`x/nft` 模块定义了一个结构体 `Class` 来描述一类 NFT 的共同特征，在此类别下，您可以创建各种 NFT，这相当于以太坊的 erc721 合约。该设计在 [ADR 043](https://github.com/cosmos/cosmos-sdk/blob/main/docs/architecture/adr-043-nft-module.md) 中定义。

### NFT

NFT 的全称是非同质化代币（Non-Fungible Tokens）。由于 NFT 的不可替代性，意味着它可以用来表示独特的事物。此模块实现的 NFT 完全兼容以太坊 ERC721 标准。

## 状态

### 类别

类别主要由 `id`、`name`、`symbol`、`description`、`uri`、`uri_hash`、`data` 组成，其中 `id` 是类别的唯一标识符，类似于以太坊 ERC721 合约地址，其他字段是可选的。

* 类别: `0x01 | classID | -> ProtocolBuffer(Class)`

### NFT

NFT 主要由 `class_id`、`id`、`uri`、`uri_hash` 和 `data` 组成。其中，`class_id` 和 `id` 是标识 NFT 唯一性的二元组，`uri` 和 `uri_hash` 是可选的，用于标识 NFT 的链下存储位置，`data` 是 Any 类型。使用 `x/nft` 模块的任何链都可以通过扩展此字段进行自定义

* NFT: `0x02 | classID | 0x00 | nftID |-> ProtocolBuffer(NFT)`

### NFTOfClassByOwner

NFTOfClassByOwner 主要用于实现使用 classID 和 owner 查询所有 NFT 的功能，没有其他冗余功能。

* NFTOfClassByOwner: `0x03 | owner | 0x00 | classID | 0x00 | nftID |-> 0x01`

### 所有者

由于 NFT 中没有额外字段来指示 NFT 的所有者，因此使用额外的键值对来保存 NFT 的所有权。随着 NFT 的转移，键值对会同步更新。

* OwnerKey: `0x04 | classID | 0x00 | nftID |-> owner`

### 总供应量

TotalSupply 负责跟踪某个类别下所有 NFT 的数量。在更改的类别下执行铸造操作时，供应量增加一，执行销毁操作时，供应量减少一。

* OwnerKey: `0x05 | classID |-> totalSupply`

## 消息

在本节中，我们描述 NFT 模块的消息处理。

:::warning\
`ClassID` 和 `NftID` 的验证留给应用开发者。SDK 不提供对这些字段的任何验证。
:::

### MsgSend

您可以使用 `MsgSend` 消息来转移 NFT 的所有权。这是 `x/nft` 模块提供的功能。当然，您可以使用 `Transfer` 方法实现自己的转移逻辑，但需要特别注意转移权限。

如果出现以下情况，消息处理应失败：

* 提供的 `ClassID` 不存在。
* 提供的 `Id` 不存在。
* 提供的 `Sender` 不是 NFT 的所有者。

## 事件

NFT 模块发出在 [Protobuf 参考](https://buf.build/cosmos/cosmos-sdk/docs/main:cosmos.nft.v1beta1) 中定义的 proto 事件。
