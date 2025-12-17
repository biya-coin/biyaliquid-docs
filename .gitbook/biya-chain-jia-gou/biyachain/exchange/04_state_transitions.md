---
sidebar_position: 5
title: State Transitions
---

# 状态转换

本文档描述了与以下内容相关的状态转换操作：

- Deposit into exchange module account
- Withdraw from exchange module account
- Instant spot market launch
- Instant perpetual market launch
- Instant expiry futures market launch
- Spot limit order creation
- Batch creation of spot limit orders
- Spot market order creation
- Cancel spot order
- Batch cancellation of spot order
- Derivative limit order creation
- Batch derivative limit order creation
- Derivative market order creation
- Cancel derivative order
- Batch cancellation of derivative orders
- Transfer between subaccounts
- Transfer to external account
- Liquidating a position
- Increasing position margin
- Spot market param update proposal
- Exchange enable proposal
- Spot market launch proposal
- Perpetual market launch proposal
- Expiry futures market launch proposal
- Derivative market param update proposal
- Trading rewards launch proposal
- Trading rewards update proposal
- Begin-blocker
- End-blocker
- Fee discount schedule proposal
- Stake grant authorizations
- Stake grant activation

## 存入交易所模块账户

存款操作由 `MsgDeposit` 执行，该消息包含 `Sender`、`SubaccountId` 和 `Amount` 字段。

**注意：** `SubaccountId` 是可选的，如果未提供，则从 `Sender` 地址动态计算。

**步骤**

- 检查 `msg.Amount` 中指定的 denom 是否是银行供应中存在的有效 denom
- 从个人账户发送代币到 `exchange` 模块账户，如果失败，则回滚
- 从 `msg.SubaccountId` 获取 `subaccountID` 的哈希类型，如果是零子账户，则使用 `SdkAddressToSubaccountID` 从 `msg.Sender` 动态计算
- 将 `subaccountID` 的存款金额增加 `msg.Amount`
- 发出 `EventSubaccountDeposit` 事件，包含 `msg.Sender`、`subaccountID` 和 `msg.Amount`

## 从交易所模块账户提取

提取操作由 `MsgWithdraw` 执行，该消息包含 `Sender`、`SubaccountId` 和 `Amount` 字段。

**注意：** `msg.Sender` 对 `msg.SubaccountId` 的所有权在 `msg.ValidateBasic` 函数中进行验证。

**步骤**

- 从 `msg.SubaccountId` 获取 `subaccountID` 的哈希类型
- 检查 `msg.Amount` 中指定的 denom 是否是银行供应中存在的有效 denom
- 从 `subaccountID` 减少提取金额 `msg.Amount`，如果失败，则回滚
- 从 `exchange` 模块发送代币到 `msg.Sender`
- 发出 `EventSubaccountWithdraw` 事件，包含 `subaccountID`、`msg.Sender` 和 `msg.Amount`

## 即时现货市场启动

即时现货市场启动操作由 `MsgInstantSpotMarketLaunch` 执行，该消息包含 `Sender`、`Ticker`、`BaseDenom`、`QuoteDenom`、`MinPriceTickSize` 和 `MinQuantityTickSize` 字段。

**步骤**

- 从 `msg.BaseDenom` 和 `msg.QuoteDenom` 计算 `marketID`
- 检查是否存在相同市场启动提案（通过 `marketID`），如果已存在则回滚
- 使用 `msg.Ticker`、`msg.BaseDenom`、`msg.QuoteDenom`、`msg.MinPriceTickSize`、`msg.MinQuantityTickSize` 启动现货市场，如果失败则回滚
- 从 `msg.Sender` 发送即时上币费（params.SpotMarketInstantListingFee）到 `exchange` 模块账户
- 最后将即时上币费发送到社区支出池

## 即时永续市场启动

