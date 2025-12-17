---
sidebar_position: 2
title: Binary Options Markets
---

# 二元期权市场

## 概念

二元期权市场不像其他市场那样有基础资产，它们以 **USDT** 报价（未来可能会添加其他报价资产）。\
二元期权市场的代码通常遵循 **UFC-KHABIB-TKO-09082022** 或类似的方案。\
通常，二元期权市场用于对体育赛事进行投注，但也可以用于对任何结果进行投注。\
所有市场的可能价格区间在 $0.00 和 $1.00 之间，用户可以从 $0.01 到 $0.99 下订单。\
（$0.00 和 $1.00 分别表示结果未发生或已发生的结束条件）。\
订单中提交的价格本质上是给定事件（市场）发生的假设概率。

对于所有二元期权市场，**费用始终以报价资产支付**，例如 USDT。

这些类型的市场没有杠杆，因为用户在零和市场中进行交易。\
由此可以得出另一个要求：如果投注的一方认为事件会发生（YES 方），\
当前市场对该确切事件的概率为 *P*（这意味着当前市场价格为 *P*），\
投注的对手方应该确定事件不会以 *(1-P)* 的概率发生。\
因此，如果 YES 方的人以价格 *P* 购买 *Q* 数量的合约，他将锁定其余额的 *Q\*P* 作为保证金，\
而对手 NO 方（卖方）应该锁定其报价余额的 *Q\*(1-P)* 作为保证金。

**示例：**

Alice 以 $0.20（以 $0.20 作为保证金）购买 1 个合约，对抗 Bob，\
Bob 以 $0.20（以 $0.80 作为保证金）卖出 1 个合约，为双方创建持仓。

- 如果市场以 $1 结算，Alice 赢得 $0.80；如果市场以 $0 结算，Bob 赢得 $0.2。

## 预言机

二元期权市场与 Provider Oracle 类型紧密耦合，它允许治理注册的提供者中继任意新价格源的价格数据，\
这些价格源属于提供者的子类型，无需额外的治理来添加连续的新价格源。\
每个二元期权市场由以下预言机参数组成：
* 预言机符号（例如 UFC-KHABIB-TKO-09082022）
* 预言机提供者（例如 frontrunner）
* 预言机类型（必须是 provider）
* 预言机缩放因子（例如，如果报价 denom 是 USDT，则为 6）

预言机的主要目标是发布事件的最终结果。这个最终价格以该确切价格结算市场。\
大多数时候，这个价格预期等于 0 或 1，反映二元结果。

此外，市场可以在 (0, 1) 价格区间内的任何价格结算。\
如果预言机发布的 *settlement_price* 在 0 或 1 之间，所有持仓将以 *settlement_price*（例如 0.42）平仓。\
如果预言机价格超过 1，结算价格将向下舍入到 1。

预言机还可以发布最终价格 **-1**，这是触发当前市场中所有持仓退款并销毁市场的标志价格。\
如果在结算之前没有预言机更新，则默认使用预言机价格 -1 来触发所有持仓的退款。

关于预言机提供者类型的进一步文档可以在 Oracle 模块文档中找到。

### 注册预言机提供者

要注册您的预言机提供者，您需要提交 `GrantProviderPrivilegeProposal` 治理提案。\
此提案将注册您的提供者，并允许您的地址中继价格源。

```go
type GrantProviderPrivilegeProposal struct {
	Title       string   
	Description string   
	Provider    string    // 提供者的名称，应该是您特定的
	Relayers    []string  // 将能够中继价格的地址
}
```

提案通过后，您的提供者将被注册，您将能够中继您的价格源（下面的示例）。

## 市场生命周期

### 市场创建
二元期权市场可以通过即时启动（通过 `MsgInstantBinaryOptionsMarketLaunch`）或通过治理（通过 `BinaryOptionsMarketLaunchProposal`）创建。

市场可以选择性地配置市场管理员，该管理员能够触发结算、更改市场状态以及修改给定市场的到期和结算时间戳。\
如果市场未指定管理员，则只能通过治理修改市场参数，结算程序将完全基于关联的预言机提供者价格源。

### 市场状态转换
二元期权市场在 Biya Chain 上可以处于三种状态之一：活跃、已到期或已销毁。\
市场创建后，市场具有 `活跃` 状态，表示个人可以开始交易。

重要的是，二元期权市场还具有特征 `ExpirationTimestamp`，它指定市场交易活动停止的截止时间，\
以及 `SettlementTimestamp`，它指定结算发生的截止时间（必须在到期之后）。

* **活跃** = 交易开放
* **已到期** = 交易关闭，开放订单被取消，持仓不变。
* **已销毁** = 持仓已结算/退款（取决于结算），市场已销毁

二元期权市场的状态转换性质如下：

| 状态变化 | 工作流程 |
| --- | --- |
| 活跃 → 已到期 | 到期是市场标准工作流程的一部分。市场交易立即停止，所有开放订单被取消。\
现在可以通过管理员或预言机立即（强制）结算市场，或者当我们到达 SettlementTimestamp 时使用最新的预言机价格自然结算。 |
| 已到期 → 已销毁（结算） | 所有持仓以强制结算或自然结算设定的价格结算。\
市场永远不能再交易或重新激活。对于自然结算，在 SettlementTimestamp 时间，记录最后一个预言机价格并用于结算。\
对于"强制结算"，管理员应发布包含 SettlementPrice 的 MarketUpdate 消息，价格设置在 [0, 1] 的价格区间内。 |
| 活跃/已到期 → 已销毁（退款） | 所有持仓获得退款。市场永远不能再交易或重新激活。\
管理员应发布包含 SettlementPrice 的 MarketUpdate 消息，价格设置为 -1。 |


### 市场结算

结算价格选项在上面的[预言机](#oracle)部分中解释。

结算市场可以通过以下两种选项之一实现：
1. 使用特定市场的注册提供者预言机。一旦提供者预言机被授予中继价格的权限（如上所述），\
具有权限的地址可以使用 `MsgRelayProviderPrices` 消息为特定价格源中继价格。
```go
// MsgRelayProviderPrices 定义通过提供者预言机设置价格的 SDK 消息。
type MsgRelayProviderPrices struct {
	Sender   string                        
	Provider string                        
	Symbols  []string                      
	Prices   []cosmossdk_io_math.LegacyDec 
}
```

2. 使用 `MsgAdminUpdateBinaryOptionsMarket`，它允许市场的管理员（创建者）直接将结算价格提交到市场。
```go
type MsgAdminUpdateBinaryOptionsMarket struct {
  // 市场将以此价格结算的新价格
  SettlementPrice *Dec 
  // 到期时间戳
  ExpirationTimestamp int64
  // 结算时间戳
  SettlementTimestamp int64
  // 市场状态
  Status MarketStatus
}

// 其中 Status 可以是以下选项之一
enum MarketStatus {
  Unspecified = 0;
  Active = 1;
  Paused = 2;
  Demolished = 3;
  Expired = 4;
} 
```
