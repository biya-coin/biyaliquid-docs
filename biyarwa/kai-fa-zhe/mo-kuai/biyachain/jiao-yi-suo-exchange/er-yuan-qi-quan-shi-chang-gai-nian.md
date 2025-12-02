# 二元期权市场概念

## 概念

二元期权市场与其他市场不同，它没有基础资产，报价通常使用USDT（未来可能会添加其他报价资产）。二元期权市场的交易对通常遵循类似 UFC-KHABIB-TKO-09082022 的命名规则。通常，二元期权市场用于对体育赛事进行投注，但也可以用于对任何事件结果进行投注。所有市场的价格区间在 $0.00 到 $1.00 之间，用户可以提交从 $0.01 到 $0.99 的订单（$0.00 和 $1.00 分别表示事件未发生或已发生的结束条件）。订单中提交的价格本质上是对给定事件（市场）发生的假设概率。

对于所有二元期权市场，费用始终以报价资产（如 USDT）支付。

这类市场没有杠杆，因为用户在一个零和市场中相互交易。由此隐含了另一个要求：如果一方认为事件将发生（YES方），且当前市场的概率为P（即当前市场价格为P），那么反方（NO方）应该确信该事件不会发生，概率为(1-P)。因此，如果YES方以价格P购买Q份合约，他需要将&#x51;_&#x50;的余额作为保证金，而反方（卖方）则需要将Q_(1-P)的报价余额作为保证金。

**示例**：

Alice以$0.20的价格购买1份合约（以$0.20作为保证金）对抗Bob，Bob以$0.20的价格卖出1份合约（以$0.80作为保证金），为双方创建了头寸。

* 如果市场最终以$1结算，Alice将赢得$0.80，Bob将赢得$0.20，如果市场结算为$0，则结果相反。

## 预言机

二元期权市场与提供者预言机类型紧密关联，允许一个治理注册的提供者在其子类型下中继价格数据，支持添加任意新的价格数据源，而无需额外的治理批准。每个二元期权市场由以下预言机参数组成：

* **预言机符号**（例如：UFC-KHABIB-TKO-09082022）
* **预言机提供者**（例如：frontrunner）
* **预言机类型**（必须为provider类型）
* **预言机规模因子**（例如：如果报价计价单位是USDT，则为6）

预言机的主要目标是发布事件的最终结果。该最终价格将以该确切价格结算市场。这个价格通常为0或1，反映二元结果。

此外，市场也可以在(0, 1)价格区间内的任何价格结算。如果预言机发布的**settlement\_price**介于0和1之间，所有头寸将在settlement\_price（例如：0.42）处结算。如果预言机价格超过1，结算价格将四舍五入为1。

预言机还可以发布最终价格为-1，这将作为触发所有当前市场头寸退款并销毁市场的标志价格。如果在结算之前没有任何预言机更新，则默认使用-1触发所有头寸的退款。

关于预言机提供者类型的进一步文档可以在预言机模块文档中找到。

### 注册预言机提供者

要注册您的预言机提供者，您需要提交一个 **GrantProviderPrivilegeProposal** 治理提案。这个提案将注册您的预言机提供者，并允许您的地址中继价格数据。

```go
type GrantProviderPrivilegeProposal struct {
	Title       string   
	Description string   
	Provider    string    // the name of the provider, should be specific to you
	Relayers    []string  // addresses which will be able to relay prices 
}
```

一旦提案通过，您的提供者将被注册，您将能够中继您的价格数据（如下例所示）。

## 市场生命周期

### 市场创建

二元期权市场可以通过即时启动（通过 **`MsgInstantBinaryOptionsMarketLaunch`**）或通过治理（通过 **`BinaryOptionsMarketLaunchProposal`**）创建。\
该市场可以选择配置一个市场管理员，管理员具有触发结算、更改市场状态以及修改给定市场的到期时间和结算时间戳的能力。如果市场没有指定管理员，则市场参数只能通过治理进行修改，结算程序将完全基于相关的预言机提供者价格数据。

### 市场状态转换

二元期权市场在 Injective 上可以有三种状态：激活、到期或拆除。市场创建后，市场处于激活状态，这表示个人可以开始交易。\
特别地，二元期权市场还具有一个特征 **ExpirationTimestamp**，它指定了市场交易活动停止的截止时间，以及一个 **SettlementTimestamp**，它指定了结算发生的截止时间（必须在到期之后）。

* **Active** = 交易开启
* **Expired** = 交易关闭，未完成的订单被取消，仓位不变
* **Demolished** = 仓位已结算/退款（取决于结算情况），市场被拆除

二元期权市场状态转换的性质如下：

| 状态改变                                 | 工作流                                                                                                                                                                 |
| ------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Active → Expired                     | 到期是市场标准工作流程的一部分。市场的交易立即停止，所有未完成的订单将被取消。此时，市场可以立即由管理员或预言机强制结算，或者在达到 **SettlementTimestamp** 时，使用最新的预言机价格自然结算。                                                        |
| Expired → Demolished (Settlement)    | 所有头寸将根据强制结算或自然结算的价格进行结算。市场将无法再进行交易或重新激活。对于自然结算，在 **SettlementTimestamp** 时间到达时，记录并使用最后的预言机价格进行结算。对于“强制结算”，管理员应发布包含结算价格的 **MarketUpdate** 消息，该价格应设置在 \[0, 1] 的价格区间内。 |
| Active/Expired → Demolished (Refund) | 所有头寸将被退款。该市场将无法再进行交易或重新激活。管理员应发布 **MarketUpdate** 消息，并将结算价格设置为 -1。                                                                                                  |

### 市场结算

结算价格选项在上面的[预言机](er-yuan-qi-quan-shi-chang-gai-nian.md#yu-yan-ji)部分中解释。

结算市场可以通过以下两种方式之一实现：

1. 使用为特定市场注册的提供者oracle。一旦提供者oracle获得了传递价格的权限（上面已解释），具有该权限的地址可以使用MsgRelayProviderPrices消息为特定价格信息源传递价格。

```go
// MsgRelayProviderPrices defines a SDK message for setting a price through the provider oracle.
type MsgRelayProviderPrices struct {
	Sender   string                        
	Provider string                        
	Symbols  []string                      
	Prices   []cosmossdk_io_math.LegacyDec 
}
```

2. 使用`MsgAdminUpdateBinaryOptionsMarket`，允许市场的管理员（创建者）直接向市场提交结算价格。

```go
type MsgAdminUpdateBinaryOptionsMarket struct {
  // new price at which market will be settled
  SettlementPrice *Dec 
  // expiration timestamp
  ExpirationTimestamp int64
  // expiration timestamp
  SettlementTimestamp int64
  // Status of the market
  Status MarketStatus
}

// Where Status can be one of these options
enum MarketStatus {
  Unspecified = 0;
  Active = 1;
  Paused = 2;
  Demolished = 3;
  Expired = 4;
} 
```