即时永续市场启动操作由 `MsgInstantPerpetualMarketLaunch` 执行，该消息包含 `Sender`、`Ticker`、`QuoteDenom`、`OracleBase`、`OracleQuote`、`OracleScaleFactor`、`OracleType`、`MakerFeeRate`、`TakerFeeRate`、`InitialMarginRatio`、`MaintenanceMarginRatio`、`MinPriceTickSize` 和 `MinQuantityTickSize` 字段。

**步骤**

- 从 `msg.Ticker`、`msg.QuoteDenom`、`msg.OracleBase`、`msg.OracleQuote` 和 `msg.OracleType` 计算 `marketID`
- 检查是否存在相同市场启动提案（通过 `marketID`），如果已存在则回滚
- 从 `msg.Sender` 发送即时上币费（params.DerivativeMarketInstantListingFee）到 `exchange` 模块账户
- 使用 `msg` 对象上的必需参数启动永续市场，如果失败则回滚
- 最后将即时上币费发送到社区支出池

## 即时到期期货市场启动

即时到期期货市场启动操作由 `MsgInstantExpiryFuturesMarketLaunch` 执行，该消息包含 `Sender`、`Ticker`、`QuoteDenom`、`OracleBase`、`OracleQuote`、`OracleScaleFactor`、`OracleType`、`Expiry`、`MakerFeeRate`、`TakerFeeRate`、`InitialMarginRatio`、`MaintenanceMarginRatio`、`MinPriceTickSize` 和 `MinQuantityTickSize` 字段。

**步骤**

- 从 `msg.Ticker`、`msg.QuoteDenom`、`msg.OracleBase`、`msg.OracleQuote`、`msg.OracleType` 和 `msg.Expiry` 计算 `marketID`
- 检查是否存在相同市场启动提案（通过 `marketID`），如果已存在则回滚
- 从 `msg.Sender` 发送即时上币费（params.DerivativeMarketInstantListingFee）到 `exchange` 模块账户
- 使用 `msg` 对象上的必需参数启动到期期货市场，如果失败则回滚
- 触发 `EventExpiryFuturesMarketUpdate` 事件，包含市场信息
- 最后将即时上币费发送到社区支出池

## 现货限价单创建

现货限价单创建由 `MsgCreateSpotLimitOrder` 执行，该消息包含 `Sender` 和 `Order`。

**步骤**

- 检查现货交易所是否已启用以在现货市场上下单，如果未启用则回滚
- 检查订单的价格和数量最小变动单位是否符合市场的最小数量和价格最小变动单位
- 增加子账户的 `TradeNonce`
- 如果现货市场 ID 未引用活跃的现货市场，则拒绝
- 使用 `TradeNonce` 计算唯一订单哈希
- 如果子账户的可用存款不足以支付交易所需的资金，则拒绝
- 减少可用余额，减少金额为订单所需的资金金额
- 将订单存储在临时限价单存储和临时市场指示器存储中

**注意：** 临时存储中的订单在 endblocker 中执行，如果没有执行，则放入长期存储中。

## 批量创建现货限价单

批量创建现货限价单由 `MsgBatchCreateSpotLimitOrders` 执行，该消息包含 `Sender` 和 `Orders`。

**步骤**

- 遍历 `msg.Orders` 并按照 `MsgCreateSpotLimitOrder` 的方式创建现货限价单

## 现货市价单创建

现货市价单创建由 `MsgCreateSpotMarketOrder` 执行，该消息包含 `Sender` 和 `Order`。

**步骤**

- 检查现货交易所是否已启用以在现货市场上下单，如果未启用则回滚
- 检查订单的价格和数量最小变动单位是否符合市场的最小数量和价格最小变动单位
- 增加子账户的 `TradeNonce`
- 如果现货市场 ID 未引用活跃的现货市场，则拒绝
- 使用 `TradeNonce` 计算唯一订单哈希
- 检查可用余额以为市价单提供资金
- 计算市价单的最差可接受价格
- 减少存款的 AvailableBalance，减少金额为持有的余额
- 将订单存储在临时现货市价单存储和临时市场指示器存储中

## 取消现货订单

