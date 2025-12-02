# 状态转换

本文档描述了以下状态转换操作：

* 向交易模块账户存款
* 从交易模块账户取款
* 即时现货市场创建
* 即时永续合约市场创建
* 即时交割合约市场创建
* 现货限价订单创建
* 批量创建现货限价订单
* 现货市价订单创建
* 取消现货订单
* 批量取消现货订单
* 衍生品限价订单创建
* 批量创建衍生品限价订单
* 衍生品市价订单创建
* 取消衍生品订单
* 批量取消衍生品订单
* 子账户之间转账
* 向外部账户转账
* 清算持仓
* 增加持仓保证金
* 现货市场参数更新提案
* 交易模块启用提案
* 现货市场创建提案
* 永续合约市场创建提案
* 交割合约市场创建提案
* 衍生品市场参数更新提案
* 交易奖励启动提案
* 交易奖励更新提案
* Begin-blocker 处理
* End-blocker 处理

## 存入 Exchange 模块账户

存款操作由 `MsgDeposit` 执行，该消息包含 `Sender`、`SubaccountId` 和 `Amount` 字段。

**注意**：`SubaccountId` 为可选字段，如果未提供，则会根据 `Sender` 地址动态计算。

**步骤**

1. 检查 `msg.Amount` 中指定的 `denom` 是否为银行供应中存在的有效 `denom`。
2. 将代币从个人账户转入 Exchange 模块账户，若失败则回滚操作。
3. 从 `msg.SubaccountId` 获取 `subaccountID` 的哈希类型，如果为零子账户，则使用 `SdkAddressToSubaccountID` 根据 `msg.Sender` 动态计算。
4. 将 `msg.Amount` 递增至 `subaccountID` 的存款余额。
5. 触发 `EventSubaccountDeposit` 事件，包含 `msg.Sender`、`subaccountID` 和 `msg.Amount`。

## 从 Exchange 模块账户提现

提现操作由 `MsgWithdraw` 执行，该消息包含 `Sender`、`SubaccountId` 和 `Amount` 字段。

**注意**：`msg.ValidateBasic` 函数会验证 `msg.Sender` 对 `msg.SubaccountId` 的所有权。

**步骤**

1. 从 `msg.SubaccountId` 获取 `subaccountID` 的哈希类型。
2. 检查 `msg.Amount` 中指定的 `denom` 是否为银行供应中存在的有效 `denom`。
3. 从 `subaccountID` 中减少 `msg.Amount`，若失败则回滚操作。
4. 将代币从 Exchange 模块账户发送至 `msg.Sender`。
5. 触发 `EventSubaccountWithdraw` 事件，包含 `subaccountID`、`msg.Sender` 和 `msg.Amount`。

## 即时现货市场启动

即时现货市场启动操作由 `MsgInstantSpotMarketLaunch` 执行，该消息包含 `Sender`、`Ticker`、`BaseDenom`、`QuoteDenom`、`MinPriceTickSize` 和 `MinQuantityTickSize` 字段。

**步骤**

1. 根据 `msg.BaseDenom` 和 `msg.QuoteDenom` 计算 `marketID`。
2. 检查是否已存在相同的市场启动提案，如果已存在，则回滚操作。
3. 使用 `msg.Ticker`、`msg.BaseDenom`、`msg.QuoteDenom`、`msg.MinPriceTickSize`、`msg.MinQuantityTickSize` 启动现货市场，若失败则回滚操作。
4. 从 `msg.Sender` 向 Exchange 模块账户发送即时上市费用 (`params.SpotMarketInstantListingFee`)。
5. 最后将即时上市费用发送至社区支出池。

## 即时永续市场启动

即时永续市场启动操作由 `MsgInstantPerpetualMarketLaunch` 执行，该消息包含 `Sender`、`Ticker`、`QuoteDenom`、`OracleBase`、`OracleQuote`、`OracleScaleFactor`、`OracleType`、`MakerFeeRate`、`TakerFeeRate`、`InitialMarginRatio`、`MaintenanceMarginRatio`、`MinPriceTickSize` 和 `MinQuantityTickSize` 字段。

