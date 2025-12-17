---
sidebar_position: 9
title: EndBlocker
---

# EndBlock

交易所 EndBlocker 在每个区块结束时运行，在我们的定义顺序中，在治理和质押模块之后，在 peggy、auction 和 insurance 模块之前。特别重要的是，治理模块的 EndBlocker 在交易所模块之前运行。

* 阶段 0：确定在当前区块中在支持费用折扣的市场上下单的所有账户的费用折扣。
* 阶段 1：并行处理所有市价单 - 现货市价单和衍生品市价单
  * 市价单针对区块开始时的挂单订单簿执行。
  * 请注意，市价单可能会在 EndBlocker 中因随后传入的预言机更新或限价单取消而失效。
* 阶段 2：将市价单执行持久化到存储
  * 现货市场
    * 持久化现货市价单执行数据
    * 发出相关事件
      * `EventBatchSpotExecution`
  * 衍生品市场
    * 持久化衍生品市价单执行数据
    * 发出相关事件
      * `EventBatchDerivativeExecution`
      * `EventCancelDerivativeOrder`
* 阶段 3：并行处理所有限价单 - 正在匹配的现货和衍生品限价单
  * 限价单在频繁批量拍卖模式下执行，以确保公平的匹配价格，详见下文。
  * 请注意，普通限价单可能会在 EndBlocker 中因随后传入的预言机更新而失效，仅减仓限价单可能会在 EndBlocker 中因随后传入的翻转持仓的订单而失效。
* 阶段 4：将限价单匹配执行 + 新限价单持久化到存储
  * 现货市场
    * 持久化现货匹配执行数据
    * 发出相关事件
      * `EventNewSpotOrders`
      * `EventBatchSpotExecution`
  * 衍生品市场
    * 持久化衍生品匹配执行数据
    * 发出相关事件
      * `EventNewDerivativeOrders`
      * `EventBatchDerivativeExecution`
      * `EventCancelDerivativeOrder`
* 阶段 5：持久化永续市场资金费率信息
* 阶段 6：持久化交易奖励总额和账户积分。
* 阶段 7：持久化新的费用折扣数据，即新的费用支付添加和新的账户层级。
* 阶段 8：处理现货市场参数更新（如果有）
* 阶段 9：处理衍生品市场参数更新（如果有）
* 阶段 10：发出存款和持仓更新事件

## 订单匹配：频繁批量拍卖（FBA）

FBA 的目标是防止任何[抢先交易](https://www.investopedia.com/terms/f/frontrunning.asp)。这是通过为给定区块中的所有匹配订单计算单一清算价格来实现的。

1. 市价单首先针对区块开始时的挂单订单簿成交。虽然挂单以其各自的订单价格成交，但市价单都以统一的清算价格成交，使用与限价单相同的机制。有关 FBA 方式的市价单匹配示例，请查看 API 文档[此处](https://api.biyachain.exchange/#examples-market-order-matching)。
2. 同样，限价单以统一的清算价格成交。新限价单与挂单订单簿合并，只要仍有负价差，订单就会匹配。清算价格是以下之一：

a. 最佳买入/卖出订单（如果最后一个匹配订单在该方向上跨越价差），\
b. 标记价格（对于衍生品市场，且标记价格在最后匹配订单之间）或\
c. 中间价格。

有关 FBA 方式的限价单匹配示例，请查看 API 文档[此处](https://api.biyachain.exchange/#examples-limit-order-matching)。

## 单笔交易计算

* 对于符合条件的市场，计算费用折扣：
  * 费用折扣作为退款应用，并记录费用支付贡献。
  * 中继者费用在扣除费用折扣后应用。
* 对于符合条件的市场，计算交易奖励积分贡献：
  * 获取做市商和吃单者的 FeePaidMultiplier。
  * 计算交易奖励积分贡献。
  * 交易奖励积分基于折扣后的交易费用。
* 计算费用退款（或收费）。订单在匹配后可能获得费用退款的几个原因：
  1. 这是一个未匹配或仅部分匹配的限价单，这意味着它将成为一个挂单限价单，并从吃单费用切换到做市商费用。退款为 `UnmatchedQuantity * (TakerFeeRate - MakerFeeRate)`。请注意，对于负做市商费用，我们改为退款 `UnmatchedQuantity * TakerFeeRate`。
  2. 应用费用折扣。我们退还原始支付的费用与折扣后支付的费用之间的差额。
  3. 订单以更好的价格匹配，导致不同的费用。
     * 对于买入订单，更好的价格意味着更低的价格，因此费用更低。我们退还费用价格差额。
     * 对于卖出订单，更好的价格意味着更高的价格，因此费用更高。我们收取费用价格差额。
  4. 您可以在[此处](https://github.com/biya-coin/biyachain-core/blob/80dbc4e9558847ff0354be5d19a4d8b0bba7da96/biyachain-chain/modules/exchange/keeper/derivative_orders_processor.go#L502)找到相应的代码和示例。请查看主分支以获取最新的链代码。