现货订单取消由 `MsgCancelSpotOrder` 执行，该消息包含 `Sender`、`MarketId`、`SubaccountId` 和 `OrderHash`。

**步骤**

- 检查现货交易所是否已启用以执行该操作，如果未启用则回滚
- 如果现货市场 ID 未引用活跃、暂停或已销毁的现货市场，则拒绝
- 通过 `marketID`、`subaccountID` 和 `orderHash` 检查现货限价单是否存在
- 将保证金持有量加回到可用余额
- 增加可用余额的保证金持有量
- 从 ordersStore 和 ordersIndexStore 删除订单状态
- 发出 `EventCancelSpotOrder` 事件，包含 marketID 和订单信息

## 批量取消现货订单

批量取消现货订单由 `MsgBatchCancelSpotOrders` 执行，该消息包含 `Sender` 和 `Data`。

**步骤**

- 遍历 `msg.Data` 并按照 `MsgCancelSpotOrder` 的方式取消现货订单

## 衍生品限价单创建

衍生品限价单创建由 `MsgCreateDerivativeLimitOrder` 执行，该消息包含 `Sender` 和 `Order`。

**步骤**

- 检查衍生品交易所是否已启用以在衍生品市场上下单，如果未启用则回滚
- 如果 `subaccountID` 已在市场上放置了市价单，则拒绝（**注意：** 市价单和限价单不能同时存在吗？）
- 通过 `marketID` 获取衍生品市场和标记价格
- 获取指定 `marketID` 和 `subaccountID` 的订单簿元数据（`SubaccountOrderbookMetadata`）
- 确保限价单有效：
  - 市场配置（市场 ID 和最小变动单位）
  - 子账户交易随机数
  - 子账户最大订单数量
  - 如果是仅减仓订单：
    - 存在具有有效数量和相反方向的持仓
    - 如果订单会导致其他仅减仓订单变为过时，则拒绝
  - 如果是限价单：
    - 子账户存款足以持有保证金
    - 如果订单与现有持仓方向相反，并导致其他仅减仓订单变为过时，则取消过时的仅减仓订单
- 将订单存储在临时限价单存储和临时市场指示器存储中
- 更新子账户的订单簿元数据

## 批量创建衍生品限价单

批量创建衍生品限价单由 `MsgBatchCreateDerivativeLimitOrders` 执行，该消息包含 `Sender` 和 `Orders`。

**步骤**

- 遍历 `msg.Orders` 并按照 `MsgCreateDerivativeLimitOrder` 的方式创建衍生品限价单

## 衍生品市价单创建

衍生品市价单创建由 `MsgCreateDerivativeMarketOrder` 执行，该消息包含 `Sender` 和 `Order`。

**步骤**

- 检查衍生品交易所是否已启用以在衍生品市场上下单，如果未启用则回滚
- 检查将要创建新订单的 `SubaccountID` 是否已有衍生品限价单或市价单，如果有则拒绝。**注意：** 永续市场不能同时下两个市价单或同时下限价单和市价单吗？
- 检查订单的价格和数量最小变动单位是否符合市场的最小数量和价格最小变动单位
- 增加子账户的 `TradeNonce`
- 如果衍生品市场 ID 未引用活跃的衍生品市场，则拒绝
- 使用 `TradeNonce` 计算唯一订单哈希
- 检查市价单的最差价格是否达到最佳对手挂单价格
- 检查订单/持仓保证金金额
- 1. 如果是仅减仓订单
- A. 检查市场上 `subaccountID` 的持仓是否不为 nil
- B. 检查订单是否可以平仓
- C. 如果 position.quantity - AggregateReduceOnlyQuantity - order.quantity < 0，则拒绝
- D. 对于卖出持仓，将 MarginHold 设置为零，表示不持有保证金
- 2. 如果不是仅减仓订单
- A. 检查可用余额以为市价单提供资金
- B. 如果子账户的可用存款不足以支付交易所需的资金，则拒绝
- C. 减少存款的 AvailableBalance，减少金额为持有的余额
- 对于相反方向的持仓，如果 AggregateVanillaQuantity > position.quantity - AggregateReduceOnlyQuantity - order.FillableQuantity，新的仅减仓订单可能会使某些现有的仅减仓订单失效或自身失效，并对此进行操作。
- 将订单存储在临时衍生品市价单存储和临时市场指示器存储中