**步骤**

1. 根据 `msg.Ticker`、`msg.QuoteDenom`、`msg.OracleBase`、`msg.OracleQuote` 和 `msg.OracleType` 计算 `marketID`。
2. 检查是否已存在相同的市场启动提案，如果已存在，则回滚操作。
3. 从 `msg.Sender` 向 Exchange 模块账户发送即时上市费用 (`params.DerivativeMarketInstantListingFee`)。
4. 使用 `msg` 对象中的必需参数启动永续市场，若失败则回滚操作。
5. 最后将即时上市费用发送至社区支出池。

## 即时到期期货市场启动

即时到期期货市场启动操作由 `MsgInstantExpiryFuturesMarketLaunch` 执行，该消息包含 `Sender`、`Ticker`、`QuoteDenom`、`OracleBase`、`OracleQuote`、`OracleScaleFactor`、`OracleType`、`Expiry`、`MakerFeeRate`、`TakerFeeRate`、`InitialMarginRatio`、`MaintenanceMarginRatio`、`MinPriceTickSize` 和 `MinQuantityTickSize` 字段。

**步骤**

1. 根据 `msg.Ticker`、`msg.QuoteDenom`、`msg.OracleBase`、`msg.OracleQuote`、`msg.OracleType` 和 `msg.Expiry` 计算 `marketID`。
2. 检查是否已存在相同的市场启动提案，如果已存在，则回滚操作。
3. 从 `msg.Sender` 向 Exchange 模块账户发送即时上市费用 (`params.DerivativeMarketInstantListingFee`)。
4. 使用 `msg` 对象中的必需参数启动到期期货市场，若失败则回滚操作。
5. 触发 `EventExpiryFuturesMarketUpdate` 事件，包含市场信息。
6. 最后将即时上市费用发送至社区支出池。

## 现货限价订单创建

现货限价订单创建操作由 `MsgCreateSpotLimitOrder` 执行，该消息包含 `Sender` 和 `Order` 字段。

**步骤**

1. 检查现货交易是否已启用，若未启用则回滚操作。
2. 检查订单的价格和数量是否符合市场的最小数量和价格刻度要求。
3. 递增子账户的 `TradeNonce`。
4. 如果现货市场 ID 没有引用有效的现货市场，则拒绝该订单。
5. 使用 `TradeNonce` 计算唯一的订单哈希。
6. 如果子账户的可用存款不足以支付该订单所需的资金，则拒绝订单。
7. 从可用余额中扣除订单所需的资金。
8. 将订单存储在临时限价订单存储和临时市场指示器存储中。

**注意**：临时存储中的订单会在结束区块处理时执行，若未执行则存入长期存储。

## 批量创建现货限价订单

批量创建现货限价订单操作由 `MsgBatchCreateSpotLimitOrders` 执行，该消息包含 `Sender` 和 `Orders` 字段。

**步骤**

1. 遍历 `msg.Orders`，并按照 `MsgCreateSpotLimitOrder` 中的步骤创建每个现货限价订单。

## 现货市场订单创建

现货市场订单创建操作由 `MsgCreateSpotMarketOrder` 执行，该消息包含 `Sender` 和 `Order` 字段。

**步骤**

1. 检查现货交易是否已启用，若未启用则回滚操作。
2. 检查订单的价格和数量是否符合市场的最小数量和价格刻度要求。
3. 递增子账户的 `TradeNonce`。
4. 如果现货市场 ID 没有引用有效的现货市场，则拒绝该订单。
5. 使用 `TradeNonce` 计算唯一的订单哈希。
6. 检查可用余额是否足以支持市场订单。
7. 计算市场订单的最差可接受价格。
8. 从存款的可用余额中扣除冻结的资金。
9. 将订单存储在临时现货市场订单存储和临时市场指示器存储中。

