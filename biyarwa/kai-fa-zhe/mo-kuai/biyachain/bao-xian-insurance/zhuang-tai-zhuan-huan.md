# 状态转换

## 状态转换

本文件描述了与以下事项相关的状态转换操作：

* 创建保险基金
* 承保保险基金
* 向保险基金请求赎回
* 自动处理到期的赎回请求

### 创建保险基金

参数描述：`Sender` 字段描述了保险基金的创建者。`Ticker、QuoteDenom、OracleBase、OracleQuote、OracleType、Expiry` 字段描述了与保险基金相关的衍生品市场信息。`InitialDeposit` 字段描述了投入保险基金的初始存款金额。

步骤

1. 获取保险基金的 MarketId——注意，市场可能尚未在交易所上线，但这不是问题。
2. 确保与该 MarketId 关联的保险基金不存在。
3. 确保初始存款金额不为零。
4. 获取唯一的 shareDenom——当请求保险基金创建的 share denom 或当承保一个余额为零且总 share denom 供应量不为零的保险基金时，会递增 share denom。
5. 从创建者账户向保险基金模块账户发送币。
6. 使用 DefaultRedemptionNoticePeriodDuration 和提供的参数创建保险基金对象。
7. 将基金对象的余额设置为初始存款金额。
8. 向创建者账户铸造 InsuranceFundInitialSupply (10^18) 的 shareDenom 代币。
9. 将保险基金对象保存到存储中。
10. 在 BankKeeper 中注册新创建的保险基金 shareDenom 元数据。

### 承保保险基金

**参数描述**：`Sender` 字段描述了保险基金的承保人。`MarketId` 字段描述了与保险基金关联的衍生品市场 ID。`Deposit` 字段描述了要添加到保险基金的存款金额。

**步骤**

1. 确保与该 `MarketId` 关联的保险基金存在。
2. 从发送者账户向模块账户发送承保代币。
3.  根据与 `MarketId` 关联的保险基金的状态进行操作。\
    A. 当余额和 `ShareDenomSupply` 为零时

    * 向发送者铸造 `InsuranceFundInitialSupply (10^18)`。
    * 设置余额为存款金额。
    * 设置 `ShareDenomSupply` 为 `InsuranceFundInitialSupply`。

    B. 当余额为零且 `ShareDenomSupply` 不为零时

    * 更改保险基金的 ShareDenom，重新开始新的保险基金。
    * 在银行 Keeper 中注册新创建的 ShareDenom。
    * 向发送者铸造 `InsuranceFundInitialSupply (10^18)`。
    * 设置余额为存款金额。
    * 设置 `ShareDenomSupply` 为 `InsuranceFundInitialSupply`。

    C. 当余额不为零且 `ShareDenomSupply` 为零时

    * 向发送者铸造 `InsuranceFundInitialSupply (10^18)`。
    * 增加余额为存款金额。
    * 设置 `ShareDenomSupply` 为 `InsuranceFundInitialSupply`。

    D. 当余额和 `ShareDenomSupply` 都不为零时——正常情况

    * 增加余额为存款金额。
    * 向发送者铸造 `prev_ShareDenomSupply * deposit_amount / prev_Balance` 数量的 ShareDenom。
    * 增加 ShareDenomSupply 与铸造数量。
4. 将保险基金对象保存到存储中

### 向保险基金请求赎回

参数描述: `Sender` 字段描述了保险基金的赎回请求者。`MarketId` 字段描述了与保险基金关联的衍生品市场 ID。`Amount` 字段描述了要赎回的份额代币数量。

步骤

1. 确保与 MarketId 关联的保险基金存在。
2. 将 ShareDenom 发送至模块账户。
3. 获取新的赎回计划 ID。
4. 根据保险基金的赎回通知期持续时间和当前区块时间计算 ClaimTime。
5. 计算用于存储待处理赎回（赎回计划）的键。
6. 创建包含详细信息的赎回计划对象。

### 衍生品市场清算事件中的保险基金操作

步骤

1. 交易模块从保险 Keeper 中查找相关的保险基金。
2. 如果 missingFund 为正值，则通过 `WithdrawFromInsuranceFund` 从保险基金提取相应金额。
3. 如果 missingFund 为负值，则通过 `DepositIntoInsuranceFund` 向保险基金存入相应金额。

### 待处理赎回的自动处理

步骤

按 ClaimTime 排序遍历所有已到期的赎回请求，并执行以下操作：

1. 如果 ClaimTime 晚于当前区块时间，则提前中断处理。
2. 确保赎回计划对应的保险基金存在。
3. 根据份额数量计算赎回金额：`shareAmt * fund.Balance / fund.TotalShare`。
4. 从模块账户向赎回者账户发送计算出的赎回金额。
5. 燃烧在赎回计划创建时发送至模块账户的份额代币。
6. 删除赎回计划对象。
7. 将保险基金的余额减少赎回金额。
8. 将更新后的保险基金对象存储至存储中。

## 钩子（Hooks）

其他模块可以注册操作，以便在保险基金发生特定事件时执行。这些事件可以注册为在交易事件之前（Before）或之后（After）执行（依据钩子名称）。

可在交易模块中注册以下钩子：\
**注意**：钩子当前不可用，交易模块会直接调用保险 Keeper 的函数。

**衍生品市场清算事件的处理步骤**

1. 交易模块从保险 Keeper 中查找相关的保险基金。
2. 如果 missingFund 为正值，则通过 `WithdrawFromInsuranceFund` 从保险基金提取相应金额。
3. 如果 missingFund 为负值，则通过 `DepositIntoInsuranceFund` 向保险基金存入相应金额。