## 取消衍生品订单

衍生品订单取消由 `MsgCancelDerivativeOrder` 执行，该消息包含 `Sender`、`MarketId`、`SubaccountId` 和 `OrderHash`。

**步骤**

- 检查衍生品交易所是否已启用以执行该操作，如果未启用则回滚
- 如果衍生品市场 ID 未引用活跃的衍生品市场，则拒绝
- 通过 `marketID`、`subaccountID` 和 `orderHash` 检查挂单衍生品限价单是否存在
- 将保证金持有量加回到可用余额
- 如果订单类型不应被取消，则跳过取消限价单
- 从 ordersStore、ordersIndexStore 和 subaccountOrderStore 删除订单状态
- 更新子账户的订单簿元数据
- 发出 `EventCancelDerivativeOrder` 事件，包含 marketID 和订单信息

## 批量取消衍生品订单

批量取消衍生品订单由 `MsgBatchCancelDerivativeOrders` 执行，该消息包含 `Sender` 和 `Data`。

**步骤**

- 遍历 `msg.Data` 并按照 `MsgCancelDerivativeOrder` 的方式取消衍生品订单

## 批量订单更新

批量更新订单由 `MsgBatchUpdateOrders` 执行，该消息包含 `Sender` 和 `Orders`。

**步骤**

- 取消指定子账户 ID 在 `SpotMarketIdsToCancelAll` 和 `DerivativeMarketIdsToCancelAll` 指定的所有市场 ID 中的所有订单
- 遍历 `msg.SpotOrdersToCancel` 并按照 `MsgCancelSpotOrder` 的方式取消现货限价单。如果取消失败，继续下一个订单。取消的成功情况在 `MsgBatchUpdateOrdersResponse` 中反映为 `SpotCancelSuccess`。
- 遍历 `msg.DerivativeOrdersToCancel` 并按照 `MsgCancelDerivativeOrder` 的方式取消衍生品限价单。如果取消失败，继续下一个订单。取消的成功情况在 `MsgBatchUpdateOrdersResponse` 中反映为 `DerivativeCancelSuccess`。
- 遍历 `msg.SpotOrdersToCreate` 并按照 `MsgCreateSpotOrder` 的方式创建现货限价单。如果创建失败，继续下一个订单。成功创建的情况在 `MsgBatchUpdateOrdersResponse` 中反映为 `SpotOrderHashes`。
- 遍历 `msg.DerivativeOrdersToCreate` 并按照 `MsgCreateDerivativeOrder` 的方式创建衍生品限价单。如果创建失败，继续下一个订单。成功创建的情况在 `MsgBatchUpdateOrdersResponse` 中反映为 `DerivativeOrderHashes`。

## 子账户间转账

子账户间转账由 `MsgSubaccountTransfer` 执行，该消息包含 `Sender`、`SourceSubaccountId`、`DestinationSubaccountId` 和 `Amount`。

**步骤**

- 从 `msg.SourceSubaccountId` 提取存款 `msg.Amount`，如果失败则回滚交易
- 将 `msg.DestinationSubaccountId` 的存款增加 `msg.Amount`
- 发出 `EventSubaccountBalanceTransfer` 事件，包含 `SrcSubaccountId`、`DstSubaccountId` 和 `msg.Amount`

**注意：** 对于子账户转账，不需要从银行模块转移实际代币，只需更改记录即可。

## 转账到外部账户

转账到外部账户由 `MsgExternalTransfer` 执行，该消息包含 `Sender`、`SourceSubaccountId`、`DestinationSubaccountId` 和 `Amount`。

**步骤**

