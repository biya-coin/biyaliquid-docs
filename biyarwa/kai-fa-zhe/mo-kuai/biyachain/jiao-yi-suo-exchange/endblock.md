# EndBlock

交易所的 [EndBlocker](https://docs.cosmos.network/master/building-modules/beginblock-endblock.html) 在每个区块结束时运行，按照我们定义的顺序，在治理和质押模块之后，佩吉、拍卖和保险模块之前。特别需要注意的是，治理模块的 EndBlocker 必须在交易所模块的 EndBlocker 之前运行。

* **阶段 0**：确定当前区块中所有在支持费用折扣的市场中下单的账户的费用折扣。
* **阶段 1**：并行处理所有市场订单
  * 现货市场和衍生品市场订单
  * 市场订单将在区块开始时根据挂单簿执行
  * 请注意，市场订单可能会由于后续的预言机更新或限价单取消而在 EndBlocker 中失效。
* **阶段 2**：将市场订单执行结果持久化到存储
  * **现货市场**
    * 持久化现货市场订单执行数据
    * 发出相关事件
      * EventBatchSpotExecution
  * **衍生品市场**
    * 持久化衍生品市场订单执行数据
    * 发出相关事件
      * EventBatchDerivativeExecution
      * EventCancelDerivativeOrder
* **阶段 3**：并行处理所有限价单
  * 匹配的现货和衍生品限价单
  * 限价单将以频繁批量拍卖模式执行，以确保公平的匹配价格，详细信息请见下文。
  * 请注意，普通限价单可能会由于后续的预言机更新而在 EndBlocker 中失效，而减仓限价单可能会由于后续到来的订单翻转头寸而在 EndBlocker 中失效。
* **阶段 4**：将限价单匹配执行结果和新限价单持久化到存储
  * **现货市场**
    * 持久化现货市场匹配执行数据
    * 发出相关事件
      * EventNewSpotOrders
      * EventBatchSpotExecution
  * **衍生品市场**
    * 持久化衍生品市场匹配执行数据
    * 发出相关事件
      * EventNewDerivativeOrders
      * EventBatchDerivativeExecution
      * EventCancelDerivativeOrder
* **阶段 5**：持久化永续市场资金信息
* **阶段 6**：持久化交易奖励总额和账户积分
* **阶段 7**：持久化新的费用折扣数据
  * 即新的已支付费用和新的账户等级
* **阶段 8**：处理现货市场参数更新（如果有）
* **阶段 9**：处理衍生品市场参数更新（如果有）
* **阶段 10**：发出存款和头寸更新事件

## 订单匹配：频繁批量拍卖（FBA）

FBA（频繁批量拍卖）的目标是防止任何前置交易（[Front-Running](https://www.investopedia.com/terms/f/frontrunning.asp)）。这一目标通过在给定区块内计算一个单一的清算价格来实现，所有匹配的订单都会按照该价格进行清算。

* 市场订单首先根据区块开始时的挂单簿进行填充。当挂单按其各自的订单价格被执行时，市场订单将以统一的清算价格执行，采用与限价单相同的机制。举个例子，关于市场订单在 FBA 模式下的匹配，详情见 [API 文档](https://api.injective.exchange/#examples-market-order-matching)。
* 同样，限价单也会以统一的清算价格执行。新的限价单与挂单簿结合，并且只要存在负价差（spread），订单就会被匹配。
*   清算价格可以是以下几种：

    a. 如果最后一个匹配的订单跨越了价格差（spread）方向，则为最佳买/卖订单；b. 如果是衍生品市场，且标记价格位于最后一个匹配订单之间，则为标记价格；c. 如果没有以上条件，则为中间价格（mid price）。

关于限价单在 FBA 模式下的匹配示例，请查看 [API 文档](https://api.injective.exchange/#examples-limit-order-matching)。

## 单笔交易计算

* 对于符合条件的市场，计算手续费折扣：
  * 手续费折扣作为退款应用，并记录支付的手续费贡献。
  * 中继商费用在应用手续费折扣后计算。
* 对于符合条件的市场，计算交易奖励积分贡献：
  * 获取做市商和接单商的FeePaidMultiplier。
  * 计算交易奖励积分贡献。
  * 交易奖励积分基于折扣后的交易手续费。
* 计算手续费退款（或收费）。订单匹配后可能有几种原因导致手续费退款：
  1. 这是一个未匹配或部分匹配的限价单，这意味着它将变成一个休息限价单，并且从接单商费用转变为做市商费用。退款为`UnmatchedQuantity * (TakerFeeRate - MakerFeeRate)`。请注意，对于负的做市商手续费，我们退还`UnmatchedQuantity * TakerFeeRate`。
  2. 应用了手续费折扣。我们退还原始手续费与折扣后支付的手续费之间的差额。
  3. 订单以更好的价格匹配，从而导致不同的费用。
     1. 对于买单，更好的价格意味着更低的价格，因此手续费较低。我们退还手续费价格差额。
     2. 对于卖单，更好的价格意味着更高的价格，因此手续费较高。我们收取手续费价格差额。
  4. 您可以在[此处](https://github.com/InjectiveLabs/injective-core/blob/80dbc4e9558847ff0354be5d19a4d8b0bba7da96/injective-chain/modules/exchange/keeper/derivative_orders_processor.go#L502)找到相关代码示例。请查看主分支以获取最新的链上代码。