## 取消现货订单

现货订单取消操作由 `MsgCancelSpotOrder` 执行，该消息包含 `Sender`、`MarketId`、`SubaccountId` 和 `OrderHash` 字段。

**步骤**

1. 检查现货交易是否已启用，若未启用则回滚操作。
2. 如果现货市场 ID 没有引用有效、挂起或已拆除的现货市场，则拒绝该操作。
3. 检查通过 `marketID`、`subaccountID` 和 `orderHash` 是否存在现货限价订单。
4. 将保证金冻结金额返还至可用余额。
5. 递增可用余额的保证金冻结金额。
6. 从 `ordersStore` 和 `ordersIndexStore` 中删除订单状态。
7. 触发 `EventCancelSpotOrder` 事件，包含 `marketID` 和订单信息。

## 批量取消现货订单

批量取消现货订单操作由 `MsgBatchCancelSpotOrders` 执行，该消息包含 `Sender` 和 `Data` 字段。

**步骤**

1. 遍历 `msg.Data`，并按照 `MsgCancelSpotOrder` 中的步骤取消每个现货订单。

## 衍生品限价订单创建

衍生品限价订单创建操作由 `MsgCreateDerivativeLimitOrder` 执行，该消息包含 `Sender` 和 `Order` 字段。

**步骤**

1. 检查衍生品交易是否已启用，若未启用则回滚操作。
2. 如果子账户已在该市场下已下单（注意：限价订单和市场订单不能同时存在），则拒绝该订单。
3. 获取衍生品市场和通过 `marketID` 获取标记价格。
4. 获取指定 `marketID` 和 `subaccountID` 的订单簿元数据（`SubaccountOrderbookMetadata`）。
5. 确保限价订单有效：
   * 市场配置（市场 ID 和刻度大小）。
   * 子账户交易 `nonce`。
   * 子账户最大订单数量。
6. 如果是减少仓位订单：
   * 确保存在有效的仓位，并且方向相反。
   * 如果订单会导致其他减少仓位订单失效，则拒绝该订单。
7. 如果是限价订单：
   * 确保子账户的存款足以支持保证金冻结。
   * 如果订单方向与现有仓位相反且会导致其他减少仓位订单失效，则取消失效的减少仓位订单。
8. 将订单存储在临时限价订单存储和临时市场指示器存储中。

## 批量创建衍生品限价订单

批量创建衍生品限价订单操作由 `MsgBatchCreateDerivativeLimitOrders` 执行，该消息包含 `Sender` 和 `Orders` 字段。

**步骤**

1. 遍历 `msg.Orders`，并按照 `MsgCreateDerivativeLimitOrder` 中的步骤创建每个衍生品限价订单。

## 衍生品市价订单创建

衍生品市场订单创建操作由 `MsgCreateDerivativeMarketOrder` 执行，该消息包含 `Sender` 和 `Order` 字段。

**步骤**

1. 检查衍生品交易是否已启用，若未启用则回滚操作。
2. 检查即将下单的 `SubaccountID` 是否已有限价衍生品订单或市场订单，若有则拒绝该订单。（注意：永续市场不能同时下两个市场订单或同时存在限价/市场订单）
3. 检查订单的价格和数量是否符合市场的最小数量和价格刻度要求。
4. 递增子账户的 `TradeNonce`。
5. 如果衍生品市场 ID 没有引用有效的衍生品市场，则拒绝该订单。
6. 使用 `TradeNonce` 计算唯一的订单哈希。
7. 检查市场订单的最差价格是否达到最优相反方向订单簿的价格。
8. 检查订单/仓位的保证金金额。

**如果是减少仓位订单**\
A. 检查该子账户在该市场的仓位是否为非空。\
B. 检查该订单是否能够平仓。\
C. 如果 `position.quantity - AggregateReduceOnlyQuantity - order.quantity < 0`，则拒绝该订单。\
D. 如果是卖出仓位，将保证金冻结金额设置为零。