- 从 `msg.SourceSubaccountId` 提取存款 `msg.Amount`，如果失败则回滚交易
- 将 `msg.DestinationSubaccountId` 的存款增加 `msg.Amount`
- 发出 `EventSubaccountBalanceTransfer` 事件，包含 `SrcSubaccountId`、`DstSubaccountId` 和 `msg.Amount`

**注意：** 对于子账户转账，不需要从银行模块转移实际代币，只需更改记录即可。

1. 子账户转账和外部转账的事件应该不同。
2. 子账户转账和外部转账没有区别，是否仍需要保留不同的消息？

## 清算持仓

清算持仓由 `MsgLiquidatePosition` 执行，该消息包含 `Sender`、`SubaccountId`、`MarketId` 和 `Order`。

**步骤**

- 检查衍生品交易所是否已启用以清算衍生品市场上的持仓，如果未启用则回滚
- 如果衍生品市场 ID 未引用活跃的衍生品市场，则拒绝
- 通过 `marketID` 获取衍生品市场和标记价格
- 获取 `marketID` 和 `subaccountID` 的持仓
- 从持仓信息计算 `liquidationPrice` 和 `bankruptcyPrice`
- 确定是蒸发还是清算，如果不是两者之一，则回滚
- 取消持仓持有者在给定市场中创建的所有仅减仓限价单
- 应用资金费率并更新持仓
- 取消持仓持有者在给定市场中创建的所有市价单
- 检查并增加子账户随机数，计算订单哈希
- 计算 `liquidationOrder` 哈希
- 将清算订单设置到存储中
- 通过匹配持仓和清算订单执行清算
- 根据支付是正数还是负数进行不同处理（保险基金参与计算）
  - 正支付：
    1. 将支付的一半发送给清算人（激励运行清算机器人）
    2. 将另一半发送给保险基金（激励参与保险基金）
  - 负支付 - 获取资金的四个升级级别：
    1. 从交易者的可用余额
    2. 通过取消交易者的普通限价单从交易者的锁定余额
    3. 从保险基金
    4. 资金不足。暂停市场并将市场添加到存储中，以便在下一个区块结算，参见 `BeginBlocker` 规范。
- 如果市场是永续市场，根据清算价格和数量升级 VWAP 数据
- 如果清算订单中有剩余，则通过取消订单返回剩余部分

## 增加持仓保证金

增加持仓保证金由 `MsgIncreasePositionMargin` 执行，该消息包含 `Sender`、`SourceSubaccountId`、`DestinationSubaccountId`、`MarketId` 和 `Amount`。

**步骤**

- 检查衍生品交易所是否已启用以增加衍生品市场上的持仓保证金，如果未启用则回滚
- 如果衍生品市场 ID 未引用活跃的衍生品市场，则拒绝
- 获取 `sourceSubaccountID` 的存款
- 如果 `deposit.AvailableBalance` 低于 `msg.Amount`，则回滚
- 通过 `marketID` 和 `destinationSubaccountID` 获取持仓，如果不存在则回滚
- 将 `sourceSubaccountID` 的存款金额减少 `msg.Amount`
- 将持仓保证金增加 `msg.Amount` 并更新存储中的持仓

## 交易所启用提案

市场类型的启用由 `ExchangeEnableProposal` 完成，该提案包含 `Title`、`Description` 和 `ExchangeType`。

**步骤**

- 对提案进行 `ValidateBasic`
- 如果 `p.ExchangeType` 是现货市场，则启用现货交易所
- 如果 `p.ExchangeType` 是衍生品市场，则启用衍生品市场

## 现货市场启动提案

现货市场启动由 `SpotMarketLaunchProposal` 处理，该提案包含 `Title`、`Description`、`Ticker`、`BaseDenom`、`QuoteDenom`、`MinPriceTickSize` 和 `MinQuantityTickSize` 字段。

**步骤**

