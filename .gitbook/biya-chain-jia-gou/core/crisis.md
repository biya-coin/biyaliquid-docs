---
sidebar_position: 1
---

# Crisis

## 概述

crisis 模块在区块链不变量被破坏的情况下停止区块链。不变量可以在应用初始化过程中向应用注册。

## 目录

* [状态](crisis.md#state)
* [消息](crisis.md#messages)
* [事件](crisis.md#events)
* [参数](crisis.md#parameters)
* [客户端](crisis.md#client)
  * [CLI](crisis.md#cli)

## 状态

### ConstantFee

由于验证不变量的预期 gas 成本较高（可能超过最大允许的区块 gas 限制），因此使用固定费用而不是标准 gas 消耗方法。固定费用旨在大于使用标准 gas 消耗方法运行不变量的预期 gas 成本。

ConstantFee 参数存储在模块参数状态中，前缀为 `0x01`，\
可以通过治理或具有权限的地址进行更新。

* Params: `mint/params -> legacy_amino(sdk.Coin)`

## 消息

在本节中，我们描述 crisis 消息的处理以及相应的状态更新。

### MsgVerifyInvariant

可以使用 `MsgVerifyInvariant` 消息检查区块链不变量。

```protobuf
https://github.com/cosmos/cosmos-sdk/blob/v0.47.0-rc1/proto/cosmos/crisis/v1beta1/tx.proto#L26-L42
```

如果出现以下情况，此消息应失败：

* 发送者没有足够的代币支付固定费用
* 不变量路由未注册

此消息检查提供的不变量，如果不变量被破坏，它会 panic，停止区块链。如果不变量被破坏，固定费用永远不会被扣除，因为交易永远不会提交到区块（相当于被退款）。但是，如果不变量未被破坏，固定费用将不会被退还。

## 事件

crisis 模块发出以下事件：

### 处理器

#### MsgVerifyInvariance

| 类型      | 属性键   | 属性值            |
| --------- | -------- | ----------------- |
| invariant | route    | {invariantRoute}  |
| message   | module   | crisis            |
| message   | action   | verify\_invariant |
| message   | sender   | {senderAddress}   |

## 参数

crisis 模块包含以下参数：

| 键          | 类型          | 示例                             |
| ----------- | ------------- | --------------------------------- |
| ConstantFee | object (coin) | {"denom":"uatom","amount":"1000"} |

## 客户端

### CLI

用户可以使用 CLI 查询和与 `crisis` 模块交互。

#### 交易

`tx` 命令允许用户与 `crisis` 模块交互。

```bash
simd tx crisis --help
```

**invariant-broken**

`invariant-broken` 命令在不变量被破坏时提交证明以停止链

```bash
simd tx crisis invariant-broken [module-name] [invariant-route] [flags]
```

示例：

```bash
simd tx crisis invariant-broken bank total-supply --from=[keyname or address]
```