**如果不是减少仓位订单**\
A. 检查可用余额是否足以支持市场订单。\
B. 如果子账户的可用存款不足以支付该订单所需的资金，则拒绝订单。\
C. 从存款的可用余额中扣除冻结的资金。\
对于相反方向的仓位，如果 `AggregateVanillaQuantity > position.quantity - AggregateReduceOnlyQuantity - order.FillableQuantity`，则可能会使某些现有的减少仓位订单失效，或使新订单本身无效，需要进行相应操作。

9. 将订单存储在临时衍生品市场订单存储和临时市场指示器存储中。

## 取消衍生品订单

衍生品订单取消操作由 `MsgCancelDerivativeOrder` 执行，该消息包含 `Sender`、`MarketId`、`SubaccountId` 和 `OrderHash` 字段。

**步骤**

1. 检查衍生品交易是否已启用，若未启用则回滚操作。
2. 如果衍生品市场 ID 没有引用有效的衍生品市场，则拒绝该操作。
3. 检查通过 `marketID`、`subaccountID` 和 `orderHash` 是否存在有效的衍生品限价订单。
4. 将保证金冻结金额返还至可用余额。
5. 如果订单类型不允许取消，则跳过取消该限价订单。
6. 从 `ordersStore`、`ordersIndexStore` 和 `subaccountOrderStore` 中删除订单状态。
7. 更新子账户的订单簿元数据。
8. 触发 `EventCancelDerivativeOrder` 事件，包含 `marketID` 和订单信息。

## 批量取消衍生品订单

批量取消衍生品订单操作由 `MsgBatchCancelDerivativeOrders` 执行，该消息包含 `Sender` 和 `Data` 字段。

**步骤**

1. 遍历 `msg.Data`，并按照 `MsgCancelDerivativeOrder` 中的步骤取消每个衍生品订单。

## 批量订单更新

批量更新订单操作由 `MsgBatchUpdateOrders` 执行，该消息包含 `Sender` 和 `Orders` 字段。

**步骤**

1. 根据指定的 `subaccountID`，取消所有在 `SpotMarketIdsToCancelAll` 和 `DerivativeMarketIdsToCancelAll` 中列出的市场 ID 中的订单。
2. 遍历 `msg.SpotOrdersToCancel`，并按照 `MsgCancelSpotOrder` 中的步骤取消现货限价订单。如果取消失败，继续下一个订单。取消成功的结果在 `MsgBatchUpdateOrdersResponse` 中反映为 `SpotCancelSuccess`。
3. 遍历 `msg.DerivativeOrdersToCancel`，并按照 `MsgCancelDerivativeOrder` 中的步骤取消衍生品限价订单。如果取消失败，继续下一个订单。取消成功的结果在 `MsgBatchUpdateOrdersResponse` 中反映为 `DerivativeCancelSuccess`。
4. 遍历 `msg.SpotOrdersToCreate`，并按照 `MsgCreateSpotOrder` 中的步骤创建现货限价订单。如果创建失败，继续下一个订单。创建成功的结果在 `MsgBatchUpdateOrdersResponse` 中反映为 `SpotOrderHashes`。
5. 遍历 `msg.DerivativeOrdersToCreate`，并按照 `MsgCreateDerivativeOrder` 中的步骤创建衍生品限价订单。如果创建失败，继续下一个订单。创建成功的结果在 `MsgBatchUpdateOrdersResponse` 中反映为 `DerivativeOrderHashes`。

## 子账户间转账

从子账户之间的转账操作由 `MsgSubaccountTransfer` 执行，该消息包含 `Sender`、`SourceSubaccountId`、`DestinationSubaccountId` 和 `Amount` 字段。

**步骤**

1. 从 `msg.SourceSubaccountId` 提取 `msg.Amount`，如果失败则回滚交易。
2. 增加 `msg.DestinationSubaccountId` 的存款余额，增加的金额为 `msg.Amount`。
3. 触发 `EventSubaccountBalanceTransfer` 事件，包含 `SrcSubaccountId`、`DstSubaccountId` 和 `msg.Amount`。