- 对提案进行 `ValidateBasic`
- 验证 `BaseDenom` 和 `QuoteDenom` 是否有效
- 验证是否不存在相同市场（通过 `msg.BaseDenom` 和 `msg.QuoteDenom`）
- 根据交易所模块参数计算 RelayerFeeShareRate。**注意：** 对于 BIYA 货币，中继者分享率设置为 100%
- 保存现货市场，包含计算的 `ticker`、`baseDenom`、`quoteDenom`、`exchangeParams.DefaultSpotMakerFeeRate`、`exchangeParams.DefaultSpotTakerFeeRate`、`relayerFeeShareRate`、`minPriceTickSize`、`minQuantityTickSize`、`marketID` 和 `MarketStatus_Active`。

## 永续市场启动提案

永续市场启动由 `PerpetualMarketLaunchProposal` 处理，该提案包含 `Title`、`Description`、`Ticker`、`QuoteDenom`、`OracleBase`、`OracleQuote`、`OracleScaleFactor`、`OracleType`、`MakerFeeRate`、`TakerFeeRate`、`InitialMarginRatio`、`MaintenanceMarginRatio`、`MinPriceTickSize` 和 `MinQuantityTickSize` 字段。

**步骤**

- 对提案进行 `ValidateBasic`
- 验证 `quoteDenom`
- 从 `ticker`、`quoteDenom`、`oracleBase`、`oracleQuote`、`oracleType` 计算 `marketID`
- 验证 `marketID` 的活跃或非活跃永续市场不存在
- 尝试通过 `oracleBase`、`oracleQuote`、`oracleScaleFactor`、`oracleType` 获取衍生品市场价格以检查价格预言机
- 验证 `marketID` 的保险基金存在
- 从 `exchange` 模块参数计算 `defaultFundingInterval`、`nextFundingTimestamp`、`relayerFeeShareRate`
- 执行 `SetDerivativeMarketWithInfo` 将市场信息设置到存储中，包含 `market`、`marketInfo` 和 `funding` 对象

## 到期期货市场启动提案

到期期货市场启动由 `ExpiryFuturesMarketLaunchProposal` 处理，该提案包含 `Title`、`Description`、`Ticker`、`QuoteDenom`、`OracleBase`、`OracleQuote`、`OracleScaleFactor`、`OracleType`、`Expiry`、`MakerFeeRate`、`TakerFeeRate`、`InitialMarginRatio`、`MaintenanceMarginRatio`、`MinPriceTickSize` 和 `MinQuantityTickSize` 字段。

**步骤**

- 对提案进行 `ValidateBasic`
- 验证 `quoteDenom`
- 从 `p.Ticker`、`p.QuoteDenom`、`p.OracleBase`、`p.OracleQuote`、`p.OracleType` 和 `p.Expiry` 计算 `marketID`
- 验证 `marketID` 的活跃或非活跃到期期货市场不存在
- 如果到期时间已超过 `ctx.BlockTime()`，则回滚
- 尝试通过 `oracleBase`、`oracleQuote`、`oracleScaleFactor`、`oracleType` 获取衍生品市场价格以检查价格预言机
- 验证 `marketID` 的保险基金存在
- 根据交易所模块参数计算 RelayerFeeShareRate。**注意：** 对于 BIYA 货币，中继者分享率设置为 100%
- 执行 `SetDerivativeMarketWithInfo` 将市场信息设置到存储中，包含 `market`、`marketInfo` 对象 **注意：** TwapStartTimestamp 设置为 `expiry - thirtyMinutesInSeconds`。

## 现货市场参数更新提案

现货市场参数更新由 `SpotMarketParamUpdateProposal` 处理，该提案包含 `Title`、`Description`、`MarketId`、`MakerFeeRate`、`TakerFeeRate`、`RelayerFeeShareRate`、`MinPriceTickSize`、`MinQuantityTickSize` 和 `Status`。

**步骤**

- 对提案进行 `ValidateBasic`
- 通过 `p.MarketId` 获取现货市场，如果不存在则回滚
- 如果 `MakerFeeRate`、`TakerFeeRate`、`RelayerFeeShareRate`、`MinPriceTickSize`、`MinQuantityTickSize` 和 `Status` 不为空，则重置这些参数；如果为空，则保持原样。
- 验证 `MakerFeeRate` 大于 `TakerFeeRate`。

## 衍生品市场参数更新提案

衍生品市场参数更新由 `DerivativeMarketParamUpdateProposal` 处理，该提案包含 `Title`、`Description`、`MarketId`、`InitialMarginRatio`、`MaintenanceMarginRatio`、`MakerFeeRate`、`TakerFeeRate`、`RelayerFeeShareRate`、`MinPriceTickSize`、`MinQuantityTickSize` 和 `Status`。

**步骤**

- 对提案进行 `ValidateBasic`
- 验证衍生品市场是否存在（通过 `p.MarketId`），如果不存在则回滚
- 如果 `InitialMarginRatio`、`MaintenanceMarginRatio`、`MakerFeeRate`、`TakerFeeRate`、`RelayerFeeShareRate`、`MinPriceTickSize`、`MinQuantityTickSize` 和 `Status` 不为空，则重置这些参数；如果为空，则保持原样。
- 验证 `MakerFeeRate` 大于 `TakerFeeRate`。
- 验证 `InitialMarginRatio` 大于 `MaintenanceMarginRatio`。
- 安排衍生品市场参数更新并在 Endblocker 上完成更新 - **注意：** 这是由于衍生品市场参数更新的订单更新 - 应确保此处不会发生任何 panic。

## 交易奖励活动启动提案

**步骤**

- 对提案进行 `ValidateBasic`
- 不能存在现有活动。
- 活动开始时间戳必须在未来。
- 活动报价货币 denoms 必须存在。
- 所有开始时间戳必须匹配持续时间。
- 设置活动数据（奖励池、信息、市场资格和市场积分乘数）
- 发出 `EventTradingRewardCampaignUpdate`

## 交易奖励活动更新提案

**步骤**

- 对提案进行 `ValidateBasic`
- `CampaignRewardPoolsUpdates` 内的所有 `StartTimestamp` 必须等于现有活动。
- `CampaignDurationSeconds` 不能修改，但必须匹配当前活动。
- `CampaignRewardPoolsUpdates` 不能修改当前活动，可能包含 nil 值以删除奖励池。
- `CampaignRewardPoolsAdditions` 中的活动开始时间戳必须在未来。
- 任何活动报价货币 denoms 必须存在。
- 删除当前活动数据（信息、市场资格和市场积分乘数）
- 设置活动数据（信息、市场资格和市场积分乘数）
- 设置奖励池更新
- 设置奖励池添加
- 发出 `EventTradingRewardCampaignUpdate`

## 费用折扣计划提案

**步骤**

- 对提案进行 `ValidateBasic`
- 如果当前费用折扣计划存在，则删除它以及市场资格
- 定义的报价货币 denoms 必须存在。
- 如果需要重新启动费用周期（桶数量、桶持续时间或报价货币 denoms 更改），则删除所有账户费用桶并重新启动周期。
- 将第一个费用支付桶时间戳设置为当前区块时间
- 设置新的费用折扣计划，删除它以及市场资格
- 设置新的市场资格

## 质押授权授权

**步骤**

- 检查授权人是否已为被授权人存在现有授权
- 通过减去现有授权金额并添加新授权金额来计算授予被授权人的新质押总额（本质上是用新授权金额覆盖现有授权金额）
- 通过确保授权总额小于或等于授权人质押总额来确保授权有效
- 更新被授权人的授权金额
- 如果当前活动授权来自同一授权人或没有当前活动授权，则将授权设置为活动状态
- 发出 `EventGrantAuthorizations`，包含授权人和授权


## 质押授权激活

**步骤**

- 检查确保从授权人到被授权人的授权存在
- 检查确保授权人授权的金额不超过其质押总额
- 如果授权金额为 0，则删除授权，否则将新授权金额写入存储
- 发出 `EventGrantActivation`，包含被授权人、授权人和金额