**备注**：对于子账户之间的转账，不需要从银行模块实际转移代币，只需要更改相关记录即可。

## **转账到外部账户**

外部账户转账由 `MsgExternalTransfer` 执行，该消息包含 `Sender`、`SourceSubaccountId`、`DestinationSubaccountId` 和 `Amount` 字段。

**步骤**

1. 从 `msg.SourceSubaccountId` 提取 `msg.Amount`，如果失败则回滚交易。
2. 增加 `msg.DestinationSubaccountId` 的存款余额，增加的金额为 `msg.Amount`。
3. 触发 `EventSubaccountBalanceTransfer` 事件，包含 `SrcSubaccountId`、`DstSubaccountId` 和 `msg.Amount`。

**备注**：对于子账户转账，不需要从银行模块实际转移代币，只需要更改相关记录即可。

1. 事件应区分子账户转账和外部转账。
2. 子账户转账和外部转账没有区别，仍然需要保持不同的消息吗？

## 清算仓位

清算仓位由 `MsgLiquidatePosition` 执行，该消息包含 `Sender`、`SubaccountId`、`MarketId` 和 `Order` 字段。

**步骤**

1. 检查衍生品交易是否已启用以清算衍生品市场中的仓位，若未启用则回滚交易。
2. 如果衍生品市场 ID 没有引用有效的衍生品市场，则拒绝该操作。
3. 根据 `marketID` 获取衍生品市场和标记价格（markPrice）。
4. 获取指定 `marketID` 和 `subaccountID` 的仓位信息。
5. 根据仓位信息计算清算价格（liquidationPrice）和破产价格（bankruptcyPrice）。
6. 确定是进行清算还是销毁仓位，如果无法全部清算，则回滚。
7. 取消仓位持有者在给定市场中创建的所有减仓限价单。
8. 应用资金并更新仓位信息。
9. 取消仓位持有者在给定市场中创建的所有市场订单。
10. 检查并增加子账户的交易序列号（nonce），计算订单哈希。
11. 计算清算订单的哈希值。
12. 将清算订单存储到存储中。
13. 通过匹配仓位和清算订单执行清算。
14. 根据清算的支付结果处理：

* **正向支付**：
  * 将一半的支付金额发送给清算人（激励清算机器人）。
  * 将另一半的支付金额发送到保险基金（激励参与保险基金的用户）。
* **负向支付** - 四个级别的资金回收步骤：
  1. 从交易者的可用余额中回收。
  2. 通过取消交易者的限价单，从交易者的锁仓余额中回收。
  3. 从保险基金中回收。
  4. 如果资金不足，暂停市场并将市场添加到存储中，以便在下一个区块中结算，见 `BeginBlocker` 规范。

15. 如果市场是永续市场，则根据清算价格和数量更新 VWAP 数据。
16. 如果清算订单中仍有剩余，取消订单并返回剩余部分。

## 增加仓位保证金

增加仓位保证金由 `MsgIncreasePositionMargin` 执行，该消息包含 `Sender`、`SourceSubaccountId`、`DestinationSubaccountId`、`MarketId` 和 `Amount` 字段。

**步骤**

1. 检查衍生品交易是否已启用以增加衍生品市场的仓位保证金，若未启用则回滚交易。
2. 如果衍生品市场 ID 没有引用有效的衍生品市场，则拒绝该操作。
3. 获取 `sourceSubaccountID` 的存款信息。
4. 如果 `deposit.AvailableBalance` 小于 `msg.Amount`，则回滚交易。
5. 根据 `marketID` 和 `destinationSubaccountID` 获取仓位信息，如果仓位不存在，则回滚交易。
6. 从 `sourceSubaccountID` 减少 `msg.Amount` 的存款金额。
7. 增加仓位保证金 `msg.Amount` 并更新存储中的仓位信息。

## 交易所启用提案

市场类型的启用通过 `ExchangeEnableProposal` 执行，该提案包含 `Title`、`Description` 和 `ExchangeType` 字段。

**步骤**

1. 对提案进行 `ValidateBasic` 验证。
2. 如果 `p.ExchangeType` 是现货市场（spot market），则启用现货交易。
3. 如果 `p.ExchangeType` 是衍生品市场（derivative market），则启用衍生品交易。

## 现货市场启动提案

现货市场启动由 `SpotMarketLaunchProposal` 执行，该提案包含 `Title`、`Description`、`Ticker`、`BaseDenom`、`QuoteDenom`、`MinPriceTickSize` 和 `MinQuantityTickSize` 字段。

**步骤**

1. 对提案进行 `ValidateBasic` 验证。
2. 验证 `BaseDenom` 和 `QuoteDenom` 是否有效。
3. 验证基于 `msg.BaseDenom` 和 `msg.QuoteDenom` 是否已有相同市场存在。
4. 根据交易模块参数计算 `RelayerFeeShareRate`。注意：对于 BIYA 货币，清算者分成比例设置为 100%。
5. 保存现货市场，包含计算的 `ticker`、`baseDenom`、`quoteDenom`、`exchangeParams.DefaultSpotMakerFeeRate`、`exchangeParams.DefaultSpotTakerFeeRate`、`relayerFeeShareRate`、`minPriceTickSize`、`minQuantityTickSize`、`marketID` 和 `MarketStatus_Active`。

## 永续市场启动提案

永续市场启动由 `PerpetualMarketLaunchProposal` 执行，该提案包含 `Title`、`Description`、`Ticker`、`QuoteDenom`、`OracleBase`、`OracleQuote`、`OracleScaleFactor`、`OracleType`、`MakerFeeRate`、`TakerFeeRate`、`InitialMarginRatio`、`MaintenanceMarginRatio`、`MinPriceTickSize` 和 `MinQuantityTickSize` 字段。

**步骤**

1. 对提案进行 `ValidateBasic` 验证。
2. 验证 `quoteDenom` 是否有效。
3. 根据 `ticker`、`quoteDenom`、`oracleBase`、`oracleQuote` 和 `oracleType` 计算 `marketID`。
4. 验证指定的 `marketID` 是否已存在有效或无效的永续市场。
5. 尝试通过 `oracleBase`、`oracleQuote`、`oracleScaleFactor` 和 `oracleType` 获取衍生品市场价格，以检查价格预言机。
6. 验证 `marketID` 是否存在保险基金。
7. 根据交易模块参数计算 `defaultFundingInterval`、`nextFundingTimestamp` 和 `relayerFeeShareRate`。
8. 执行 `SetDerivativeMarketWithInfo` 将市场信息、市场信息和资金对象存储到存储中。

## 到期期货市场启动提案

到期期货市场启动由 `ExpiryFuturesMarketLaunchProposal` 执行，该提案包含 `Title`、`Description`、`Ticker`、`QuoteDenom`、`OracleBase`、`OracleQuote`、`OracleScaleFactor`、`OracleType`、`Expiry`、`MakerFeeRate`、`TakerFeeRate`、`InitialMarginRatio`、`MaintenanceMarginRatio`、`MinPriceTickSize` 和 `MinQuantityTickSize` 字段。

**步骤**

1. 对提案进行 `ValidateBasic` 验证。
2. 验证 `quoteDenom` 是否有效。
3. 根据 `p.Ticker`、`p.QuoteDenom`、`p.OracleBase`、`p.OracleQuote`、`p.OracleType` 和 `p.Expiry` 计算 `marketID`。
4. 验证指定的 `marketID` 是否已存在有效或无效的到期期货市场。
5. 如果到期时间已经过去（即 `ctx.BlockTime()` 已经超过），则回滚。
6. 尝试通过 `oracleBase`、`oracleQuote`、`oracleScaleFactor` 和 `oracleType` 获取衍生品市场价格，以检查价格预言机。
7. 验证 `marketID` 是否存在保险基金。
8. 根据交易模块参数计算 `RelayerFeeShareRate`。注意：对于 BIYA 货币，清算者分成比例设置为 100%。
9. 执行 `SetDerivativeMarketWithInfo` 将市场信息和市场信息对象存储到存储中。注意：`TwapStartTimestamp` 设置为到期时间减去 30 分钟的秒数。

## 现货市场参数更新提案

现货市场参数更新由 `SpotMarketParamUpdateProposal` 执行，该提案包含 `Title`、`Description`、`MarketId`、`MakerFeeRate`、`TakerFeeRate`、`RelayerFeeShareRate`、`MinPriceTickSize`、`MinQuantityTickSize` 和 `Status` 字段。

**步骤**

1. 对提案进行 `ValidateBasic` 验证。
2. 根据 `p.MarketId` 获取现货市场，如果不存在，则回滚。
3. 如果参数不为空，则重置 `MakerFeeRate`、`TakerFeeRate`、`RelayerFeeShareRate`、`MinPriceTickSize`、`MinQuantityTickSize` 和 `Status`，如果为空，则保持不变。
4. 验证 `MakerFeeRate` 是否大于 `TakerFeeRate`。

## 衍生品市场参数更新提案

衍生品市场参数更新由 `DerivativeMarketParamUpdateProposal` 处理，包含标题、描述、市场ID、初始保证金比例、维持保证金比例、做市商费用率、交易者费用率、分销商费用分成比例、最小价格刻度、最小数量刻度和状态。

步骤：

1. 对提案进行基本验证。
2. 通过 `p.MarketId` 验证衍生品市场是否存在，如果不存在，回滚交易。
3. 如果不为空，则重置初始保证金比例、维持保证金比例、做市商费用率、交易者费用率、分销商费用分成比例、最小价格刻度、最小数量刻度和状态的参数；如果为空，保持原值。
4. 验证做市商费用率大于交易者费用率。
5. 验证初始保证金比例大于维持保证金比例。
6. 调度衍生品市场参数更新，并在 `Endblocker` 上进行最终更新 - 注意：这是由于衍生品市场参数更新的订单更新，需确保此过程中不会发生异常。

## 交易奖励活动启动提案

步骤

1. 对提案进行基本验证（ValidateBasic）。
2. 不允许存在已启动的活动。
3. 活动开始时间戳必须是未来时间。
4. 活动的报价币种必须存在。
5. 所有开始时间戳必须匹配持续时间。
6. 设置活动数据（奖励池、信息、市场资格和市场积分乘数）。
7. 触发 EventTradingRewardCampaignUpdate 事件。

## 交易奖励活动更新提案

步骤

1. 对提案进行基本验证（ValidateBasic）。
2. 所有在CampaignRewardPoolsUpdates中的StartTimestamp必须匹配现有活动。
3. CampaignDurationSeconds不能修改，但必须与当前活动匹配。
4. CampaignRewardPoolsUpdates不能修改当前活动，可以包含nil值来删除奖励池。
5. 来自CampaignRewardPoolsAdditions的活动开始时间戳必须在未来。
6. 所有活动的quote denoms必须存在。
7. 删除当前活动的数据（信息、市场资格和市场点数乘数）。
8. 设置活动数据（信息、市场资格和市场点数乘数）。
9. 设置奖励池更新。
10. 设置奖励池添加。
11. 触发EventTradingRewardCampaignUpdate事件。

## 费率折扣计划提案

步骤

1. 验证提案的基本信息
2. 如果当前的费率折扣计划存在，则删除它以及市场资格
3. 定义的报价币种必须存在
4. 如果需要重启费率周期（例如桶数、桶持续时间或报价币种发生变化），则删除所有账户费率桶并重启周期
5. 将第一个已付费桶的时间戳设置为当前区块时间
6. 设置新的费率折扣计划，并删除它以及市场资格
7. 设置新的市场资格
